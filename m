From: fgao@ikuai8.com
Subject: [PATCH nf 1/1] netfilter: h323,sip: Fix possible dead loop in nat_rtp_rtcp and nf_nat_sdp_media
Date: Thu,  2 Mar 2017 15:57:00 +0800
Message-ID: <1488441420-25537-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: pablo@netfilter.org, kadlec@blackhole.kfki.hu, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

When h323 and sip try to insert expect nodes, they would increase
the port by 2 for loop, and the loop condition is that "port != 0".
So when the start port is odd number, port never increases to zero.

Now make port as u32 instead of u_int16_t, and the loop condition is
"port <= USHRT_MAX".

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 net/ipv4/netfilter/nf_nat_h323.c | 4 ++--
 net/netfilter/nf_nat_sip.c       | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
index 574f7eb..010fc3e 100644
--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -183,7 +183,7 @@ static int nat_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 	struct nf_ct_h323_master *info = nfct_help_data(ct);
 	int dir = CTINFO2DIR(ctinfo);
 	int i;
-	u_int16_t nated_port;
+	u32 nated_port;
 
 	/* Set expectations for NAT */
 	rtp_exp->saved_proto.udp.port = rtp_exp->tuple.dst.u.udp.port;
@@ -218,7 +218,7 @@ static int nat_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 
 	/* Try to get a pair of ports. */
 	for (nated_port = ntohs(rtp_exp->tuple.dst.u.udp.port);
-	     nated_port != 0; nated_port += 2) {
+	     nated_port <= USHRT_MAX; nated_port += 2) {
 		int ret;
 
 		rtp_exp->tuple.dst.u.udp.port = htons(nated_port);
diff --git a/net/netfilter/nf_nat_sip.c b/net/netfilter/nf_nat_sip.c
index 791fac4..0b24eb3 100644
--- a/net/netfilter/nf_nat_sip.c
+++ b/net/netfilter/nf_nat_sip.c
@@ -548,7 +548,7 @@ static unsigned int nf_nat_sdp_media(struct sk_buff *skb, unsigned int protoff,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
-	u_int16_t port;
+	u32 port;
 
 	/* Connection will come from reply */
 	if (nf_inet_addr_cmp(&ct->tuplehash[dir].tuple.src.u3,
@@ -571,7 +571,7 @@ static unsigned int nf_nat_sdp_media(struct sk_buff *skb, unsigned int protoff,
 
 	/* Try to get same pair of ports: if not, try to change them. */
 	for (port = ntohs(rtp_exp->tuple.dst.u.udp.port);
-	     port != 0; port += 2) {
+	     port <= USHRT_MAX; port += 2) {
 		int ret;
 
 		rtp_exp->tuple.dst.u.udp.port = htons(port);
-- 
1.9.1


