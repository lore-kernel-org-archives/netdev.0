From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net] ipv4: igmp: Allow removing groups from a removed interface
Date: Tue,  1 Dec 2015 16:31:08 +0100
Message-ID: <1448983868-811-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50213 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753669AbbLAPbQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 10:31:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a multicast group is joined on a socket, a struct ip_mc_socklist
is appended to the sockets mc_list containing information about the
joined group.

If the interface is hot unplugged, this entry becomes stale. Prior to
commit 52ad353a5344f ("igmp: fix the problem when mc leave group") it
was possible to remove the stale entry by performing a
IP_DROP_MEMBERSHIP, passing either the old ifindex or ip address on
the interface. However, this fix enforces that the interface must
still exist. Thus with time, the number of stale entries grows, until
sysctl_igmp_max_memberships is reached and then it is not possible to
join and more groups.

The previous patch fixes an issue where a IP_DROP_MEMBERSHIP is
performed without specifying the interface, either by ifindex or ip
address. However here we do supply one of these. So loosen the
restriction on device existence to only apply when the interface has
not been specified. This then restores the ability to clean up the
stale entries.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Fixes: 52ad353a5344f "(igmp: fix the problem when mc leave group")
---
v2:

Don't dereference in_dev when it is NULL when calling
ip_mc_dec_group().

Calling ip_mc_leave_src() is safe with a NULL in_dev.
---
 net/ipv4/igmp.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 6baf36e11808..05e4cba14162 100644
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
@@ -2147,7 +2147,8 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 
 		*imlp = iml->next_rcu;
 
-		ip_mc_dec_group(in_dev, group);
+		if (in_dev)
+			ip_mc_dec_group(in_dev, group);
 
 		/* decrease mem now to avoid the memleak warning */
 		atomic_sub(sizeof(*iml), &sk->sk_omem_alloc);
-- 
2.6.2
