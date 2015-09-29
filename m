From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH RFC 3/7] netfilter: add NF_INET_LOCAL_SOCKET_IN chain type
Date: Tue, 29 Sep 2015 13:12:16 +0200
Message-ID: <1443525140-13493-4-git-send-email-daniel@zonque.org>
References: <1443525140-13493-1-git-send-email-daniel@zonque.org>
Cc: daniel@iogearbox.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, fw@strlen.de, balazs.scheidler@balabit.com,
	Daniel Mack <daniel@zonque.org>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1443525140-13493-1-git-send-email-daniel@zonque.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new chain type NF_INET_LOCAL_SOCKET_IN which is ran after the
input demux is complete and the final destination socket (if any)
has been determined.

This helps filtering packets based on information stored in the
destination socket, such as cgroup controller supplied net class IDs.

Note that rules in such chains are not processed in case the local
listen socket cannot be determined. Hence, if no application is
listening on a specific task, the resulting error code that is sent
back to the remote peer can't be controlled with rules in
NF_INET_LOCAL_SOCKET_IN chains.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 include/uapi/linux/netfilter.h      | 1 +
 net/ipv4/netfilter/iptable_filter.c | 1 +
 net/ipv4/netfilter/nf_tables_ipv4.c | 4 +++-
 net/netfilter/nf_tables_inet.c      | 3 ++-
 4 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/netfilter.h b/include/uapi/linux/netfilter.h
index d93f949..96c3f8b 100644
--- a/include/uapi/linux/netfilter.h
+++ b/include/uapi/linux/netfilter.h
@@ -49,6 +49,7 @@ enum nf_inet_hooks {
 	NF_INET_FORWARD,
 	NF_INET_LOCAL_OUT,
 	NF_INET_POST_ROUTING,
+	NF_INET_LOCAL_SOCKET_IN,
 	NF_INET_NUMHOOKS
 };
 
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index a0f3bec..d65616a5 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -21,6 +21,7 @@ MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("iptables filter table");
 
 #define FILTER_VALID_HOOKS ((1 << NF_INET_LOCAL_IN) | \
+			    (1 << NF_INET_LOCAL_SOCKET_IN) | \
 			    (1 << NF_INET_FORWARD) | \
 			    (1 << NF_INET_LOCAL_OUT))
 
diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index aa180d3..abee60a 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -55,6 +55,7 @@ struct nft_af_info nft_af_ipv4 __read_mostly = {
 		[NF_INET_FORWARD]	= nft_do_chain_ipv4,
 		[NF_INET_PRE_ROUTING]	= nft_do_chain_ipv4,
 		[NF_INET_POST_ROUTING]	= nft_do_chain_ipv4,
+		[NF_INET_LOCAL_SOCKET_IN]	= nft_do_chain_ipv4,
 	},
 };
 EXPORT_SYMBOL_GPL(nft_af_ipv4);
@@ -96,7 +97,8 @@ static const struct nf_chain_type filter_ipv4 = {
 			  (1 << NF_INET_LOCAL_OUT) |
 			  (1 << NF_INET_FORWARD) |
 			  (1 << NF_INET_PRE_ROUTING) |
-			  (1 << NF_INET_POST_ROUTING),
+			  (1 << NF_INET_POST_ROUTING) |
+			  (1 << NF_INET_LOCAL_SOCKET_IN),
 };
 
 static int __init nf_tables_ipv4_init(void)
diff --git a/net/netfilter/nf_tables_inet.c b/net/netfilter/nf_tables_inet.c
index 9dd2d21..5544196 100644
--- a/net/netfilter/nf_tables_inet.c
+++ b/net/netfilter/nf_tables_inet.c
@@ -75,7 +75,8 @@ static const struct nf_chain_type filter_inet = {
 			  (1 << NF_INET_LOCAL_OUT) |
 			  (1 << NF_INET_FORWARD) |
 			  (1 << NF_INET_PRE_ROUTING) |
-			  (1 << NF_INET_POST_ROUTING),
+			  (1 << NF_INET_POST_ROUTING) |
+			  (1 << NF_INET_LOCAL_SOCKET_IN),
 };
 
 static int __init nf_tables_inet_init(void)
-- 
2.5.0

