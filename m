From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net: restore ip source validation WAS(Re:
 [tproxy,regression] tproxy broken in 2.6.32
Date: Sun, 13 Dec 2009 14:15:16 -0500
Message-ID: <1260731716.6167.27.camel@bigi>
References: <1259585129.3992.13.camel@nienna.balabit>
	 <1259589577.873.30.camel@bigi> <1259674488.3168.45.camel@bigi>
	 <20091202.223117.228943068.davem@davemloft.net>
	 <1259848398.3766.43.camel@bigi>  <4B17C346.3000906@trash.net>
	 <1259849264.13245.3.camel@nienna.balabit>  <1259850594.3766.46.camel@bigi>
	 <1260723147.6167.20.camel@bigi>
	 <Pine.LNX.4.58.0912132009410.12698@u.domain.uli>
	 <1260729530.6167.22.camel@bigi>  <1260731510.6167.25.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-wewBsxZXn+GPgeSXG/pZ"
Cc: Julian Anastasov <ja@ssi.bg>, KOVACS Krisztian <hidden@balabit.hu>,
	Patrick McHardy <kaber@trash.net>, hidden@sch.bme.hu,
	aschultz@warp10.net, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org, Rick Jones <rick.jones2@hp.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:38626 "HELO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753872AbZLMTPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 14:15:20 -0500
Received: by qw-out-2122.google.com with SMTP id 3so539894qwe.37
        for <netdev@vger.kernel.org>; Sun, 13 Dec 2009 11:15:19 -0800 (PST)
In-Reply-To: <1260731510.6167.25.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wewBsxZXn+GPgeSXG/pZ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2009-12-13 at 14:11 -0500, jamal wrote:
> On Sun, 2009-12-13 at 13:38 -0500, jamal wrote:
> 
> > Of course. I will resend ..
> 
> Updated. Much thanks Julian.

Grrr. As a self-proclaimed master craftsman man i insist on blaming some
tool. It must be git! Proper patch attached.

cheers,
jamal

--=-wewBsxZXn+GPgeSXG/pZ
Content-Disposition: attachment; filename="src-valid-m3"
Content-Type: application/mbox; name="src-valid-m3"
Content-Transfer-Encoding: 7bit

>From 2a69541430da1a888605e6092f5b35a76efd8475 Mon Sep 17 00:00:00 2001
From: Jamal Hadi Salim <hadi@cyberus.ca>
Date: Sun, 13 Dec 2009 14:02:46 -0500
Subject: [PATCH] [PATCH] net: restore ip source validation

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
---
 include/linux/inetdevice.h |    1 +
 include/linux/sysctl.h     |    1 +
 net/ipv4/devinet.c         |    1 +
 net/ipv4/fib_frontend.c    |    2 ++
 4 files changed, 5 insertions(+), 0 deletions(-)

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
 
-- 
1.5.6.5


--=-wewBsxZXn+GPgeSXG/pZ--

