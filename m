From: "Sean Kormilo" <skormilo@nortel.com>
Subject: [PATCH 2.6.21.1] ipconfig: add support for multiple user devs
Date: Wed, 27 Jun 2007 13:51:48 -0400
Message-ID: <1182966708.6090.73.camel@wcary0u3.ca.nortel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04f.nortel.com ([47.129.242.57]:34199 "EHLO
	zcars04f.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762974AbXF0SBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 14:01:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update ipconfig to enable users to specify multiple devices on the kernel commandline
ip= option. This allows for an arbitrary number of devices to be specified up-to a
255 character limit. Devices are separated by a '/' character.  
For example, to limit autoconfig requests to eth0 and eth2:
	ip=:::::eth0/eth2:DHCP

This is required in cases where one might want to allow DHCP requests from multiple
devices, but not necessarily want to broadcast on all ethernet devices that are present 
in the system.

The implementation manipulates the existing user_dev_name string and replaces the '/' 
characters with NULLs and keeps track of the number of devices parsed. It then scans
through the multiple NULL terminated string array looking for matches.

This patch was tested successfully under vmware and qemu. In particular: verified
via tcpdump that all devices in the list were autoconfiguring. That any other devices
in the system were not autoconfiguring. Also verified that if an empty string was
supplied it would behave as it did before (broadcast on all suitable devices). Verified
that a single device behaved as before, and just used the single device.

Signed-off-by: Sean Kormilo <skormilo@nortel.com>
---
Remove the arbitrary 4 device limit per request from David Miller. I was not able to
use kmalloc in the ip_auto_config_setup function, it returned NULL. I guess this may
make sense given that it is in the kernel commandline parsing phase. I settled on
using an array, but removing the array of pointers.
I'm not subscribed to the mailing list, so please CC my email address on any responses.

--- linux-2.6.21.1/Documentation/nfsroot.txt    2007-06-27 08:41:53.000000000 -0400
+++ linux-2.6.21.1-ipconfig/Documentation/nfsroot.txt   2007-06-27 13:22:56.000000000 -0400
@@ -125,7 +125,7 @@ ip=<client-ip>:<server-ip>:<gw-ip>:<netm

                Default: Client IP address is used in ASCII notation.

-  <device>     Name of network device to use.
+  <devices>    Name of network device(s) to use.

                Default: If the host only has one device, it is used.
                         Otherwise the device is determined using
@@ -133,6 +133,14 @@ ip=<client-ip>:<server-ip>:<gw-ip>:<netm
                         autoconfiguration requests out of all devices,
                         and using the device that received the first reply.

+               It is also possible to restrict the DHCP requests to a set of
+               devices. This can be done by passing in a '/' separated list of
+               device names.
+
+               For example, to specify that DHCP requests should only go out
+               eth0 and eth2:
+                       ip=:::::eth0/eth2:DHCP
+
   <autoconf>   Method to use for autoconfiguration. In the case of options
                 which specify multiple autoconfiguration protocols,
                requests are sent using all protocols, and the first one
--- linux-2.6.21.1/net/ipv4/ipconfig.c  2007-06-27 08:42:28.000000000 -0400
+++ linux-2.6.21.1-ipconfig/net/ipv4/ipconfig.c 2007-06-27 13:34:51.000000000 -0400
@@ -101,6 +101,9 @@
 #define CONF_NAMESERVERS_MAX   3       /* Maximum number of nameservers
                                           - '3' from resolv.h */

+#define CONF_USER_DEVS_MAX_LEN 255
+#define CONF_USER_DEVS_SEP    '/' /* Separator for devices */
+
 #define NONE __constant_htonl(INADDR_NONE)

 /*
@@ -149,8 +152,11 @@ static u8 ic_domain[64];           /* DNS (not NI
  * Private state.
  */

-/* Name of user-selected boot device */
-static char user_dev_name[IFNAMSIZ] __initdata = { 0, };
+/* Name of user-selected boot device(s) */
+static char user_dev_name[CONF_USER_DEVS_MAX_LEN] __initdata = { 0, };
+
+/* Number of user selected boot devices */
+static int num_user_devs __initdata = 0;

 /* Protocols supported by available interfaces */
 static int ic_proto_have_if __initdata = 0;
@@ -184,7 +190,10 @@ static int __init ic_open_devs(void)
        struct ic_device *d, **last;
        struct net_device *dev;
        unsigned short oflags;
-
+       int able;
+       char *udn;
+       int udn_num;
+
        last = &ic_first_dev;
        rtnl_lock();

@@ -195,43 +204,68 @@ static int __init ic_open_devs(void)
        for (dev = dev_base; dev; dev = dev->next) {
                if (dev == &loopback_dev)
                        continue;
-               if (user_dev_name[0] ? !strcmp(dev->name, user_dev_name) :
-                   (!(dev->flags & IFF_LOOPBACK) &&
-                    (dev->flags & (IFF_POINTOPOINT|IFF_BROADCAST)) &&
-                    strncmp(dev->name, "dummy", 5))) {
-                       int able = 0;
-                       if (dev->mtu >= 364)
-                               able |= IC_BOOTP;
-                       else
-                               printk(KERN_WARNING "DHCP/BOOTP: Ignoring device %s, MTU %d too small", dev->name, dev->mtu);
-                       if (!(dev->flags & IFF_NOARP))
-                               able |= IC_RARP;
-                       able &= ic_proto_enabled;
-                       if (ic_proto_enabled && !able)
+
+               if (user_dev_name[0]) {
+                       udn = user_dev_name;
+
+                       for (udn_num = 0;
+                            udn_num < num_user_devs;
+                            udn_num++ ) {
+                               if (udn && !strcmp(dev->name, udn))
+                                       /* found a match */
+                                       break;
+
+                               /* move the pointer to the next null */
+                               /* terminated string in the array    */
+                               udn += strlen(udn) + 1;
+                       }
+
+                       if (udn_num >= num_user_devs)
+                               /* did not find a match for this device */
+                               /* skip to the next one */
                                continue;
-                       oflags = dev->flags;
-                       if (dev_change_flags(dev, oflags | IFF_UP) < 0) {
-                               printk(KERN_ERR "IP-Config: Failed to open %s\n", dev->name);
+               } else {
+                       if (! (!(dev->flags & IFF_LOOPBACK) &&
+                              (dev->flags & (IFF_POINTOPOINT|IFF_BROADCAST)) &&
+                              strncmp(dev->name, "dummy", 5)))
+                               /* not a usable or non-dummy device - skip it */
                                continue;
-                       }
-                       if (!(d = kmalloc(sizeof(struct ic_device), GFP_KERNEL))) {
-                               rtnl_unlock();
-                               return -1;
-                       }
-                       d->dev = dev;
-                       *last = d;
-                       last = &d->next;
-                       d->flags = oflags;
-                       d->able = able;
-                       if (able & IC_BOOTP)
-                               get_random_bytes(&d->xid, sizeof(__be32));
-                       else
-                               d->xid = 0;
-                       ic_proto_have_if |= able;
-                       DBG(("IP-Config: %s UP (able=%d, xid=%08x)\n",
-                               dev->name, able, d->xid));
                }
+
+               able = 0;
+
+               if (dev->mtu >= 364)
+                       able |= IC_BOOTP;
+               else
+                       printk(KERN_WARNING "DHCP/BOOTP: Ignoring device %s, MTU %d too small", dev->name, dev->mtu);
+               if (!(dev->flags & IFF_NOARP))
+                       able |= IC_RARP;
+               able &= ic_proto_enabled;
+               if (ic_proto_enabled && !able)
+                       continue;
+               oflags = dev->flags;
+               if (dev_change_flags(dev, oflags | IFF_UP) < 0) {
+                       printk(KERN_ERR "IP-Config: Failed to open %s\n", dev->name);
+                       continue;
+               }
+               if (!(d = kmalloc(sizeof(struct ic_device), GFP_KERNEL))) {
+                       rtnl_unlock();
+                       return -1;
+               }
+               d->dev = dev;
+               *last = d;
+               last = &d->next;
+               d->flags = oflags;
+               d->able = able;
+               if (able & IC_BOOTP)
+                       get_random_bytes(&d->xid, sizeof(__be32));
+               else
+                       d->xid = 0;
+               ic_proto_have_if |= able;
+               DBG(("IP-Config: %s UP (able=%d, xid=%08x)\n",
+                    dev->name, able, d->xid));
        }
+
        rtnl_unlock();

        *last = NULL;
@@ -1387,7 +1421,7 @@ late_initcall(ip_auto_config);
  *  command line parameter. It consists of option fields separated by colons in
  *  the following order:
  *
- *  <client-ip>:<server-ip>:<gw-ip>:<netmask>:<host name>:<device>:<PROTO>
+ *  <client-ip>:<server-ip>:<gw-ip>:<netmask>:<host name>:<devices>:<PROTO>
  *
  *  Any of the fields can be empty which means to use a default value:
  *     <client-ip>     - address given by BOOTP or RARP
@@ -1397,7 +1431,7 @@ late_initcall(ip_auto_config);
  *                       one returned by BOOTP
  *     <host name>     - <client-ip> in ASCII notation, or the name returned
  *                       by BOOTP
- *     <device>        - use all available devices
+ *     <devices>       - device list separated by / or use all devices
  *     <PROTO>:
  *        off|none         - don't do autoconfig at all (DEFAULT)
  *        on|any           - use any configured protocol
@@ -1438,7 +1472,7 @@ static int __init ic_proto_name(char *na

 static int __init ip_auto_config_setup(char *addrs)
 {
-       char *cp, *ip, *dp;
+       char *cp, *ip, *dp, *udn;
        int num = 0;

        ic_set_manually = 1;
@@ -1487,7 +1521,26 @@ static int __init ip_auto_config_setup(c
                                ic_host_name_set = 1;
                                break;
                        case 5:
+                               if (!ip[0])
+                                       break;
+
                                strlcpy(user_dev_name, ip, sizeof(user_dev_name));
+
+                               udn = user_dev_name;
+
+                               /* create a NULL separated array of strings */
+                               /* with a NULL replacing each SEP character */
+                               while (udn && *udn) {
+                                       if (dp = strchr(udn,
+                                                        CONF_USER_DEVS_SEP))
+                                               *dp++ = '\0';
+
+                                       if (strlen(udn) > 0)
+                                               num_user_devs++;
+
+                                       udn = dp;
+                               }
+
                                break;
                        case 6:
                                ic_proto_name(ip);

