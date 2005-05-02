From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: icmp_unreachable uses wrong ip
Date: Mon, 2 May 2005 16:59:05 +0300
Message-ID: <200505021659.05674.hasso@estpak.ee>
References: <1115040079.5620.11.camel@jeroens.office.netland.nl>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_pIjdCRH/C+iyHjz"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "J. Simonetti" <jeroens@office.netland.nl>
In-Reply-To: <1115040079.5620.11.camel@jeroens.office.netland.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--Boundary-00=_pIjdCRH/C+iyHjz
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

J. Simonetti wrote:
> I've recently come to notice that traceroutes through a linux router use
> the wrong ip (ip of exitting interface) wich should actually be the ip
> of the incomming interface.

There is nothing _wrong_ with this behaviour. Linux just behaves this way.

> I've found a trivial patch (attached) wich resolves this. Perhaps this
> is something to include (or have a sysctl to toggle this behaviour). I
> unfortunately have no knowledge of programming, so the sysctl option
> would have te be done by a volunteer.

Similar patches have been posted to the list repeatedly AFAIK with no any 
response from developers. Can someone enlighten us why? Is there something 
wrong with it? This is the feature people administrating routers would like 
to have. It makes debugging complicated topologies much easier and all 
routers I have seen behave this way.

I'm attaching patch which was posted to the list some time ago. I'm using it 
for some time already. I can't find the post from the archive though at the 
moment.


-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator

--Boundary-00=_pIjdCRH/C+iyHjz
Content-Type: text/x-diff;
  charset="iso-8859-6";
  name="linux-2.4.26-icmperrors.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="linux-2.4.26-icmperrors.patch"

diff -ru linux-2.4.26/include/linux/sysctl.h linux-2.4.26-icmperrors/include/linux/sysctl.h
--- linux-2.4.26/include/linux/sysctl.h	2004-04-14 14:05:40.000000000 +0100
+++ linux-2.4.26-icmperrors/include/linux/sysctl.h	2004-09-23 22:52:16.000000000 +0100
@@ -314,6 +314,7 @@
 	NET_IPV4_IPFRAG_SECRET_INTERVAL=94,
 	NET_TCP_WESTWOOD=95,
 	NET_IPV4_IGMP_MAX_MSF=96,
+	NET_IPV4_ICMP_ERRORS_USE_INBOUND_IFADDR=97,
 };
 
 enum {
diff -ru linux-2.4.26/net/ipv4/icmp.c linux-2.4.26-icmperrors/net/ipv4/icmp.c
--- linux-2.4.26/net/ipv4/icmp.c	2004-04-14 14:05:41.000000000 +0100
+++ linux-2.4.26-icmperrors/net/ipv4/icmp.c	2004-09-23 22:52:38.000000000 +0100
@@ -162,6 +162,7 @@
 
 int sysctl_icmp_ratelimit = 1*HZ;
 int sysctl_icmp_ratemask = 0x1818;
+int sysctl_icmp_errors_use_inbound_ifaddr = 0;
 
 /*
  *	ICMP control array. This specifies what to do with each ICMP.
@@ -452,8 +453,12 @@
 #endif
 
 	saddr = iph->daddr;
-	if (!(rt->rt_flags & RTCF_LOCAL))
-		saddr = 0;
+	if (!(rt->rt_flags & RTCF_LOCAL)) {
+		if(sysctl_icmp_errors_use_inbound_ifaddr)
+			saddr = inet_select_addr(skb_in->dev, 0, RT_SCOPE_LINK);
+		else
+			saddr = 0;
+	}
 
 	tos = icmp_pointers[type].error ?
 		((iph->tos & IPTOS_TOS_MASK) | IPTOS_PREC_INTERNETCONTROL) :
diff -ru linux-2.4.26/net/ipv4/sysctl_net_ipv4.c linux-2.4.26-icmperrors/net/ipv4/sysctl_net_ipv4.c
--- linux-2.4.26/net/ipv4/sysctl_net_ipv4.c	2004-04-14 14:05:41.000000000 +0100
+++ linux-2.4.26-icmperrors/net/ipv4/sysctl_net_ipv4.c	2004-09-23 22:53:07.000000000 +0100
@@ -22,6 +22,7 @@
 extern int sysctl_icmp_echo_ignore_all;
 extern int sysctl_icmp_echo_ignore_broadcasts;
 extern int sysctl_icmp_ignore_bogus_error_responses;
+extern int sysctl_icmp_errors_use_inbound_ifaddr;
 
 /* From ip_fragment.c */
 extern int sysctl_ipfrag_low_thresh;
@@ -181,6 +182,9 @@
 	{NET_IPV4_ICMP_IGNORE_BOGUS_ERROR_RESPONSES, "icmp_ignore_bogus_error_responses",
 	 &sysctl_icmp_ignore_bogus_error_responses, sizeof(int), 0644, NULL,
 	 &proc_dointvec},
+	{NET_IPV4_ICMP_ERRORS_USE_INBOUND_IFADDR, "icmp_errors_use_inbound_ifaddr",
+	 &sysctl_icmp_errors_use_inbound_ifaddr, sizeof(int), 0644, NULL,
+	 &proc_dointvec},
 	{NET_IPV4_ROUTE, "route", NULL, 0, 0555, ipv4_route_table},
 #ifdef CONFIG_IP_MULTICAST
 	{NET_IPV4_IGMP_MAX_MEMBERSHIPS, "igmp_max_memberships",

--Boundary-00=_pIjdCRH/C+iyHjz--
