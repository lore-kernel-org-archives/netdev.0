From: "Sean Kormilo" <skormilo@nortel.com>
Subject: [PATCH 2.6.21.1] ipconfig: add support for multiple user devs
Date: Thu, 17 May 2007 15:16:12 -0400
Message-ID: <1179429372.31146.31.camel@wcary0u3.ca.nortel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04f.nortel.com ([47.129.242.57]:56734 "EHLO
	zcars04f.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754183AbXEQTnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 15:43:08 -0400
Received: from zcarhxm1.corp.nortel.com (zcarhxm1.corp.nortel.com [47.129.230.97])
	by zcars04f.nortel.com (Switch-2.2.6/Switch-2.2.0) with ESMTP id l4HJGHQ01998
	for <netdev@vger.kernel.org>; Thu, 17 May 2007 19:16:17 GMT
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update ipconfig to enable users to specify multiple devices on the kernel commandline
ip= option. This allows for up-to 4 devices to be specified, with devices separated by 
a '/' character.  For example, to limit autoconfig requests to eth0 and eth2:
	ip=:::::eth0/eth2:DHCP

This is required in cases where one might want to allow DHCP requests from multiple
devices, but not necessarily want to broadcast on all ethernet devices that are present 
in the system.

The implementation manipulates the existing user_dev_name string and replaces the '/' 
characters with NULLs, and then uses a new small array of pointers into the 
substrings created by adding the NULLs.

This patch was tested successfully under vmware and qemu. In particular: verified
via tcpdump that all devices in the list were autoconfiguring. That any other devices
in the system were not autoconfiguring. Also verified that if an empty string was
supplied it would behave as it did before (broadcast on all suitable devices). Verified
that a single device behaved as before, and just used the single device.

Signed-off-by: Sean Kormilo <skormilo@nortel.com>
---
This is my first patch submission request - please be gentle. ;)
I'm not subscribed to the mailing list, so please CC my email address on any responses.

--- linux-2.6.21.1/Documentation/nfsroot.txt	2007-04-27 17:49:26.000000000 -0400
+++ linux-2.6.21.1-ipconfig/Documentation/nfsroot.txt	2007-05-17 14:35:32.000000000 -0400
@@ -125,13 +125,18 @@ ip=<client-ip>:<server-ip>:<gw-ip>:<netm
 
   		Default: Client IP address is used in ASCII notation.
 
-  <device>	Name of network device to use.
+  <devices>	Name of network device(s) to use.
 
 		Default: If the host only has one device, it is used.
 			 Otherwise the device is determined using
 			 autoconfiguration. This is done by sending
 			 autoconfiguration requests out of all devices,
 			 and using the device that received the first reply.
+             
+		Up-to 4 devices	may be specified. They should be separated by
+		'/' characters. For example, to specify that DHCP requests
+		should only go out eth0 and eth2:
+			ip=:::::eth0/eth2:DHCP
 
   <autoconf>	Method to use for autoconfiguration. In the case of options
                 which specify multiple autoconfiguration protocols,
--- linux-2.6.21.1/net/ipv4/ipconfig.c	2007-05-17 14:35:15.000000000 -0400
+++ linux-2.6.21.1-ipconfig/net/ipv4/ipconfig.c	2007-05-17 14:44:50.000000000 -0400
@@ -101,6 +101,9 @@
 #define CONF_NAMESERVERS_MAX   3       /* Maximum number of nameservers
 					   - '3' from resolv.h */
 
+#define CONF_USER_DEVS_MAX    4   /* Max number of devices passed in with ip= */
+#define CONF_USER_DEVS_SEP    '/' /* Separator for devices */
+
 #define NONE __constant_htonl(INADDR_NONE)
 
 /*
@@ -149,8 +152,11 @@ static u8 ic_domain[64];		/* DNS (not NI
  * Private state.
  */
 
-/* Name of user-selected boot device */
-static char user_dev_name[IFNAMSIZ] __initdata = { 0, };
+/* Name of user-selected boot device(s) */
+static char user_dev_name[IFNAMSIZ * CONF_USER_DEVS_MAX] __initdata = { 0, };
+/* Array of pointers into the user selected boot devices */
+static char *user_dev_ptrs[CONF_USER_DEVS_MAX] __initdata = { 0, };
+
 
 /* Protocols supported by available interfaces */
 static int ic_proto_have_if __initdata = 0;
@@ -184,7 +190,10 @@ static int __init ic_open_devs(void)
 	struct ic_device *d, **last;
 	struct net_device *dev;
 	unsigned short oflags;
-
+	int udn_num = 0;
+	int udn_used = (int) user_dev_ptrs[0];
+	int able;
+	
 	last = &ic_first_dev;
 	rtnl_lock();
 
