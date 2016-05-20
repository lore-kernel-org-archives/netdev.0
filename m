From: Ezequiel Garcia <ezequiel@vanguardiasur.com.ar>
Subject: [PATCH] ipv4: Fix non-initialized TTL when CONFIG_SYSCTL=n
Date: Fri, 20 May 2016 13:21:10 -0300
Message-ID: <1463761270-8955-1-git-send-email-ezequiel@vanguardiasur.com.ar>
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	Ezequiel Garcia <ezequiel@vanguardiasur.com.ar>
To: <netdev@vger.kernel.org>, Nikolay Borisov <kernel@kyup.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:36365 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755845AbcETQVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 12:21:34 -0400
Received: by mail-qk0-f177.google.com with SMTP id x7so69378277qkd.3
        for <netdev@vger.kernel.org>; Fri, 20 May 2016 09:21:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit fa50d974d104 ("ipv4: Namespaceify ip_default_ttl sysctl knob")
moves the default TTL assignment, and as side-effect IPv4 TTL now
has a default value only if sysctl support is enabled (CONFIG_SYSCTL=y).

The sysctl_ip_default_ttl is fundamental for IP to work properly,
as it provides the TTL to be used as default. The defautl TTL may be
used in ip_selected_ttl, through the following flow:

  ip_select_ttl
    ip4_dst_hoplimit
      net->ipv4.sysctl_ip_default_ttl

This commit fixes the issue by assigning net->ipv4.sysctl_ip_default_ttl
in net_init_net, called during ipv4's initialization.

Without this commit, a kernel built without sysctl support will send
all IP packets with zero TTL (unless a TTL is explicitly set, e.g.
with setsockopt).

Given a similar issue might appear on the other knobs that were
namespaceify, this commit also moves them.

Fixes: fa50d974d104 ("ipv4: Namespaceify ip_default_ttl sysctl knob")
Signed-off-by: Ezequiel Garcia <ezequiel@vanguardiasur.com.ar>
---
 net/ipv4/af_inet.c         | 8 ++++++++
 net/ipv4/sysctl_net_ipv4.c | 4 ----
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 2e6e65fc4d20..8d334816f89d 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1697,6 +1697,14 @@ static __net_init int inet_init_net(struct net *net)
 	 */
 	net->ipv4.ping_group_range.range[0] = make_kgid(&init_user_ns, 1);
 	net->ipv4.ping_group_range.range[1] = make_kgid(&init_user_ns, 0);
+
+	/* Default values for sysctl-controlled parameters.
+	 * We set them here, in case sysctl is not compiled.
+	 */
+	net->ipv4.sysctl_ip_default_ttl = IPDEFTTL;
+	net->ipv4.sysctl_ip_dynaddr = 0;
+	net->ipv4.sysctl_ip_early_demux = 1;
+
 	return 0;
 }
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index bb0419582b8d..1cb67de106fe 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -999,10 +999,6 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 	if (!net->ipv4.sysctl_local_reserved_ports)
 		goto err_ports;
 
-	net->ipv4.sysctl_ip_default_ttl = IPDEFTTL;
-	net->ipv4.sysctl_ip_dynaddr = 0;
-	net->ipv4.sysctl_ip_early_demux = 1;
-
 	return 0;
 
 err_ports:
-- 
2.7.0
