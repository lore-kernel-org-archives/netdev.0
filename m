From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [RFC PATCH net] IPv6: Fix broken IPv6 routing table after loopback down-up
Date: Wed, 22 Jan 2014 16:35:08 +0100
Message-ID: <1390404908-3914-1-git-send-email-sd@queasysnail.net>
Cc: hannes@stressinduktion.org, gaofeng@cn.fujitsu.com,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:33524 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755238AbaAVPgA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 10:36:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch solves bug 67951 on bugzilla
https://bugzilla.kernel.org/show_bug.cgi?id=67951

> Bug: No reply after loopback down-up
> 
> kernel:3.13.0-rc4
> 
> I did a test like this:
> On host1:
> 1)ifconfig eth0 add fd00::3
> On host2:
> 1)ifconfig eth0 add fd00::4
> 2)ping6 fd00::3
> 
> Everything went OK.
> 
> Then:
> On host1:
> 1)ifconfig lo down;ifconfig lo up
> On hsot2:
> 1)ping6 fd00::3
> 
> There was no reply from host1!


Reply from Hannes:

> This was first fixed with 25fb6ca4ed9cad72f14f61629b68dc03c0d9713f
> ("net IPv6 : Fix broken IPv6 routing table after loopback down-up")
> and broken again in a881ae1f625c599b460cc8f8a7fcb1c438f699ad ("ipv6:
> don't call addrconf_dst_alloc again when enable lo")

This patch first reverts commit a881ae1f625, since from what I can
see, it actually stops all local routes from being added back, instead
of just the sit ones. Which is actually good, since even with a normal
interface (tried with e1000 in qemu), when I reverted a881ae1f625, I
could get the "unregister_netdevice" problem when doing rmmod e1000:

unregister_netdevice: waiting for ens3 to become free. Usage count = 1

(repeated until I removed the local routes manually)

The patch then adds a function that detects if the local route for an
IP address has been re-created before init_loopback is called. That
way, we avoid the usage count problem, but if we do a down-up on
loopback, the necessary routes are created.


Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---

I'm sending this as a RFC, because I'm not sure the way I detect if
the route has been added before is good.

It works in my tests (below). Is the call to rt6_lookup ok? Or is
there a better way to do that? The flags checked are the ones set by
addrconf_dst_alloc, so that if the route returned by rt6_lookup isn't
the local route for this IP address, it should be ignored and a new
local route created.

I've put addrconf_dst_alloc_once right above init_loopback in
addrconf.c, but it could go somewhere else, or be included directly in
init_loopback.



All suggestions and comments are welcome.

Thanks,
Sabrina

---

Here are the tests. They all fail with the unregister_netdevice
problem if I simply revert the a881ae1f625, but everything looks fine
with the patch below: no unregister_netdevice problem, and all the
local routes are back, ping works.

---

#############
# sit tests #
#############

# setup sit
ip tunnel add sit1 mode sit remote 10.0.1.10 local 10.0.1.24 ttl 10
ip link set sit1 up
ip a a fd00::1/64 dev sit1
ip r a ::/0 dev sit1

# test 1
ifconfig lo down ; ifconfig lo up
ip tunnel del sit1

# test 2
# before: setup sit tunnel again
ifconfig lo down ; ifconfig ens3 down ; ifconfig sit1 down ; ifconfig sit1 up
ip a a fd00::1/64 dev sit1
./ens3.sh
ifconfig lo up
ip tunnel del sit1


###############
# e1000 tests #
###############

#########
# ens3.sh
ifconfig ens3 up
ip a a fec0::3456/64 dev ens3
#########

./ens3.sh

# test 1
ifconfig lo down ; ifconfig lo up
rmmod e1000

# test 2
# before: setup things again
ifconfig lo down ; ifconfig ens3 down
./ens3.sh
ifconfig lo up
rmmod e1000


---
 net/ipv6/addrconf.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4b6b720..b2eb653 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2578,6 +2578,23 @@ static void sit_add_v4_addrs(struct inet6_dev *idev)
 }
 #endif
 
+struct rt6_info *addrconf_dst_alloc_once(struct inet6_dev *idev,
+					 const struct in6_addr *addr,
+					 bool anycast)
+{
+	struct net *net = dev_net(idev->dev);
+	struct rt6_info *rt = rt6_lookup(net, addr, NULL, 0, 0);
+
+	if (rt == NULL)
+		return addrconf_dst_alloc(idev, addr, anycast);
+	else if (!(rt->rt6i_flags & RTF_NONEXTHOP &&
+		   ((anycast && rt->rt6i_flags & RTF_ANYCAST) ||
+		    (!anycast && rt->rt6i_flags & RTF_LOCAL))))
+		return addrconf_dst_alloc(idev, addr, anycast);
+
+	return ERR_PTR(-EEXIST);
+}
+
 static void init_loopback(struct net_device *dev)
 {
 	struct inet6_dev  *idev;
@@ -2611,10 +2628,7 @@ static void init_loopback(struct net_device *dev)
 			if (sp_ifa->flags & (IFA_F_DADFAILED | IFA_F_TENTATIVE))
 				continue;
 
-			if (sp_ifa->rt)
-				continue;
-
-			sp_rt = addrconf_dst_alloc(idev, &sp_ifa->addr, false);
+			sp_rt = addrconf_dst_alloc_once(idev, &sp_ifa->addr, false);
 
 			/* Failure cases are ignored */
 			if (!IS_ERR(sp_rt)) {
-- 
1.8.5.3