@@ -195,43 +204,63 @@ static int __init ic_open_devs(void)
 	for (dev = dev_base; dev; dev = dev->next) {
 		if (dev == &loopback_dev)
 			continue;
-		if (user_dev_name[0] ? !strcmp(dev->name, user_dev_name) :
-		    (!(dev->flags & IFF_LOOPBACK) &&
-		     (dev->flags & (IFF_POINTOPOINT|IFF_BROADCAST)) &&
-		     strncmp(dev->name, "dummy", 5))) {
-			int able = 0;
-			if (dev->mtu >= 364)
-				able |= IC_BOOTP;
-			else
-				printk(KERN_WARNING "DHCP/BOOTP: Ignoring device %s, MTU %d too small", dev->name, dev->mtu);
-			if (!(dev->flags & IFF_NOARP))
-				able |= IC_RARP;
-			able &= ic_proto_enabled;
-			if (ic_proto_enabled && !able)
+
+		if (udn_used) {
+			for (udn_num = 0;
+			     udn_num < CONF_USER_DEVS_MAX;
+			     udn_num++ ) {
+				if (user_dev_ptrs[udn_num] &&
+				    !strcmp(dev->name, user_dev_ptrs[udn_num]))
+					/* found a match */
+					break;
+			}
+
+			if (udn_num >= CONF_USER_DEVS_MAX)
+				/* did not find a match for this device */
+				/* skip to the next one */
 				continue;
-			oflags = dev->flags;
-			if (dev_change_flags(dev, oflags | IFF_UP) < 0) {
-				printk(KERN_ERR "IP-Config: Failed to open %s\n", dev->name);
+		} else {
+			if (! (!(dev->flags & IFF_LOOPBACK) &&
+			       (dev->flags & (IFF_POINTOPOINT|IFF_BROADCAST)) &&
+			       strncmp(dev->name, "dummy", 5)))
+				/* not a usable or non-dummy device - skip it */
 				continue;
-			}
-			if (!(d = kmalloc(sizeof(struct ic_device), GFP_KERNEL))) {
-				rtnl_unlock();
-				return -1;
-			}
-			d->dev = dev;
-			*last = d;
-			last = &d->next;
-			d->flags = oflags;
-			d->able = able;
-			if (able & IC_BOOTP)
-				get_random_bytes(&d->xid, sizeof(__be32));
-			else
-				d->xid = 0;
-			ic_proto_have_if |= able;
-			DBG(("IP-Config: %s UP (able=%d, xid=%08x)\n",
-				dev->name, able, d->xid));
 		}
+
+		able = 0;
+        
+		if (dev->mtu >= 364)
+			able |= IC_BOOTP;
+		else
+			printk(KERN_WARNING "DHCP/BOOTP: Ignoring device %s, MTU %d too small", dev->name, dev->mtu);
+		if (!(dev->flags & IFF_NOARP))
+			able |= IC_RARP;
+		able &= ic_proto_enabled;
+		if (ic_proto_enabled && !able)
+			continue;
+		oflags = dev->flags;
+		if (dev_change_flags(dev, oflags | IFF_UP) < 0) {
+			printk(KERN_ERR "IP-Config: Failed to open %s\n", dev->name);
+			continue;
+		}
+		if (!(d = kmalloc(sizeof(struct ic_device), GFP_KERNEL))) {
+			rtnl_unlock();
+			return -1;
+		}
+		d->dev = dev;
+		*last = d;
+		last = &d->next;
+		d->flags = oflags;
+		d->able = able;
+		if (able & IC_BOOTP)
+			get_random_bytes(&d->xid, sizeof(__be32));
+		else
+			d->xid = 0;
+		ic_proto_have_if |= able;
+		DBG(("IP-Config: %s UP (able=%d, xid=%08x)\n",
+		     dev->name, able, d->xid));
 	}
+
 	rtnl_unlock();
 
 	*last = NULL;
@@ -1438,8 +1467,9 @@ static int __init ic_proto_name(char *na
 
 static int __init ip_auto_config_setup(char *addrs)
 {
-	char *cp, *ip, *dp;
+	char *cp, *ip, *dp, *udn;
 	int num = 0;
+	int udn_num;
 
 	ic_set_manually = 1;
 
@@ -1488,6 +1518,32 @@ static int __init ip_auto_config_setup(c
 				break;
 			case 5:
 				strlcpy(user_dev_name, ip, sizeof(user_dev_name));
+
+				if (!user_dev_name[0])
+					break;
+				
+				/* make sure pointers are initialized to 0 */
+				for (udn_num = 0;
+				     udn_num < CONF_USER_DEVS_MAX;
+				     udn_num++ )
+					user_dev_ptrs[udn_num] = 0;
+				
+				udn = user_dev_name;
+				udn_num = 0;
+				
+				while (udn && *udn &&
+				       (udn_num < CONF_USER_DEVS_MAX)) {
+					
+					if ((dp = strchr(udn,
+							 CONF_USER_DEVS_SEP)))
+						*dp++ = '\0';
+					
+					if (strlen(udn) > 0) 
+						user_dev_ptrs[udn_num++] = udn;  
+					
+					udn = dp;
+				}
+				
 				break;
 			case 6:
 				ic_proto_name(ip);

