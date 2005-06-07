From: "J. Simonetti" <jeroen@simonetti.nl>
Subject: Re: [PATCH 1/1] sysctl configurable icmperror sourceaddress
Date: Tue, 07 Jun 2005 11:40:50 +0200
Message-ID: <1118137250.10479.17.camel@jeroens.office.netland.nl>
References: <1118136384.10479.15.camel@jeroens.office.netland.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-XV4zojviW1nuiDFTTQao"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1118136384.10479.15.camel@jeroens.office.netland.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-XV4zojviW1nuiDFTTQao
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2005-06-07 at 11:26 +0200, J. Simonetti wrote:
> This patch alows you to change the source address of icmp error
> messages. It applies cleanly to 2.6.11.11 and retains the default
> behaviour.

I swear I had attached it... really... ;)

Jeroen Simonetti
--
character density, n.:
	The number of very weird people in the office.

--=-XV4zojviW1nuiDFTTQao
Content-Disposition: attachment; filename=linux-2.6.11.11-icmperrors.patch
Content-Type: text/x-patch; name=linux-2.6.11.11-icmperrors.patch; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- include/linux/sysctl.h.orig	2004-12-24 22:34:58.000000000 +0100
+++ include/linux/sysctl.h	2005-06-07 10:16:39.730585288 +0200
@@ -345,6 +345,7 @@
 	NET_TCP_MODERATE_RCVBUF=106,
 	NET_TCP_TSO_WIN_DIVISOR=107,
	NET_TCP_BIC_BETA=108,
+	NET_IPV4_ICMP_ERRORS_USE_INBOUND_IFADDR=109,
 };
 
 enum {
--- net/ipv4/icmp.c.orig	2004-12-24 22:35:28.000000000 +0100
+++ net/ipv4/icmp.c	2005-06-07 10:15:42.645263576 +0200
@@ -207,6 +207,7 @@
 
 int sysctl_icmp_ratelimit = 1 * HZ;
 int sysctl_icmp_ratemask = 0x1818;
+int sysctl_icmp_errors_use_inbound_ifaddr = 0;
 
 /*
  *	ICMP control array. This specifies what to do with each ICMP.
@@ -511,8 +512,12 @@
 	 */
 
 	saddr = iph->daddr;
-	if (!(rt->rt_flags & RTCF_LOCAL))
-		saddr = 0;
+	if (!(rt->rt_flags & RTCF_LOCAL)) {
+		if(sysctl_icmp_errors_use_inbound_ifaddr)
+			saddr = inet_select_addr(skb_in->dev, 0, RT_SCOPE_LINK);
+		else
+			saddr = 0;
+	}
 
 	tos = icmp_pointers[type].error ? ((iph->tos & IPTOS_TOS_MASK) |
 					   IPTOS_PREC_INTERNETCONTROL) :
--- net/ipv4/sysctl_net_ipv4.c.orig	2004-12-24 22:35:23.000000000 +0100
+++ net/ipv4/sysctl_net_ipv4.c	2005-06-07 10:19:44.538490216 +0200
@@ -23,6 +23,7 @@
 extern int sysctl_icmp_echo_ignore_all;
 extern int sysctl_icmp_echo_ignore_broadcasts;
 extern int sysctl_icmp_ignore_bogus_error_responses;
+extern int sysctl_icmp_errors_use_inbound_ifaddr;
 
 /* From ip_fragment.c */
 extern int sysctl_ipfrag_low_thresh;
@@ -396,6 +397,14 @@
 		.proc_handler	= &proc_dointvec
 	},
 	{
+		.ctl_name	= NET_IPV4_ICMP_ERRORS_USE_INBOUND_IFADDR,
+		.procname	= "icmp_errors_use_inbound_ifaddr",
+		.data		= &sysctl_icmp_errors_use_inbound_ifaddr,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
+	{
 		.ctl_name	= NET_IPV4_ROUTE,
 		.procname	= "route",
 		.maxlen		= 0,

--=-XV4zojviW1nuiDFTTQao--
