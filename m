From: "Chris Friesen" <cfriesen@nortel.com>
Subject: [PATCH] ipconfig: handle case of delayed DHCP server
Date: Fri, 08 May 2009 14:56:11 -0600
Message-ID: <4A049C6B.9070000@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org,
	Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:64168 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755502AbZEHU4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 16:56:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If a DHCP server is delayed, it's possible for the client to receive the 
DHCPOFFER after it has already sent out a new DHCPDISCOVER message from 
a second interface.  The client then sends out a DHCPREQUEST from the 
second interface, but the server doesn't recognize the device and 
rejects the request.

This patch simply tracks the current device being configured and throws 
away the OFFER if it is not intended for the current device.  A more 
sophisticated approach would be to put the OFFER information into the 
struct ic_device rather than storing it globally.

Signed-off-by: Chris Friesen <cfriesen@nortel.com>

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 90d22ae..88bf051 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -139,6 +139,8 @@ __be32 ic_servaddr = NONE;	/* Boot server IP address */
 __be32 root_server_addr = NONE;	/* Address of NFS server */
 u8 root_server_path[256] = { 0, };	/* Path to mount as root */
 
+u32 ic_dev_xid;		/* Device under configuration */
+
 /* vendor class identifier */
 static char vendor_class_identifier[253] __initdata;
 
@@ -932,6 +934,13 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 		goto drop_unlock;
 	}
 
+	/* Is it a reply for the device we are configuring? */
+	if (b->xid != ic_dev_xid) {
+		if (net_ratelimit())
+			printk(KERN_ERR "DHCP/BOOTP: Ignoring delayed packet \n");
+		goto drop_unlock;
+	}
+
 	/* Parse extensions */
 	if (ext_len >= 4 &&
 	    !memcmp(b->exten, ic_bootp_cookie, 4)) { /* Check magic cookie */
@@ -1115,6 +1124,9 @@ static int __init ic_dynamic(void)
 	get_random_bytes(&timeout, sizeof(timeout));
 	timeout = CONF_BASE_TIMEOUT + (timeout % (unsigned) CONF_TIMEOUT_RANDOM);
 	for (;;) {
+		/* Track the device we are configuring */
+		ic_dev_xid = d->xid;
+
 #ifdef IPCONFIG_BOOTP
 		if (do_bootp && (d->able & IC_BOOTP))
 			ic_bootp_send_if(d, jiffies - start_jiffies);
