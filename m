From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: [PATCH] ipconfig: handle case of delayed DHCP server
Date: Mon, 11 May 2009 11:44:45 -0600
Message-ID: <4A08640D.7020100@nortel.com>
References: <4A049C6B.9070000@nortel.com>	<20090508.143947.207466029.davem@davemloft.net>	<m17i0pwg0w.fsf@fess.ebiederm.org> <20090510.010821.00122250.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:43898 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756072AbZEKRou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 13:44:50 -0400
In-Reply-To: <20090510.010821.00122250.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Sun, 10 May 2009 00:53:03 -0700
> 
>> David Miller <davem@davemloft.net> writes:
>>
>>> From: "Chris Friesen" <cfriesen@nortel.com>
>>> Date: Fri, 08 May 2009 14:56:11 -0600
>>>
>>>> +	/* Is it a reply for the device we are configuring? */
>>>> +	if (b->xid != ic_dev_xid) {
>>>> +		if (net_ratelimit())
>>>> + printk(KERN_ERR "DHCP/BOOTP: Ignoring delayed packet \n");
>>>> +		goto drop_unlock;
>>> Please don't use such odd indentation for this printk
>>> statement.
>> Weird it looked ok in my mailer 3 tabs in, and out to coloumn 82.  Dave someting
>> word wrap it for you?
> 
> I hope it's not my arch-nemesis, format=flowed :-/

Yeah, that's what it was.  The underlying text wasn't actually
wrapped though, so it was probably your MTA that was doing the
wrapping.

Here's a resend with flowed disabled.

Chris






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
