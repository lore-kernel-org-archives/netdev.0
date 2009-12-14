From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net: restore ip source validation WAS(Re:
 [tproxy,regression] tproxy broken in 2.6.32
Date: Mon, 14 Dec 2009 05:19:45 -0500
Message-ID: <1260785985.6167.29.camel@bigi>
References: <1260729530.6167.22.camel@bigi> <1260731510.6167.25.camel@bigi>
	 <1260731716.6167.27.camel@bigi>
	 <20091213.191024.193699730.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-M2pLcKOl47/fAhQGzyBb"
Cc: ja@ssi.bg, hidden@balabit.hu, kaber@trash.net, hidden@sch.bme.hu,
	aschultz@warp10.net, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org, rick.jones2@hp.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f192.google.com ([209.85.221.192]:58212 "EHLO
	mail-qy0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755893AbZLNKTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 05:19:51 -0500
Received: by qyk30 with SMTP id 30so1466511qyk.33
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2009 02:19:50 -0800 (PST)
In-Reply-To: <20091213.191024.193699730.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-M2pLcKOl47/fAhQGzyBb
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2009-12-13 at 19:10 -0800, David Miller wrote:

> Don't use binary attachments like that please.
> 
> It doesn't end up in patchwork properly, and I need that to
> happen in order to track people's work effectively.

That was me venturing into git-land. This is how i normally send them:

cheers,
jamal

--=-M2pLcKOl47/fAhQGzyBb
Content-Disposition: attachment; filename="src-valid-m3-1"
Content-Type: text/plain; name="src-valid-m3-1"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

commit 2a69541430da1a888605e6092f5b35a76efd8475
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Sun Dec 13 14:02:46 2009 -0500

    [PATCH] net: restore ip source validation
    
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
 

--=-M2pLcKOl47/fAhQGzyBb--

