From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] Change masquerade code to use first IP address of interface.
Date: Wed, 20 Oct 2004 12:58:56 +1000
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <1098241135.10571.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netfilter development mailing list <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

As discussed previously, let's try this in 2.6.10, and see who screams.

Cheers,
Rusty.

Name: Change MASQUERADE to Use Device Address Directly
Status: Untested
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (created)

Instead of doing a dubious route lookup, just use the first IP address
of the (dynamic) interface.  Also, reset assured bit so after a device
goes down, masq connections can be cleaned up if memory pressure.

diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal .2156-linux-2.6.9-rc1-bk12/net/ipv4/netfilter/ipt_MASQUERADE.c .2156-linux-2.6.9-rc1-bk12.updated/net/ipv4/netfilter/ipt_MASQUERADE.c
--- .2156-linux-2.6.9-rc1-bk12/net/ipv4/netfilter/ipt_MASQUERADE.c	2004-08-25 09:54:25.000000000 +1000
+++ .2156-linux-2.6.9-rc1-bk12.updated/net/ipv4/netfilter/ipt_MASQUERADE.c	2004-09-08 00:15:05.000000000 +1000
@@ -82,7 +82,6 @@ masquerade_target(struct sk_buff **pskb,
 	const struct ip_nat_multi_range *mr;
 	struct ip_nat_multi_range newrange;
 	u_int32_t newsrc;
-	struct rtable *rt;
 
 	IP_NF_ASSERT(hooknum == NF_IP_POST_ROUTING);
 
@@ -96,36 +95,12 @@ masquerade_target(struct sk_buff **pskb,
 	                    || ctinfo == IP_CT_RELATED + IP_CT_IS_REPLY));
 
 	mr = targinfo;
-
-	{
-		struct flowi fl = { .nl_u = { .ip4_u =
-					      { .daddr = (*pskb)->nh.iph->daddr,
-						.tos = (RT_TOS((*pskb)->nh.iph->tos) |
-							RTO_CONN),
-#ifdef CONFIG_IP_ROUTE_FWMARK
-						.fwmark = (*pskb)->nfmark
-#endif
-					      } } };
-		if (ip_route_output_key(&rt, &fl) != 0) {
-			/* Funky routing can do this. */
-			if (net_ratelimit())
-				printk("MASQUERADE:"
-				       " No route: Rusty's brain broke!\n");
-			return NF_DROP;
-		}
-		if (rt->u.dst.dev != out) {
-			if (net_ratelimit())
-				printk("MASQUERADE:"
-				       " Route sent us somewhere else.\n");
-			ip_rt_put(rt);
-			return NF_DROP;
-		}
+	newsrc = inet_select_addr(out, 0, RT_SCOPE_UNIVERSE);
+	if (!newsrc) {
+		printk("MASQUERADE: %s ate my IP address\n", out->name);
+		return NF_DROP;
 	}
 
-	newsrc = rt->rt_src;
-	DEBUGP("newsrc = %u.%u.%u.%u\n", NIPQUAD(newsrc));
-	ip_rt_put(rt);
-
 	WRITE_LOCK(&masq_lock);
 	ct->nat.masq_index = out->ifindex;
 	WRITE_UNLOCK(&masq_lock);
@@ -157,6 +132,18 @@ device_cmp(const struct ip_conntrack *i,
 	return ret;
 }
 
+static inline int
+connect_unassure(const struct ip_conntrack *i, void *_ina)
+{
+	struct in_ifaddr *ina = _ina;
+
+	/* We reset the ASSURED bit on all connections, so they will
+	 * get reaped under memory pressure. */
+	if (i->nat.masq_index == ina->ifa_dev->dev->ifindex)
+		clear_bit(IPS_ASSURED_BIT, (unsigned long *)&i->status);
+	return 0;
+}
+
 static int masq_inet_event(struct notifier_block *this,
 			   unsigned long event,
 			   void *ptr)
@@ -166,6 +153,8 @@ static int masq_inet_event(struct notifi
 	 * entries. */
 	if (event == NETDEV_UP)
 		ip_ct_selective_cleanup(device_cmp, ptr);
+	else if (event == NETDEV_DOWN)
+		ip_ct_selective_cleanup(connect_unassure, ptr);
 
 	return NOTIFY_DONE;
 }

-- 
Anyone who quotes me in their signature is an idiot -- Rusty Russell
