From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2.6 NET] Device name changing via rtnetlink
Date: Fri, 10 Sep 2004 16:28:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910142804.GC20088@postel.suug.ch>
References: <20040910133637.GA20088@postel.suug.ch> <20040910.230038.322907649.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040910.230038.322907649.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* YOSHIFUJI Hideaki / ?$B5HF#1QL@ <20040910.230038.322907649.yoshfuji@linux-ipv6.org> 2004-09-10 23:00
> In article <20040910133637.GA20088@postel.suug.ch> (at Fri, 10 Sep 2004 15:36:37 +0200), Thomas Graf <tgraf@suug.ch> says:
> 
> > Allows changing of device name via rtnetlink. Last bit needed to do full
> > link configuration via rtnetlink.
> > 
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> :
> > +		if (ida[IFLA_IFNAME - 1]->rta_len > RTA_LENGTH(IFNAMSIZ))
> > +			goto out;
> 
> Please use sizeof(ifname) instead.

Thanks for the hint.

Allows changing of device name via rtnetlink. Last bit needed to do full
link configuration via rtnetlink.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc1-bk15.orig/include/linux/netdevice.h	2004-09-08 18:32:05.000000000 +0200
+++ linux-2.6.9-rc1-bk15/include/linux/netdevice.h	2004-09-10 12:42:07.000000000 +0200
@@ -677,6 +677,7 @@
 extern int		dev_ethtool(struct ifreq *);
 extern unsigned		dev_get_flags(const struct net_device *);
 extern int		dev_change_flags(struct net_device *, unsigned);
+extern int		dev_change_name(struct net_device *, char *);
 extern int		dev_set_mtu(struct net_device *, int);
 extern void		dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev);
 
--- linux-2.6.9-rc1-bk15.orig/net/core/dev.c	2004-09-08 18:33:42.000000000 +0200
+++ linux-2.6.9-rc1-bk15/net/core/dev.c	2004-09-10 12:41:19.000000000 +0200
@@ -3347,6 +3347,7 @@
 EXPORT_SYMBOL(dev_set_allmulti);
 EXPORT_SYMBOL(dev_set_promiscuity);
 EXPORT_SYMBOL(dev_change_flags);
+EXPORT_SYMBOL(dev_change_name);
 EXPORT_SYMBOL(dev_set_mtu);
 EXPORT_SYMBOL(free_netdev);
 EXPORT_SYMBOL(netdev_boot_setup_check);
--- linux-2.6.9-rc1-bk15.orig/net/core/rtnetlink.c	2004-09-08 18:33:42.000000000 +0200
+++ linux-2.6.9-rc1-bk15/net/core/rtnetlink.c	2004-09-10 16:13:46.000000000 +0200
@@ -345,6 +345,23 @@
 		dev->weight = *((u32 *) RTA_DATA(ida[IFLA_WEIGHT - 1]));
 	}
 
+	if (ida[IFLA_IFNAME - 1]) {
+		char ifname[IFNAMSIZ];
+
+		if (ida[IFLA_IFNAME - 1]->rta_len > RTA_LENGTH(sizeof(ifname)))
+			goto out;
+
+		memset(ifname, 0, sizeof(ifname));
+		memcpy(ifname, RTA_DATA(ida[IFLA_IFNAME - 1]),
+			RTA_PAYLOAD(ida[IFLA_IFNAME - 1]));
+		ifname[IFNAMSIZ - 1] = '\0';
+
+		err = dev_change_name(dev, ifname);
+
+		if (err)
+			goto out;
+	}
+
 	err = 0;
 
 out:
