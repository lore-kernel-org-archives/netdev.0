From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/2] net caif:  Register properly as a pernet subsystem.
Date: Thu, 26 Jan 2012 16:04:53 -0800
Message-ID: <m1aa5ac8nu.fsf_-_@fess.ebiederm.org>
References: <4F212E7E.2040801@parallels.com>
	<1327575108.2500.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<m1zkdacbsx.fsf@fess.ebiederm.org>
	<20120126.180754.679593869814492219.davem@davemloft.net>
	<m1ehumc8r4.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, xemul@parallels.com,
	sjur.brandeland@stericsson.com, levinsasha928@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davej@redhat.com, sjurbren@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1ehumc8r4.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 26 Jan 2012 16:02:55 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


caif is a subsystem and as such it needs to register with
register_pernet_subsys instead of register_pernet_device.

Among other problems using register_pernet_device was resulting in
net_generic being called before the caif_net structure was allocated.
Which has been causing net_generic to fail with either BUG_ON's or by
return NULL pointers.

A more ugly problem that could be caused is packets in flight why the
subsystem is shutting down.

To remove confusion also remove the cruft cause by inappropriately
trying to fix this bug.

With the aid of the previous patch I have tested this patch and
confirmed that using register_pernet_subsys makes the failure go away as
it should.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/caif/caif_dev.c |   22 ++--------------------
 net/caif/cfcnfg.c   |    1 -
 2 files changed, 2 insertions(+), 21 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 673728a..82c5706 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -59,8 +59,6 @@ struct cfcnfg *get_cfcnfg(struct net *net)
 {
 	struct caif_net *caifn;
 	caifn = net_generic(net, caif_net_id);
-	if (!caifn)
-		return NULL;
 	return caifn->cfg;
 }
 EXPORT_SYMBOL(get_cfcnfg);
@@ -69,8 +67,6 @@ static struct caif_device_entry_list *caif_device_list(struct net *net)
 {
 	struct caif_net *caifn;
 	caifn = net_generic(net, caif_net_id);
-	if (!caifn)
-		return NULL;
 	return &caifn->caifdevs;
 }
 
@@ -99,8 +95,6 @@ static struct caif_device_entry *caif_device_alloc(struct net_device *dev)
 	struct caif_device_entry *caifd;
 
 	caifdevs = caif_device_list(dev_net(dev));
-	if (!caifdevs)
-		return NULL;
 
 	caifd = kzalloc(sizeof(*caifd), GFP_KERNEL);
 	if (!caifd)
@@ -120,8 +114,6 @@ static struct caif_device_entry *caif_get(struct net_device *dev)
 	struct caif_device_entry_list *caifdevs =
 	    caif_device_list(dev_net(dev));
 	struct caif_device_entry *caifd;
-	if (!caifdevs)
-		return NULL;
 
 	list_for_each_entry_rcu(caifd, &caifdevs->list, list) {
 		if (caifd->netdev == dev)
@@ -321,8 +313,6 @@ void caif_enroll_dev(struct net_device *dev, struct caif_dev_common *caifdev,
 	struct caif_device_entry_list *caifdevs;
 
 	caifdevs = caif_device_list(dev_net(dev));
-	if (!cfg || !caifdevs)
-		return;
 	caifd = caif_device_alloc(dev);
 	if (!caifd)
 		return;
@@ -374,8 +364,6 @@ static int caif_device_notify(struct notifier_block *me, unsigned long what,
 
 	cfg = get_cfcnfg(dev_net(dev));
 	caifdevs = caif_device_list(dev_net(dev));
-	if (!cfg || !caifdevs)
-		return 0;
 
 	caifd = caif_get(dev);
 	if (caifd == NULL && dev->type != ARPHRD_CAIF)
@@ -507,9 +495,6 @@ static struct notifier_block caif_device_notifier = {
 static int caif_init_net(struct net *net)
 {
 	struct caif_net *caifn = net_generic(net, caif_net_id);
-	if (WARN_ON(!caifn))
-		return -EINVAL;
-
 	INIT_LIST_HEAD(&caifn->caifdevs.list);
 	mutex_init(&caifn->caifdevs.lock);
 
@@ -527,9 +512,6 @@ static void caif_exit_net(struct net *net)
 	    caif_device_list(net);
 	struct cfcnfg *cfg =  get_cfcnfg(net);
 
-	if (!cfg || !caifdevs)
-		return;
-
 	rtnl_lock();
 	mutex_lock(&caifdevs->lock);
 
@@ -569,7 +551,7 @@ static int __init caif_device_init(void)
 {
 	int result;
 
-	result = register_pernet_device(&caif_net_ops);
+	result = register_pernet_subsys(&caif_net_ops);
 
 	if (result)
 		return result;
@@ -582,7 +564,7 @@ static int __init caif_device_init(void)
 
 static void __exit caif_device_exit(void)
 {
-	unregister_pernet_device(&caif_net_ops);
+	unregister_pernet_subsys(&caif_net_ops);
 	unregister_netdevice_notifier(&caif_device_notifier);
 	dev_remove_pack(&caif_packet_type);
 }
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index 598aafb..ba9cfd4 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -309,7 +309,6 @@ int caif_connect_client(struct net *net, struct caif_connect_request *conn_req,
 	int err;
 	struct cfctrl_link_param param;
 	struct cfcnfg *cfg = get_cfcnfg(net);
-	caif_assert(cfg != NULL);
 
 	rcu_read_lock();
 	err = caif_connect_req_to_link_param(cfg, conn_req, &param);
-- 
1.7.2.5
