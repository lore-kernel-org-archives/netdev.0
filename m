From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] Ensure to use icmpv6_socket in non-preemptive context.
Date: Sun, 12 Jun 2005 23:03:58 +0900 (JST)
Message-ID: <20050612.230358.119812619.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

[IPV6] Make sure to use icmpv6_socket in non-preemptive context.

We saw following trace several times:

|BUG: using smp_processor_id() in preemptible [00000001] code: httpd/30137
|caller is icmpv6_send+0x23/0x540
| [<c01ad63b>] smp_processor_id+0x9b/0xb8
| [<c02993e7>] icmpv6_send+0x23/0x540

This is because of icmpv6_socket, which is the only one user of
smp_processor_id() in icmpv6_send(), AFAIK.

Since it should be used in non-preemptive context,
let's defer the dereference after disabling preemption
(by icmpv6_xmit_lock()).

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -277,8 +277,8 @@ void icmpv6_send(struct sk_buff *skb, in
 {
 	struct inet6_dev *idev = NULL;
 	struct ipv6hdr *hdr = skb->nh.ipv6h;
-	struct sock *sk = icmpv6_socket->sk;
-	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct sock *sk;
+	struct ipv6_pinfo *np;
 	struct in6_addr *saddr = NULL;
 	struct dst_entry *dst;
 	struct icmp6hdr tmp_hdr;
@@ -358,6 +358,9 @@ void icmpv6_send(struct sk_buff *skb, in
 	if (icmpv6_xmit_lock())
 		return;
 
+	sk = icmpv6_socket->sk;
+	np = inet6_sk(sk);
+
 	if (!icmpv6_xrlim_allow(sk, type, &fl))
 		goto out;
 
@@ -423,9 +426,9 @@ out:
 
 static void icmpv6_echo_reply(struct sk_buff *skb)
 {
-	struct sock *sk = icmpv6_socket->sk;
+	struct sock *sk;
 	struct inet6_dev *idev;
-	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct ipv6_pinfo *np;
 	struct in6_addr *saddr = NULL;
 	struct icmp6hdr *icmph = (struct icmp6hdr *) skb->h.raw;
 	struct icmp6hdr tmp_hdr;
@@ -454,6 +457,9 @@ static void icmpv6_echo_reply(struct sk_
 	if (icmpv6_xmit_lock())
 		return;
 
+	sk = icmpv6_socket->sk;
+	np = inet6_sk(sk);
+
 	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
 		fl.oif = np->mcast_oif;
 

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
