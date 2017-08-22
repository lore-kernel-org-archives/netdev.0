From: "Chopra, Manish" <Manish.Chopra@cavium.com>
Subject: RE: [patch net-next] net/sched: Fix the logic error to decide the
 ingress qdisc
Date: Tue, 22 Aug 2017 20:47:38 +0000
Message-ID: <BN3PR0701MB1412C429E0CECC64429CF39289840@BN3PR0701MB1412.namprd07.prod.outlook.com>
References: <1503055460-36795-1-git-send-email-chrism@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "jiri@resnulli.us" <jiri@resnulli.us>
To: Chris Mi <chrism@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0043.outbound.protection.outlook.com ([104.47.38.43]:6608
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752955AbdHVUrk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 16:47:40 -0400
In-Reply-To: <1503055460-36795-1-git-send-email-chrism@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On=
 Behalf Of Chris Mi
Sent: Friday, August 18, 2017 4:54 PM
To: netdev@vger.kernel.org
Cc: davem@davemloft.net; jiri@resnulli.us
Subject: [patch net-next] net/sched: Fix the logic error to decide the ingr=
ess qdisc

The offending commit used a newly added helper function.
But the logic is wrong. Without this fix, the affected NICs can't do HW off=
load. Error -EOPNOTSUPP will be returned directly.

Fixes: a2e8da9378cc ("net/sched: use newly added classid identity helpers")
Signed-off-by: Chris Mi <chrism@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c       | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c   | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c    | 2 +-
 drivers/net/ethernet/netronome/nfp/bpf/main.c       | 2 +-
 drivers/net/ethernet/netronome/nfp/flower/offload.c | 2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/=
ethernet/chelsio/cxgb4/cxgb4_main.c
index 77538cd..e55a929 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2892,7 +2892,7 @@ static int cxgb_set_tx_maxrate(struct net_device *dev=
, int index, u32 rate)  static int cxgb_setup_tc_cls_u32(struct net_device =
*dev,
 				 struct tc_cls_u32_offload *cls_u32)  {
-	if (is_classid_clsact_ingress(cls_u32->common.classid) ||
+	if (!is_classid_clsact_ingress(cls_u32->common.classid) ||
 	    cls_u32->common.chain_index)
 		return -EOPNOTSUPP;
=20
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/et=
hernet/intel/ixgbe/ixgbe_main.c
index f9fd8d8..56d7ef0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9230,7 +9230,7 @@ static int ixgbe_setup_tc_cls_u32(struct net_device *=
dev,  {
 	struct ixgbe_adapter *adapter =3D netdev_priv(dev);
=20
-	if (is_classid_clsact_ingress(cls_u32->common.classid) ||
+	if (!is_classid_clsact_ingress(cls_u32->common.classid) ||
 	    cls_u32->common.chain_index)
 		return -EOPNOTSUPP;

Hi Jiri/Chris,

I was looking at ixgbe and observed that it uses "is_tcf_mirred_egress_redi=
rect()" API which works for below filter command -

     # add u32 filter with action to redirect to macvlan netdev
     tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
        handle 800:0:2 u32 ht 800: \
        match ip src 192.168.2.3/32 \
        action mirred egress redirect dev mvlan_1

Assuming that hardware actually redirect the packets to "ingress" direction=
 of mac vlan interface [that is it delivers the packet to the driver in rec=
eive flow]
Isn't the use of above API incorrect or misleading ?  shouldn't it be somet=
hing like "is_tcf_mirred_ingress_redirect()" and part of the command should=
 be replaced with below ?

action mirrred ingress redirect mvlan_1=20

Thanks,
Manish
