From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v3 2/2] net: l3mdev: prefer VRF master for source address selection
Date: Wed, 24 Feb 2016 11:47:03 -0800
Message-ID: <1456343223-17622-3-git-send-email-dsa@cumulusnetworks.com>
References: <1456343223-17622-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Lamparter <equinox@diac24.net>,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34343 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753607AbcBXTrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 14:47:15 -0500
Received: by mail-pa0-f44.google.com with SMTP id fy10so17960007pac.1
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 11:47:15 -0800 (PST)
In-Reply-To: <1456343223-17622-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lamparter <equinox@diac24.net>

When selecting an address in context of a VRF, the vrf master should be
preferred for address selection.  If it isn't, the user has a hard time
getting the system to select to their preference - the code will pick
the address off the first in-VRF interface it can find, which on a
router could well be a non-routable address.

Signed-off-by: David Lamparter <equinox@diac24.net>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
[dsa: Fixed comment style and removed extra blank link ]
---
v3
- removed blank link

v2
- fixed comment to use preferred style for net code

 net/ipv4/devinet.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 18d510fa7ee2..8c3df2ccba45 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1217,6 +1217,23 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 no_in_dev:
 	master_idx = l3mdev_master_ifindex_rcu(dev);
 
+	/* For VRFs, the VRF device takes the place of the loopback device,
+	 * with addresses on it being preferred.  Note in such cases the
+	 * loopback device will be among the devices that fail the master_idx
+	 * equality check in the loop below.
+	 */
+	if (master_idx &&
+	    (dev = dev_get_by_index_rcu(net, master_idx)) &&
+	    (in_dev = __in_dev_get_rcu(dev))) {
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
2.1.4
