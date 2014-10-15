From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH v3 net] ixgbe: check adapter->vfinfo before dereference
Date: Wed, 15 Oct 2014 22:50:31 +0000
Message-ID: <87618083B2453E4A8714035B62D67992500E2629@FMSMSX105.amr.corp.intel.com>
References: <1412930732-892-1-git-send-email-thierry.herbelot@6wind.com>
 <1413367080-31540-1-git-send-email-thierry.herbelot@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Thierry Herbelot <thierry.herbelot@6wind.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:49789 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750809AbaJOWul convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 18:50:41 -0400
In-Reply-To: <1413367080-31540-1-git-send-email-thierry.herbelot@6wind.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Thierry Herbelot [mailto:thierry.herbelot@6wind.com]
>Sent: Wednesday, October 15, 2014 2:58 AM
>To: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W;
>netdev@vger.kernel.org; Tantilov, Emil S
>Cc: Thierry Herbelot
>Subject: [PATCH v3 net] ixgbe: check adapter->vfinfo before dereference
>
>this protects against the following panic:
>(before a VF was actually created on p96p1 PF Ethernet port)
>
>ip link set p96p1 vf 0 spoofchk off
>BUG: unable to handle kernel NULL pointer dereference at 0000000000000052
>IP: [<ffffffffa044a1c1>]
>ixgbe_ndo_set_vf_spoofchk+0x51/0x150 [ixgbe]
>
>Signed-off-by: Thierry Herbelot <thierry.herbelot@6wind.com>
>---
>
>v2:
>  compilation fixes
>
>v3:
>  remove checks in functions where vfinfo is known not to be NULL
>  return -EINVAL as error code
>
> drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |   42
>++++++++++++++++++++++--
> 1 file changed, 40 insertions(+), 2 deletions(-)

Actually looking into this a bit more, the check for vfinfo is not sufficient
because it does not protect against specifying vf that is outside of sriov_num_vfs range.

All of the ndo functions have a check for it except for ixgbevf_ndo_set_spoofcheck().

The following patch should be all we need to protect against this panic:

This patch adds a check to return -EINVAL when setting spoofcheck on
VF that is not configured.

Reported-by: Thierry Herbelot <thierry.herbelot@6wind.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 706fc69..97c85b8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -1261,6 +1261,9 @@ int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 regval;
 
+	if (vf >= adapter->num_vfs)
+		return -EINVAL;
+
 	adapter->vfinfo[vf].spoofchk_enabled = setting;
 
 	regval = IXGBE_READ_REG(hw, IXGBE_PFVFSPOOF(vf_target_reg));
