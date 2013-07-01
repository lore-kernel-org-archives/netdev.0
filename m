From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: skbuff: skb_under_panic warning in 3.10rc7+
Date: Mon, 1 Jul 2013 18:08:44 +0200
Message-ID: <20130701160844.GA8937@order.stressinduktion.org>
References: <20130630160246.GA24539@redhat.com> <20130630221322.GA27948@order.stressinduktion.org> <20130630232308.GC24483@order.stressinduktion.org> <20130701082440.GA3351@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:48069 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002Ab3GAQIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 12:08:46 -0400
Content-Disposition: inline
In-Reply-To: <20130701082440.GA3351@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 01, 2013 at 10:24:40AM +0200, Hannes Frederic Sowa wrote:
> On Mon, Jul 01, 2013 at 01:23:08AM +0200, Hannes Frederic Sowa wrote:
> > I'll look at it again tomorrow.
> 
> [Cc Gao feng because of commit 0c1833797a5a6ec23ea9261d979aa18078720b74
> ("ipv6: fix incorrect ipsec fragment")]
> 
> Just a small update:

I could reproduce Dave's exact bug and this fixes it for me:

--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -182,6 +182,7 @@ extern void udp_err(struct sk_buff *, u32);
 extern int udp_sendmsg(struct kiocb *iocb, struct sock *sk,
                            struct msghdr *msg, size_t len);
 extern void udp_flush_pending_frames(struct sock *sk);
+extern int udp_push_pending_frames(struct sock *sk);
 extern int udp_rcv(struct sk_buff *skb);
 extern int udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 extern int udp_disconnect(struct sock *sk, int flags);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 959502a..6b270e5 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -800,7 +800,7 @@ send:
 /*
  * Push out all pending data as one UDP datagram. Socket is locked.
  */
-static int udp_push_pending_frames(struct sock *sk)
+int udp_push_pending_frames(struct sock *sk)
 {
        struct udp_sock  *up = udp_sk(sk);
        struct inet_sock *inet = inet_sk(sk);
@@ -819,6 +819,7 @@ out:
        up->pending = 0;
        return err;
 }
+EXPORT_SYMBOL(udp_push_pending_frames);
 
 int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
                size_t len)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f77e34c..748046c 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1322,7 +1322,9 @@ int udpv6_setsockopt(struct sock *sk, int level, int optname,
 {
        if (level == SOL_UDP  ||  level == SOL_UDPLITE)
                return udp_lib_setsockopt(sk, level, optname, optval, optlen,
-                                         udp_v6_push_pending_frames);
+                                       udp_sk(sk)->pending == AF_INET6 ?
+                                       udp_v6_push_pending_frames :
+                                       udp_push_pending_frames);
        return ipv6_setsockopt(sk, level, optname, optval, optlen);
 }
 
@@ -1332,7 +1334,9 @@ int compat_udpv6_setsockopt(struct sock *sk, int level, int optname,
 {
        if (level == SOL_UDP  ||  level == SOL_UDPLITE)
                return udp_lib_setsockopt(sk, level, optname, optval, optlen,
-                                         udp_v6_push_pending_frames);
+                                       udp_sk(sk)->pending == AF_INET6 ?
+                                       udp_v6_push_pending_frames :
+                                       udp_push_pending_frames);
        return compat_ipv6_setsockopt(sk, level, optname, optval, optlen);
 }
 #endif

We call udp_v6_push_pending_frames on a socket which pending data is
actually AF_INET only. I would beautify the above patches (and perhaps
move the call to udp_push_pending_frames into udp_v6_push_pending_frames,
whatever looks nicer) and would do proper patch submissions then.

Greetings,

  Hannes
