From: Dan Aloni <da-x@gmx.net>
Subject: Re: [BK PATCH 2.6] repost, fix sysctl breakage during network device renaming, for ipv4
Date: Fri, 17 Oct 2003 23:32:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031017213235.GA5278@callisto.yi.org>
References: <20030901164624.GA26886@callisto.yi.org> <20030901094127.6a0f6878.davem@redhat.com> <20030901165559.GA27099@callisto.yi.org> <20030901113143.1ba34464.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030901113143.1ba34464.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 01, 2003 at 11:31:43AM -0700, David S. Miller wrote:
> On Mon, 1 Sep 2003 19:55:59 +0300
> Dan Aloni <da-x@gmx.net> wrote:
> 
> > The private copy of strdup() is something that I'd also wouldn't
> > want, but I don't have much choice. Please read a recent 
> > thread in lkml regarding strdup() consolidation.
> 
> Ugh, I'm afraid to look...  I guess the controversy is
> over the allocation function, what GFP_* flags it should
> use etc.?
> 
> For now just call the thing in your patch netdev_name_dup() or
> something like that.  I can't handle having something named
> "strdup()" in there :-)

Here is the patch. I've compiled and tested it.


You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1292, 2003-10-17 22:39:48+02:00, da-x@gmx.net
  Sysctl assumes its ctl_table.procname field is const, but the 
  networking points ctl_table.procname to dev->name. When renaming 
  a network device using SIOCSIFNAME, dev->name is modified and 
  sysctl's assumption breaks, causing this behaviour, at least:
  
    1. sysctl wouldn't be able to remove the proc entry when the 
       device requests to be unregistered, because it would be 
       using the new name instead of the old one.
    2. proc entries for devices remain with the old name after 
       rename.
    
  This change includes allocating the current device name to a
  new copy upon registering with sysctl, plus re-registering with 
  sysctl when the device is renamed.
  
  This only fixes IPv4, IPv6, and net/core/neightbour.c.
  Fixes for ax25 and decnet are also planned.


 include/linux/netdevice.h  |    3 +++
 net/core/neighbour.c       |   29 ++++++++++++++++++++++++++---
 net/core/sysctl_net_core.c |   13 +++++++++++++
 net/ipv4/devinet.c         |   40 +++++++++++++++++++++++++++++++++++-----
 net/ipv6/addrconf.c        |   37 ++++++++++++++++++++++++++++++++++---
 5 files changed, 111 insertions(+), 11 deletions(-)


diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	Fri Oct 17 22:40:18 2003
+++ b/include/linux/netdevice.h	Fri Oct 17 22:40:18 2003
@@ -869,6 +869,9 @@
 extern void		dev_clear_fastroute(struct net_device *dev);
 #endif
 
+#ifdef CONFIG_SYSCTL
+extern char *net_sysctl_strdup(const char *s);
+#endif
 
 #endif /* __KERNEL__ */
 
diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	Fri Oct 17 22:40:18 2003
+++ b/net/core/neighbour.c	Fri Oct 17 22:40:18 2003
@@ -1627,6 +1627,9 @@
 			  int p_id, int pdev_id, char *p_name)
 {
 	struct neigh_sysctl_table *t = kmalloc(sizeof(*t), GFP_KERNEL);
+	const char *dev_name_source = NULL;
+	char *dev_name = NULL;
+	int err = 0;
 
 	if (!t)
 		return -ENOBUFS;
@@ -1643,8 +1646,10 @@
 	t->neigh_vars[9].data  = &p->anycast_delay;
 	t->neigh_vars[10].data = &p->proxy_delay;
 	t->neigh_vars[11].data = &p->locktime;
+
+ 	dev_name_source = t->neigh_dev[0].procname;
 	if (dev) {
-		t->neigh_dev[0].procname = dev->name;
+		dev_name_source = dev->name;
 		t->neigh_dev[0].ctl_name = dev->ifindex;
 		memset(&t->neigh_vars[12], 0, sizeof(ctl_table));
 	} else {
@@ -1653,6 +1658,15 @@
 		t->neigh_vars[14].data = (int *)(p + 1) + 2;
 		t->neigh_vars[15].data = (int *)(p + 1) + 3;
 	}
+
+	dev_name = net_sysctl_strdup(dev_name_source);
+	if (!dev_name) {
+		err = -ENOBUFS;
+		goto free;
+	}
+
+ 	t->neigh_dev[0].procname = dev_name;
+
 	t->neigh_neigh_dir[0].ctl_name = pdev_id;
 
 	t->neigh_proto_dir[0].procname = p_name;
@@ -1665,11 +1679,19 @@
 
 	t->sysctl_header = register_sysctl_table(t->neigh_root_dir, 0);
 	if (!t->sysctl_header) {
-		kfree(t);
-		return -ENOBUFS;
+		err = -ENOBUFS;
+		goto free_procname;
 	}
 	p->sysctl_table = t;
 	return 0;
+
+	/* error path */
+ free_procname:
+	kfree(dev_name);
+ free:
+	kfree(t);
+
+	return err;
 }
 
 void neigh_sysctl_unregister(struct neigh_parms *p)
