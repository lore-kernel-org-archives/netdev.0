From: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Subject: [PATCH] netdevice.7: document SIOCGIFCONF case ifc_req==NULL
Date: Fri, 10 Jan 2014 00:30:18 +0100 (CET)
Message-ID: <20140109233018.886FA140064@xenon.ts.pxnet.com>
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add the missing description of the possibility to call SIOCGIFCONF
with ifc_req==NULL to determine the needed buffer size, as described
in http://lkml.indiana.edu/hypermail/linux/kernel/0110.1/0506.html
and verified against source files net/core/dev_ioctl.c and
net/ipv4/devinet.c in the current kernel git tree.
This functionality has been present since the beginning of the 2.6
series. It's about time it gets documented.
While I'm at it, also generally clarify the section on SIOCGIFCONF.

Patch prepared against man-pages version 3.55.

Signed-off-by: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>

---
 man7/netdevice.7 |   83 +++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 57 insertions(+), 26 deletions(-)

--- a/man7/netdevice.7	2013-12-12 08:42:55.000000000 +0100
+++ b/man7/netdevice.7	2014-01-09 23:43:23.000000000 +0100
@@ -15,7 +15,7 @@
 .\" Modified, 2011-11-02, <bidulock-B8ReZeU34LJAfugRpC6u6w@public.gmane.org>, added many basic
 .\"  but missing ioctls, such as SIOCGIFADDR.
 .\"
-.TH NETDEVICE  7 2012-04-26 "Linux" "Linux Programmer's Manual"
+.TH NETDEVICE  7 2014-01-09 "Linux" "Linux Programmer's Manual"
 .SH NAME
 netdevice \- low-level access to Linux network devices
 .SH SYNOPSIS
@@ -29,7 +29,7 @@
 Linux supports some standard ioctls to configure network devices.
 They can be used on any socket's file descriptor regardless of the
 family or type.
-They pass an
+Most of them pass an
 .I ifreq
 structure:
 
@@ -53,14 +53,6 @@
         char           *ifr_data;
     };
 };
-
-struct ifconf {
-    int                 ifc_len; /* size of buffer */
-    union {
-        char           *ifc_buf; /* buffer address */
-        struct ifreq   *ifc_req; /* array of structures */
-    };
-};
 .fi
 .in
 
@@ -265,30 +257,69 @@
 means only addresses of the
 .B AF_INET
 (IPv4) family for compatibility.
-The user passes a
+Unlike the others, this ioctl passes an
 .I ifconf
-structure as argument to the ioctl.
-It contains a pointer to an array of
-.I ifreq
-structures in
+structure:
+
+.in +4n
+.nf
+struct ifconf {
+    int                 ifc_len; /* size of buffer */
+    union {
+        char           *ifc_buf; /* buffer address */
+        struct ifreq   *ifc_req; /* array of structures */
+    };
+};
+.fi
+.in
+
+If
 .I ifc_req
-and its length in bytes in
+is NULL,
+.B SIOCGIFCONF
+returns the necessary buffer size in bytes
+for receiving all available addresses in
 .IR ifc_len .
-The kernel fills the ifreqs with all current L3 interface addresses that
-are running:
+Otherwise
+.I ifc_req
+contains a pointer to an array of
+.I ifreq
+structures to be filled with all currently active L3 interface addresses.
+.I ifc_len
+contains the size of the array in bytes.
+Within each
+.I ifreq
+structure,
 .I ifr_name
-contains the interface name (eth0:1 etc.),
+will receive the interface name, and
 .I ifr_addr
 the address.
-The kernel returns with the actual length in
+The actual number of bytes transferred is returned in
 .IR ifc_len .
-If
+
+If the size specified by
+.I ifc_len
+is insufficient to store all the addresses,
+the kernel will skip the exceeding ones and return success.
+There is no reliable way of detecting this condition once it has occurred.
+It is therefore recommended to either determine the necessary buffer size
+beforehand by calling
+.B SIOCGIFCONF
+with
+.I ifc_req
+set to NULL, or to retry the call with a bigger buffer whenever
 .I ifc_len
-is equal to the original length the buffer probably has overflowed
-and you should retry with a bigger buffer to get all addresses.
-When no error occurs the ioctl returns 0;
-otherwise \-1.
-Overflow is not an error.
+upon return differs by less than sizeof(struct
+.IR ifreq )
+from its original value.
+
+If an error occurs accessing the
+.I ifconf
+or
+.I ifreq
+structures,
+.B EFAULT
+will be returned.
 .\" Slaving isn't supported in 2.2
 .\" .
 .\" .TP
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
