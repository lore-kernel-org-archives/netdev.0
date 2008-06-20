From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH net-next 4/8] bridge: sysfs cleanup
Date: Fri, 20 Jun 2008 12:48:44 +0800
Message-ID: <485B36AC.60206@cn.fujitsu.com>
References: <485AFFF3.6070802@cn.fujitsu.com> <20080619181945.2b242e4d@extreme> <485B133E.9080307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63423 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751945AbYFTEwu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 00:52:50 -0400
In-Reply-To: <485B133E.9080307@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen said the following on 2008-6-20 10:17:
> Stephen Hemminger said the following on 2008-6-20 9:19:
>> On Fri, 20 Jun 2008 08:55:15 +0800
>> Wang Chen <wangchen@cn.fujitsu.com> wrote:
>>
>>> When I am doing this series of patch, I notice that bridge's sysfs are
>>> not cleanuped after failure and bridge delete.
>>>
>>> Here is the patch for it.
>>>
>>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
>> Let me look at this, I don't think it used to be a problem before the
>> conversion from class_device to just device model.
>>
> 
> But, sysfs_create_link/file will leave some junk after failing.
> Don't we care about that?
> 

Stephen, since I changed PATCH 3/8, I have to resend a new one for
4/8.
But, about whether this fix is needed, we can talk.

---
Do sysfs cleanup after failure and bridge deleting.

---
 net/bridge/br_if.c       |    2 ++
 net/bridge/br_private.h  |    2 ++
 net/bridge/br_sysfs_if.c |   26 +++++++++++++++++++++++++-
 3 files changed, 29 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 805dbb7..5d22d23 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -161,6 +161,7 @@ static void del_br(struct net_bridge *br)
 	struct net_bridge_port *p, *n;
 
 	list_for_each_entry_safe(p, n, &br->port_list, list) {
+		br_sysfs_removeif(p);
 		del_nbp(p);
 	}
 
@@ -434,6 +435,7 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 	if (!p || p->br != br)
 		return -EINVAL;
 
+	br_sysfs_removeif(p);
 	del_nbp(p);
 
 	spin_lock_bh(&br->lock);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index c11b554..c1bbfea 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -250,6 +250,7 @@ extern void br_ifinfo_notify(int event, struct net_bridge_port *port);
 /* br_sysfs_if.c */
 extern struct sysfs_ops brport_sysfs_ops;
 extern int br_sysfs_addif(struct net_bridge_port *p);
+extern void br_sysfs_removeif(struct net_bridge_port *p);
 
 /* br_sysfs_br.c */
 extern int br_sysfs_addbr(struct net_device *dev);
@@ -258,6 +259,7 @@ extern void br_sysfs_delbr(struct net_device *dev);
 #else
 
 #define br_sysfs_addif(p)	(0)
+#define br_sysfs_removeif(p)	do { } while (0)
 #define br_sysfs_addbr(dev)	(0)
 #define br_sysfs_delbr(dev)	do { } while(0)
 #endif /* CONFIG_SYSFS */
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 02b2d50..9e9d17c 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -226,10 +226,34 @@ int br_sysfs_addif(struct net_bridge_port *p)
 	for (a = brport_attrs; *a; ++a) {
 		err = sysfs_create_file(&p->kobj, &((*a)->attr));
 		if (err)
-			goto out2;
+			goto out1;
 	}
 
 	err = sysfs_create_link(br->ifobj, &p->kobj, p->dev->name);
+	if (err)
+		goto out1;
+	return 0;
+out1:
+	for (a = brport_attrs; *a; ++a)
+		sysfs_remove_file(&p->kobj, &((*a)->attr));
+	sysfs_remove_link(&br->dev->dev.kobj, SYSFS_BRIDGE_PORT_LINK);
 out2:
 	return err;
 }
+
+/*
+ * Remove sysfs entries of ethernet device added to a bridge.
+ * Revert all the things be done by br_sysfs_addif().
+ */
+void br_sysfs_removeif(struct net_bridge_port *p)
+{
+	struct net_bridge *br = p->br;
+	struct brport_attribute **a;
+
+	sysfs_remove_link(&p->kobj, p->dev->name);
+
+	for (a = brport_attrs; *a; ++a)
+		sysfs_remove_file(&p->kobj, &((*a)->attr));
+
+	sysfs_remove_link(&br->dev->dev.kobj, SYSFS_BRIDGE_PORT_LINK);
+}
-- 
1.5.3.4