@@ -1678,6 +1700,7 @@
 		struct neigh_sysctl_table *t = p->sysctl_table;
 		p->sysctl_table = NULL;
 		unregister_sysctl_table(t->sysctl_header);
+		kfree(t->neigh_dev[0].procname);
 		kfree(t);
 	}
 }
diff -Nru a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
--- a/net/core/sysctl_net_core.c	Fri Oct 17 22:40:18 2003
+++ b/net/core/sysctl_net_core.c	Fri Oct 17 22:40:18 2003
@@ -33,6 +33,19 @@
 extern char sysctl_divert_version[];
 #endif /* CONFIG_NET_DIVERT */
 
+/*
+ * This strdup() is used for creating copies of network 
+ * device names to be handed over to sysctl.
+ */
+ 
+char *net_sysctl_strdup(const char *s)
+{
+	char *rv = kmalloc(strlen(s)+1, GFP_KERNEL);
+	if (rv)
+		strcpy(rv, s);
+	return rv;
+}
+
 ctl_table core_table[] = {
 #ifdef CONFIG_NET
 	{
diff -Nru a/net/ipv4/devinet.c b/net/ipv4/devinet.c
--- a/net/ipv4/devinet.c	Fri Oct 17 22:40:18 2003
+++ b/net/ipv4/devinet.c	Fri Oct 17 22:40:18 2003
@@ -904,6 +904,14 @@
 		 * not interesting to applications using netlink.
 		 */
 		inetdev_changename(dev, in_dev);
+
+#ifdef CONFIG_SYSCTL
+		devinet_sysctl_unregister(&in_dev->cnf);
+		neigh_sysctl_unregister(in_dev->arp_parms);
+		neigh_sysctl_register(dev, in_dev->arp_parms, NET_IPV4,
+				      NET_IPV4_NEIGH, "ipv4");
+		devinet_sysctl_register(in_dev, &in_dev->cnf);
+#endif
 		break;
 	}
 out:
@@ -1301,6 +1309,7 @@
 	int i;
 	struct net_device *dev = in_dev ? in_dev->dev : NULL;
 	struct devinet_sysctl_table *t = kmalloc(sizeof(*t), GFP_KERNEL);
+	char *dev_name = NULL;
 
 	if (!t)
 		return;
@@ -1309,13 +1318,25 @@
 		t->devinet_vars[i].data += (char *)p - (char *)&ipv4_devconf;
 		t->devinet_vars[i].de = NULL;
 	}
+
 	if (dev) {
-		t->devinet_dev[0].procname = dev->name;
+		dev_name = dev->name; 
 		t->devinet_dev[0].ctl_name = dev->ifindex;
 	} else {
-		t->devinet_dev[0].procname = "default";
+		dev_name = "default";
 		t->devinet_dev[0].ctl_name = NET_PROTO_CONF_DEFAULT;
 	}
+
+	/* 
+	 * Make a copy of dev_name, because '.procname' is regarded as const 
+	 * by sysctl and we wouldn't want anyone to change it under our feet
+	 * (see SIOCSIFNAME).
+	 */	
+	dev_name = net_sysctl_strdup(dev_name);
+	if (!dev_name)
+	    goto free;
+
+	t->devinet_dev[0].procname    = dev_name;
 	t->devinet_dev[0].child	      = t->devinet_vars;
 	t->devinet_dev[0].de	      = NULL;
 	t->devinet_conf_dir[0].child  = t->devinet_dev;
@@ -1327,9 +1348,17 @@
 
 	t->sysctl_header = register_sysctl_table(t->devinet_root_dir, 0);
 	if (!t->sysctl_header)
-		kfree(t);
-	else
-		p->sysctl = t;
+	    goto free_procname;
+
+	p->sysctl = t;
+	return;
+
+	/* error path */
+ free_procname:
+	kfree(dev_name);
+ free:
+	kfree(t);
+	return;
 }
 
 static void devinet_sysctl_unregister(struct ipv4_devconf *p)
@@ -1338,6 +1367,7 @@
 		struct devinet_sysctl_table *t = p->sysctl;
 		p->sysctl = NULL;
 		unregister_sysctl_table(t->sysctl_header);
+		kfree(t->devinet_dev[0].procname);
 		kfree(t);
 	}
 }
diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	Fri Oct 17 22:40:18 2003
+++ b/net/ipv6/addrconf.c	Fri Oct 17 22:40:18 2003
@@ -1875,6 +1875,14 @@
 		break;
 	case NETDEV_CHANGE:
 		break;
+	case NETDEV_CHANGENAME:
+#ifdef CONFIG_SYSCTL
+		addrconf_sysctl_unregister(&idev->cnf);
+		neigh_sysctl_unregister(idev->nd_parms);
+		neigh_sysctl_register(dev, idev->nd_parms, NET_IPV6, NET_IPV6_NEIGH, "ipv6");
+		addrconf_sysctl_register(idev, &idev->cnf);
+#endif
+		break;
 	};
 
 	return NOTIFY_OK;
@@ -2815,6 +2823,7 @@
 	int i;
 	struct net_device *dev = idev ? idev->dev : NULL;
 	struct addrconf_sysctl_table *t;
+	char *dev_name = NULL;
 
 	t = kmalloc(sizeof(*t), GFP_KERNEL);
 	if (t == NULL)
@@ -2826,12 +2835,24 @@
 		t->addrconf_vars[i].extra1 = idev; /* embedded; no ref */
 	}
 	if (dev) {
-		t->addrconf_dev[0].procname = dev->name;
+		dev_name = dev->name; 
 		t->addrconf_dev[0].ctl_name = dev->ifindex;
 	} else {
-		t->addrconf_dev[0].procname = "default";
+		dev_name = "default";
 		t->addrconf_dev[0].ctl_name = NET_PROTO_CONF_DEFAULT;
 	}
+
+	/* 
+	 * Make a copy of dev_name, because '.procname' is regarded as const 
+	 * by sysctl and we wouldn't want anyone to change it under our feet
+	 * (see SIOCSIFNAME).
+	 */	
+	dev_name = net_sysctl_strdup(dev_name);
+	if (!dev_name)
+	    goto free;
+
+	t->addrconf_dev[0].procname = dev_name;
+
 	t->addrconf_dev[0].child = t->addrconf_vars;
 	t->addrconf_dev[0].de = NULL;
 	t->addrconf_conf_dir[0].child = t->addrconf_dev;
@@ -2843,9 +2864,18 @@
 
 	t->sysctl_header = register_sysctl_table(t->addrconf_root_dir, 0);
 	if (t->sysctl_header == NULL)
-		kfree(t);
+		goto free_procname;
 	else
 		p->sysctl = t;
+	return;
+
+	/* error path */
+ free_procname:
+	kfree(dev_name);
+ free:
+	kfree(t);
+
+	return;
 }
 
 static void addrconf_sysctl_unregister(struct ipv6_devconf *p)
@@ -2854,6 +2884,7 @@
 		struct addrconf_sysctl_table *t = p->sysctl;
 		p->sysctl = NULL;
 		unregister_sysctl_table(t->sysctl_header);
+		kfree(t->addrconf_dev[0].procname);
 		kfree(t);
 	}
 }

===================================================================


This BitKeeper patch contains the following changesets:
+
## Wrapped with gzip_uu ##


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
@[S8?%/E6_S<7]GDXR">C(]P+P\"CU/POI)7C0PX<    
 


-- 
Dan Aloni
da-x@gmx.net
