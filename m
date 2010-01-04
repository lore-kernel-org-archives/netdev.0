From: David Miller <davem@davemloft.net>
Subject: Re: regression in socket match caused by "net: Fix RPF to work
 with policy routing"
Date: Mon, 04 Jan 2010 10:35:27 -0800 (PST)
Message-ID: <20100104.103527.134676041.davem@davemloft.net>
References: <20100104100417.GA7699@verge.net.au>
	<1262600022.3568.2.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: horms@verge.net.au, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36489
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753744Ab0ADSfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 13:35:24 -0500
In-Reply-To: <1262600022.3568.2.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Mon, 04 Jan 2010 05:13:42 -0500

> Hi Simon,
> 
> 
> On Mon, 2010-01-04 at 21:04 +1100, Simon Horman wrote:
>> Hi Jamal,
>> 
>> the patch "net: Fix RPF to work with policy routing",
>> which was added between 2.6.32-rc5 and rc6 seems to
>> cause a regression when using the socket match.
>> 
>> In particular I'm using IP_TRANSPARENT as detailed
>> in Documentation/networking/tproxy.txt with the following
>> rules:
> 
> Try latest tree - should be resolved.

Specifically this commit:

commit 28f6aeea3f12d37bd258b2c0d5ba891bff4ec479
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Fri Dec 25 17:30:22 2009 -0800

    net: restore ip source validation
    
    when using policy routing and the skb mark:
    there are cases where a back path validation requires us
    to use a different routing table for src ip validation than
    the one used for mapping ingress dst ip.
    One such a case is transparent proxying where we pretend to be
    the destination system and therefore the local table
    is used for incoming packets but possibly a main table would
    be used on outbound.
    Make the default behavior to allow the above and if users
    need to turn on the symmetry via sysctl src_valid_mark
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 699e85c..b230492 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -81,6 +81,7 @@ static inline void ipv4_devconf_setall(struct in_device *in_dev)
 #define IN_DEV_FORWARD(in_dev)		IN_DEV_CONF_GET((in_dev), FORWARDING)
 #define IN_DEV_MFORWARD(in_dev)		IN_DEV_ANDCONF((in_dev), MC_FORWARDING)
 #define IN_DEV_RPFILTER(in_dev)		IN_DEV_MAXCONF((in_dev), RP_FILTER)
+#define IN_DEV_SRC_VMARK(in_dev)    	IN_DEV_ORCONF((in_dev), SRC_VMARK)
 #define IN_DEV_SOURCE_ROUTE(in_dev)	IN_DEV_ANDCONF((in_dev), \
 						       ACCEPT_SOURCE_ROUTE)
 #define IN_DEV_ACCEPT_LOCAL(in_dev)	IN_DEV_ORCONF((in_dev), ACCEPT_LOCAL)
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 877ba03..bd27fbc 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -482,6 +482,7 @@ enum
 	NET_IPV4_CONF_ARP_ACCEPT=21,
 	NET_IPV4_CONF_ARP_NOTIFY=22,
 	NET_IPV4_CONF_ACCEPT_LOCAL=23,
+	NET_IPV4_CONF_SRC_VMARK=24,
 	__NET_IPV4_CONF_MAX
 };
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 5cdbc10..040c4f0 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1397,6 +1397,7 @@ static struct devinet_sysctl_table {
 		DEVINET_SYSCTL_RW_ENTRY(ACCEPT_SOURCE_ROUTE,
 					"accept_source_route"),
 		DEVINET_SYSCTL_RW_ENTRY(ACCEPT_LOCAL, "accept_local"),
+		DEVINET_SYSCTL_RW_ENTRY(SRC_VMARK, "src_valid_mark"),
 		DEVINET_SYSCTL_RW_ENTRY(PROXY_ARP, "proxy_arp"),
 		DEVINET_SYSCTL_RW_ENTRY(MEDIUM_ID, "medium_id"),
 		DEVINET_SYSCTL_RW_ENTRY(BOOTP_RELAY, "bootp_relay"),
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 3323168..82dbf71 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -252,6 +252,8 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 		no_addr = in_dev->ifa_list == NULL;
 		rpf = IN_DEV_RPFILTER(in_dev);
 		accept_local = IN_DEV_ACCEPT_LOCAL(in_dev);
+		if (mark && !IN_DEV_SRC_VMARK(in_dev))
+			fl.mark = 0;
 	}
 	rcu_read_unlock();
 
