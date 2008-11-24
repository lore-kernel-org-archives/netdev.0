From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [RFC] Could we avoid touching dst->refcount in some cases ?
Date: Mon, 24 Nov 2008 09:57:56 +0100
Message-ID: <492A6C94.7030308@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050305060805040902030108"
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:32957 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452AbYKXI56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 03:57:58 -0500
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by gw1.cosmosbay.com (8.13.7/8.13.7) with ESMTP id mAO8vupb030925
	for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 09:57:57 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050305060805040902030108
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

tbench has hard time incrementing decrementing the route cache refcount
shared by all communications on localhost.

On real world, we also have this problem on RTP servers sending many UDP
frames to mediagateways, especially big ones handling thousand of streams.

Given that route entries are using RCU, we probably can avoid incrementing
their refcount in case of connected sockets ?

Here is a (untested and probably not working at all) patch on UDP part to
illustrate the idea :


--------------050305060805040902030108
Content-Type: text/plain;
 name="avoid_touching_refcount.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="avoid_touching_refcount.patch"

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index da869ce..c385f13 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -553,6 +553,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	int ulen = len;
 	struct ipcm_cookie ipc;
 	struct rtable *rt = NULL;
+	int rt_release = 0;
 	int free = 0;
 	int connected = 0;
 	__be32 daddr, faddr, saddr;
@@ -656,8 +657,9 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		connected = 0;
 	}
 
+	rcu_read_lock();
 	if (connected)
-		rt = (struct rtable*)sk_dst_check(sk, 0);
+		rt = (struct rtable *)__sk_dst_check(sk, 0);
 
 	if (rt == NULL) {
 		struct flowi fl = { .oif = ipc.oif,
@@ -681,11 +683,14 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		}
 
 		err = -EACCES;
+		rt_release = 1;
 		if ((rt->rt_flags & RTCF_BROADCAST) &&
 		    !sock_flag(sk, SOCK_BROADCAST))
 			goto out;
-		if (connected)
-			sk_dst_set(sk, dst_clone(&rt->u.dst));
+		if (connected) {
+			sk_dst_set(sk, &rt->u.dst);
+			rt_release = 0;
+		}
 	}
 
 	if (msg->msg_flags&MSG_CONFIRM)
@@ -730,7 +735,9 @@ do_append_data:
 	release_sock(sk);
 
 out:
-	ip_rt_put(rt);
+	if (rt_release)
+		ip_rt_put(rt);
+	rcu_read_unlock();
 	if (free)
 		kfree(ipc.opt);
 	if (!err)

--------------050305060805040902030108--
