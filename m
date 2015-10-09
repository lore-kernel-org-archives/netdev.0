From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] ipv4/icmp: redirect messages can use the ingress daddr as source
Date: Fri,  9 Oct 2015 14:34:31 +0200
Message-ID: <d10d2ec1cdf0334e9951b819051d4a127e103091.1444385951.git.pabeni@redhat.com>
Cc: Jonathan Corbet <corbet@lwn.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53284 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751262AbbJIMfB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Oct 2015 08:35:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows configuring how the source address of ICMP
redirect messages is selected; by default the old behaviour is
retained, while setting icmp_redirects_use_orig_daddr force the
usage of the destination address of the packet that caused the
redirect.

The new behaviour fits closely the RFC 5798 section 8.1.1, and fix the
following scenario:

Two machines are set up with VRRP to act as routers out of a subnet,
they have IPs x.x.x.1/24 and x.x.x.2/24, with VRRP holding on to
x.x.x.254/24.

If a host in said subnet needs to get an ICMP redirect from the VRRP
router, i.e. to reach a destination behind a different gateway, the
source IP in the ICMP redirect is chosen as the primary IP on the
interface that the packet arrived at, i.e. x.x.x.1 or x.x.x.2.

The host will then ignore said redirect, due to RFC 1122 section 3.2.2.2,
and will continue to use the wrong next-op.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 Documentation/networking/ip-sysctl.txt | 19 +++++++++++++++++--
 include/net/netns/ipv4.h               |  1 +
 net/ipv4/icmp.c                        |  9 ++++++++-
 net/ipv4/sysctl_net_ipv4.c             |  7 +++++++
 4 files changed, 33 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ebe94f2..9983825 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -884,8 +884,8 @@ icmp_ignore_bogus_error_responses - BOOLEAN
 
 icmp_errors_use_inbound_ifaddr - BOOLEAN
 
-	If zero, icmp error messages are sent with the primary address of
-	the exiting interface.
+	If zero, icmp error messages except redirects are sent with the primary
+	address of the exiting interface.
 
 	If non-zero, the message will be sent with the primary address of
 	the interface that received the packet that caused the icmp error.
@@ -897,8 +897,23 @@ icmp_errors_use_inbound_ifaddr - BOOLEAN
 	then the primary address of the first non-loopback interface that
 	has one will be used regardless of this setting.
 
+	The source address selection of icmp redirect messages is controlled by
+	icmp_errors_use_inbound_ifaddr.
 	Default: 0
 
+icmp_redirects_use_orig_daddr - BOOLEAN
+
+	If zero, icmp redirect messages are sent using the address specified for
+	other icmp errors by icmp_errors_use_inbound_ifaddr.
+
+	If non-zero, the message will be sent with the destination address of
+	the packet that caused the icmp redirect.
+	This behaviour is the preferred one on VRRP routers (see RFC 5798
+	section 8.1.1).
+
+	Default: 0
+
+
 igmp_max_memberships - INTEGER
 	Change the maximum number of multicast groups we can subscribe to.
 	Default: 20
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index c68926b..46d336a 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -74,6 +74,7 @@ struct netns_ipv4 {
 	int sysctl_icmp_ratelimit;
 	int sysctl_icmp_ratemask;
 	int sysctl_icmp_errors_use_inbound_ifaddr;
+	int sysctl_icmp_redirects_use_orig_daddr;
 
 	struct local_ports ip_local_ports;
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index e5eb8ac..3b57aa4 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -642,7 +642,9 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	 */
 
 	saddr = iph->daddr;
-	if (!(rt->rt_flags & RTCF_LOCAL)) {
+	if (!((type == ICMP_REDIRECT) &&
+	      net->ipv4.sysctl_icmp_redirects_use_orig_daddr) &&
+	    !(rt->rt_flags & RTCF_LOCAL)) {
 		struct net_device *dev = NULL;
 
 		rcu_read_lock();
@@ -1205,6 +1207,11 @@ static int __net_init icmp_sk_init(struct net *net)
 	net->ipv4.sysctl_icmp_ratemask = 0x1818;
 	net->ipv4.sysctl_icmp_errors_use_inbound_ifaddr = 0;
 
+	/* Control paramerer - use the daddr of originating packets as saddr
+	 * in redirect messages?
+	 */
+	net->ipv4.sysctl_icmp_redirects_use_orig_daddr = 0;
+
 	return 0;
 
 fail:
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 894da3a..30a531c 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -818,6 +818,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname	= "icmp_redirects_use_orig_daddr",
+		.data		= &init_net.ipv4.sysctl_icmp_redirects_use_orig_daddr,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
 		.procname	= "icmp_ratelimit",
 		.data		= &init_net.ipv4.sysctl_icmp_ratelimit,
 		.maxlen		= sizeof(int),
-- 
1.8.3.1
