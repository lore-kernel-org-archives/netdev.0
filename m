From: "David S. Miller" <davem@redhat.com>
Subject: Re: Restrict local IP announcements in ARP requests
Date: Mon, 9 Feb 2004 14:20:14 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209142014.413209d7.davem@redhat.com>
References: <Pine.LNX.4.58.0402081149001.6268@u.domain.uli>
	<20040209140853.69ab8bea.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040209140853.69ab8bea.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 9 Feb 2004 14:08:53 -0800
"David S. Miller" <davem@redhat.com> wrote:

> as a birthday present to everyone I'll also add an IN_DEV_ARP_IGNORE
> flag for inet devices to so people can control
> complete ARP ignoring via a global/per-device sysctl.

Ok, does this do what everyone wants?  Speak now or forever hold your peace
on this issue :-)

I'll add this to 2.6.x and 2.4.x if folks are OK with it.  Write this date
down on your calendars, I doubt I'll capitulate like this ever again 8-)

===== Documentation/networking/ip-sysctl.txt 1.20 vs edited =====
--- 1.20/Documentation/networking/ip-sysctl.txt	Mon Feb  2 10:20:58 2004
+++ edited/Documentation/networking/ip-sysctl.txt	Mon Feb  9 14:08:57 2004
@@ -499,6 +499,15 @@
 	conf/{all,interface}/arp_filter is set to TRUE,
 	it will be disabled otherwise
 
+arp_ignore - BOOLEAN
+	0 - (default) Process ARP requests.
+	1 - Ignore ARP requests.
+
+	ARP requests received on a given interface will be ignored if
+	at least one of conf/{all,interface}/arp_ignore is set to TRUE.
+	ARP requests will be processed otherwise (barring any other
+	restrictive controls such as 'arp_filter' documented above).
+
 tag - INTEGER
 	Allows you to write a number, which can be used as required.
 	Default value is 0.
===== include/linux/inetdevice.h 1.7 vs edited =====
--- 1.7/include/linux/inetdevice.h	Thu Jan 29 14:57:46 2004
+++ edited/include/linux/inetdevice.h	Mon Feb  9 14:09:31 2004
@@ -18,6 +18,7 @@
 	int	mc_forwarding;
 	int	tag;
 	int     arp_filter;
+	int     arp_ignore;
 	int	medium_id;
 	int	no_xfrm;
 	int	no_policy;
@@ -71,6 +72,7 @@
 	  (ipv4_devconf.accept_redirects || (in_dev)->cnf.accept_redirects)))
 
 #define IN_DEV_ARPFILTER(in_dev)	(ipv4_devconf.arp_filter || (in_dev)->cnf.arp_filter)
+#define IN_DEV_ARPIGNORE(in_dev)	(ipv4_devconf.arp_ignore || (in_dev)->cnf.arp_ignore)
 
 struct in_ifaddr
 {
===== include/linux/sysctl.h 1.60 vs edited =====
--- 1.60/include/linux/sysctl.h	Fri Feb  6 19:37:57 2004
+++ edited/include/linux/sysctl.h	Mon Feb  9 14:09:51 2004
@@ -362,6 +362,7 @@
 	NET_IPV4_CONF_NOXFRM=15,
 	NET_IPV4_CONF_NOPOLICY=16,
 	NET_IPV4_CONF_FORCE_IGMP_VERSION=17,
+	NET_IPV4_CONF_ARP_IGNORE=18,
 };
 
 /* /proc/sys/net/ipv4/netfilter */
===== net/ipv4/arp.c 1.36 vs edited =====
--- 1.36/net/ipv4/arp.c	Fri Feb  6 16:00:17 2004
+++ edited/net/ipv4/arp.c	Mon Feb  9 14:10:27 2004
@@ -779,7 +779,9 @@
 			n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
 			if (n) {
 				int dont_send = 0;
-				if (IN_DEV_ARPFILTER(in_dev))
+				if (IN_DEV_ARPIGNORE(in_dev))
+					dont_send = 1;
+				else if (IN_DEV_ARPFILTER(in_dev))
 					dont_send |= arp_filter(sip,tip,dev); 
 				if (!dont_send)
 					arp_send(ARPOP_REPLY,ETH_P_ARP,sip,dev,tip,sha,dev->dev_addr,sha);
===== net/ipv4/devinet.c 1.24 vs edited =====
--- 1.24/net/ipv4/devinet.c	Thu Jan 29 14:57:46 2004
+++ edited/net/ipv4/devinet.c	Mon Feb  9 14:12:38 2004
@@ -1132,7 +1132,7 @@
 
 static struct devinet_sysctl_table {
 	struct ctl_table_header *sysctl_header;
-	ctl_table		devinet_vars[18];
+	ctl_table		devinet_vars[19];
 	ctl_table		devinet_dev[2];
 	ctl_table		devinet_conf_dir[2];
 	ctl_table		devinet_proto_dir[2];
@@ -1277,6 +1277,14 @@
 			.mode		= 0644,
 			.proc_handler	= &ipv4_doint_and_flush,
 			.strategy	= &ipv4_doint_and_flush_strategy,
+		},
+		{
+			.ctl_name	= NET_IPV4_CONF_ARP_IGNORE,
+			.procname	= "arp_ignore",
+			.data		= &ipv4_devconf.arp_ignore,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= &proc_dointvec,
 		},
 	},
 	.devinet_dev = {
