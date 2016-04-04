From: Daniel Walker <danielwa@cisco.com>
Subject: Re: [Intel-wired-lan] [PATCH-RFC] drivers: net: ethernet: intel:
 e1000e: fix ethtool autoneg off for fiber
Date: Mon, 4 Apr 2016 16:03:50 -0700
Message-ID: <5702F2D6.5010105@cisco.com>
References: <1458943126-32258-1-git-send-email-danielwa@cisco.com>
 <56FC2A62.6040206@cisco.com>
 <36CDDD56DDB4D44E911123902EFC26B05B440F17@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>,
	"danielwa@fifo99.com" <danielwa@fifo99.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Steve Shih <sshih@cisco.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: "Ruinskiy, Dima" <dima.ruinskiy@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-5.cisco.com ([173.37.86.76]:1892 "EHLO
	rcdn-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974AbcDDXDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 19:03:54 -0400
In-Reply-To: <36CDDD56DDB4D44E911123902EFC26B05B440F17@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/03/2016 07:23 AM, Ruinskiy, Dima wrote:
> I have a couple of comments (sorry for not getting to it a bit sooner).
>
>> For fiber media, e1000_get_settings should return ETH_TP_MDI_INVALID for
>> eth_tp_mdix_ctrl instead of ETH_TP_MDI_AUTO so subsequent e1000_set_settings
>> call would not fail with -EOPNOTSUPP.
> Should this be specific to fiber? Because the code just checks media != copper. There is at least other media type (e1000_media_type_internal_serdes), which will be affected by this change as well. What is the proper behavior in this case?
Steve is shy, so here are his comments,

<Steve>
Regarding the 1st comment. The issue affects all non-copper media. In 
fact, we are using e1000_media_type_internal_serdes and are affected due 
to the following check in e1000_set_settings:

/* MDI setting is only allowed when autoneg enabled because
* some hardware doesn't allow MDI setting when speed or
* duplex is forced.
*/
if (ecmd->eth_tp_mdix_ctrl) {
if (hw->phy.media_type != e1000_media_type_copper)
return -EOPNOTSUPP;

if ((ecmd->eth_tp_mdix_ctrl != ETH_TP_MDI_AUTO) &&
(ecmd->autoneg != AUTONEG_ENABLE)) {
e_err("forcing MDI/MDI-X state is not supported when link speed and/or 
duplex are forced\n");
return -EINVAL;
}
}

</Steve>

>> e1000_set_spd_dplx should not automatically turn autoneg back on for forced
>> 1000 Mbps full duplex settings.
> I seem to remember that this code is there because the copper-based NICs only support 1000Mbps in auto-negotiation mode, not forced (this is according to the IEEE spec, as far as I know). I believe this code is there to ensure that a user can force the speed to 1000 via the API, and still have the link resolve correctly via auto-negotiation. I am concerned that changing this code will break clients that rely on it. Maybe it is best to also limit it to fiber devices only?
>

<Steve>
Regarding the 2nd comment. Yes, will limit to non-copper media.
</Steve>

He supplied me with a second patch which I can send.. Can we remove the 
RFC this time ?

Daniel
