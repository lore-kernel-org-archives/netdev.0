From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/6] netfilter: synproxy: fix BUG_ON triggered by corrupt TCP packets
Date: Tue,  1 Oct 2013 11:35:32 +0200
Message-ID: <1380620132-7388-6-git-send-email-pablo@netfilter.org>
References: <1380620132-7388-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1380620132-7388-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

TCP packets hitting the SYN proxy through the SYNPROXY target are not
validated by TCP conntrack. When th->doff is below 5, an underflow happens
when calculating the options length, causing skb_header_pointer() to
return NULL and triggering the BUG_ON().

Handle this case gracefully by checking for NULL instead of using BUG_ON().

Reported-by: Martin Topholm <mph@one.com>
Tested-by: Martin Topholm <mph@one.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_synproxy.h |    2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c             |   10 +++++++---
 net/ipv6/netfilter/ip6t_SYNPROXY.c            |   10 +++++++---
 net/netfilter/nf_synproxy_core.c              |   12 +++++++-----
 4 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_synproxy.h b/include/net/netfilter/nf_conntrack_synproxy.h
index 806f54a..f572f31 100644
--- a/include/net/netfilter/nf_conntrack_synproxy.h
+++ b/include/net/netfilter/nf_conntrack_synproxy.h
@@ -56,7 +56,7 @@ struct synproxy_options {
 
 struct tcphdr;
 struct xt_synproxy_info;
-extern void synproxy_parse_options(const struct sk_buff *skb, unsigned int doff,
+extern bool synproxy_parse_options(const struct sk_buff *skb, unsigned int doff,
 				   const struct tcphdr *th,
 				   struct synproxy_options *opts);
 extern unsigned int synproxy_options_size(const struct synproxy_options *opts);
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 67e17dc..b6346bf 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -267,7 +267,8 @@ synproxy_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 	if (th == NULL)
 		return NF_DROP;
 
-	synproxy_parse_options(skb, par->thoff, th, &opts);
+	if (!synproxy_parse_options(skb, par->thoff, th, &opts))
+		return NF_DROP;
 
 	if (th->syn && !(th->ack || th->fin || th->rst)) {
 		/* Initial SYN from client */
@@ -350,7 +351,8 @@ static unsigned int ipv4_synproxy_hook(unsigned int hooknum,
 
 		/* fall through */
 	case TCP_CONNTRACK_SYN_SENT:
-		synproxy_parse_options(skb, thoff, th, &opts);
+		if (!synproxy_parse_options(skb, thoff, th, &opts))
+			return NF_DROP;
 
 		if (!th->syn && th->ack &&
 		    CTINFO2DIR(ctinfo) == IP_CT_DIR_ORIGINAL) {
@@ -373,7 +375,9 @@ static unsigned int ipv4_synproxy_hook(unsigned int hooknum,
 		if (!th->syn || !th->ack)
 			break;
 
-		synproxy_parse_options(skb, thoff, th, &opts);
+		if (!synproxy_parse_options(skb, thoff, th, &opts))
+			return NF_DROP;
+
 		if (opts.options & XT_SYNPROXY_OPT_TIMESTAMP)
 			synproxy->tsoff = opts.tsval - synproxy->its;
 
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 19cfea8..2748b04 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -282,7 +282,8 @@ synproxy_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 	if (th == NULL)
 		return NF_DROP;
 
-	synproxy_parse_options(skb, par->thoff, th, &opts);
+	if (!synproxy_parse_options(skb, par->thoff, th, &opts))
+		return NF_DROP;
 
 	if (th->syn && !(th->ack || th->fin || th->rst)) {
 		/* Initial SYN from client */
@@ -372,7 +373,8 @@ static unsigned int ipv6_synproxy_hook(unsigned int hooknum,
 
 		/* fall through */
 	case TCP_CONNTRACK_SYN_SENT:
-		synproxy_parse_options(skb, thoff, th, &opts);
+		if (!synproxy_parse_options(skb, thoff, th, &opts))
+			return NF_DROP;
 
 		if (!th->syn && th->ack &&
 		    CTINFO2DIR(ctinfo) == IP_CT_DIR_ORIGINAL) {
@@ -395,7 +397,9 @@ static unsigned int ipv6_synproxy_hook(unsigned int hooknum,
 		if (!th->syn || !th->ack)
 			break;
 
-		synproxy_parse_options(skb, thoff, th, &opts);
+		if (!synproxy_parse_options(skb, thoff, th, &opts))
+			return NF_DROP;
+
 		if (opts.options & XT_SYNPROXY_OPT_TIMESTAMP)
 			synproxy->tsoff = opts.tsval - synproxy->its;
 
diff --git a/net/netfilter/nf_synproxy_core.c b/net/netfilter/nf_synproxy_core.c
index 6fd967c..cdf4567 100644
--- a/net/netfilter/nf_synproxy_core.c
+++ b/net/netfilter/nf_synproxy_core.c
@@ -24,7 +24,7 @@
 int synproxy_net_id;
 EXPORT_SYMBOL_GPL(synproxy_net_id);
 
-void
+bool
 synproxy_parse_options(const struct sk_buff *skb, unsigned int doff,
 		       const struct tcphdr *th, struct synproxy_options *opts)
 {
@@ -32,7 +32,8 @@ synproxy_parse_options(const struct sk_buff *skb, unsigned int doff,
 	u8 buf[40], *ptr;
 
 	ptr = skb_header_pointer(skb, doff + sizeof(*th), length, buf);
-	BUG_ON(ptr == NULL);
+	if (ptr == NULL)
+		return false;
 
 	opts->options = 0;
 	while (length > 0) {
@@ -41,16 +42,16 @@ synproxy_parse_options(const struct sk_buff *skb, unsigned int doff,
 
 		switch (opcode) {
 		case TCPOPT_EOL:
-			return;
+			return true;
 		case TCPOPT_NOP:
 			length--;
 			continue;
 		default:
 			opsize = *ptr++;
 			if (opsize < 2)
-				return;
+				return true;
 			if (opsize > length)
-				return;
+				return true;
 
 			switch (opcode) {
 			case TCPOPT_MSS:
@@ -84,6 +85,7 @@ synproxy_parse_options(const struct sk_buff *skb, unsigned int doff,
 			length -= opsize;
 		}
 	}
+	return true;
 }
 EXPORT_SYMBOL_GPL(synproxy_parse_options);
 
-- 
1.7.10.4

