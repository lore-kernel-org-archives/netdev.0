From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/7] cxgb4: add common api support for
 configuring filters
Date: Mon, 12 Sep 2016 10:57:16 +0200
Message-ID: <20160912085716.GG2021@nanopsycho>
References: <cover.1473667613.git.rahul.lakkireddy@chelsio.com>
 <05ef6c530086d3df5b8f4128141e3c12d3812105.1473667613.git.rahul.lakkireddy@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        hariprasad@chelsio.com, leedom@chelsio.com, nirranjan@chelsio.com,
        indranil@chelsio.com
To: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34220 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756792AbcILI5b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 04:57:31 -0400
Received: by mail-wm0-f65.google.com with SMTP id g141so1583848wmd.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 01:57:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <05ef6c530086d3df5b8f4128141e3c12d3812105.1473667613.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Sep 12, 2016 at 10:12:35AM CEST, rahul.lakkireddy@chelsio.com wrote:
>Enable filters for non-offload configuration and add common api support
>for setting and deleting filters in LE-TCAM region of the hardware.
>
>IPv4 filters occupy one slot.  IPv6 filters occupy 4 slots and must
>be on a 4-slot boundary.  IPv4 filters can not occupy a slot belonging
>to IPv6 and the vice-versa is also true.
>
>Filters are set and deleted asynchronously.  Use completion to wait
>for reply from firmware in order to allow for synchronization if needed.
>
>Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
>Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
>---
> drivers/net/ethernet/chelsio/cxgb4/cxgb4.h        |   3 +
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c | 424 +++++++++++++++++++++-
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h |   1 +
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c   |  33 +-
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h    |  23 +-
> 5 files changed, 453 insertions(+), 31 deletions(-)
>
>diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
>index 053976f..fbd593a 100644
>--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
>+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
>@@ -1055,7 +1055,10 @@ struct filter_entry {
> 
> 	u32 pending:1;          /* filter action is pending firmware reply */
> 	u32 smtidx:8;           /* Source MAC Table index for smac */
>+	struct filter_ctx *ctx; /* Caller's completion hook */
> 	struct l2t_entry *l2t;  /* Layer Two Table entry for dmac */
>+	struct net_device *dev; /* Associated net device */
>+	u32 tid;                /* This will store the actual tid */
> 
> 	/* The filter itself.  Most of this is a straight copy of information
> 	 * provided by the extended ioctl().  Some fields are translated to
>diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
>index 2e86902..490bd94 100644
>--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
>+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
>@@ -33,10 +33,138 @@
>  */
> 
> #include "cxgb4.h"
>+#include "t4_regs.h"
> #include "l2t.h"
> #include "t4fw_api.h"
> #include "cxgb4_filter.h"
> 
>+/* Validate filter spec against configuration done on the card.
>+ */
>+static int validate_filter(struct net_device *dev,
>+			   struct ch_filter_specification *fs)
>+{
>+	struct adapter *adapter = netdev2adap(dev);
>+	u32 fconf, iconf;
>+
>+	/* Check for unconfigured fields being used. */
>+	fconf = adapter->params.tp.vlan_pri_map;
>+	iconf = adapter->params.tp.ingress_config;
>+
>+	#define S(_field) \
>+		(fs->val._field || fs->mask._field)
>+	#define U(_mask, _field) \
>+		(!(fconf & (_mask)) && S(_field))


Wow, this is really odd. Please replace these mysterious "S" and "U"
with some properly named static helper function.


>+
>+	if (U(FCOE_F, fcoe) || U(PORT_F, iport) || U(TOS_F, tos) ||
>+	    U(ETHERTYPE_F, ethtype) || U(MACMATCH_F, macidx) ||
>+	    U(MPSHITTYPE_F, matchtype) || U(FRAGMENTATION_F, frag) ||
>+	    U(PROTOCOL_F, proto) ||
>+	    U(VNIC_ID_F, pfvf_vld) ||
>+	    U(VNIC_ID_F, ovlan_vld) ||
>+	    U(VLAN_F, ivlan_vld))
>+		return -EOPNOTSUPP;
>+
>+	/* T4 inconveniently uses the same FT_VNIC_ID_W bits for both the Outer
>+	 * VLAN Tag and PF/VF/VFvld fields based on VNIC_F being set
>+	 * in TP_INGRESS_CONFIG.  Hense the somewhat crazy checks
>+	 * below.  Additionally, since the T4 firmware interface also
>+	 * carries that overlap, we need to translate any PF/VF
>+	 * specification into that internal format below.
>+	 */
>+	if (S(pfvf_vld) && S(ovlan_vld))
>+		return -EOPNOTSUPP;
>+	if ((S(pfvf_vld) && !(iconf & VNIC_F)) ||
>+	    (S(ovlan_vld) && (iconf & VNIC_F)))
>+		return -EOPNOTSUPP;
>+	if (fs->val.pf > 0x7 || fs->val.vf > 0x7f)
>+		return -ERANGE;
>+	fs->mask.pf &= 0x7;
>+	fs->mask.vf &= 0x7f;
>+
>+	#undef S
>+	#undef U
>+
