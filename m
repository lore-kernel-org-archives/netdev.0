From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC/PATCH] Convert architecture dependent rtnetlink attribute to fixed sized ones
Date: Tue, 24 Aug 2004 22:47:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824204704.GM21296@postel.suug.ch>
References: <20040824094952.GF21073@postel.suug.ch> <E1BzYMJ-000208-00@gondolin.me.apana.org.au> <20040824120442.GA21296@postel.suug.ch> <20040824103205.1ea9c999.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040824103205.1ea9c999.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20040824103205.1ea9c999.davem@redhat.com> 2004-08-24 10:32
> Because otherwise things will break and explode for 32-bit
> binaries running on 64-bit kernels, which is the situation
> for the majority of userland on some platforms.

Below is a patch which fixes some of the obvious architecture
dependent and easy to fix attributes. But there are dozens more of
them such as the int in struct tcf_police.

Is it really worth changing all of them and probably a few
userspace applications just to make it easier for them because
they won't have to check size for some of the attributes
anymore? On top of that, most of the ...->rta_len !=
RTA_LENGTH(struct XXX) checks in RTM_* handlers will fail anyway
if there is a int-size mismatch between kernel and userspace.

--- 1.17/net/sched/sch_atm.c	Sat Feb 21 03:48:58 2004
+++ 1.18/net/sched/sch_atm.c	Tue Aug 24 22:19:23 2004
@@ -639,7 +639,7 @@
 	RTA_PUT(skb,TCA_ATM_HDR,flow->hdr_len,flow->hdr);
 	if (flow->vcc) {
 		struct sockaddr_atmpvc pvc;
-		int state;
+		u32 state;
 
 		pvc.sap_family = AF_ATMPVC;
 		pvc.sap_addr.itf = flow->vcc->dev ? flow->vcc->dev->number : -1;

--- 1.4/net/sched/police.c	Sun Sep 28 19:00:40 2003
+++ 1.5/net/sched/police.c	Tue Aug 24 22:19:23 2004
@@ -237,8 +237,10 @@
 	else
 		memset(&opt.peakrate, 0, sizeof(opt.peakrate));
 	RTA_PUT(skb, TCA_POLICE_TBF, sizeof(opt), &opt);
-	if (p->result)
-		RTA_PUT(skb, TCA_POLICE_RESULT, sizeof(int), &p->result);
+	if (p->result) {
+		u32 result = p->result;
+		RTA_PUT(skb, TCA_POLICE_RESULT, sizeof(u32), &result);
+	}
 #ifdef CONFIG_NET_ESTIMATOR
 	if (p->ewma_rate)
 		RTA_PUT(skb, TCA_POLICE_AVRATE, 4, &p->ewma_rate);

--- 1.7/net/sched/cls_tcindex.c	Sat Feb 21 03:37:25 2004
+++ 1.8/net/sched/cls_tcindex.c	Tue Aug 24 22:19:23 2004
@@ -432,12 +432,15 @@
 	rta = (struct rtattr *) b;
 	RTA_PUT(skb,TCA_OPTIONS,0,NULL);
 	if (!fh) {
+		u32 hash = p->hash;
+		u32 shift = p->shift;
+		u32 fall_through = p->fall_through;
 		t->tcm_handle = ~0; /* whatever ... */
-		RTA_PUT(skb,TCA_TCINDEX_HASH,sizeof(p->hash),&p->hash);
+		RTA_PUT(skb,TCA_TCINDEX_HASH,sizeof(u32),&hash);
 		RTA_PUT(skb,TCA_TCINDEX_MASK,sizeof(p->mask),&p->mask);
-		RTA_PUT(skb,TCA_TCINDEX_SHIFT,sizeof(p->shift),&p->shift);
-		RTA_PUT(skb,TCA_TCINDEX_FALL_THROUGH,sizeof(p->fall_through),
-		    &p->fall_through);
+		RTA_PUT(skb,TCA_TCINDEX_SHIFT,sizeof(u32),&shift);
+		RTA_PUT(skb,TCA_TCINDEX_FALL_THROUGH,sizeof(u32),
+		    &fall_through);
 	} else {
 		if (p->perfect) {
 			t->tcm_handle = r-p->perfect;

--- 1.7/net/sched/cls_route.c	Sat Feb 21 03:37:25 2004
+++ 1.8/net/sched/cls_route.c	Tue Aug 24 22:19:23 2004
@@ -567,8 +567,10 @@
 		RTA_PUT(skb, TCA_ROUTE4_TO, sizeof(id), &id);
 	}
 	if (f->handle&0x80000000) {
-		if ((f->handle>>16) != 0xFFFF)
-			RTA_PUT(skb, TCA_ROUTE4_IIF, sizeof(f->iif), &f->iif);
+		if ((f->handle>>16) != 0xFFFF) {
+			u32 iif = f->iif;
+			RTA_PUT(skb, TCA_ROUTE4_IIF, sizeof(u32), &iif);
+		}
 	} else {
 		id = f->id>>16;
 		RTA_PUT(skb, TCA_ROUTE4_FROM, sizeof(id), &id);

--- 1.67/net/ipv6/route.c	Tue Feb 24 00:11:22 2004
+++ 1.68/net/ipv6/route.c	Tue Aug 24 22:19:23 2004
@@ -1532,8 +1532,10 @@
 		goto rtattr_failure;
 	if (rt->u.dst.neighbour)
 		RTA_PUT(skb, RTA_GATEWAY, 16, &rt->u.dst.neighbour->primary_key);
-	if (rt->u.dst.dev)
-		RTA_PUT(skb, RTA_OIF, sizeof(int), &rt->rt6i_dev->ifindex);
+	if (rt->u.dst.dev) {
+		u32 oif = rt->rt6i_dev->ifindex;
+		RTA_PUT(skb, RTA_OIF, sizeof(u32), &oif);
+	}
 	RTA_PUT(skb, RTA_PRIORITY, 4, &rt->rt6i_metric);
 	ci.rta_lastuse = jiffies_to_clock_t(jiffies - rt->u.dst.lastuse);
 	if (rt->rt6i_expires)

--- 1.98/net/ipv6/addrconf.c	Mon Apr  5 23:41:40 2004
+++ 1.99/net/ipv6/addrconf.c	Tue Aug 24 22:19:23 2004
@@ -2819,8 +2819,10 @@
 		RTA_PUT(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr);
 
 	RTA_PUT(skb, IFLA_MTU, sizeof(mtu), &mtu);
-	if (dev->ifindex != dev->iflink)
-		RTA_PUT(skb, IFLA_LINK, sizeof(int), &dev->iflink);
+	if (dev->ifindex != dev->iflink) {
+		u32 link = dev->iflink;
+		RTA_PUT(skb, IFLA_LINK, sizeof(u32), &link);
+	}
 			
 	subattr = (struct rtattr*)skb->tail;
 

--- 1.80/net/ipv4/route.c	Fri Apr 30 01:26:35 2004
+++ 1.81/net/ipv4/route.c	Tue Aug 24 22:19:23 2004
@@ -2291,8 +2291,10 @@
 		r->rtm_src_len = 32;
 		RTA_PUT(skb, RTA_SRC, 4, &rt->fl.fl4_src);
 	}
-	if (rt->u.dst.dev)
-		RTA_PUT(skb, RTA_OIF, sizeof(int), &rt->u.dst.dev->ifindex);
+	if (rt->u.dst.dev) {
+		u32 oif = rt->u.dst.dev->ifindex;
+		RTA_PUT(skb, RTA_OIF, 4, &oif);
+	}
 #ifdef CONFIG_NET_CLS_ROUTE
 	if (rt->u.dst.tclassid)
 		RTA_PUT(skb, RTA_FLOW, 4, &rt->u.dst.tclassid);
@@ -2345,7 +2347,10 @@
 			}
 		} else
 #endif
-			RTA_PUT(skb, RTA_IIF, sizeof(int), &rt->fl.iif);
+		if (1) {
+			u32 iif = rt->fl.iif;
+			RTA_PUT(skb, RTA_IIF, sizeof(u32), &iif);
+		}
 	}
 
 	nlh->nlmsg_len = skb->tail - b;

--- 1.6/net/decnet/dn_table.c	Tue May  6 09:58:43 2003
+++ 1.7/net/decnet/dn_table.c	Tue Aug 24 22:19:23 2004
@@ -296,8 +296,10 @@
         if (fi->fib_nhs == 1) {
                 if (fi->fib_nh->nh_gw)
                         RTA_PUT(skb, RTA_GATEWAY, 2, &fi->fib_nh->nh_gw);
-                if (fi->fib_nh->nh_oif)
-                        RTA_PUT(skb, RTA_OIF, sizeof(int), &fi->fib_nh->nh_oif);
+                if (fi->fib_nh->nh_oif) {
+                        u32 oif = fi->fib_nh->nh_oif;
+                        RTA_PUT(skb, RTA_OIF, sizeof(u32), &oif);
+                }
         }
         if (fi->fib_nhs > 1) {
                 struct rtnexthop *nhp;
