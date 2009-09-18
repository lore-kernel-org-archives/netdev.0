From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 6/6] net: fix double skb free in dcbnl
Date: Thu, 17 Sep 2009 17:58:52 -0700
Message-ID: <20090918005852.25594.92386.stgit@localhost.localdomain>
References: <20090918005708.25594.52575.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	linux-scsi@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090918005708.25594.52575.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Fastabend <john.r.fastabend@intel.com>

netlink_unicast() calls kfree_skb even in the error case.

dcbnl calls netlink_unicast() which when it fails free's the
skb and returns an error value.  dcbnl is free'ing the skb
again when this error occurs.  This patch removes the double
free.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/dcb/dcbnl.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index e0879bf..ac1205d 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -194,7 +194,7 @@ static int dcbnl_reply(u8 value, u8 event, u8 cmd, u8 attr, u32 pid,
 	nlmsg_end(dcbnl_skb, nlh);
 	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
 	if (ret)
-		goto err;
+		return -EINVAL;
 
 	return 0;
 nlmsg_failure:
@@ -275,7 +275,7 @@ static int dcbnl_getpfccfg(struct net_device *netdev, struct nlattr **tb,
 
 	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
 	if (ret)
-		goto err;
+		goto err_out;
 
 	return 0;
 nlmsg_failure:
@@ -316,12 +316,11 @@ static int dcbnl_getperm_hwaddr(struct net_device *netdev, struct nlattr **tb,
 
 	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
 	if (ret)
-		goto err;
+		goto err_out;
 
 	return 0;
 
 nlmsg_failure:
-err:
 	kfree_skb(dcbnl_skb);
 err_out:
 	return -EINVAL;
@@ -383,7 +382,7 @@ static int dcbnl_getcap(struct net_device *netdev, struct nlattr **tb,
 
 	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
 	if (ret)
-		goto err;
+		goto err_out;
 
 	return 0;
 nlmsg_failure:
@@ -460,7 +459,7 @@ static int dcbnl_getnumtcs(struct net_device *netdev, struct nlattr **tb,
 	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
 	if (ret) {
 		ret = -EINVAL;
-		goto err;
+		goto err_out;
 	}
 
 	return 0;
@@ -799,7 +798,7 @@ static int __dcbnl_pg_getcfg(struct net_device *netdev, struct nlattr **tb,
 
 	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
 	if (ret)
-		goto err;
+		goto err_out;
 
 	return 0;
 
@@ -1063,7 +1062,7 @@ static int dcbnl_bcn_getcfg(struct net_device *netdev, struct nlattr **tb,
 
 	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
 	if (ret)
-		goto err;
+		goto err_out;
 
 	return 0;
 

