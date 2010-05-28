From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-2.6 PATCH 2/2] netlink: bug fix: wrong size was calculated for
	vfinfo list blob
Date: Fri, 28 May 2010 00:15:51 -0700
Message-ID: <20100528071551.4058.24521.stgit@localhost.localdomain>
References: <20100528071546.4058.1332.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: chrisw@redhat.com, netdev@vger.kernel.org, kaber@trash.net,
	arnd@arndb.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:41639 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753321Ab0E1HPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 03:15:52 -0400
In-Reply-To: <20100528071546.4058.1332.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

The wrong size was being calculated for vfinfo.  In one case, it was over-
calculating using nlmsg_total_size on attrs, in another case, it was
under-calculating by assuming ifla_vf_* structs are packed together, but
each struct is it's own attr w/ hdr (and padding).

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 net/core/rtnetlink.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)


diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 7331bb2..1a2af24 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -650,11 +650,12 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev)
 	if (dev->dev.parent && dev_is_pci(dev->dev.parent)) {
 
 		int num_vfs = dev_num_vf(dev->dev.parent);
-		size_t size = nlmsg_total_size(sizeof(struct nlattr));
-		size += nlmsg_total_size(num_vfs * sizeof(struct nlattr));
-		size += num_vfs * (sizeof(struct ifla_vf_mac) +
-				  sizeof(struct ifla_vf_vlan) +
-				  sizeof(struct ifla_vf_tx_rate));
+		size_t size = nla_total_size(sizeof(struct nlattr));
+		size += nla_total_size(num_vfs * sizeof(struct nlattr));
+		size += num_vfs *
+			(nla_total_size(sizeof(struct ifla_vf_mac)) +
+			 nla_total_size(sizeof(struct ifla_vf_vlan)) +
+			 nla_total_size(sizeof(struct ifla_vf_tx_rate)));
 		return size;
 	} else
 		return 0;

