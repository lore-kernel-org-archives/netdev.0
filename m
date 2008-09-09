From: Thierry <thierry.bultel@wanadoo.fr>
Subject: Suggested patch: Sending the FQDN when booting via DHCP
Date: Tue, 09 Sep 2008 19:35:22 +0200
Message-ID: <48C6B3DA.3040904@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.152]:25386 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754906AbYIIS3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 14:29:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[re-sent without HTML encoding, and to the right aliases ...]

Hi all,

the following patch can be useful, in order to let the DHCP server 
accordingly update the DNS, when booting via DHCP.

This can be useful for 2 reasons:
1) on small systems, the embedded filesystem may even not have udhcpd
2) when booting nfsroot, the nfs server does not like when udhcpd in 
invoked, even when requested the same IP address.

Here is the patch, for 2.6.27-rc5. (Notice that it is the very first 
time I deliver a patch for Linux, and I may
have missed some points on the procedure, if it is the case I apologize 
for that). What do you think about it ?

Any ideas or comments are welcome.

Thanks,
Thierry

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 591ea23..74111da 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -162,6 +162,16 @@ config IP_PNP_DHCP
      must be operating on your network.  Read
      for details.

+config IP_PNP_DHCP_FQDN
+    bool "IP: DHCP FQDN"
+    default y
+    depends on IP_PNP_DHCP
+    ---help---
+       If you want your Linux box to send its FQDN in the DHCP request,
+       in order to let the DHCP server know how to update the DNS, you
+       can say Y here.
+
+
config IP_PNP_BOOTP
    bool "IP: BOOTP support"
    depends on IP_PNP
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 42065ff..6a2b159 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -565,6 +565,19 @@ struct bootp_pkt {        /* BOOTP packet format */
#define DHCPRELEASE    7
#define DHCPINFORM    8

+/* DHCP options        */
+
+#define DHCP_OPT_REQUESTED_IP    50
+#define DHCP_OPT_MESSAGE_TYPE    53
+#define DHCP_OPT_SERVER_ID    54
+#define DHCP_OPT_VEND_CLASS_ID    60
+#define DHCP_OPT_FQDN        81
+
+#define DHCP_FQDN_FLAGS_S    0x1    /* Server update */
+#define DHCP_FQDN_FLAGS_O    0x2
+#define DHCP_FQDN_FLAGS_E    0x4
+#define DHCP_FQDN_FLAGS_N    0x8
+
static int ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, 
struct packet_type *pt, struct net_device *orig_dev);

static struct packet_type bootp_packet_type __initdata = {
@@ -596,20 +609,35 @@ ic_dhcp_init_options(u8 *options)
    memcpy(e, ic_bootp_cookie, 4);    /* RFC1048 Magic Cookie */
    e += 4;

-    *e++ = 53;        /* DHCP message type */
+    *e++ = DHCP_OPT_MESSAGE_TYPE;        /* DHCP message type */
    *e++ = 1;
    *e++ = mt;

    if (mt == DHCPREQUEST) {
-        *e++ = 54;    /* Server ID (IP address) */
-        *e++ = 4;
+#ifdef CONFIG_IP_PNP_DHCP_FQDN
+        char * hostname = utsname()->nodename;
+        int    len    = strlen(hostname);       +
+        *e++ = DHCP_OPT_FQDN;
+        *e++ = len + 3;    /* Len with flags and R1+R2 */
+        *e++ = DHCP_FQDN_FLAGS_S;
+        e += 2;
+        memcpy(e,hostname,len);
+        e += len;
+#endif /* CONFIG_IP_PNP_DHCP_FQDN */
+
+        *e++ = DHCP_OPT_SERVER_ID;    /* Server ID (IP address) */
+        *e++ = 4;    /* Len */
        memcpy(e, &ic_servaddr, 4);
        e += 4;

-        *e++ = 50;    /* Requested IP address */
+        *e++ = DHCP_OPT_REQUESTED_IP;    /* Requested IP address */
        *e++ = 4;
        memcpy(e, &ic_myaddr, 4);
        e += 4;
+
    }

    /* always? */
@@ -632,7 +660,7 @@ ic_dhcp_init_options(u8 *options)
        if (*vendor_class_identifier) {
            printk(KERN_INFO "DHCP: sending class identifier \"%s\"\n",
                   vendor_class_identifier);
-            *e++ = 60;    /* Class-identifier */
+            *e++ = DHCP_OPT_VEND_CLASS_ID;    /* Class-identifier */
            len = strlen(vendor_class_identifier);
            *e++ = len;
            memcpy(e, vendor_class_identifier, len);

