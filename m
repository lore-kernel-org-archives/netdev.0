From: Patrick McHardy <kaber@trash.net>
Subject: [IPV4]: Uninline netfilter okfns
Date: Mon, 15 Oct 2007 09:57:24 +0200
Message-ID: <47131D64.3080008@trash.net>
References: <E1IbT8r-0000Av-00@gondolin.me.apana.org.au> <46FE6D73.4000002@trash.net> <20070929.171339.59681016.davem@davemloft.net> <20070930002601.GB7502@gondor.apana.org.au> <20070930004341.GA7769@gondor.apana.org.au> <46FFC2F4.8090602@trash.net> <20071014042604.GA11431@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070507010206090403090207"
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37689 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751905AbXJOH51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 03:57:27 -0400
In-Reply-To: <20071014042604.GA11431@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070507010206090403090207
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Your patches work fine so far, tested with fragments, packet
content mangling etc. Thanks again for doing this. And they
really do enable gcc to generate tail-calls for the NF_HOOK
okfns, so this patch changes net/ipv4 to take advantage of
this. IPv6 and bridge will follow ...



--------------070507010206090403090207
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[IPV4]: Uninline netfilter okfns

Now that we don't pass double skb pointers to nf_hook_slow anymore, gcc
can generate tail calls for some of the netfilter hook okfn invocations,
so there is no need to inline the functions anymore. This caused huge
code bloat since we ended up with one inlined version and one out-of-line
version since we pass the address to nf_hook_slow.

Before:
   text    data     bss     dec     hex filename
8997385 1016524  524652 10538561         a0ce41 vmlinux

After:
   text    data     bss     dec     hex filename
8994009 1016524  524652 10535185         a0c111 vmlinux
-------------------------------------------------------
  -3376

All cases have been verified to generate tail-calls with and without
netfilter. The okfns in ipmr and xfrm4_input still remain inline because
gcc can't generate tail-calls for them.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 39533dafc9b0458fecebd2da36d682837c6ff9a2
tree af5f872142f9a0703c167843a1f51642f89c5662
parent 3e7e83795236b54106ef3ac57f140d97300aa5f5
author Patrick McHardy <kaber@trash.net> Mon, 15 Oct 2007 09:56:24 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 15 Oct 2007 09:56:24 +0200

 net/ipv4/ip_forward.c |    2 +-
 net/ipv4/ip_input.c   |    4 ++--
 net/ipv4/ip_output.c  |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index afbf938..877da3e 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -40,7 +40,7 @@
 #include <net/route.h>
 #include <net/xfrm.h>
 
-static inline int ip_forward_finish(struct sk_buff *skb)
+static int ip_forward_finish(struct sk_buff *skb)
 {
 	struct ip_options * opt	= &(IPCB(skb)->opt);
 
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 8f75e43..168c871 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -195,7 +195,7 @@ int ip_call_ra_chain(struct sk_buff *skb)
 	return 0;
 }
 
-static inline int ip_local_deliver_finish(struct sk_buff *skb)
+static int ip_local_deliver_finish(struct sk_buff *skb)
 {
 	__skb_pull(skb, ip_hdrlen(skb));
 
@@ -324,7 +324,7 @@ drop:
 	return -1;
 }
 
-static inline int ip_rcv_finish(struct sk_buff *skb)
+static int ip_rcv_finish(struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 699f067..f508835 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -202,7 +202,7 @@ static inline int ip_skb_dst_mtu(struct sk_buff *skb)
 	       skb->dst->dev->mtu : dst_mtu(skb->dst);
 }
 
-static inline int ip_finish_output(struct sk_buff *skb)
+static int ip_finish_output(struct sk_buff *skb)
 {
 #if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
 	/* Policy lookup after SNAT yielded a new policy */

--------------070507010206090403090207--
