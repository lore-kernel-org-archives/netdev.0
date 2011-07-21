From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 18/47 V2] igbvf: do vlan cleanup
Date: Thu, 21 Jul 2011 18:23:39 +0200
Message-ID: <20110721162338.GH2107@minipsycho>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
 <1311173689-17419-19-git-send-email-jpirko@redhat.com>
 <20110721132229.GC2107@minipsycho>
 <43F901BD926A4E43B106BF17856F0755019404FB53@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shemminger@linux-foundation.org" <shemminger@linux-foundation.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"greearb@candelatech.com" <greearb@candelatech.com>,
	"mirqus@gmail.com" <mirqus@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"jesse@nicira.com" <jesse@nicira.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55582 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753189Ab1GUQYb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2011 12:24:31 -0400
Content-Disposition: inline
In-Reply-To: <43F901BD926A4E43B106BF17856F0755019404FB53@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jul 21, 2011 at 05:57:08PM CEST, gregory.v.rose@intel.com wrote:
>> -----Original Message-----
>> From: Jiri Pirko [mailto:jpirko@redhat.com]
>> Sent: Thursday, July 21, 2011 6:23 AM
>> To: netdev@vger.kernel.org
>> Cc: davem@davemloft.net; shemminger@linux-foundation.org;
>> eric.dumazet@gmail.com; greearb@candelatech.com; mirqus@gmail.com;
>> Kirsher, Jeffrey T; Brandeburg, Jesse; Waskiewicz Jr, Peter P; Allan,
>> Bruce W; Wyborny, Carolyn; Skidmore, Donald C; Rose, Gregory V; Duyck,
>> Alexander H; Ronciak, John; e1000-devel@lists.sourceforge.net;
>> jesse@nicira.com
>> Subject: [patch net-next-2.6 18/47 V2] igbvf: do vlan cleanup
>> 
>> - unify vlan and nonvlan rx path
>> - kill adapter->vlgrp and igbvf_vlan_rx_register
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> ---
>>  drivers/net/igbvf/igbvf.h  |    4 +-
>>  drivers/net/igbvf/netdev.c |   55 +++++++++++++++++++--------------------
>> ----
>>  2 files changed, 26 insertions(+), 33 deletions(-)
>> 
>> diff --git a/drivers/net/igbvf/igbvf.h b/drivers/net/igbvf/igbvf.h
>> index d5dad5d..fd4a7b7 100644
>> --- a/drivers/net/igbvf/igbvf.h
>> +++ b/drivers/net/igbvf/igbvf.h
>> @@ -34,7 +34,7 @@
>>  #include <linux/timer.h>
>>  #include <linux/io.h>
>>  #include <linux/netdevice.h>
>> -
>> +#include <linux/if_vlan.h>
>> 
>>  #include "vf.h"
>> 
>> @@ -173,7 +173,7 @@ struct igbvf_adapter {
>> 
>>  	const struct igbvf_info *ei;
>> 
>> -	struct vlan_group *vlgrp;
>> +	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
>>  	u32 bd_number;
>>  	u32 rx_buffer_len;
>>  	u32 polling_interval;
>> diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
>> index 64b47bf..d924b09 100644
>> --- a/drivers/net/igbvf/netdev.c
>> +++ b/drivers/net/igbvf/netdev.c
>> @@ -100,12 +100,12 @@ static void igbvf_receive_skb(struct igbvf_adapter
>> *adapter,
>>                                struct sk_buff *skb,
>>                                u32 status, u16 vlan)
>>  {
>> -	if (adapter->vlgrp && (status & E1000_RXD_STAT_VP))
>> -		vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
>> -		                         le16_to_cpu(vlan) &
>> -		                         E1000_RXD_SPC_VLAN_MASK);
>> -	else
>> -		netif_receive_skb(skb);
>> +	if (status & E1000_RXD_STAT_VP) {
>> +		u16 vid = le16_to_cpu(vlan) & E1000_RXD_SPC_VLAN_MASK;
>> +
>> +		__vlan_hwaccel_put_tag(skb, vid);
>> +	}
>> +	netif_receive_skb(skb);
>>  }
>> 
>>  static inline void igbvf_rx_checksum_adv(struct igbvf_adapter *adapter,
>> @@ -1167,22 +1167,29 @@ static int igbvf_poll(struct napi_struct *napi,
>> int budget)
>>   */
>>  static void igbvf_set_rlpml(struct igbvf_adapter *adapter)
>>  {
>> -	int max_frame_size = adapter->max_frame_size;
>> +	int max_frame_size;
>>  	struct e1000_hw *hw = &adapter->hw;
>> 
>> -	if (adapter->vlgrp)
>> -		max_frame_size += VLAN_TAG_SIZE;
>> -
>> +	max_frame_size = adapter->max_frame_size + VLAN_TAG_SIZE;
>>  	e1000_rlpml_set_vf(hw, max_frame_size);
>>  }
>> 
>> -static void igbvf_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
>> +static bool __igbvf_vlan_rx_add_vid(struct igbvf_adapter *adapter, u16
>> vid)
>>  {
>> -	struct igbvf_adapter *adapter = netdev_priv(netdev);
>>  	struct e1000_hw *hw = &adapter->hw;
>> 
>>  	if (hw->mac.ops.set_vfta(hw, vid, true))
>>  		dev_err(&adapter->pdev->dev, "Failed to add vlan id %d\n",
>> vid);
>> +		return false;
>> +	return true;
>> +}
>
>I'm pretty sure you intended to put a curly brace after the if statement here.

Right, missed that. Thanks.

Rsposting also with removing igbvf_set_rlpml call from
igbvf_restore_vlan since it is called from igbvf_configure_rx

Thanks

Jirka
>
>Other than that it seems fine.
>
>- Greg
>
>
