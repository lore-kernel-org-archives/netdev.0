From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/6] netfilter: restore rule tracing via nfnetlink_log
Date: Sun, 22 Mar 2015 19:46:36 +0100
Message-ID: <1427049998-5665-5-git-send-email-pablo@netfilter.org>
References: <1427049998-5665-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427049998-5665-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since fab4085 ("netfilter: log: nf_log_packet() as real unified
interface"), the loginfo structure that is passed to nf_log_packet() is
used to explicitly indicate the logger type you want to use.

This is a problem for people tracing rules through nfnetlink_log since
packets are always routed to the NF_LOG_TYPE logger after the
aforementioned patch.

We can fix this by removing the trace loginfo structures, but that stil=
l
changes the log level from 4 to 5 for tracing messages and there may be
someone relying on this outthere. So let's just introduce a new
nf_log_trace() function that restores the former behaviour.

Reported-by: Markus K=C3=B6tter <koetter@rrzn.uni-hannover.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_log.h  |   10 ++++++++++
 net/ipv4/netfilter/ip_tables.c  |    6 +++---
 net/ipv6/netfilter/ip6_tables.c |    6 +++---
 net/netfilter/nf_log.c          |   24 ++++++++++++++++++++++++
 net/netfilter/nf_tables_core.c  |    8 ++++----
 5 files changed, 44 insertions(+), 10 deletions(-)

diff --git a/include/net/netfilter/nf_log.h b/include/net/netfilter/nf_=
log.h
index 534e1f2..57639fc 100644
--- a/include/net/netfilter/nf_log.h
+++ b/include/net/netfilter/nf_log.h
@@ -79,6 +79,16 @@ void nf_log_packet(struct net *net,
 		   const struct nf_loginfo *li,
 		   const char *fmt, ...);
=20
+__printf(8, 9)
+void nf_log_trace(struct net *net,
+		  u_int8_t pf,
+		  unsigned int hooknum,
+		  const struct sk_buff *skb,
+		  const struct net_device *in,
+		  const struct net_device *out,
+		  const struct nf_loginfo *li,
+		  const char *fmt, ...);
+
 struct nf_log_buf;
=20
 struct nf_log_buf *nf_log_buf_open(void);
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tab=
les.c
index 99e810f..cf5e82f 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -272,9 +272,9 @@ static void trace_packet(const struct sk_buff *skb,
 		    &chainname, &comment, &rulenum) !=3D 0)
 			break;
=20
-	nf_log_packet(net, AF_INET, hook, skb, in, out, &trace_loginfo,
-		      "TRACE: %s:%s:%s:%u ",
-		      tablename, chainname, comment, rulenum);
+	nf_log_trace(net, AF_INET, hook, skb, in, out, &trace_loginfo,
+		     "TRACE: %s:%s:%s:%u ",
+		     tablename, chainname, comment, rulenum);
 }
 #endif
=20
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_t=
ables.c
index e080fbb..bb00c6f 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -298,9 +298,9 @@ static void trace_packet(const struct sk_buff *skb,
 		    &chainname, &comment, &rulenum) !=3D 0)
 			break;
=20
-	nf_log_packet(net, AF_INET6, hook, skb, in, out, &trace_loginfo,
-		      "TRACE: %s:%s:%s:%u ",
-		      tablename, chainname, comment, rulenum);
+	nf_log_trace(net, AF_INET6, hook, skb, in, out, &trace_loginfo,
+		     "TRACE: %s:%s:%s:%u ",
+		     tablename, chainname, comment, rulenum);
 }
 #endif
=20
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 0d8448f..675d12c 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -212,6 +212,30 @@ void nf_log_packet(struct net *net,
 }
 EXPORT_SYMBOL(nf_log_packet);
=20
+void nf_log_trace(struct net *net,
+		  u_int8_t pf,
+		  unsigned int hooknum,
+		  const struct sk_buff *skb,
+		  const struct net_device *in,
+		  const struct net_device *out,
+		  const struct nf_loginfo *loginfo, const char *fmt, ...)
+{
+	va_list args;
+	char prefix[NF_LOG_PREFIXLEN];
+	const struct nf_logger *logger;
+
+	rcu_read_lock();
+	logger =3D rcu_dereference(net->nf.nf_loggers[pf]);
+	if (logger) {
+		va_start(args, fmt);
+		vsnprintf(prefix, sizeof(prefix), fmt, args);
+		va_end(args);
+		logger->logfn(net, pf, hooknum, skb, in, out, loginfo, prefix);
+	}
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL(nf_log_trace);
+
 #define S_SIZE (1024 - (sizeof(unsigned int) + 1))
=20
 struct nf_log_buf {
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_c=
ore.c
index 3b90eb2..2d298dc 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -94,10 +94,10 @@ static void nft_trace_packet(const struct nft_pktin=
fo *pkt,
 {
 	struct net *net =3D dev_net(pkt->in ? pkt->in : pkt->out);
=20
-	nf_log_packet(net, pkt->xt.family, pkt->ops->hooknum, pkt->skb, pkt->=
in,
-		      pkt->out, &trace_loginfo, "TRACE: %s:%s:%s:%u ",
-		      chain->table->name, chain->name, comments[type],
-		      rulenum);
+	nf_log_trace(net, pkt->xt.family, pkt->ops->hooknum, pkt->skb, pkt->i=
n,
+		     pkt->out, &trace_loginfo, "TRACE: %s:%s:%s:%u ",
+		     chain->table->name, chain->name, comments[type],
+		     rulenum);
 }
=20
 unsigned int
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
