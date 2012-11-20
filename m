From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 7/7] netprio_cgroup: allow nesting and inherit config on
	cgroup creation
Date: Tue, 20 Nov 2012 00:30:11 -0800
Message-ID: <1353400211-5182-8-git-send-email-tj@kernel.org>
References: <1353400211-5182-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353400211-5182-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Inherit netprio configuration from ->css_online(), allow nesting and
remove .broken_hierarchy marking.  This makes netprio_cgroup's
behavior match netcls_cgroup's.

Note that this patch changes userland-visible behavior.  Nesting is
allowed and the first level cgroups below the root cgroup behave
differently - they inherit priorities from the root cgroup on creation
instead of starting with 0.  This is unfortunate but not doing so is
much crazier.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 Documentation/cgroups/net_prio.txt |  2 ++
 net/core/netprio_cgroup.c          | 42 ++++++++++++++++++++++----------------
 2 files changed, 26 insertions(+), 18 deletions(-)

diff --git a/Documentation/cgroups/net_prio.txt b/Documentation/cgroups/net_prio.txt
index 01b3226..a82cbd2 100644
--- a/Documentation/cgroups/net_prio.txt
+++ b/Documentation/cgroups/net_prio.txt
@@ -51,3 +51,5 @@ One usage for the net_prio cgroup is with mqprio qdisc allowing application
 traffic to be steered to hardware/driver based traffic classes. These mappings
 can then be managed by administrators or other networking protocols such as
 DCBX.
+
+A new net_prio cgroup inherits the parent's configuration.
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index b2af0d0..bde53da 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -136,9 +136,6 @@ static struct cgroup_subsys_state *cgrp_css_alloc(struct cgroup *cgrp)
 {
 	struct cgroup_netprio_state *cs;
 
-	if (cgrp->parent && cgrp->parent->id)
-		return ERR_PTR(-EINVAL);
-
 	cs = kzalloc(sizeof(*cs), GFP_KERNEL);
 	if (!cs)
 		return ERR_PTR(-ENOMEM);
@@ -146,16 +143,34 @@ static struct cgroup_subsys_state *cgrp_css_alloc(struct cgroup *cgrp)
 	return &cs->css;
 }
 
-static void cgrp_css_free(struct cgroup *cgrp)
+static int cgrp_css_online(struct cgroup *cgrp)
 {
-	struct cgroup_netprio_state *cs = cgrp_netprio_state(cgrp);
+	struct cgroup *parent = cgrp->parent;
 	struct net_device *dev;
+	int ret = 0;
+
+	if (!parent)
+		return 0;
 
 	rtnl_lock();
-	for_each_netdev(&init_net, dev)
-		WARN_ON_ONCE(netprio_set_prio(cgrp, dev, 0));
+	/*
+	 * Inherit prios from the parent.  As all prios are set during
+	 * onlining, there is no need to clear them on offline.
+	 */
+	for_each_netdev(&init_net, dev) {
+		u32 prio = netprio_prio(parent, dev);
+
+		ret = netprio_set_prio(cgrp, dev, prio);
+		if (ret)
+			break;
+	}
 	rtnl_unlock();
-	kfree(cs);
+	return ret;
+}
+
+static void cgrp_css_free(struct cgroup *cgrp)
+{
+	kfree(cgrp_netprio_state(cgrp));
 }
 
 static u64 read_prioidx(struct cgroup *cgrp, struct cftype *cft)
@@ -237,21 +252,12 @@ static struct cftype ss_files[] = {
 struct cgroup_subsys net_prio_subsys = {
 	.name		= "net_prio",
 	.css_alloc	= cgrp_css_alloc,
+	.css_online	= cgrp_css_online,
 	.css_free	= cgrp_css_free,
 	.attach		= net_prio_attach,
 	.subsys_id	= net_prio_subsys_id,
 	.base_cftypes	= ss_files,
 	.module		= THIS_MODULE,
-
-	/*
-	 * net_prio has artificial limit on the number of cgroups and
-	 * disallows nesting making it impossible to co-mount it with other
-	 * hierarchical subsystems.  Remove the artificially low PRIOIDX_SZ
-	 * limit and properly nest configuration such that children follow
-	 * their parents' configurations by default and are allowed to
-	 * override and remove the following.
-	 */
-	.broken_hierarchy = true,
 };
 
 static int netprio_device_event(struct notifier_block *unused,
-- 
1.7.11.7
