From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Sun, 22 May 2011 12:39:18 -0700
Message-ID: <m1ei3qjzix.fsf_-_@fess.ebiederm.org>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
	<20110412.141645.112604563.davem@davemloft.net>
	<BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
	<20110521072925.GA2588@jirka.orion>
	<BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
	<4DD7BB61.9050200@gmail.com>
	<BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
	<4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>
	<m17h9jp7js.fsf@fess.ebiederm.org>
	<BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>,
	Nicolas de =?utf-8?Q?Peslo=C3=BCan?=
	<nicolas.2p.debian@gmail.com>, Changli Gao <xiaosuo@gmail.com>,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60195 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752237Ab1EVTj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 15:39:26 -0400
In-Reply-To: <BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com> (Jesse
	Gross's message of "Sun, 22 May 2011 09:11:01 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Simplify the vlan handling code by not supporing clearing of
VLAN_FLAG_REORDER_HDR.  Which means we always make the vlan handling
code strip the vlan header from the packets, and always insert the vlan
header when transmitting packets.

Not stripping the vlan header has alwasy been broken in combination with
vlan hardware accelleration.  Now that we are making everything look
like accelerated vlan handling not stripping the vlan header is always
broken.

I don't think anyone actually cares so simply stop supporting the broken
case.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/8021q/vlan_dev.c     |    3 +--
 net/8021q/vlan_netlink.c |    4 +---
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index f247f5b..20629fe 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -242,8 +242,7 @@ int vlan_dev_change_flags(const struct net_device *dev, u32 flags, u32 mask)
 	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	u32 old_flags = vlan->flags;
 
-	if (mask & ~(VLAN_FLAG_REORDER_HDR | VLAN_FLAG_GVRP |
-		     VLAN_FLAG_LOOSE_BINDING))
+	if (mask & ~(VLAN_FLAG_GVRP | VLAN_FLAG_LOOSE_BINDING))
 		return -EINVAL;
 
 	vlan->flags = (old_flags & ~mask) | (flags & mask);
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index be9a5c1..a638a4c 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -59,9 +59,7 @@ static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
 	}
 	if (data[IFLA_VLAN_FLAGS]) {
 		flags = nla_data(data[IFLA_VLAN_FLAGS]);
-		if ((flags->flags & flags->mask) &
-		    ~(VLAN_FLAG_REORDER_HDR | VLAN_FLAG_GVRP |
-		      VLAN_FLAG_LOOSE_BINDING))
+		if (flags->mask & ~(VLAN_FLAG_GVRP | VLAN_FLAG_LOOSE_BINDING))
 			return -EINVAL;
 	}
 
-- 
1.7.5.1.217.g4e3aa

