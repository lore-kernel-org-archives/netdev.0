From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [IPV4] ROUTE: ip_rt_dump() is unecessary slow
Date: Mon, 7 Jan 2008 19:30:02 +0100
Message-ID: <20080107193002.df137d57.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:58910 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752161AbYAGSaF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2008 13:30:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed "ip route list cache x.y.z.t" can be *very* slow.

While strace-ing -T it I also noticed that first part of route cache is
fetched quite fast :


recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"p\0\0\0\30\0\2\0\254i\202
GXm\0\0\2  \0\376\0\0\2\0\2\0"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3772 <0.000047>
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\234\0\0\0\30\0\2\0\254i\
202GXm\0\0\2  \0\376\0\0\1\0\2"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3736 <0.000042>
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\204\0\0\0\30\0\2\0\254i\
202GXm\0\0\2  \0\376\0\0\1\0\2"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3740 <0.000055>
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\234\0\0\0\30\0\2\0\254i\
202GXm\0\0\2  \0\376\0\0\1\0\2"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3712 <0.000043>
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\204\0\0\0\30\0\2\0\254i\
202GXm\0\0\2  \0\376\0\0\1\0\2"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3732 <0.000053>
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"p\0\0\0\30\0\2\0\254i\202
GXm\0\0\2  \0\376\0\0\2\0\2\0"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3708 <0.000052>
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"p\0\0\0\30\0\2\0\254i\202
GXm\0\0\2  \0\376\0\0\2\0\2\0"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3680 <0.000041>

while the part at the end of the table is more expensive:

recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\204\0\0\0\30\0\2\0\254i\202GXm\0\0\2  \0\376\0\0\1\0\2"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3656 <0.003857>
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\204\0\0\0\30\0\2\0\254i\202GXm\0\0\2  \0\376\0\0\1\0\2"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3772 <0.003891>
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"p\0\0\0\30\0\2\0\254i\202GXm\0\0\2  \0\376\0\0\2\0\2\0"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3712 <0.003765>
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"p\0\0\0\30\0\2\0\254i\202GXm\0\0\2  \0\376\0\0\2\0\2\0"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3700 <0.003879>
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"p\0\0\0\30\0\2\0\254i\202GXm\0\0\2  \0\376\0\0\2\0\2\0"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3676 <0.003797>
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"p\0\0\0\30\0\2\0\254i\202GXm\0\0\2  \0\376\0\0\2\0\2\0"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3724 <0.003856>
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\234\0\0\0\30\0\2\0\254i\202GXm\0\0\2  \0\376\0\0\1\0\2"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3736 <0.003848>

The following patch corrects this performance/latency problem, removing quadratic behavior.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 10915bb..b7aa6dd 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2755,11 +2755,10 @@ int ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb)
 	int idx, s_idx;
 
 	s_h = cb->args[0];
+	if (s_h < 0)
+		s_h = 0;
 	s_idx = idx = cb->args[1];
-	for (h = 0; h <= rt_hash_mask; h++) {
-		if (h < s_h) continue;
-		if (h > s_h)
-			s_idx = 0;
+	for (h = s_h; h <= rt_hash_mask; h++) {
 		rcu_read_lock_bh();
 		for (rt = rcu_dereference(rt_hash_table[h].chain), idx = 0; rt;
 		     rt = rcu_dereference(rt->u.dst.rt_next), idx++) {
@@ -2776,6 +2775,7 @@ int ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb)
 			dst_release(xchg(&skb->dst, NULL));
 		}
 		rcu_read_unlock_bh();
+		s_idx = 0;
 	}
 
 done:

