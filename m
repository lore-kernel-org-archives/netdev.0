From: Dan Aloni <da-x@gmx.net>
Subject: Re: [BK PATCH 2.6] repost, fix sysctl breakage during network device renaming, for ipv4
Date: Sat, 18 Oct 2003 13:20:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031018112011.GA16613@callisto.yi.org>
References: <20030901164624.GA26886@callisto.yi.org> <20030901094127.6a0f6878.davem@redhat.com> <20030901165559.GA27099@callisto.yi.org> <20030901113143.1ba34464.davem@redhat.com> <20031017213235.GA5278@callisto.yi.org> <20031018000131.52a13c98.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031018000131.52a13c98.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Oct 18, 2003 at 12:01:31AM -0700, David S. Miller wrote:
> On Fri, 17 Oct 2003 23:32:35 +0200
> Dan Aloni <da-x@gmx.net> wrote:
> 
> > Here is the patch. I've compiled and tested it.
> 
> But not with ipv6 modular :-)  Please add the necessary
> module symbol export for net_sysctl_strdup() and resubmit
> the patch.

Of course, what was I thinking.


You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1365, 2003-10-18 13:08:35+02:00, da-x@gmx.net
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
 net/core/sysctl_net_core.c |   16 ++++++++++++++++
 net/ipv4/devinet.c         |   40 +++++++++++++++++++++++++++++++++++-----
 net/ipv6/addrconf.c        |   37 ++++++++++++++++++++++++++++++++++---
 5 files changed, 114 insertions(+), 11 deletions(-)


diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	Sat Oct 18 13:16:14 2003
+++ b/include/linux/netdevice.h	Sat Oct 18 13:16:14 2003
@@ -901,6 +901,9 @@
 extern void		dev_clear_fastroute(struct net_device *dev);
 #endif
 
+#ifdef CONFIG_SYSCTL
+extern char *net_sysctl_strdup(const char *s);
+#endif
 
 #endif /* __KERNEL__ */
 
diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	Sat Oct 18 13:16:14 2003
+++ b/net/core/neighbour.c	Sat Oct 18 13:16:14 2003
@@ -1628,6 +1628,9 @@
 			  int p_id, int pdev_id, char *p_name)
 {
 	struct neigh_sysctl_table *t = kmalloc(sizeof(*t), GFP_KERNEL);
+	const char *dev_name_source = NULL;
+	char *dev_name = NULL;
+	int err = 0;
 
 	if (!t)
 		return -ENOBUFS;
@@ -1644,8 +1647,10 @@
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
@@ -1654,6 +1659,15 @@
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
@@ -1666,11 +1680,19 @@
 
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
@@ -1679,6 +1701,7 @@
 		struct neigh_sysctl_table *t = p->sysctl_table;
 		p->sysctl_table = NULL;
 		unregister_sysctl_table(t->sysctl_header);
+		kfree(t->neigh_dev[0].procname);
 		kfree(t);
 	}
 }
diff -Nru a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
--- a/net/core/sysctl_net_core.c	Sat Oct 18 13:16:14 2003
+++ b/net/core/sysctl_net_core.c	Sat Oct 18 13:16:14 2003
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
@@ -162,4 +175,7 @@
 #endif /* CONFIG_NET */
 	{ .ctl_name = 0 }
 };
+
+EXPORT_SYMBOL(net_sysctl_strdup);
+
 #endif
diff -Nru a/net/ipv4/devinet.c b/net/ipv4/devinet.c
--- a/net/ipv4/devinet.c	Sat Oct 18 13:16:14 2003
+++ b/net/ipv4/devinet.c	Sat Oct 18 13:16:14 2003
@@ -905,6 +905,14 @@
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
@@ -1302,6 +1310,7 @@
 	int i;
 	struct net_device *dev = in_dev ? in_dev->dev : NULL;
 	struct devinet_sysctl_table *t = kmalloc(sizeof(*t), GFP_KERNEL);
+	char *dev_name = NULL;
 
 	if (!t)
 		return;
@@ -1310,13 +1319,25 @@
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
@@ -1328,9 +1349,17 @@
 
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
@@ -1339,6 +1368,7 @@
 		struct devinet_sysctl_table *t = p->sysctl;
 		p->sysctl = NULL;
 		unregister_sysctl_table(t->sysctl_header);
+		kfree(t->devinet_dev[0].procname);
 		kfree(t);
 	}
 }
diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	Sat Oct 18 13:16:14 2003
+++ b/net/ipv6/addrconf.c	Sat Oct 18 13:16:14 2003
@@ -1874,6 +1874,14 @@
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
@@ -2904,6 +2912,7 @@
 	int i;
 	struct net_device *dev = idev ? idev->dev : NULL;
 	struct addrconf_sysctl_table *t;
+	char *dev_name = NULL;
 
 	t = kmalloc(sizeof(*t), GFP_KERNEL);
 	if (t == NULL)
@@ -2915,12 +2924,24 @@
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
@@ -2932,9 +2953,18 @@
 
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
@@ -2943,6 +2973,7 @@
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
6P,)AEH^/;.R%U(HB_7]+]PG5/1P     
 


-- 
Dan Aloni
da-x@gmx.net
