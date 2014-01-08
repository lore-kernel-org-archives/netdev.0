From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net 1/2] bonding: ensure that the TSO being set on bond
 master
Date: Wed, 8 Jan 2014 09:33:03 +0100
Message-ID: <20140108083303.GA28509@redhat.com>
References: <52CCFE18.7040606@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57054 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755170AbaAHIgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 03:36:08 -0500
Content-Disposition: inline
In-Reply-To: <52CCFE18.7040606@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 08, 2014 at 03:28:24PM +0800, Ding Tianhong wrote:
>The commit b0ce3508(bonding: allow TSO being set on bonding master)
>has make the TSO being set for bond dev, but in some situation, if
>the slave did not have the NETIF_F_SG features, the bond master will
>miss the TSO features in netdev_fix_features because the TSO is
>depended on SG. So I have to add SG and TSO features on bond master
>together.

Do you know why TSO depends on SG? And what will happen if bonding supports
SG, but one of its slaves doesn't?

>
>The netdev_add_tso_features() was only used for bonding, so I think no
>need to export it to netdevice.h.
>
>Cc: Eric Dumazet <edumazet@google.com>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>---
> drivers/net/bonding/bond_main.c | 16 +++++++++++++++-
> 1 file changed, 15 insertions(+), 1 deletion(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index e06c445..8ce67ed 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1045,6 +1045,20 @@ static void bond_netpoll_cleanup(struct net_device *bond_dev)
>
> /*---------------------------------- IOCTL ----------------------------------*/
>
>+/* Allow TSO being used on stacked device:
>+ * Performing the GSO segmentation before last device
>+ * is a performance improvement.
>+ * The TSO is depended on SG, so add SG and TSO together,
>+ * otherwise the netdev_fix_features() may clean the TSO.
>+ */
>+static netdev_features_t bond_add_tso_features(netdev_features_t features,
>+					       netdev_features_t mask)
>+{
>+	return netdev_increment_features(features,
>+					 NETIF_F_ALL_TSO | NETIF_F_SG,
>+					 mask);
>+}
>+
> static netdev_features_t bond_fix_features(struct net_device *dev,
> 					   netdev_features_t features)
> {
>@@ -1068,7 +1082,7 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
> 						     slave->dev->features,
> 						     mask);
> 	}
>-	features = netdev_add_tso_features(features, mask);
>+	features = bond_add_tso_features(features, mask);
>
> 	return features;
> }
>-- 
>1.8.0
>
>
>
