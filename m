From: jamal <hadi@cyberus.ca>
Subject: Re: primary and secondary ip addresses
Date: 20 Dec 2004 08:55:02 -0500
Message-ID: <1103550901.1050.292.camel@jzny.localdomain>
References: <200412161153.51251.hasso@estpak.ee>
	 <Pine.LNX.4.61.0412161103320.30452@filer.marasystems.com>
	 <200412161302.42357.hasso@estpak.ee> <41C2F6E5.5010607@cs.columbia.edu>
	 <Pine.LNX.4.61.0412171621200.15793@filer.marasystems.com>
	 <41C30212.6000906@cs.columbia.edu>
	 <20041217112025.27688eb6.davem@davemloft.net>
	 <Pine.LNX.4.61.0412172046320.18698@filer.marasystems.com>
	 <1103487517.1047.181.camel@jzny.localdomain>
	 <20041219214120.GX17302@sunbeam.de.gnumonks.org>
	 <20041219220211.GQ17998@postel.suug.ch>
	 <1103497168.1046.218.camel@jzny.localdomain>
	 <1103500587.1048.269.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-+5XeGy0BAYdkSAlQxb0L"
Cc: Henrik Nordstrom <hno@marasystems.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrea G Forte <andreaf@cs.columbia.edu>, hasso@estpak.ee,
	nhorman@redhat.com, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>, Harald Welte <laforge@gnumonks.org>
In-Reply-To: <1103500587.1048.269.camel@jzny.localdomain>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-+5XeGy0BAYdkSAlQxb0L
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2004-12-19 at 18:56, jamal wrote:
> Harald,
> 
> My (stoopid) ISP doesnt like your email address. In any case, attached
> patch of what i was alluding to. Maybe be missing some things. 
> Compiles - not tested 

Didnt boot ;->
A small silly magic number i missed. Now boots - but doesnt mean it
works. And i dont have much time to spare chasing it.

cheers,
jamal

--=-+5XeGy0BAYdkSAlQxb0L
Content-Disposition: attachment; filename=p5-take2
Content-Type: text/plain; name=p5-take2; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- 2610-rc3-bk12/net/ipv4/bak.devinet.c	2004-12-19 17:30:33.000000000 -0500
+++ 2610-rc3-bk12/net/ipv4/devinet.c	2004-12-20 08:48:30.038520264 -0500
@@ -230,11 +230,14 @@
 static void inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 			 int destroy)
 {
+	struct in_ifaddr *promote = NULL;
 	struct in_ifaddr *ifa1 = *ifap;
 
 	ASSERT_RTNL();
 
-	/* 1. Deleting primary ifaddr forces deletion all secondaries */
+	/* 1. Deleting primary ifaddr forces deletion all secondaries 
+	 * unless alias promotion is set
+	 **/
 
 	if (!(ifa1->ifa_flags & IFA_F_SECONDARY)) {
 		struct in_ifaddr *ifa;
@@ -248,11 +251,16 @@
 				continue;
 			}
 
-			*ifap1 = ifa->ifa_next;
+			if (!IN_DEV_PROMOTE_ALIASES(in_dev)) {
+				*ifap1 = ifa->ifa_next;
 
-			rtmsg_ifa(RTM_DELADDR, ifa);
-			notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa);
-			inet_free_ifa(ifa);
+				rtmsg_ifa(RTM_DELADDR, ifa);
+				notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa);
+				inet_free_ifa(ifa);
+			} else {
+				promote = ifa;
+				break;
+			}
 		}
 	}
 
@@ -278,6 +286,13 @@
 		if (!in_dev->ifa_list)
 			inetdev_destroy(in_dev);
 	}
+
+	if (promote && IN_DEV_PROMOTE_ALIASES(in_dev)) {
+		/* not sure if we should send a delete notify first? */
+		promote->ifa_flags &= ~IFA_F_SECONDARY;
+		rtmsg_ifa(RTM_NEWADDR, promote);
+		notifier_call_chain(&inetaddr_chain, NETDEV_UP, promote);
+	}
 }
 
 static int inet_insert_ifa(struct in_ifaddr *ifa)
@@ -1209,10 +1224,10 @@
 	return 1;
 }
 
-
+#define DEVINET_SIZE 21
 static struct devinet_sysctl_table {
 	struct ctl_table_header *sysctl_header;
-	ctl_table		devinet_vars[20];
+	ctl_table		devinet_vars[DEVINET_SIZE];
 	ctl_table		devinet_dev[2];
 	ctl_table		devinet_conf_dir[2];
 	ctl_table		devinet_proto_dir[2];
@@ -1374,6 +1389,15 @@
 			.proc_handler	= &ipv4_doint_and_flush,
 			.strategy	= &ipv4_doint_and_flush_strategy,
 		},
+		{
+			.ctl_name	= NET_IPV4_CONF_PROMOTE_ALIASES,
+			.procname	= "promote_aliases",
+			.data		= &ipv4_devconf.promote_aliases,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= &ipv4_doint_and_flush,
+			.strategy	= &ipv4_doint_and_flush_strategy,
+		},
 	},
 	.devinet_dev = {
 		{

--- a/include/linux/bak.sysctl.h	2004-12-19 18:26:04.622675432 -0500
+++ b/include/linux/sysctl.h	2004-12-19 18:27:18.471448712 -0500
@@ -395,6 +395,7 @@
 	NET_IPV4_CONF_FORCE_IGMP_VERSION=17,
 	NET_IPV4_CONF_ARP_ANNOUNCE=18,
 	NET_IPV4_CONF_ARP_IGNORE=19,
+	NET_IPV4_CONF_PROMOTE_ALIASES=20,
 };
 
 /* /proc/sys/net/ipv4/netfilter */

--- a/include/linux/bak.inetdevice.h	2004-12-19 17:54:26.610217184 -0500
+++ b/include/linux/inetdevice.h	2004-12-19 17:58:45.130916064 -0500
@@ -29,6 +29,7 @@
 	int	no_xfrm;
 	int	no_policy;
 	int	force_igmp_version;
+	int	promote_aliases;
 	void	*sysctl;
 };
 
@@ -71,6 +72,7 @@
 #define IN_DEV_SEC_REDIRECTS(in_dev)	(ipv4_devconf.secure_redirects || (in_dev)->cnf.secure_redirects)
 #define IN_DEV_IDTAG(in_dev)		((in_dev)->cnf.tag)
 #define IN_DEV_MEDIUM_ID(in_dev)	((in_dev)->cnf.medium_id)
+#define IN_DEV_PROMOTE_ALIASES(in_dev)	(ipv4_devconf.promote_aliases || (in_dev)->cnf.promote_aliases)
 
 #define IN_DEV_RX_REDIRECTS(in_dev) \
 	((IN_DEV_FORWARD(in_dev) && \

--=-+5XeGy0BAYdkSAlQxb0L--

