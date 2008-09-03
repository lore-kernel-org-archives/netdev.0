From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: tipc on sparc32
Date: Tue, 2 Sep 2008 23:46:45 -0700
Message-ID: <20080902234645.7fd16229.akpm@linux-foundation.org>
References: <20080902224059.70a182ba.akpm@linux-foundation.org>
	<20080902.231201.184658566.davem@davemloft.net>
	<20080902.232627.209816179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20080902.232627.209816179.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Sender: tipc-discussion-bounces@lists.sourceforge.net
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 02 Sep 2008 23:26:27 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: David Miller <davem@davemloft.net>
> Date: Tue, 02 Sep 2008 23:12:01 -0700 (PDT)
> 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Date: Tue, 2 Sep 2008 22:40:59 -0700
> > 
> > > sparc32 allmodconfig:
> > > 
> > > In file included from net/tipc/link.h:43,
> > >                  from net/tipc/bcast.c:41:
> > > net/tipc/node.h:71: error: redefinition of 'struct node'
> > > 
> > > sparc32 likes catching code which uses insufficiently cautiously chosen
> > > identifiers.  dlm is presently blowing up on sparc32 because it has a
> > > to_node() function.
> > > 
> > > Arguably, sparc32 should be fixed, but I'd suggest that random bits of
> > > networking code should not be using identifiers as generic-sounding as "node".
> > 
> > I'll fix sparc for the time being, thanks.
> 
> Actually, the conflict is between the include/linux/node.h which the
> generic device layer uses, and TIPC.
> 
> This isn't a sparc specific problem.
> 
> And the DLM issue is the same thing.
> 
> It might be triggering on sparc32 because linux/node.h gets included
> in the tangle of arch and non-arch include files that happen during
> the build, but that's benign as far as blaming sparc is concerned.
> 
> I can take care of TIPC.

OK.

> Andrew can you take a stab at DLM?

dlm had a `node' a few weeks ago, that got fixed.


I fixed the new `to_node' build problem today like this:

From: Andrew Morton <akpm@linux-foundation.org>

sparc32:

fs/dlm/config.c:397: error: expected identifier or '(' before '{' token
fs/dlm/config.c: In function 'drop_node':
fs/dlm/config.c:589: warning: initialization from incompatible pointer type
fs/dlm/config.c:589: warning: initialization from incompatible pointer type
fs/dlm/config.c: In function 'release_node':
fs/dlm/config.c:601: warning: initialization from incompatible pointer type
fs/dlm/config.c:601: warning: initialization from incompatible pointer type
fs/dlm/config.c: In function 'show_node':
fs/dlm/config.c:717: warning: initialization from incompatible pointer type
fs/dlm/config.c:717: warning: initialization from incompatible pointer type
fs/dlm/config.c: In function 'store_node':
fs/dlm/config.c:726: warning: initialization from incompatible pointer type
fs/dlm/config.c:726: warning: initialization from incompatible pointer type

Cc: Christine Caulfield <ccaulfie@redhat.com>
Cc: David Teigland <teigland@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/dlm/config.c |   44 ++++++++++++++++++++++----------------------
 1 file changed, 22 insertions(+), 22 deletions(-)

diff -puN fs/dlm/config.c~fs-dlm-configc-choose-better-identifiers fs/dlm/config.c
--- a/fs/dlm/config.c~fs-dlm-configc-choose-better-identifiers
+++ a/fs/dlm/config.c
@@ -377,24 +377,24 @@ static struct config_item_type node_type
 	.ct_owner = THIS_MODULE,
 };
 
-static struct dlm_cluster *to_cluster(struct config_item *i)
+static struct dlm_cluster *config_item_to_cluster(struct config_item *i)
 {
 	return i ? container_of(to_config_group(i), struct dlm_cluster, group) :
 		   NULL;
 }
 
-static struct dlm_space *to_space(struct config_item *i)
+static struct dlm_space *config_item_to_space(struct config_item *i)
 {
 	return i ? container_of(to_config_group(i), struct dlm_space, group) :
 		   NULL;
 }
 
-static struct dlm_comm *to_comm(struct config_item *i)
+static struct dlm_comm *config_item_to_comm(struct config_item *i)
 {
 	return i ? container_of(i, struct dlm_comm, item) : NULL;
 }
 
-static struct dlm_node *to_node(struct config_item *i)
+static struct dlm_node *config_item_to_node(struct config_item *i)
 {
 	return i ? container_of(i, struct dlm_node, item) : NULL;
 }
