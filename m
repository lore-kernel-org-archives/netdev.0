From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH] net: ipv4: inlining ip_send_check()
Date: Tue, 18 Aug 2015 14:14:39 +0200 (CEST)
Message-ID: <20150818121439.3E5621A241A@localhost.localdomain>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2.236.17.93.rev.sfr.net ([93.17.236.2]:17157 "EHLO
	mailhub1.si.c-s.fr" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751165AbbHRMOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 08:14:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_send_check() is a function that does nothing but calling
ip_fast_csum() after having zeroed iph->check

We get (on PPC) a quite long function for just that, as it requires
setting the stack frame, saving volatile regs, restoring them after
the call, etc ...

c02d3e3c <ip_send_check>:
c02d3e3c:       7c 08 02 a6     mflr    r0
c02d3e40:       94 21 ff f0     stwu    r1,-16(r1)
c02d3e44:       39 20 00 00     li      r9,0
c02d3e48:       93 e1 00 0c     stw     r31,12(r1)
c02d3e4c:       90 01 00 14     stw     r0,20(r1)
c02d3e50:       b1 23 00 0a     sth     r9,10(r3)
c02d3e54:       88 83 00 00     lbz     r4,0(r3)
c02d3e58:       7c 7f 1b 78     mr      r31,r3
c02d3e5c:       54 84 07 3e     clrlwi  r4,r4,28
c02d3e60:       4b d3 ab 7d     bl      c000e9dc <ip_fast_csum>
c02d3e64:       b0 7f 00 0a     sth     r3,10(r31)
c02d3e68:       80 01 00 14     lwz     r0,20(r1)
c02d3e6c:       83 e1 00 0c     lwz     r31,12(r1)
c02d3e70:       7c 08 03 a6     mtlr    r0
c02d3e74:       38 21 00 10     addi    r1,r1,16
c02d3e78:       4e 80 00 20     blr

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 include/net/ip.h     | 9 ++++++++-
 net/ipv4/ip_output.c | 8 --------
 2 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index c0c26c3..b88d592 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -32,6 +32,7 @@
 #include <net/snmp.h>
 #include <net/flow.h>
 #include <net/flow_keys.h>
+#include <net/checksum.h>
 
 struct sock;
 
@@ -110,7 +111,13 @@ int ip_output(struct sock *sk, struct sk_buff *skb);
 int ip_mc_output(struct sock *sk, struct sk_buff *skb);
 int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
 int ip_do_nat(struct sk_buff *skb);
-void ip_send_check(struct iphdr *ip);
+/* Generate a checksum for an outgoing IP datagram. */
+static inline void ip_send_check(struct iphdr *iph)
+{
+	iph->check = 0;
+	iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+}
+
 int __ip_local_out(struct sk_buff *skb);
 int ip_local_out_sk(struct sock *sk, struct sk_buff *skb);
 static inline int ip_local_out(struct sk_buff *skb)
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 357c2a9..fa054cf 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -83,14 +83,6 @@
 int sysctl_ip_default_ttl __read_mostly = IPDEFTTL;
 EXPORT_SYMBOL(sysctl_ip_default_ttl);
 
-/* Generate a checksum for an outgoing IP datagram. */
-void ip_send_check(struct iphdr *iph)
-{
-	iph->check = 0;
-	iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
-}
-EXPORT_SYMBOL(ip_send_check);
-
 int __ip_local_out(struct sk_buff *skb)
 {
 	struct iphdr *iph = ip_hdr(skb);
-- 
2.1.0
