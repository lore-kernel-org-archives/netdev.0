From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC] ARP notify option
Date: Tue, 6 Mar 2007 10:51:32 -0800
Message-ID: <20070306105132.52c77491@freekitty>
References: <20070301164214.4a40bc59@freekitty> <45E7764A.7000100@goop.org>
	<20070301173030.754514ec@freekitty>
	<20070305.203536.92584097.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, jeff@garzik.org, ian.pratt@xensource.com,
   netdev@vger.kernel.org, linux-kernel@vger.kernel.org, chrisw@sous-sol.org,
   virtualization@lists.osdl.org, akpm@linux-foundation.org, ak@muc.de
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.osdl.org>
In-Reply-To: <20070305.203536.92584097.davem@davemloft.net>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.osdl.org>
List-Help: <mailto:virtualization-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.osdl.org?subject=subscribe>
Sender: virtualization-bounces@lists.osdl.org
Errors-To: virtualization-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

This adds another inet device option to enable gratuitous ARP
when device is brought up or address change. This is handy for
clusters or virtualization.

Tested on a normal device (not Xen).

Signed-off-by: Stephen Hemminger <shemminge@linux-foundation.org>

---
 Documentation/networking/ip-sysctl.txt |    6 ++++++
 include/linux/inetdevice.h             |    2 ++
 include/linux/sysctl.h                 |    1 +
 net/ipv4/devinet.c                     |   16 ++++++++++++++++
 4 files changed, 25 insertions(+)

--- net-2.6.22.orig/Documentation/networking/ip-sysctl.txt	2007-03-05 14:35=
:31.000000000 -0800
+++ net-2.6.22/Documentation/networking/ip-sysctl.txt	2007-03-05 16:46:47.0=
00000000 -0800
@@ -732,6 +732,12 @@
 	The max value from conf/{all,interface}/arp_ignore is used
 	when ARP request is received on the {interface}
 =

+arp_notify - BOOLEAN
+	Define mode for notification of address and device changes.
+	0 - (default): do nothing
+	1 - Generate gratuitous arp replies when device is brought up
+	    or hardware address changes.
+
 arp_accept - BOOLEAN
 	Define behavior when gratuitous arp replies are received:
 	0 - drop gratuitous arp frames
--- net-2.6.22.orig/include/linux/inetdevice.h	2007-03-05 14:35:34.00000000=
0 -0800
+++ net-2.6.22/include/linux/inetdevice.h	2007-03-05 16:46:47.000000000 -08=
00
@@ -26,6 +26,7 @@
 	int	arp_announce;
 	int	arp_ignore;
 	int	arp_accept;
+	int	arp_notify;
 	int	medium_id;
 	int	no_xfrm;
 	int	no_policy;
@@ -84,6 +85,7 @@
 #define IN_DEV_ARPFILTER(in_dev)	(ipv4_devconf.arp_filter || (in_dev)->cnf=
.arp_filter)
 #define IN_DEV_ARP_ANNOUNCE(in_dev)	(max(ipv4_devconf.arp_announce, (in_de=
v)->cnf.arp_announce))
 #define IN_DEV_ARP_IGNORE(in_dev)	(max(ipv4_devconf.arp_ignore, (in_dev)->=
cnf.arp_ignore))
+#define IN_DEV_ARP_NOTIFY(in_dev)	(ipv4_devconf.arp_notify || (in_dev)->cn=
f.arp_notify)
 =

 struct in_ifaddr
 {
--- net-2.6.22.orig/include/linux/sysctl.h	2007-03-05 14:35:34.000000000 -0=
800
+++ net-2.6.22/include/linux/sysctl.h	2007-03-05 16:46:47.000000000 -0800
@@ -495,6 +495,7 @@
 	NET_IPV4_CONF_ARP_IGNORE=3D19,
 	NET_IPV4_CONF_PROMOTE_SECONDARIES=3D20,
 	NET_IPV4_CONF_ARP_ACCEPT=3D21,
+	NET_IPV4_CONF_ARP_NOTIFY=3D22,
 	__NET_IPV4_CONF_MAX
 };
 =

--- net-2.6.22.orig/net/ipv4/devinet.c	2007-03-05 14:35:34.000000000 -0800
+++ net-2.6.22/net/ipv4/devinet.c	2007-03-05 16:46:47.000000000 -0800
@@ -1089,6 +1089,14 @@
 			}
 		}
 		ip_mc_up(in_dev);
+		/* fall through */
+	case NETDEV_CHANGEADDR:
+		if (IN_DEV_ARP_NOTIFY(in_dev))
+			arp_send(ARPOP_REQUEST, ETH_P_ARP,
+				 in_dev->ifa_list->ifa_address,
+				 dev,
+				 in_dev->ifa_list->ifa_address,
+				 NULL, dev->dev_addr, NULL);
 		break;
 	case NETDEV_DOWN:
 		ip_mc_down(in_dev);
@@ -1495,6 +1503,14 @@
 			.proc_handler	=3D &proc_dointvec,
 		},
 		{
+			.ctl_name	=3D NET_IPV4_CONF_ARP_NOTIFY,
+			.procname	=3D "arp_notify",
+			.data		=3D &ipv4_devconf.arp_notify,
+			.maxlen		=3D sizeof(int),
+			.mode		=3D 0644,
+			.proc_handler	=3D &proc_dointvec,
+		},
+		{
 			.ctl_name	=3D NET_IPV4_CONF_NOXFRM,
 			.procname	=3D "disable_xfrm",
 			.data		=3D &ipv4_devconf.no_xfrm,