@@ -450,7 +450,7 @@ static struct config_group *make_cluster
 
 static void drop_cluster(struct config_group *g, struct config_item *i)
 {
-	struct dlm_cluster *cl = to_cluster(i);
+	struct dlm_cluster *cl = config_item_to_cluster(i);
 	struct config_item *tmp;
 	int j;
 
@@ -468,7 +468,7 @@ static void drop_cluster(struct config_g
 
 static void release_cluster(struct config_item *i)
 {
-	struct dlm_cluster *cl = to_cluster(i);
+	struct dlm_cluster *cl = config_item_to_cluster(i);
 	kfree(cl->group.default_groups);
 	kfree(cl);
 }
@@ -507,7 +507,7 @@ static struct config_group *make_space(s
 
 static void drop_space(struct config_group *g, struct config_item *i)
 {
-	struct dlm_space *sp = to_space(i);
+	struct dlm_space *sp = config_item_to_space(i);
 	struct config_item *tmp;
 	int j;
 
@@ -524,7 +524,7 @@ static void drop_space(struct config_gro
 
 static void release_space(struct config_item *i)
 {
-	struct dlm_space *sp = to_space(i);
+	struct dlm_space *sp = config_item_to_space(i);
 	kfree(sp->group.default_groups);
 	kfree(sp);
 }
@@ -546,7 +546,7 @@ static struct config_item *make_comm(str
 
 static void drop_comm(struct config_group *g, struct config_item *i)
 {
-	struct dlm_comm *cm = to_comm(i);
+	struct dlm_comm *cm = config_item_to_comm(i);
 	if (local_comm == cm)
 		local_comm = NULL;
 	dlm_lowcomms_close(cm->nodeid);
@@ -557,13 +557,13 @@ static void drop_comm(struct config_grou
 
 static void release_comm(struct config_item *i)
 {
-	struct dlm_comm *cm = to_comm(i);
+	struct dlm_comm *cm = config_item_to_comm(i);
 	kfree(cm);
 }
 
 static struct config_item *make_node(struct config_group *g, const char *name)
 {
-	struct dlm_space *sp = to_space(g->cg_item.ci_parent);
+	struct dlm_space *sp = config_item_to_space(g->cg_item.ci_parent);
 	struct dlm_node *nd;
 
 	nd = kzalloc(sizeof(struct dlm_node), GFP_KERNEL);
@@ -585,8 +585,8 @@ static struct config_item *make_node(str
 
 static void drop_node(struct config_group *g, struct config_item *i)
 {
-	struct dlm_space *sp = to_space(g->cg_item.ci_parent);
-	struct dlm_node *nd = to_node(i);
+	struct dlm_space *sp = config_item_to_space(g->cg_item.ci_parent);
+	struct dlm_node *nd = config_item_to_node(i);
 
 	mutex_lock(&sp->members_lock);
 	list_del(&nd->list);
@@ -598,7 +598,7 @@ static void drop_node(struct config_grou
 
 static void release_node(struct config_item *i)
 {
-	struct dlm_node *nd = to_node(i);
+	struct dlm_node *nd = config_item_to_node(i);
 	kfree(nd);
 }
 
@@ -632,7 +632,7 @@ void dlm_config_exit(void)
 static ssize_t show_cluster(struct config_item *i, struct configfs_attribute *a,
 			    char *buf)
 {
-	struct dlm_cluster *cl = to_cluster(i);
+	struct dlm_cluster *cl = config_item_to_cluster(i);
 	struct cluster_attribute *cla =
 			container_of(a, struct cluster_attribute, attr);
 	return cla->show ? cla->show(cl, buf) : 0;
@@ -642,7 +642,7 @@ static ssize_t store_cluster(struct conf
 			     struct configfs_attribute *a,
 			     const char *buf, size_t len)
 {
-	struct dlm_cluster *cl = to_cluster(i);
+	struct dlm_cluster *cl = config_item_to_cluster(i);
 	struct cluster_attribute *cla =
 		container_of(a, struct cluster_attribute, attr);
 	return cla->store ? cla->store(cl, buf, len) : -EINVAL;
@@ -651,7 +651,7 @@ static ssize_t store_cluster(struct conf
 static ssize_t show_comm(struct config_item *i, struct configfs_attribute *a,
 			 char *buf)
 {
-	struct dlm_comm *cm = to_comm(i);
+	struct dlm_comm *cm = config_item_to_comm(i);
 	struct comm_attribute *cma =
 			container_of(a, struct comm_attribute, attr);
 	return cma->show ? cma->show(cm, buf) : 0;
@@ -660,7 +660,7 @@ static ssize_t show_comm(struct config_i
 static ssize_t store_comm(struct config_item *i, struct configfs_attribute *a,
 			  const char *buf, size_t len)
 {
-	struct dlm_comm *cm = to_comm(i);
+	struct dlm_comm *cm = config_item_to_comm(i);
 	struct comm_attribute *cma =
 		container_of(a, struct comm_attribute, attr);
 	return cma->store ? cma->store(cm, buf, len) : -EINVAL;
@@ -714,7 +714,7 @@ static ssize_t comm_addr_write(struct dl
 static ssize_t show_node(struct config_item *i, struct configfs_attribute *a,
 			 char *buf)
 {
-	struct dlm_node *nd = to_node(i);
+	struct dlm_node *nd = config_item_to_node(i);
 	struct node_attribute *nda =
 			container_of(a, struct node_attribute, attr);
 	return nda->show ? nda->show(nd, buf) : 0;
@@ -723,7 +723,7 @@ static ssize_t show_node(struct config_i
 static ssize_t store_node(struct config_item *i, struct configfs_attribute *a,
 			  const char *buf, size_t len)
 {
-	struct dlm_node *nd = to_node(i);
+	struct dlm_node *nd = config_item_to_node(i);
 	struct node_attribute *nda =
 		container_of(a, struct node_attribute, attr);
 	return nda->store ? nda->store(nd, buf, len) : -EINVAL;
@@ -768,7 +768,7 @@ static struct dlm_space *get_space(char 
 	i = config_group_find_item(space_list, name);
 	mutex_unlock(&space_list->cg_subsys->su_mutex);
 
-	return to_space(i);
+	return config_item_to_space(i);
 }
 
 static void put_space(struct dlm_space *sp)
@@ -788,7 +788,7 @@ static struct dlm_comm *get_comm(int nod
 	mutex_lock(&clusters_root.subsys.su_mutex);
 
 	list_for_each_entry(i, &comm_list->cg_children, ci_entry) {
-		cm = to_comm(i);
+		cm = config_item_to_comm(i);
 
 		if (nodeid) {
 			if (cm->nodeid != nodeid)
_


-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
