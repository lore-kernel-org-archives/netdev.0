From: Ben Greear <greearb@candelatech.com>
Subject: Patch to latest iproute to get it to compile on FC5
Date: Wed, 13 Feb 2008 11:32:32 -0800
Message-ID: <47B345D0.1020707@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010603090805070709060703"
To: NetDev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:51051 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752777AbYBMTcf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 14:32:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010603090805070709060703
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

I notice that the latest snapshot and git repository for iproute
will not compile on FC5 due to not finding __constant_hton* symbols
and a lack of the hdlc/ioctl.h file on FC5.

I am attaching a patch that appears to fix the problems for me.

Please consider applying this or something similar.

Signed-off-by:  Ben Greear <greearb@candelatech.com>


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------010603090805070709060703
Content-Type: text/x-patch;
 name="iproute.fc5.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="iproute.fc5.patch"

diff --git a/configure b/configure
index dc14e54..f28e4cf 100755
--- a/configure
+++ b/configure
@@ -25,3 +25,22 @@ else
     echo no
 fi
 rm -f /tmp/atmtest.c /tmp/atmtest
+
+echo -n "HDLC IOCTL:   "
+cat >/tmp/hdlctest.c <<EOF
+#include <net/if.h>
+#include <linux/hdlc/ioctl.h>
+int main(int argc, char **argv) {
+        return 0;
+}
+EOF
+gcc -I$INCLUDE -o /tmp/hdlctest /tmp/hdlctest.c >/dev/null 2>&1
+if [ $? -eq 0 ]
+then
+    echo "IPROUTE_CONFIG_HDLC:=y" >>Config
+    echo yes
+else
+    echo no
+fi
+rm -f /tmp/hdlctest.c /tmp/hdlctest
+
diff --git a/include/linux/if.h b/include/linux/if.h
index 40eb61f..9651cc9 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -23,7 +23,10 @@
 #include <linux/socket.h>		/* for "struct sockaddr" et al	*/
 
 #define	IFNAMSIZ	16
+
+#ifdef HAVE_HDLC_IOCTL
 #include <linux/hdlc/ioctl.h>
+#endif
 
 /* Standard interface flags (netdevice->flags). */
 #define	IFF_UP		0x1		/* interface is up		*/
@@ -133,6 +136,7 @@ struct if_settings
 {
 	unsigned int type;	/* Type of physical device or protocol */
 	unsigned int size;	/* Size of the data allocated by the caller */
+#ifdef HAVE_HDLC_IOCTL
 	union {
 		/* {atm/eth/dsl}_settings anyone ? */
 		raw_hdlc_proto	 *raw_hdlc;
@@ -145,6 +149,7 @@ struct if_settings
 		sync_serial_settings *sync;
 		te1_settings	 *te1;
 	} ifs_ifsu;
+#endif
 };
 
 /*
diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 228eb4e..0eb5b04 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -2,6 +2,7 @@
 #define _IF_TUNNEL_H_
 
 #include <linux/types.h>
+#include <asm/byteorder.h>
 
 #define SIOCGETTUNNEL   (SIOCDEVPRIVATE + 0)
 #define SIOCADDTUNNEL   (SIOCDEVPRIVATE + 1)
diff --git a/lib/Makefile b/lib/Makefile
index bc270bf..1c51a42 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -1,3 +1,9 @@
+include ../Config
+
+ifeq ($(IPROUTE_CONFIG_HDLC),y)
+   CFLAGS += -DHAVE_HDLC_IOCTL
+endif
+
 
 UTILOBJ=utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o inet_proto.o
 

--------------010603090805070709060703--
