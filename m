From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH] ipv6: correct the ipv6 option name - Pad0 to Pad1
Date: Thu, 17 May 2012 18:00:25 +0200
Message-ID: <1337270425-21873-1-git-send-email-eldad@fogrefinery.com>
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eldad Zack <eldad@fogrefinery.com>
To: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The padding destination or hop-by-hop option is called Pad1 and not Pad0.

See RFC2460 (4.2) or the IANA ipv6-parameters registry:
http://www.iana.org/assignments/ipv6-parameters/ipv6-parameters.xml

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>

diff --git a/include/linux/in6.h b/include/linux/in6.h
index 5c83d9e..cba469b 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -142,7 +142,7 @@ struct in6_flowlabel_req {
 /*
  *	IPv6 TLV options.
  */
-#define IPV6_TLV_PAD0		0
+#define IPV6_TLV_PAD1		0
 #define IPV6_TLV_PADN		1
 #define IPV6_TLV_ROUTERALERT	5
 #define IPV6_TLV_JUMBO		194
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 5ca4c50..b665812 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -460,8 +460,8 @@ static struct sk_buff *br_ip6_multicast_alloc_query(struct net_bridge *br,
 	hopopt[3] = 2;				/* Length of RA Option */
 	hopopt[4] = 0;				/* Type = 0x0000 (MLD) */
 	hopopt[5] = 0;
-	hopopt[6] = IPV6_TLV_PAD0;		/* Pad0 */
-	hopopt[7] = IPV6_TLV_PAD0;		/* Pad0 */
+	hopopt[6] = IPV6_TLV_PAD1;		/* Pad1 */
+	hopopt[7] = IPV6_TLV_PAD1;		/* Pad1 */
 
 	skb_put(skb, sizeof(*ip6h) + 8);
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index dce55d4..e41456b 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -558,7 +558,7 @@ static int check_hbh_len(struct sk_buff *skb)
 		int optlen = nh[off + 1] + 2;
 
 		switch (nh[off]) {
-		case IPV6_TLV_PAD0:
+		case IPV6_TLV_PAD1:
 			optlen = 1;
 			break;
 
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 9aa3d01..5d32e7a 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -127,7 +127,7 @@ static int zero_out_mutable_opts(struct ipv6_opt_hdr *opthdr)
 
 		switch (opt[off]) {
 
-		case IPV6_TLV_PAD0:
+		case IPV6_TLV_PAD1:
 			optlen = 1;
 			break;
 		default:
@@ -171,7 +171,7 @@ static void ipv6_rearrange_destopt(struct ipv6hdr *iph, struct ipv6_opt_hdr *des
 
 		switch (opt[off]) {
 
-		case IPV6_TLV_PAD0:
+		case IPV6_TLV_PAD1:
 			optlen = 1;
 			break;
 		default:
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index a93bd23..a3cded6 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -75,7 +75,7 @@ int ipv6_find_tlv(struct sk_buff *skb, int offset, int type)
 			return offset;
 
 		switch (opttype) {
-		case IPV6_TLV_PAD0:
+		case IPV6_TLV_PAD1:
 			optlen = 1;
 			break;
 		default:
@@ -156,7 +156,7 @@ static int ip6_parse_tlv(struct tlvtype_proc *procs, struct sk_buff *skb)
 		int i;
 
 		switch (nh[off]) {
-		case IPV6_TLV_PAD0:
+		case IPV6_TLV_PAD1:
 			optlen = 1;
 			break;
 
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 2e02f7c..5b087c3 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -46,7 +46,7 @@ static inline void *mip6_padn(__u8 *data, __u8 padlen)
 	if (!data)
 		return NULL;
 	if (padlen == 1) {
-		data[0] = IPV6_TLV_PAD0;
+		data[0] = IPV6_TLV_PAD1;
 	} else if (padlen > 1) {
 		data[0] = IPV6_TLV_PADN;
 		data[1] = padlen - 2;
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 882124c..2c8ad7c 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -397,7 +397,7 @@ static int tcf_csum_ipv6_hopopts(struct ipv6_opt_hdr *ip6xh,
 
 	while (len > 1) {
 		switch (xh[off]) {
-		case IPV6_TLV_PAD0:
+		case IPV6_TLV_PAD1:
 			optlen = 1;
 			break;
 		case IPV6_TLV_JUMBO:
-- 
1.7.10
