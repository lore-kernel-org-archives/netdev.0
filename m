From: Jaap Keuter <jaap.keuter@xs4all.nl>
Subject: [PATCH] broadcast address on subnet
Date: Wed, 30 Jun 2004 13:02:16 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040630125858.K68876-100000@xs1.xs4all.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello David and list,

While getting hands-on with netkit (www.netkit.org), a networking
simulation environment based on UML, it struck me that ifconfig wasn't
capable of calculating the proper broadcast address for a subnetted
interface. Some browsing through newsgroups and on the Debian package
site (nettools), showed that this leads to misconfigured interfaces and
a couple of bugreports on ifconfig.

Digging a bit deeper revealed that it actually is an issue with
SIOIFNETMASK. Once you bring up an interface with SIOIFADDR, a classfull
netmask and broadcast address is set (if applicable for the type of
interface), in order to get a properly configured interface. But if you
subnet the network using SIOIFNETMASK no proper broadcast address is
set. So you always have to calculate it yourself, obviously leading to
configuration errors.

This patch takes care of this. First of all it doesn't change
existing functionality, eg. a command like 'ifconfig eth0 192.168.1.1
netmask 255.255.255.240 broadcast 192.168.1.0' still works. But if you
omit the broadcast address, a proper 'all ones' broadcast address for the
subnet is set. 'ifconfig eth0 192.168.1.1 netmask 255.255.255.240' gives
you 'eth0 inet addr:192.168.1.1 Bcast:192.168.1.15 Mask:255.255.255.240'
and this should solve some real life problems.

The patch is created against kernel 2.4.26, but can easily be ported.

Signed-off-by: Jaap Keuter <jaap.keuter@xs4all.nl>

--- linux-2.4.26/net/ipv4/devinet.c.orig        2004-04-14 13:05:41.000000000 +0000
+++ linux-2.4.26/net/ipv4/devinet.c     2004-06-23 11:28:36.000000000 +0000
@@ -661,8 +661,18 @@

                        if (ifa->ifa_mask != sin->sin_addr.s_addr) {
                                inet_del_ifa(in_dev, ifap, 0);
+                               ifa->ifa_prefixlen = inet_mask_len(sin->sin_addr.s_addr);
+                               /*
+                                * See if current broadcast address matches with current netmask,
+                                * then recalculate the broadcast address. Otherwise it's a funny
+                                * address, so don't touch it since the user seems to know what
+                                * (s)he's doing...
+                                */
+                               if ((dev->flags&IFF_BROADCAST) && (ifa->ifa_prefixlen < 31) &&
+                                   (ifa->ifa_broadcast == (ifa->ifa_local|~ifa->ifa_mask))) {
+                                       ifa->ifa_broadcast = ifa->ifa_local|~sin->sin_addr.s_addr;
+                               }
                                ifa->ifa_mask = sin->sin_addr.s_addr;
-                               ifa->ifa_prefixlen = inet_mask_len(ifa->ifa_mask);
                                inet_insert_ifa(ifa);
                        }
                        break;
