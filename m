From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/1] net: neighbour: Simplify ifdefs around
 neigh_app_ns()
Date: Wed, 28 Aug 2013 18:26:08 -0700
Message-ID: <1377739568.1928.64.camel@joe-AO722>
References: <1377714286-51816-1-git-send-email-tim.gardner@canonical.com>
	 <1377715873.1928.47.camel@joe-AO722> <521E4AE6.7080703@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Gao feng <gaofeng@cn.fujitsu.com>
To: Tim Gardner <tim.gardner@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <521E4AE6.7080703@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-08-28 at 13:09 -0600, Tim Gardner wrote:
> On 08/28/2013 12:51 PM, Joe Perches wrote:
> > On Wed, 2013-08-28 at 12:24 -0600, Tim Gardner wrote:
> >> Drop a couple of ifdef/endif pairs by moving the ifdef
> >> surrounding neigh_app_ns() to the interior of neigh_app_ns().
> > []
> >> This is an admittedly trivial change. I stumbled on it while trying to figure
> >> out why Ubuntu doesn't have CONFIG_ARPD enabled.

> > I'd be more inclined to make neigh_app_ns static inline
> > in the .h file and remove the EXPORT_SYMBOL

> I thought about that as well, but then you'd have to extern
> __neigh_notify(), which is currently a static function and large enough
> to not really be suitable for inlining. Seems like unnecessary churn to me.

Hi Tim.

As is, this makes the call to neight_app_ns
impossible to optimize away.

Perhaps this:

(this does add a possibly unused neigh_notify as a global symbol)

Rename __neigh_notify to neigh_notify and make public
Add static inline neigh_app_ns
Remove #ifdefs around use of neigh_app_ns

---

Compile tested only

 include/net/neighbour.h | 10 +++++++++-
 net/core/neighbour.c    | 15 +++------------
 net/ipv4/arp.c          |  2 --
 net/ipv6/ndisc.c        |  2 --
 4 files changed, 12 insertions(+), 17 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 536501a..a08b0a7 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -249,7 +249,15 @@ static inline struct net *pneigh_net(const struct pneigh_entry *pneigh)
 	return read_pnet(&pneigh->net);
 }
 
-void neigh_app_ns(struct neighbour *n);
+void neigh_notify(struct neighbour *n, int type, int flags);
+
+static inline void neigh_app_ns(struct neighbour *n)
+{
+#ifdef CONFIG_ARPD
+	neigh_notify(n, RTM_GETNEIGH, NLM_F_REQUEST);
+#endif
+}
+
 void neigh_for_each(struct neigh_table *tbl,
 		    void (*cb)(struct neighbour *, void *), void *cookie);
 void __neigh_for_each_release(struct neigh_table *tbl,
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 60533db..6ec5f86 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -50,7 +50,6 @@ do {						\
 #define PNEIGH_HASHMASK		0xF
 
 static void neigh_timer_handler(unsigned long arg);
-static void __neigh_notify(struct neighbour *n, int type, int flags);
 static void neigh_update_notify(struct neighbour *neigh);
 static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
 
@@ -103,7 +102,7 @@ static void neigh_cleanup_and_release(struct neighbour *neigh)
 	if (neigh->parms->neigh_cleanup)
 		neigh->parms->neigh_cleanup(neigh);
 
-	__neigh_notify(neigh, RTM_DELNEIGH, 0);
+	neigh_notify(neigh, RTM_DELNEIGH, 0);
 	neigh_release(neigh);
 }
 
@@ -2215,7 +2214,7 @@ nla_put_failure:
 static void neigh_update_notify(struct neighbour *neigh)
 {
 	call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, neigh);
-	__neigh_notify(neigh, RTM_NEWNEIGH, 0);
+	neigh_notify(neigh, RTM_NEWNEIGH, 0);
 }
 
 static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
@@ -2735,7 +2734,7 @@ static inline size_t neigh_nlmsg_size(void)
 	       + nla_total_size(4); /* NDA_PROBES */
 }
 
-static void __neigh_notify(struct neighbour *n, int type, int flags)
+void neigh_notify(struct neighbour *n, int type, int flags)
 {
 	struct net *net = dev_net(n->dev);
 	struct sk_buff *skb;
@@ -2759,14 +2758,6 @@ errout:
 		rtnl_set_sk_err(net, RTNLGRP_NEIGH, err);
 }
 
-#ifdef CONFIG_ARPD
-void neigh_app_ns(struct neighbour *n)
-{
-	__neigh_notify(n, RTM_GETNEIGH, NLM_F_REQUEST);
-}
-EXPORT_SYMBOL(neigh_app_ns);
-#endif /* CONFIG_ARPD */
-
 #ifdef CONFIG_SYSCTL
 static int zero;
 static int int_max = INT_MAX;
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 4429b01..7808093 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -368,9 +368,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	} else {
 		probes -= neigh->parms->app_probes;
 		if (probes < 0) {
-#ifdef CONFIG_ARPD
 			neigh_app_ns(neigh);
-#endif
 			return;
 		}
 	}
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 04d31c2..d5693ad 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -663,9 +663,7 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 		}
 		ndisc_send_ns(dev, neigh, target, target, saddr);
 	} else if ((probes -= neigh->parms->app_probes) < 0) {
-#ifdef CONFIG_ARPD
 		neigh_app_ns(neigh);
-#endif
 	} else {
 		addrconf_addr_solict_mult(target, &mcaddr);
 		ndisc_send_ns(dev, NULL, target, &mcaddr, saddr);
