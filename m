From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net] ipv4: igmp: Allow removing groups from a removed interface
Date: Wed, 25 Nov 2015 21:15:36 +0100
Message-ID: <1448482536-26081-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41928 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751671AbbKYUPk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2015 15:15:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a multicast group is joined on a socket, a struct ip_mc_socklist
is appended to the sockets mc_list containing information about the
joined group.

If the interface is hot unplugged, this entry becomes stale. Prior to
52ad353a5344f "(igmp: fix the problem when mc leave group") it was
possible to remove the stale entry by performing a IP_DROP_MEMBERSHIP,
passing either the old ifindex or ip address on the
interface. However, this fix enforces that the interface must still
exist. Thus with time, the number of stale entries grows, until
sysctl_igmp_max_memberships is reached and then it is not possible to
join any more groups.

The 52ad353a5344f fixes an issue where a IP_DROP_MEMBERSHIP is
performed without specifying the interface, either by ifindex or ip
address. However here we do supply one of these. So loosen the
restriction on device existence to only apply when the interface has
not been specified. This then restores the ability to clean up the
stale entries.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Fixes: 52ad353a5344f "(igmp: fix the problem when mc leave group")
---
 net/ipv4/igmp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 6baf36e11808..e31dd1f0a55e 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2126,7 +2126,7 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 	ASSERT_RTNL();
 
 	in_dev = ip_mc_find_dev(net, imr);
-	if (!in_dev) {
+	if (!imr->imr_ifindex && !imr->imr_address.s_addr && !in_dev) {
 		ret = -ENODEV;
 		goto out;
 	}
-- 
2.6.2
