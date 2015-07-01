From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: bail on sock_wfree, sock_rfree when we
 have a TCP_TIMEWAIT sk
Date: Thu, 02 Jul 2015 01:53:54 +0200
Message-ID: <1435794834.11970.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1435781589-2210146-1-git-send-email-agartrell@fb.com>
	 <20150701.141402.587634025761326092.davem@davemloft.net>
	 <CANn89iK8SMLFNA6J0WB_qVTB+-C6qoX2o7-CxvwrLVua-cXzWg@mail.gmail.com>
	 <CALCkm3fUmO0pmQEgrwjoNy5PjFk+mzYbUd1wmBsV7hVSHBngPA@mail.gmail.com>
	 <CANn89iL4Pr1MQ_7uDcKEyT+D+193cQk9R304JsMAE0od4+ieEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"agartrell@fb.com" <agartrell@fb.com>,
	netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>
To: Eric Dumazet <edumazet@google.com>,
	Alex Gartrell <alexgartrell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:37328 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbbGAXyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 19:54:00 -0400
Received: by wicgi11 with SMTP id gi11so59057948wic.0
        for <netdev@vger.kernel.org>; Wed, 01 Jul 2015 16:53:58 -0700 (PDT)
In-Reply-To: <CANn89iL4Pr1MQ_7uDcKEyT+D+193cQk9R304JsMAE0od4+ieEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-07-02 at 01:26 +0200, Eric Dumazet wrote:
> On Thu, Jul 2, 2015 at 1:18 AM, Alex Gartrell <alexgartrell@gmail.com> wrote:
> > On Wednesday, July 1, 2015, Eric Dumazet <edumazet@google.com> wrote:
> >>
> >> On Wed, Jul 1, 2015 at 11:14 PM, David Miller <davem@davemloft.net> wrote:
> >> > From: Alex Gartrell <agartrell@fb.com>
> >> > Date: Wed, 1 Jul 2015 13:13:09 -0700
> >> >
> >> >> If we early-demux bind a TCP_TIMEWAIT socket to an skb and then orphan
> >> >> it
> >> >> (as we need to do in the ipvs forwarding case), sock_wfree and
> >> >> sock_rfree
> >> >> are going to reach into the inet_timewait_sock and mess with fields
> >> >> that
> >> >> don't exist.
> >> >>
> >> >> Signed-off-by: Alex Gartrell <agartrell@fb.com>
> >> >
> >> > If we're forwarding, we should not find a local socket, period.
> >>
> >> A socket cannot change state to TCP_TIMEWAIT.
> >>
> >> A new object is allocated and old one is removed from ehash, then
> >> freed (rcu rules being applied)
> >>
> >> Also sock_wfree() has nothing to do with early demux. It is for output
> >> path skbs only.
> >
> >
> > Alright I kind of cheated and didn't include full context here. The problem
> > is that within ipvs we are getting  packets that have been early demuxed and
> > associated with time wait sockets which we then wish to forward immediately
> > (ip_vs_xmit.c).  Under normal circumstances it would never be associated
> > with any sk at all, but it is because of early demux, so we want to drop the
> > relationship by calling skb_orphan.  This invokes the destructor which lands
> > us there.
> >
> > So that is how we reach this illegal "treating a twsk like an sk" state.
> >
> > If there is a better way to drop the association than skb_orphan I will use
> > it.
> 
> I think you are mistaken Alex.
> 
> socket early demux cannot possibly set skb->destructor to sock_rfree()
> 
> If skb->destructor is set by early demux, it correctly points to sock_edemux()
> 
> And this one correctly handles all socket variants.


If ipvs is the problem, could you try instead following patch ?

Shoot in the dark, as you do not give a lot of details :(

diff --git a/include/net/sock.h b/include/net/sock.h
index 05a8c1aea251..f77fe9acc7a4 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1932,6 +1932,14 @@ static inline void skb_set_hash_from_sk(struct sk_buff *skb, struct sock *sk)
 	}
 }
 
+/* This helper checks if a socket is a full socket,
+ * ie _not_ a timewait or request socket.
+ */
+static inline bool sk_fullsock(const struct sock *sk)
+{
+	return (1 << sk->sk_state) & ~(TCPF_TIME_WAIT | TCPF_NEW_SYN_RECV);
+}
+
 /*
  *	Queue a received datagram if it will fit. Stream and sequenced
  *	protocols can't normally use this as they need to fit buffers in
@@ -1944,6 +1952,9 @@ static inline void skb_set_hash_from_sk(struct sk_buff *skb, struct sock *sk)
 static inline void skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
 {
 	skb_orphan(skb);
+	if (unlikely(!sk_fullsock(sk))
+		return;
+
 	skb->sk = sk;
 	skb->destructor = sock_wfree;
 	skb_set_hash_from_sk(skb, sk);
@@ -2204,14 +2215,6 @@ static inline struct sock *skb_steal_sock(struct sk_buff *skb)
 	return NULL;
 }
 
-/* This helper checks if a socket is a full socket,
- * ie _not_ a timewait or request socket.
- */
-static inline bool sk_fullsock(const struct sock *sk)
-{
-	return (1 << sk->sk_state) & ~(TCPF_TIME_WAIT | TCPF_NEW_SYN_RECV);
-}
-
 void sock_enable_timestamp(struct sock *sk, int flag);
 int sock_get_timestamp(struct sock *, struct timeval __user *);
 int sock_get_timestampns(struct sock *, struct timespec __user *);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 5d2b806a862e..ff05ec5a9016 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1161,9 +1161,10 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (unlikely(skb->sk != NULL && hooknum == NF_INET_LOCAL_OUT &&
 		     af == AF_INET)) {
 		struct sock *sk = skb->sk;
-		struct inet_sock *inet = inet_sk(skb->sk);
 
-		if (inet && sk->sk_family == PF_INET && inet->nodefrag)
+		if (sk_fullsock(sk) &&
+		    sk->sk_family == PF_INET &&
+		    inet_sk(sk)->nodefrag)
 			return NF_ACCEPT;
 	}
 
@@ -1640,9 +1641,10 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (unlikely(skb->sk != NULL && hooknum == NF_INET_LOCAL_OUT &&
 		     af == AF_INET)) {
 		struct sock *sk = skb->sk;
-		struct inet_sock *inet = inet_sk(skb->sk);
 
-		if (inet && sk->sk_family == PF_INET && inet->nodefrag)
+		if (sk_fullsock(sk) &&
+		    sk->sk_family == PF_INET &&
+		    inet_sk(sk)->nodefrag)
 			return NF_ACCEPT;
 	}
 

 
