From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 6/7] cxgb4: add support for deleting u32 filters
Date: Mon, 12 Sep 2016 10:47:11 +0200
Message-ID: <20160912084711.GE2021@nanopsycho>
References: <cover.1473667613.git.rahul.lakkireddy@chelsio.com>
 <01b1dd8d57eb3ebb2e8a5f338a956f300de5f841.1473667613.git.rahul.lakkireddy@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        hariprasad@chelsio.com, leedom@chelsio.com, nirranjan@chelsio.com,
        indranil@chelsio.com
To: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36235 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751579AbcILIrP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 04:47:15 -0400
Received: by mail-wm0-f66.google.com with SMTP id z194so209182wmd.3
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 01:47:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <01b1dd8d57eb3ebb2e8a5f338a956f300de5f841.1473667613.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Sep 12, 2016 at 10:12:39AM CEST, rahul.lakkireddy@chelsio.com wrote:
>Add support for deleting an offloaded u32 filter from hardware.  If a
>link is deleted, then all corresponding filters associated with the link
>are also deleted.  Also enable hardware tc offload as a supported
>feature.
>
>Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
>Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

I don't understand why add and delete are 2 separate patches. I believe
it should go in one.



>---
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c   |  5 +-
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c | 92 +++++++++++++++++++++++
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h |  2 +
> 3 files changed, 98 insertions(+), 1 deletion(-)
>
>diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
>index 28396f5..087066a 100644
>--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
>+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
>@@ -3047,6 +3047,8 @@ int cxgb_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
> 		case TC_CLSU32_NEW_KNODE:
> 		case TC_CLSU32_REPLACE_KNODE:
> 			return cxgb4_config_knode(dev, proto, tc->cls_u32);
>+		case TC_CLSU32_DELETE_KNODE:
>+			return cxgb4_delete_knode(dev, proto, tc->cls_u32);
> 		default:
> 			return -EOPNOTSUPP;
> 		}
>@@ -5155,7 +5157,8 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
> 		netdev->hw_features = NETIF_F_SG | TSO_FLAGS |
> 			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> 			NETIF_F_RXCSUM | NETIF_F_RXHASH |
>-			NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
>+			NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX |
>+			NETIF_F_HW_TC;
> 		if (highdma)
> 			netdev->hw_features |= NETIF_F_HIGHDMA;
> 		netdev->features |= netdev->hw_features;
>diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
>index 62c1695..31847e3 100644
>--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
>+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
>@@ -279,6 +279,98 @@ out:
> 	return ret;
> }
> 
>+int cxgb4_delete_knode(struct net_device *dev, __be16 protocol,
>+		       struct tc_cls_u32_offload *cls)
>+{
>+	struct adapter *adapter = netdev2adap(dev);
>+	struct cxgb4_tc_u32_table *t;
>+	struct cxgb4_link *link = NULL;
>+	struct filter_ctx ctx;
>+	u32 handle, uhtid;
>+	unsigned int filter_id;
>+	unsigned int max_tids;
>+	unsigned int i, j;
>+	int ret;
>+
>+	if (!can_tc_u32_offload(dev))
>+		return -EOPNOTSUPP;
>+
>+	/* Fetch the location to delete the filter. */
>+	filter_id = (cls->knode.handle & 0xFFFFF);

Again with the (). Looks like you have it all over the place.


>+
>+	if (filter_id > adapter->tids.nftids) {
>+		dev_err(adapter->pdev_dev,
>+			"Location %d out of range for deletion. Max: %d\n",
>+			filter_id, adapter->tids.nftids);
>+		return -ERANGE;
>+	}
>+
>+	t = adapter->tc_u32;
>+	handle = cls->knode.handle;
>+	uhtid = TC_U32_USERHTID(cls->knode.handle);
>+
>+	/* Ensure that uhtid is either root u32 (i.e. 0x800)
>+	 * or a a valid linked bucket.
>+	 */
>+	if (uhtid != 0x800 && uhtid >= t->size)
>+		return -EINVAL;
>+
>+	/* Delete the specified filter */
>+	if (uhtid != 0x800) {
>+		link = &t->table[uhtid - 1];
>+		if (!link->link_handle)
>+			return -EINVAL;
>+
>+		if (!test_bit(filter_id, link->tid_map))
>+			return -EINVAL;
>+	}
>+
>+	init_completion(&ctx.completion);
>+
>+	ret = cxgb4_del_filter(dev, filter_id, &ctx);
>+	if (ret)
>+		goto out;
>+
>+	/* Wait for reply */
>+	ret = wait_for_completion_timeout(&ctx.completion, 10 * HZ);
>+	if (!ret)
>+		return -ETIMEDOUT;


Hmm, I think it would be nicer to have the completion dance wrapped
inside cxgb4_del_filter and have __cxgb4_del_filter for case you don't
need it.


>+
>+	ret = ctx.result;
>+	if (!ret && link)
>+		clear_bit(filter_id, link->tid_map);
>+
>+	/* If a link is being deleted, then delete all filters
>+	 * associated with the link.
>+	 */
>+	max_tids = adapter->tids.nftids;
>+	for (i = 0; i < t->size; i++) {
>+		link = &t->table[i];
>+
>+		if (link->link_handle == handle) {
>+			for (j = 0; j < max_tids; j++) {
>+				if (!test_bit(j, link->tid_map))
>+					continue;
>+
>+				ret = cxgb4_del_filter(dev, j, NULL);
>+				if (ret)
>+					goto out;
>+
>+				clear_bit(j, link->tid_map);
>+			}
>+
>+			/* Clear the link state */
>+			link->match_field = NULL;
>+			link->link_handle = 0;
>+			memset(&link->fs, 0, sizeof(link->fs));
>+			break;
>+		}
>+	}
>+
>+out:
>+	return ret;
>+}
>+
> void cxgb4_cleanup_tc_u32(struct adapter *adap)
> {
> 	struct cxgb4_tc_u32_table *t;
>diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h
>index 46575843..6bdc885 100644
>--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h
>+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h
>@@ -48,6 +48,8 @@ static inline bool can_tc_u32_offload(struct net_device *dev)
> 
> int cxgb4_config_knode(struct net_device *dev, __be16 protocol,
> 		       struct tc_cls_u32_offload *cls);
>+int cxgb4_delete_knode(struct net_device *dev, __be16 protocol,
>+		       struct tc_cls_u32_offload *cls);
> 
> void cxgb4_cleanup_tc_u32(struct adapter *adapter);
> struct cxgb4_tc_u32_table *cxgb4_init_tc_u32(struct adapter *adap,
>-- 
>2.5.3
>
