From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [resend] Passive OS fingerprint xtables match.
Date: Thu, 4 Jun 2009 18:50:09 +0400
Message-ID: <20090604145009.GB18251@ioremap.net>
References: <20090511095343.GA30778@ioremap.net> <4A1D6A20.8050404@trash.net> <20090604113723.GA13018@ioremap.net> <4A27B5A1.9050300@trash.net> <20090604120719.GA14981@ioremap.net> <4A27B9EC.2010301@trash.net> <20090604131153.GA18251@ioremap.net> <4A27C921.6020301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A27C921.6020301@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 04, 2009 at 03:16:17PM +0200, Patrick McHardy (kaber@trash.net) wrote:
> Exactly. But please verify that by reordering, you're not moving
> the more commonly used members out of the first cacheline.

That's what I ended up with. arptable does not use match entries. Did I
miss others?

As of cache line alignment - I moved the only writable member at the end
of the structure, so it should even improve things a bit, although I
really do not think this will ever be noticeble.

--

Added hook number into match extension parameter structure.

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 7b1a652..65a08ae 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -184,9 +184,10 @@ struct xt_counters_info
  * @matchinfo:	per-match data
  * @fragoff:	packet is a fragment, this is the data offset
  * @thoff:	position of transport header relative to skb->data
- * @hotdrop:	drop packet if we had inspection problems
+ * @hook:	hook number given packet came from
  * @family:	Actual NFPROTO_* through which the function is invoked
  * 		(helpful when match->family == NFPROTO_UNSPEC)
+ * @hotdrop:	drop packet if we had inspection problems
  */
 struct xt_match_param {
 	const struct net_device *in, *out;
@@ -194,8 +195,9 @@ struct xt_match_param {
 	const void *matchinfo;
 	int fragoff;
 	unsigned int thoff;
-	bool *hotdrop;
+	unsigned int hooknum;
 	u_int8_t family;
+	bool *hotdrop;
 };
 
 /**
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 820252a..db2540e 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -164,7 +164,7 @@ unsigned int ebt_do_table (unsigned int hook, struct sk_buff *skb,
 	mtpar.in      = tgpar.in  = in;
 	mtpar.out     = tgpar.out = out;
 	mtpar.hotdrop = &hotdrop;
-	tgpar.hooknum = hook;
+	mtpar.hooknum = tgpar.hooknum = hook;
 
 	read_lock_bh(&table->lock);
 	private = table->private;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 810c0b6..385e4a0 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -335,7 +335,7 @@ ipt_do_table(struct sk_buff *skb,
 	mtpar.in      = tgpar.in  = in;
 	mtpar.out     = tgpar.out = out;
 	mtpar.family  = tgpar.family = NFPROTO_IPV4;
-	tgpar.hooknum = hook;
+	mtpar.hooknum = tgpar.hooknum = hook;
 
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
 
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 800ae85..d603ae4 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -361,7 +361,7 @@ ip6t_do_table(struct sk_buff *skb,
 	mtpar.in      = tgpar.in  = in;
 	mtpar.out     = tgpar.out = out;
 	mtpar.family  = tgpar.family = NFPROTO_IPV6;
-	tgpar.hooknum = hook;
+	mtpar.hooknum = tgpar.hooknum = hook;
 
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
 


-- 
	Evgeniy Polyakov
