From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH] ixgbe: Correctly disable vlan filter in promiscuous mode
Date: Tue, 18 Nov 2014 20:24:26 +0000
Message-ID: <87618083B2453E4A8714035B62D679925019F38A@FMSMSX105.amr.corp.intel.com>
References: <1416338897-13007-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: Vladislav Yasevich <vyasevich@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:14953 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754223AbaKRUY2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 15:24:28 -0500
In-Reply-To: <1416338897-13007-1-git-send-email-vyasevic@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-
>owner@vger.kernel.org] On Behalf Of Vladislav Yasevich
>Sent: Tuesday, November 18, 2014 11:28 AM
>To: netdev@vger.kernel.org
>Cc: Vladislav Yasevich; Kirsher, Jeffrey T; Keller, Jacob E
>Subject: [PATCH] ixgbe: Correctly disable vlan filter in promiscuous mode
>
>IXGBE adapater seems to require that vlan filtering be enabled if VMDQ
>or SRIOV are enabled.  When those functions are disabled,
>vlan filtering may be disabled in promiscuous mode.
>
>Prior to commit a9b8943ee129e11045862d6d6e25c5b63c95403c
>    ixgbe: remove vlan_filter_disable and enable functions
>
>the logic was correct.  However, after the commit the logic
>got reversed and vlan filtered in now turned on when VMDQ/SRIOV
>is disabled.
>
>This patch changes the condition to enable hw vlan filtered
>when VMDQ or SRIOV is enabled.
>
>Fixes: a9b8943ee129e11045862d6d6e25c5b63c95403c (ixgbe:
>remove
>vlan_filter_disable and enable functions)
>CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>CC: Jacob Keller <jacob.e.keller@intel.com>
>Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>---
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>index d2df4e3..3f81c7a 100644
>--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>@@ -3936,8 +3936,8 @@ void ixgbe_set_rx_mode(struct
>net_device *netdev)
> 		 * if SR-IOV and VMDQ are disabled - otherwise ensure
> 		 * that hardware VLAN filters remain enabled.
> 		 */
>-		if (!(adapter->flags & (IXGBE_FLAG_VMDQ_ENABLED |
>-					IXGBE_FLAG_SRIOV_ENABLED)))
>+		if (adapter->flags & (IXGBE_FLAG_VMDQ_ENABLED |
>+				      IXGBE_FLAG_SRIOV_ENABLED))
> 			vlnctrl |= (IXGBE_VLNCTRL_VFE |
>IXGBE_VLNCTRL_CFIEN);
> 	} else {
> 		if (netdev->flags & IFF_ALLMULTI) {

The current logic is correct and it's like this on purpose as it should be obvious by the comment preceding this check. The reason for not disabling the vlan filters in promisc mode is because this can break VLAN isolation between VMs which is considered a security risk.

There is another patch that was proposed:
http://marc.info/?l=linux-netdev&m=141586938625969

which should do what you want using an ethtool toggle.

Thanks,
Emil
