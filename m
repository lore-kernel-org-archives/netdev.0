From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 3/3] netfilter: bridge: don't mangle ipv4 header options
Date: Sat,  4 Oct 2014 03:04:30 +0200
Message-ID: <1412384670-17794-4-git-send-email-fw@strlen.de>
References: <1412384670-17794-1-git-send-email-fw@strlen.de>
Cc: bsd@redhat.com, stephen@networkplumber.org, netdev@cger.kernel.org,
	herbert@gondor.apana.org.au, eric.dumazet@gmail.com,
	davidn@davidnewall.com, Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1412384670-17794-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

a bridge is meant to be L3 protocol agnostic, we should not act on ipv4
header options.  Thus, ensure that skb data isn't modified when
parsing options and also remove the ip_options_rcv_srr() call.

The only purpose of this function is to do sanity tests so upcalls into
netfilter will have the same checks applied as done by the ipv4 input path.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Bandan Das <bsd@redhat.com>
Reported-by: David Newall <davidn@davidnewall.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/bridge/br_netfilter.c | 42 +++++++++++++++++++-----------------------
 1 file changed, 19 insertions(+), 23 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 56c7ed8..f5cb2ef 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -185,14 +185,17 @@ static inline void nf_bridge_save_header(struct sk_buff *skb)
 					 skb->nf_bridge->data, header_size);
 }
 
-/* When handing a packet over to the IP layer
- * check whether we have a skb that is in the
- * expected format
+/* When handing an ipv4 packet over to netfilter, we must
+ * first replicate the sanity tests performed in the IP stack
+ * input path.  This includes making sure that the entire ip
+ * header is in the linear skb area, ip->ihl is sane, etc.
  */
-
-static int br_parse_ip_options(struct sk_buff *skb)
+static bool br_ip_input_valid(struct sk_buff *skb)
 {
-	struct ip_options *opt;
+	struct {
+		struct ip_options opt;
+		u8 hdrdata[0xf * 4];
+	} ip_opts;
 	const struct iphdr *iph;
 	struct net_device *dev = skb->dev;
 	u32 len;
@@ -201,7 +204,6 @@ static int br_parse_ip_options(struct sk_buff *skb)
 		goto inhdr_error;
 
 	iph = ip_hdr(skb);
-	opt = &(IPCB(skb)->opt);
 
 	/* Basic sanity checks */
 	if (iph->ihl < 5 || iph->version != 4)
@@ -228,28 +230,22 @@ static int br_parse_ip_options(struct sk_buff *skb)
 
 	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
 	if (iph->ihl == 5)
-		return 0;
-
-	opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
-	if (ip_options_compile(dev_net(dev), opt, skb))
-		goto inhdr_error;
+		return true;
 
-	/* Check correct handling of SRR option */
-	if (unlikely(opt->srr)) {
-		struct in_device *in_dev = __in_dev_get_rcu(dev);
-		if (in_dev && !IN_DEV_SOURCE_ROUTE(in_dev))
-			goto drop;
+	memset(&ip_opts.opt, 0, sizeof(ip_opts.opt));
+	ip_opts.opt.optlen = iph->ihl*4 - sizeof(struct iphdr);
+	memcpy(ip_opts.hdrdata, iph + 1, ip_opts.opt.optlen);
 
-		if (ip_options_rcv_srr(skb))
-			goto drop;
-	}
+	/* We only call this to validate iph options. */
+	if (ip_options_compile(dev_net(dev), &ip_opts.opt, NULL))
+		goto inhdr_error;
 
-	return 0;
+	return true;
 
 inhdr_error:
 	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
 drop:
-	return -1;
+	return false;
 }
 
 /* PF_BRIDGE/PRE_ROUTING *********************************************/
@@ -617,7 +613,7 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
 
 	nf_bridge_pull_encap_header_rcsum(skb);
 
-	if (br_parse_ip_options(skb))
+	if (!br_ip_input_valid(skb))
 		return NF_DROP;
 
 	nf_bridge_put(skb->nf_bridge);
-- 
2.0.4

