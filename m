From: "Chris Friesen" <cfriesen@nortel.com>
Subject: [PATCH] teach ipconfig about the MTU option in DHCP
Date: Tue, 19 May 2009 12:05:34 -0600
Message-ID: <4A12F4EE.7070305@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04e.nortel.com ([47.129.242.56]:43510 "EHLO
	zcars04e.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265AbZESSFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 14:05:37 -0400
Received: from zcarhxs1.corp.nortel.com (casmtp.ca.nortel.com [47.129.230.89])
	by zcars04e.nortel.com (Switch-2.2.0/Switch-2.2.0) with ESMTP id n4JI4Yo29201
	for <netdev@vger.kernel.org>; Tue, 19 May 2009 18:04:34 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The DHCP spec allows the server to specify the MTU.  This can be useful
for netbooting with UDP-based NFS-root on a network using jumbo frames.
This patch allows the kernel IP autoconfiguration to handle this option
correctly.

It would be possible to use initramfs and add a script to set the MTU,
but that seems like a complicated solution if no initramfs is otherwise
necessary, and would bloat the kernel image more than this code would.

This patch was originally submitted to LKML in 2003 by Hans-Peter Jansen.

Signed-off-by: Chris Friesen <cfriesen@nortel.com>




diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index ff75000..21b3b05 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -158,6 +158,9 @@ static char user_dev_name[IFNAMSIZ] __initdata = { 0, };
 /* Protocols supported by available interfaces */
 static int ic_proto_have_if __initdata = 0;
 
+/* MTU for boot device */
+static int ic_dev_mtu __initdata = 0;
+
 #ifdef IPCONFIG_DYNAMIC
 static DEFINE_SPINLOCK(ic_recv_lock);
 static volatile int ic_got_reply __initdata = 0;    /* Proto(s) that replied */
@@ -284,7 +287,7 @@ set_sockaddr(struct sockaddr_in *sin, __be32 addr, __be16 port)
 	sin->sin_port = port;
 }
 
-static int __init ic_dev_ioctl(unsigned int cmd, struct ifreq *arg)
+static int __init ic_devinet_ioctl(unsigned int cmd, struct ifreq *arg)
 {
 	int res;
 
@@ -295,6 +298,17 @@ static int __init ic_dev_ioctl(unsigned int cmd, struct ifreq *arg)
 	return res;
 }
 
+static int __init ic_dev_ioctl(unsigned int cmd, struct ifreq *arg)
+{
+	int res;
+
+	mm_segment_t oldfs = get_fs();
+	set_fs(get_ds());
+	res = dev_ioctl(&init_net, cmd, (struct ifreq __user *) arg);
+	set_fs(oldfs);
+	return res;
+}
+
 static int __init ic_route_ioctl(unsigned int cmd, struct rtentry *arg)
 {
 	int res;
@@ -319,20 +333,31 @@ static int __init ic_setup_if(void)
 	memset(&ir, 0, sizeof(ir));
 	strcpy(ir.ifr_ifrn.ifrn_name, ic_dev->name);
 	set_sockaddr(sin, ic_myaddr, 0);
-	if ((err = ic_dev_ioctl(SIOCSIFADDR, &ir)) < 0) {
+	if ((err = ic_devinet_ioctl(SIOCSIFADDR, &ir)) < 0) {
 		printk(KERN_ERR "IP-Config: Unable to set interface address (%d).\n", err);
 		return -1;
 	}
 	set_sockaddr(sin, ic_netmask, 0);
-	if ((err = ic_dev_ioctl(SIOCSIFNETMASK, &ir)) < 0) {
+	if ((err = ic_devinet_ioctl(SIOCSIFNETMASK, &ir)) < 0) {
 		printk(KERN_ERR "IP-Config: Unable to set interface netmask (%d).\n", err);
 		return -1;
 	}
 	set_sockaddr(sin, ic_myaddr | ~ic_netmask, 0);
-	if ((err = ic_dev_ioctl(SIOCSIFBRDADDR, &ir)) < 0) {
+	if ((err = ic_devinet_ioctl(SIOCSIFBRDADDR, &ir)) < 0) {
 		printk(KERN_ERR "IP-Config: Unable to set interface broadcast address (%d).\n", err);
 		return -1;
 	}
+	/* Handle the case where we need non-standard MTU on the boot link (a network
+	 * using jumbo frames, for instance).  If we can't set the mtu, don't error
+	 * out, we'll try to muddle along.
+	 */
+	if (ic_dev_mtu != 0) {
+		strcpy(ir.ifr_name, ic_dev->name); 
+		ir.ifr_mtu = ic_dev_mtu;
+		if ((err = ic_dev_ioctl(SIOCSIFMTU, &ir)) < 0)
+			printk(KERN_ERR "IP-Config: Unable to set interface mtu to %d (%d).\n",
+			                 ic_dev_mtu, err);
+	}
 	return 0;
 }
 
@@ -621,6 +646,7 @@ ic_dhcp_init_options(u8 *options)
 			12,	/* Host name */
 			15,	/* Domain name */
 			17,	/* Boot path */
+			26,	/* MTU */
 			40,	/* NIS domain name */
 		};
 
@@ -796,6 +822,7 @@ static void __init ic_do_bootp_ext(u8 *ext)
 {
        u8 servers;
        int i;
+	u16 mtu;
 
 #ifdef IPCONFIG_DEBUG
 	u8 *c;
@@ -835,6 +862,10 @@ static void __init ic_do_bootp_ext(u8 *ext)
 			if (!root_server_path[0])
 				ic_bootp_string(root_server_path, ext+1, *ext, sizeof(root_server_path));
 			break;
+		case 26:	/* Interface MTU */
+			memcpy(&mtu, ext+1, sizeof(mtu));
+			ic_dev_mtu = ntohs(mtu);
+			break;
 		case 40:	/* NIS Domain name (_not_ DNS) */
 			ic_bootp_string(utsname()->domainname, ext+1, *ext, __NEW_UTS_LEN);
 			break;
@@ -1395,6 +1426,8 @@ static int __init ip_auto_config(void)
 	printk(",\n     bootserver=" NIPQUAD_FMT, NIPQUAD(ic_servaddr));
 	printk(", rootserver=" NIPQUAD_FMT, NIPQUAD(root_server_addr));
 	printk(", rootpath=%s", root_server_path);
+	if( ic_dev_mtu )
+		printk(", mtu=%d", ic_dev_mtu);
 	printk("\n");
 #endif /* !SILENT */
 
