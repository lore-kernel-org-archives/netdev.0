From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net 3/4] ipv6: datagram: Update dst cache of a connected datagram sk during pmtu update
Date: Fri, 1 Apr 2016 15:56:30 -0700
Message-ID: <1459551391-69969-4-git-send-email-kafai@fb.com>
References: <1459551391-69969-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>, Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:63836 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753769AbcDAW5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 18:57:35 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u31MrnfS022227
	for <netdev@vger.kernel.org>; Fri, 1 Apr 2016 15:57:34 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 221ymagpg2-2
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 15:57:34 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 1d5fcc92f85d11e597d724be05956610-e96cc3f0 for <netdev@vger.kernel.org>;	Fri,
 01 Apr 2016 15:57:31 -0700
In-Reply-To: <1459551391-69969-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a case in connected UDP socket such that
getsockopt(IPV6_MTU) will return a stale MTU value. The reproducible
sequence could be the following:
1. Create a connected UDP socket
2. Send some datagrams out
3. Receive a ICMPV6_PKT_TOOBIG
4. No new outgoing datagrams to trigger the sk_dst_check()
   logic to update the sk->sk_dst_cache.
5. getsockopt(IPV6_MTU) returns the mtu from the invalid
   sk->sk_dst_cache instead of the newly created RTF_CACHE clone.

This patch updates the sk->sk_dst_cache for a connected datagram sk.

It is done under '!sock_owned_by_user(sk)' condition because
the user may make another ip6_datagram_connect() while
dst lookup and update are happening.

For the sock_owned_by_user(sk) == true case, the next patch will
introduce a release_cb() which will update the sk->sk_dst_cache.

Test:

Server (Connected UDP Socket):
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Route Details:
[root@arch-fb-vm1 ~]# ip -6 r show | egrep '2fac'
2fac::/64 dev eth0  proto kernel  metric 256  pref medium
2fac:face::/64 via 2fac::face dev eth0  metric 1024  pref medium

A simple python code to create a connected UDP socket:

import socket
import errno

HOST = '2fac::1'
PORT = 8080

s = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
s.bind((HOST, PORT))
s.connect(('2fac:face::face', 53))
print("connected")
while True:
    try:
	data = s.recv(1024)
    except socket.error as se:
	if se.errno == errno.EMSGSIZE:
		pmtu = s.getsockopt(41, 24)
		print("PMTU:%d" % pmtu)
		break
s.close()

Python program output after getting a ICMPV6_PKT_TOOBIG:
[root@arch-fb-vm1 ~]# python2 ~/devshare/kernel/tasks/fib6/udp-connect-53-8080.py
connected
PMTU:1300

Cache routes after recieving TOOBIG:
[root@arch-fb-vm1 ~]# ip -6 r show table cache
2fac:face::face via 2fac::face dev eth0  metric 0
    cache  expires 463sec mtu 1300 pref medium

Client (Send the ICMPV6_PKT_TOOBIG):
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
scapy is used to generate the TOOBIG message.  Here is the scapy script I have
used:

>>> p=Ether(src='da:75:4d:36:ac:32', dst='52:54:00:12:34:66', type=0x86dd)/IPv6(src='2fac::face', dst='2fac::1')/ICMPv6PacketTooBig(mtu=1300)/IPv6(src='2fac::
1',dst='2fac:face::face', nh='UDP')/UDP(sport=8080,dport=53)
>>> sendp(p, iface='qemubr0')

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reported-by: Wei Wang <weiwan@google.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Wei Wang <weiwan@google.com>
---
 include/net/ipv6.h  |  1 +
 net/ipv6/datagram.c | 20 +++++++++++---------
 net/ipv6/route.c    | 11 +++++++++++
 3 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index d0aeb97..fd02e90 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -959,6 +959,7 @@ int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
 int ip6_datagram_connect(struct sock *sk, struct sockaddr *addr, int addr_len);
 int ip6_datagram_connect_v6_only(struct sock *sk, struct sockaddr *addr,
 				 int addr_len);
+int ip6_datagram_dst_update(struct sock *sk, bool fix_sk_saddr);
 
 int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len,
 		    int *addr_len);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 140665b..0b60f1e 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -64,7 +64,7 @@ static void ip6_datagram_flow_key_init(struct flowi6 *fl6, struct sock *sk)
 	security_sk_classify_flow(sk, flowi6_to_flowi(fl6));
 }
 
-static int ip6_datagram_dst_update(struct sock *sk)
+int ip6_datagram_dst_update(struct sock *sk, bool fix_sk_saddr)
 {
 	struct ip6_flowlabel *flowlabel = NULL;
 	struct in6_addr *final_p, final;
@@ -93,14 +93,16 @@ static int ip6_datagram_dst_update(struct sock *sk)
 		goto out;
 	}
 
-	if (ipv6_addr_any(&np->saddr))
-		np->saddr = fl6.saddr;
+	if (fix_sk_saddr) {
+		if (ipv6_addr_any(&np->saddr))
+			np->saddr = fl6.saddr;
 
-	if (ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
-		sk->sk_v6_rcv_saddr = fl6.saddr;
-		inet->inet_rcv_saddr = LOOPBACK4_IPV6;
-		if (sk->sk_prot->rehash)
-			sk->sk_prot->rehash(sk);
+		if (ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
+			sk->sk_v6_rcv_saddr = fl6.saddr;
+			inet->inet_rcv_saddr = LOOPBACK4_IPV6;
+			if (sk->sk_prot->rehash)
+				sk->sk_prot->rehash(sk);
+		}
 	}
 
 	ip6_dst_store(sk, dst,
@@ -221,7 +223,7 @@ ipv4_connected:
 	 *	destination cache for it.
 	 */
 
-	err = ip6_datagram_dst_update(sk);
+	err = ip6_datagram_dst_update(sk, true);
 	if (err)
 		goto out;
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ed44663..f7e6a6d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1417,8 +1417,19 @@ EXPORT_SYMBOL_GPL(ip6_update_pmtu);
 
 void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu)
 {
+	struct dst_entry *dst;
+
 	ip6_update_pmtu(skb, sock_net(sk), mtu,
 			sk->sk_bound_dev_if, sk->sk_mark);
+
+	dst = __sk_dst_get(sk);
+	if (!dst || dst->ops->check(dst, inet6_sk(sk)->dst_cookie))
+		return;
+
+	bh_lock_sock(sk);
+	if (!sock_owned_by_user(sk))
+		ip6_datagram_dst_update(sk, false);
+	bh_unlock_sock(sk);
 }
 EXPORT_SYMBOL_GPL(ip6_sk_update_pmtu);
 
-- 
2.5.1
