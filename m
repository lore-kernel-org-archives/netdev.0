From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 2/2] net: l3mdev: prefer VRF master for source address selection
Date: Mon, 22 Feb 2016 10:23:51 -0800
Message-ID: <1456165431-867-2-git-send-email-dsa@cumulusnetworks.com>
References: <1456165431-867-1-git-send-email-dsa@cumulusnetworks.com>
Cc: david@opensourcerouting.org, David Lamparter <equinox@diac24.net>,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36017 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755340AbcBVSYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 13:24:00 -0500
Received: by mail-pa0-f51.google.com with SMTP id yy13so94954465pab.3
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 10:24:00 -0800 (PST)
In-Reply-To: <1456165431-867-1-git-send-email-dsa@cumulusnetworks.com>
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
[dsa: Fixed comment style ]
---
v2
- Fixed comment per Dave's response

 net/ipv4/devinet.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 614904c29cbd..01119fbf3b30 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1217,6 +1217,24 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
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
2.1.4
