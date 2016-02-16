From: David Lamparter <equinox@diac24.net>
Subject: [net-next] net: l3mdev: prefer VRF master for source address selection
Date: Wed, 17 Feb 2016 00:48:28 +0100
Message-ID: <1455666508-672875-1-git-send-email-equinox@diac24.net>
References: <20160216234115.GI659150@eidolon>
Cc: David Lamparter <equinox@diac24.net>,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([85.239.127.252]:43490 "EHLO eidolon.nox.tf"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933243AbcBPXsl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 18:48:41 -0500
In-Reply-To: <20160216234115.GI659150@eidolon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When selecting an address in context of a VRF, the vrf master should be
preferred for address selection.  If it isn't, the user has a hard time
getting the system to select to their preference - the code will pick
the address off the first in-VRF interface it can find, which on a
router could well be a non-routable address.

Cc: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: David Lamparter <equinox@diac24.net>
---

This patch applies on top of the one by dsa@ in the root of this thread.

---
 net/ipv4/devinet.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 614904c..4ba5790 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1217,6 +1217,24 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 no_in_dev:
 	master_idx = l3mdev_master_ifindex_rcu(dev);
 
+	/* For VRFs, the VRF device takes the place of the loopback device,
+	   with addresses on it being preferred.  Note in such cases the
+	   loopback device will be among the devices that fail the master_idx
+	   equality check in the loop below.
+	 */
+	if (master_idx &&
+	    (dev = dev_get_by_index_rcu(net, master_idx)) &&
+	    (in_dev = __in_dev_get_rcu(dev))) {
+
+		for_primary_ifa(in_dev) {
+			if (ifa->ifa_scope != RT_SCOPE_LINK &&
+			    ifa->ifa_scope <= scope) {
+				addr = ifa->ifa_local;
+				goto out_unlock;
+			}
+		} endfor_ifa(in_dev);
+	}
+
 	/* Not loopback addresses on loopback should be preferred
 	   in this case. It is important that lo is the first interface
 	   in dev_base list.
-- 
2.4.10
