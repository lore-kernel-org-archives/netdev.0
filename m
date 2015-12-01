From: Maximilian Wilhelm <max@rfc2324.org>
Subject: [RFC] Stable interface index option
Date: Tue, 1 Dec 2015 13:04:20 +0100
Message-ID: <20151201120420.GT12404@principal.rfc2324.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="f0KYrhQ4vYSV2aJu"
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.rfc2324.org ([31.172.8.67]:38913 "EHLO mail.rfc2324.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755200AbbLAMXe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 07:23:34 -0500
Received: from rfc2324.org ([31.172.8.84] helo=principal.rfc2324.org)
	by mail.rfc2324.org with esmtp rfc2324.org Mailserver
	id 1a3jfQ-0000eX-QW
	for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 13:04:21 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--f0KYrhQ4vYSV2aJu
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Hi,

we are operating some free wifi networks (»Freifunk« in Germany)
including a backbone in the DFZ all running on Linux boxes, thanks to
all the cool stuff available there! :)

For a while now we are struggling with unstable/random interface
indexes as our interfaces (GRE tunnels, OpenVPN/Tinc tunnels, etc.)
come and go as users come and go and are obviously rearranged after a
reboot because of undeterministic start up behaviour of services.

Arguably we could force the interface indexes of GRE tunnels and
OpenVPN interfaces to be stable when creating them manually and not
rely on the infrastructure provided by the distribution (Debian in
most cases). That would fix some of our problems, but currently I
don't see a way to create tinc interfaces or even l2tp interfaces this
way with stable indexes.

The reason we would like to have those is quite simple: As we operate
a somewhat larger network we would like to monitor it accordingly and
see when links get saturated etc. Therefore we used snmp based
solutions and the net-snmp daemon on all the boxes. Now SNMP uses
interface indexes for identifying the interfaces. If they aren't
stable the monitoring software will see a lot of new interfaces now
and then, e.g. after a OpenVPN server/client restarted (which is bad)
or even mix up interfaces (which is worse).

As the first approach of hacking the net-snmp daemon to map the
interface ids of interfaces with certian names to stable ids got messy
and doesn't seem suitable we thought about solving the "underlying
problem" and add some mechanism for stable ids to the kernel. As there
already is an option to netlink/iproute to create certian interfaces
with a given index that seems as a nice way to go.

A prove of concept hack (see attached patch) works fine for me. The
idea I would propose would be to add some kind of bind/unbind
interface like for device drivers by which a user could add/remove and
in addition to driver bindings view the current "ifname -> ifindex"
bindings. I would assume that would best be done in sysfs? While
digging around a bit I didn't find a useful place where to place these
and I didn't find the relevant pieces of code where this is done to
add some PoC therefore as well.

I believe this would be a nice optional feature (I would assume this
would be something one could activate in Kconfig) to aid people using
Linux for heavy networking stuff. Any thoughs and hints on this?

At [42] you can see a console log showing the code works as intended.

Thanks in advance and best regards
Max

[42] http://files.rfc2324.org/kernel/stable_ifindexes/stable_ifindexes.txt
-- 
"I have to admit I've always suspected that MTBWTF would be a more useful
 metric of real-world performance."
 -- Valdis Kletnieks on NANOG

--f0KYrhQ4vYSV2aJu
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: attachment; filename="stable_ifindexes_poc.patch"

diff --git a/net/core/dev.c b/net/core/dev.c
index ae00b89..4ea2ab410 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6611,6 +6611,7 @@ int register_netdevice(struct net_device *dev)
 {
 	int ret;
 	struct net *net = dev_net(dev);
+	int ifindex = 0;
 
 	BUG_ON(dev_boot_phase);
 	ASSERT_RTNL();
@@ -6648,6 +6649,23 @@ int register_netdevice(struct net_device *dev)
 	}
 
 	ret = -EBUSY;
+	/* See if interface name is present in name2index map */
+	if (!dev->ifindex) {
+		if (strcmp (dev->name, "gre_ffrl_fra_a") == 0) {
+			ifindex = 23;
+		} else if (strcmp (dev->name, "bb-pad-cr01") == 0) {
+			ifindex = 42;
+		}
+
+		/* If we found and index and it's not already in use, use it.
+		 * XXX: One could argue that if the users wants index X and it's
+		 *      already in use, this should raise EBUSY. Not decided yet
+		 *      which way would be preferable.
+		 */
+		if (ifindex && !__dev_get_by_index(net, ifindex))
+			dev->ifindex = ifindex;
+	}
+
 	if (!dev->ifindex)
 		dev->ifindex = dev_new_index(net);
 	else if (__dev_get_by_index(net, dev->ifindex))

--f0KYrhQ4vYSV2aJu--
