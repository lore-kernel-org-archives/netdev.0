From: Francesco Fusco <ffusco@redhat.com>
Subject: [PATCH net-next] sysctl: accept_redirects do not change when disabling ip_forwarding
Date: Fri,  9 Aug 2013 10:08:59 +0200
Message-ID: <b560b71eadb678de8a573f18a10f840bf0a68df0.1375979491.git.ffusco@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61441 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030436Ab3HIIJC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Aug 2013 04:09:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sysctl behavior in the current kernel in not in synch with what is stated
in the ip-sysctl.txt documentation file. When disabling ip_forwarding the
net.ipv4.conf.all.accept_redirects is enabled without warning even if all the
accept_redirects were set to zero.

1. Set initial values of accept_redirects to zero:
	sysctl -w net.ipv4.ip_forward=1
	for i in `ls /proc/sys/net/ipv4/conf/` 
	do 
		sysctl -w net.ipv4.conf.$i.accept_redirects=0 
	done

2. Disable ip_forwarding.
	sysctl -w net.ipv4.ip_forward=0

3. Now net.ipv4.conf.all.accept_redirects will be enabled:
	syctl net.ipv4.conf.all.accept_redirects
	net.ipv4.conf.all.accept_redirects = 1

This patch prevents this issue and net.ipv4.conf.all.accept_redirects won't
be set to one after disabling forwarding.

Reported-by: Karthik <karthik@live.fi>
Signed-off-by: Francesco Fusco <ffusco@redhat.com>
---
 net/ipv4/devinet.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 43923dc..e668c3e 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1917,7 +1917,6 @@ static void inet_forward_change(struct net *net)
 	struct net_device *dev;
 	int on = IPV4_DEVCONF_ALL(net, FORWARDING);
 
-	IPV4_DEVCONF_ALL(net, ACCEPT_REDIRECTS) = !on;
 	IPV4_DEVCONF_DFLT(net, FORWARDING) = on;
 	inet_netconf_notify_devconf(net, NETCONFA_FORWARDING,
 				    NETCONFA_IFINDEX_ALL,
-- 
1.8.3.1
