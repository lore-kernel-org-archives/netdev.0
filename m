From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/2] netfilter: fix wrong arithmetics regarding NFT_REJECT_ICMPX_MAX
Date: Thu,  9 Oct 2014 20:27:41 +0200
Message-ID: <1412879261-25045-3-git-send-email-pablo@netfilter.org>
References: <1412879261-25045-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1412879261-25045-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NFT_REJECT_ICMPX_MAX should be __NFT_REJECT_ICMPX_MAX - 1.

nft_reject_icmp_code() and nft_reject_icmpv6_code() are called from the
packet path, so BUG_ON in case we try to access an unknown abstracted
ICMP code. This should not happen since we already validate this from
nft_reject_{inet,bridge}_init().

Fixes: 51b0a5d ("netfilter: nft_reject: introduce icmp code abstraction for inet and bridge")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |    2 +-
 net/netfilter/nft_reject.c               |   10 ++++------
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index c26df67..f31fe7b 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -774,7 +774,7 @@ enum nft_reject_inet_code {
 	NFT_REJECT_ICMPX_ADMIN_PROHIBITED,
 	__NFT_REJECT_ICMPX_MAX
 };
-#define NFT_REJECT_ICMPX_MAX	(__NFT_REJECT_ICMPX_MAX + 1)
+#define NFT_REJECT_ICMPX_MAX	(__NFT_REJECT_ICMPX_MAX - 1)
 
 /**
  * enum nft_reject_attributes - nf_tables reject expression netlink attributes
diff --git a/net/netfilter/nft_reject.c b/net/netfilter/nft_reject.c
index ec8a456..57d3e1a 100644
--- a/net/netfilter/nft_reject.c
+++ b/net/netfilter/nft_reject.c
@@ -72,7 +72,7 @@ nla_put_failure:
 }
 EXPORT_SYMBOL_GPL(nft_reject_dump);
 
-static u8 icmp_code_v4[NFT_REJECT_ICMPX_MAX] = {
+static u8 icmp_code_v4[NFT_REJECT_ICMPX_MAX + 1] = {
 	[NFT_REJECT_ICMPX_NO_ROUTE]		= ICMP_NET_UNREACH,
 	[NFT_REJECT_ICMPX_PORT_UNREACH]		= ICMP_PORT_UNREACH,
 	[NFT_REJECT_ICMPX_HOST_UNREACH]		= ICMP_HOST_UNREACH,
@@ -81,8 +81,7 @@ static u8 icmp_code_v4[NFT_REJECT_ICMPX_MAX] = {
 
 int nft_reject_icmp_code(u8 code)
 {
-	if (code > NFT_REJECT_ICMPX_MAX)
-		return -EINVAL;
+	BUG_ON(code > NFT_REJECT_ICMPX_MAX);
 
 	return icmp_code_v4[code];
 }
@@ -90,7 +89,7 @@ int nft_reject_icmp_code(u8 code)
 EXPORT_SYMBOL_GPL(nft_reject_icmp_code);
 
 
-static u8 icmp_code_v6[NFT_REJECT_ICMPX_MAX] = {
+static u8 icmp_code_v6[NFT_REJECT_ICMPX_MAX + 1] = {
 	[NFT_REJECT_ICMPX_NO_ROUTE]		= ICMPV6_NOROUTE,
 	[NFT_REJECT_ICMPX_PORT_UNREACH]		= ICMPV6_PORT_UNREACH,
 	[NFT_REJECT_ICMPX_HOST_UNREACH]		= ICMPV6_ADDR_UNREACH,
@@ -99,8 +98,7 @@ static u8 icmp_code_v6[NFT_REJECT_ICMPX_MAX] = {
 
 int nft_reject_icmpv6_code(u8 code)
 {
-	if (code > NFT_REJECT_ICMPX_MAX)
-		return -EINVAL;
+	BUG_ON(code > NFT_REJECT_ICMPX_MAX);
 
 	return icmp_code_v6[code];
 }
-- 
1.7.10.4

