From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH v1 net-next 2/3] igb: move initialization of link
 properties before igb_sw_init
Date: Tue, 28 Apr 2015 03:20:18 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B78DBB061@ORSMSX101.amr.corp.intel.com>
References: <1428707018-6405-1-git-send-email-jtoppins@cumulusnetworks.com>
 <1428707018-6405-2-git-send-email-jtoppins@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:23326 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752854AbbD1DUT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 23:20:19 -0400
In-Reply-To: <1428707018-6405-2-git-send-email-jtoppins@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Jonathan Toppins
> Sent: Friday, April 10, 2015 4:04 PM
> To: Kirsher, Jeffrey T
> Cc: Brandeburg, Jesse; Nelson, Shannon; Wyborny, Carolyn; Skidmore, Donald
> C; Vick, Matthew; Ronciak, John; Williams, Mitch A; intel-wired-
> lan@lists.osuosl.org; netdev@vger.kernel.org; gospo@cumulusnetworks.com;
> shm@cumulusnetworks.com
> Subject: [PATCH v1 net-next 2/3] igb: move initialization of link
> properties before igb_sw_init
> 
> This is required otherwise the driver may experience a NULL ptr
> dereference if CONFIG_PCI_IOV is set to yes.
> 
> Since the code can follow the flow on init (driver insmod):
> 	hw->mac.autoneg = false; (this is not set it is its default)
> 	igb_probe()
> 	+- igb_sw_init()
> 	    +- igb_probe_vfs()
> 	        +- igb_pci_enable_sriov()
> 	            +- igb_sriov_reinit()
> 	               +- igb_reset()
> 	                  trimmed path is the same see call path for
> 	                  igb_reset below
> 	+- hw->mac.autoneg = true;
> 	+- igb_reset()
> 
> 	/* igb_reset() call chain */
> 	igb_reset()
> 	+- hw->mac.ops.init_hw() == igb_init_hw_82575
> 	   +- igb_setup_link()
> 	      +- hw->mac.ops.setup_physical_interface() ==
> 	           igb_setup_copper_link_82575()
> 	         +- igb_setup_copper_link()
> 	            +- possible NULL dereference
> 
> Pseudo code from igb_setup_copper_link():
> 	if (hw->mac.autoneg) {
> 	    /* setup link */
> 	} else {
> 	    hw->phy.ops.force_speed_duplex(hw);  // <-- NULL deref here
> 	}
> 
> Since the way the current code is designed the driver will call
> igb_setup_copper_link twice if SRIOV is configured to be enabled. The
> call will occur once with autoneg == false and the second
> time autoneg == true. Since the decision to call the function pointer
> (hw->phy.ops.force_speed_duplex) is predicated on autoneg being set
> correctly move the setting of these parameters to as early as possible
> in the probe function.
> 
> Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c |   16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
