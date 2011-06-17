From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH 1/7] dcb: Add DCBX capabilities bitmask to the get_ieee
	response
Date: Fri, 17 Jun 2011 14:16:13 -0700
Message-ID: <20110617211613.26578.63959.stgit@jf-dev1-dcblab>
References: <20110617211027.26578.11317.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shmulikr@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16974 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755629Ab1FQVWx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2011 17:22:53 -0400
In-Reply-To: <20110617211027.26578.11317.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding the capabilities bitmask to the get_ieee response allows
user space to determine the current DCBX mode. Either CEE or IEEE
this is useful with devices that support switching between modes
where knowing the current state is relevant.

Derived from work by Mark Rustad

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/dcb/dcbnl.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index ed1bb8c..3a6d97d 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1288,6 +1288,7 @@ static int dcbnl_ieee_get(struct net_device *netdev, struct nlattr **tb,
 	struct nlattr *ieee, *app;
 	struct dcb_app_type *itr;
 	const struct dcbnl_rtnl_ops *ops = netdev->dcbnl_ops;
+	int dcbx;
 	int err;
 
 	if (!ops)
@@ -1338,6 +1339,12 @@ static int dcbnl_ieee_get(struct net_device *netdev, struct nlattr **tb,
 			}
 		}
 	}
+
+	if (netdev->dcbnl_ops->getdcbx)
+		dcbx = netdev->dcbnl_ops->getdcbx(netdev);
+	else
+		dcbx = -EOPNOTSUPP;
+
 	spin_unlock(&dcb_lock);
 	nla_nest_end(skb, app);
 
@@ -1366,6 +1373,11 @@ static int dcbnl_ieee_get(struct net_device *netdev, struct nlattr **tb,
 	}
 
 	nla_nest_end(skb, ieee);
+	if (dcbx >= 0) {
+		err = nla_put_u8(skb, DCB_ATTR_DCBX, dcbx);
+		if (err)
+			goto nla_put_failure;
+	}
 	nlmsg_end(skb, nlh);
 
 	return rtnl_unicast(skb, &init_net, pid);

