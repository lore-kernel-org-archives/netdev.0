From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] ipv4: Kill ip_rt_frag_needed().
Date: Mon, 11 Jun 2012 16:02:58 -0700 (PDT)
Message-ID: <20120611.160258.866525532025442350.davem@davemloft.net>
References: <20120611.042024.1022194952800114410.davem@davemloft.net>
	<20120611.042813.401909584318598192.davem@davemloft.net>
	<20120611114256.GL27795@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46775 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495Ab2FKXC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 19:02:59 -0400
In-Reply-To: <20120611114256.GL27795@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 11 Jun 2012 13:42:56 +0200

> On Mon, Jun 11, 2012 at 04:28:13AM -0700, David Miller wrote:
>> From: David Miller <davem@davemloft.net>
>> Date: Mon, 11 Jun 2012 04:20:24 -0700 (PDT)
>> 
>> > We need to find a way to implement this then, in such a way
>> > that we have the route context used to send the ping packet
>> > out.
>> 
>> The problem is RAW sockets right?  If so, then this is where the
>> fix belongs.
>> 
> 
> Hm, I've just tried with tracepath (udp) and I also don't see the
> pmtu informations cached.
> 
> I still had no time to look deeper into the new inetpeer code,
> I've just gave it a quick try. I'll try to find out what's going on.

Here below is the kind of patch I was suggesting we make.  I did a
simple test to make sure the update MTU code path is taken in
raw_err().

But I'm having second thoughts about whether any of this is a good
idea.

UDP works by notifying userspace of PMTU events.  And this is
mandatory, if we're setting DF we have to get the user to decrease the
size of it's datagram writes below the reported PMTU value.

As a consequence I believe RAW sockets should also work via
notifications.

And therefore it can be argued that in neither case should we update
the routing cache PMTU information.  This is in line with the fact
that TCP goes to great lengths to validate that the PMTU it's getting
is really legitimate and not forged, and UDP and RAW have no way of
making such strict checks.

And it also shows that those TCP strict checks were for nothing
beforehand.  That PMTU update guard done by TCP was (before my changes
this past weekend) pointless because we were doing the PMTU update
unconditionally earlier in the ICMP handling.

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 4032b81..3e2507b 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -242,6 +242,17 @@ static void raw_err(struct sock *sk, struct sk_buff *skb, u32 info)
 		err = icmp_err_convert[code].errno;
 		harderr = icmp_err_convert[code].fatal;
 		if (code == ICMP_FRAG_NEEDED) {
+			struct flowi4 *fl4 = &inet->cork.fl.u.ip4;
+			struct rtable *rt;
+
+			bh_lock_sock(sk);
+			rt = ip_route_output_flow(sock_net(sk), fl4, sk);
+			if (!IS_ERR(rt)) {
+				rt->dst.ops->update_pmtu(&rt->dst, info);
+				ip_rt_put(rt);
+			}
+			bh_unlock_sock(sk);
+
 			harderr = inet->pmtudisc != IP_PMTUDISC_DONT;
 			err = EMSGSIZE;
 		}
@@ -316,9 +327,8 @@ int raw_rcv(struct sock *sk, struct sk_buff *skb)
 	return 0;
 }
 
-static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
-			   void *from, size_t length,
-			   struct rtable **rtp,
+static int raw_send_hdrinc(struct sock *sk, __be32 saddr, __be32 daddr,
+			   void *from, size_t length, struct rtable **rtp,
 			   unsigned int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -331,7 +341,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 	int hlen, tlen;
 
 	if (length > rt->dst.dev->mtu) {
-		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport,
+		ip_local_error(sk, EMSGSIZE, daddr, inet->inet_dport,
 			       rt->dst.dev->mtu);
 		return -EMSGSIZE;
 	}
@@ -378,7 +388,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 
 	if (iphlen >= sizeof(*iph)) {
 		if (!iph->saddr)
-			iph->saddr = fl4->saddr;
+			iph->saddr = saddr;
 		iph->check   = 0;
 		iph->tot_len = htons(length);
 		if (!iph->id)
@@ -461,7 +471,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipcm_cookie ipc;
 	struct rtable *rt = NULL;
-	struct flowi4 fl4;
+	struct flowi4 *fl4;
 	int free = 0;
 	__be32 daddr;
 	__be32 saddr;
@@ -563,54 +573,66 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	} else if (!ipc.oif)
 		ipc.oif = inet->uc_index;
 
-	flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
+	lock_sock(sk);
+	fl4 = &inet->cork.fl.u.ip4;
+	flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
 			   RT_SCOPE_UNIVERSE,
 			   inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
 			   inet_sk_flowi_flags(sk) | FLOWI_FLAG_CAN_SLEEP,
 			   daddr, saddr, 0, 0);
 
 	if (!inet->hdrincl) {
-		err = raw_probe_proto_opt(&fl4, msg);
+		err = raw_probe_proto_opt(fl4, msg);
 		if (err)
-			goto done;
+			goto done_unlock;
 	}
 
-	security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
-	rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
+	security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
+	rt = ip_route_output_flow(sock_net(sk), fl4, sk);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		rt = NULL;
-		goto done;
+		goto done_unlock;
 	}
 
 	err = -EACCES;
 	if (rt->rt_flags & RTCF_BROADCAST && !sock_flag(sk, SOCK_BROADCAST))
-		goto done;
+		goto done_unlock;
+
+	if (msg->msg_flags & MSG_CONFIRM) {
+		dst_confirm(&rt->dst);
+		if ((msg->msg_flags & MSG_PROBE) && !len) {
+			err = 0;
+			goto done_unlock;
+		}
+	}
 
-	if (msg->msg_flags & MSG_CONFIRM)
-		goto do_confirm;
-back_from_confirm:
+	if (inet->hdrincl) {
+		__be32 saddr = fl4->saddr;
+		__be32 daddr = fl4->daddr;
 
-	if (inet->hdrincl)
-		err = raw_send_hdrinc(sk, &fl4, msg->msg_iov, len,
+		release_sock(sk);
+		err = raw_send_hdrinc(sk, saddr, daddr,
+				      msg->msg_iov, len,
 				      &rt, msg->msg_flags);
 
-	 else {
+		goto done;
+	}  else {
 		if (!ipc.addr)
-			ipc.addr = fl4.daddr;
-		lock_sock(sk);
-		err = ip_append_data(sk, &fl4, ip_generic_getfrag,
+			ipc.addr = fl4->daddr;
+		err = ip_append_data(sk, fl4, ip_generic_getfrag,
 				     msg->msg_iov, len, 0,
 				     &ipc, &rt, msg->msg_flags);
 		if (err)
 			ip_flush_pending_frames(sk);
 		else if (!(msg->msg_flags & MSG_MORE)) {
-			err = ip_push_pending_frames(sk, &fl4);
+			err = ip_push_pending_frames(sk, fl4);
 			if (err == -ENOBUFS && !inet->recverr)
 				err = 0;
 		}
-		release_sock(sk);
 	}
+done_unlock:
+	release_sock(sk);
 done:
 	if (free)
 		kfree(ipc.opt);
@@ -620,13 +642,6 @@ out:
 	if (err < 0)
 		return err;
 	return len;
-
-do_confirm:
-	dst_confirm(&rt->dst);
-	if (!(msg->msg_flags & MSG_PROBE) || len)
-		goto back_from_confirm;
-	err = 0;
-	goto done;
 }
 
 static void raw_close(struct sock *sk, long timeout)
