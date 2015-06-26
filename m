From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net 06/10] e1000e: i219 - increase IPG for speed 10/100 full
 duplex
Date: Fri, 26 Jun 2015 14:30:45 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB57C45@AcuExch.aculab.com>
References: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1435314040-3228-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Yanir Lubetkin <yanirx.lubetkin@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: 'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.190]:52174 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772AbbFZOdW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 10:33:22 -0400
In-Reply-To: <1435314040-3228-7-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Of Jeff Kirsher
> Sent: 26 June 2015 11:21
> In SPT/i219, there were CRC errors in speed 10/100 full duplex.
> The solution given by the HW team is to increase the IPG from 8 to 0xC
> 
> Signed-off-by: Yanir Lubetkin <yanirx.lubetkin@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/e1000e/ich8lan.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
> index c5bb1dd..983f5bf 100644
> --- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
> +++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
> @@ -1400,16 +1400,20 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
>  	if (((hw->mac.type == e1000_pch2lan) ||
>  	     (hw->mac.type == e1000_pch_lpt) ||
>  	     (hw->mac.type == e1000_pch_spt)) && link) {
> -		u32 reg;
> +		u16 speed, duplex;
> 
> -		reg = er32(STATUS);
> +		e1000e_get_speed_and_duplex_copper(hw, &speed, &duplex);
>  		tipg_reg = er32(TIPG);
>  		tipg_reg &= ~E1000_TIPG_IPGT_MASK;
> 
> -		if (!(reg & (E1000_STATUS_FD | E1000_STATUS_SPEED_MASK))) {
> +		if (duplex == HALF_DUPLEX && speed == SPEED_10) {
>  			tipg_reg |= 0xFF;
>  			/* Reduce Rx latency in analog PHY */
>  			emi_val = 0;
> +		} else if (hw->mac.type == e1000_pch_spt &&
> +			   duplex == FULL_DUPLEX && speed != SPEED_1000) {

You really ought to have a comment here explaining why the inter-packet
gap is increased.

> +			tipg_reg |= 0xC;

Shouldn't you mask out the old IPG value - just in case it isn't 8.

> +			emi_val = 1;
>  		} else {
> 
>  			/* Roll back the default values */

	David
