From: Laurent Deniel <laurent.deniel@free.fr>
Subject: [patch] superfluous CAP_NET_ADMIN required for some ioctl
Date: Tue, 01 Feb 2005 21:49:14 +0100
Message-ID: <41FFEB4A.90400@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

It should be possible to obtain bonding information with
SIOCBOND[SLAVE]INFOQUERY ioctls without root privilege
(like with /proc/net/bonding/bond? or ifconfig).

Laurent

Signed-off-by: Laurent Deniel <laurent.deniel@free.fr>

--- linux-2.6.9.orig/net/core/dev.c     2005-01-08 17:29:55.000000000 +0100
+++ linux-2.6.9/net/core/dev.c  2005-01-08 18:00:01.000000000 +0100
@@ -2692,8 +2692,6 @@ int dev_ioctl(unsigned int cmd, void __u
                 case SIOCBONDENSLAVE:
                 case SIOCBONDRELEASE:
                 case SIOCBONDSETHWADDR:
-               case SIOCBONDSLAVEINFOQUERY:
-               case SIOCBONDINFOQUERY:
                 case SIOCBONDCHANGEACTIVE:
                 case SIOCBRADDIF:
                 case SIOCBRDELIF:
@@ -2705,6 +2703,20 @@ int dev_ioctl(unsigned int cmd, void __u
                         rtnl_unlock();
                         return ret;

+               /*
+                *      These ioctl calls:
+                *      - can be done by all.
+                *      - require strict serialization.
+                *      - return a value (but already copied to user)
+                */
+               case SIOCBONDSLAVEINFOQUERY:
+               case SIOCBONDINFOQUERY:
+                       dev_load(ifr.ifr_name);
+                       rtnl_lock();
+                       ret = dev_ifsioc(&ifr, cmd);
+                       rtnl_unlock();
+                       return ret;
+
                 case SIOCGIFMEM:
                         /* Get the per device memory space. We can add this but
                          * currently do not support it */
