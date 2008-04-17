From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 3/5] e1000e: Allow TSO to trickle down to VLAN device
Date: Thu, 17 Apr 2008 14:45:58 -0700
Message-ID: <4807C516.90308@intel.com>
References: <20080414170557.23286.71580.stgit@localhost.localdomain> <20080414170609.23286.42880.stgit@localhost.localdomain> <4803903B.1020100@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, jeff@garzik.org,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56098 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752918AbYDQVrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2008 17:47:16 -0400
In-Reply-To: <4803903B.1020100@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Auke Kok wrote:
>> Fix TSO over VLAN's by propagating settings to our VLAN devices.
>>   
> 
>> @@ -378,8 +381,21 @@ static int e1000_set_tso(struct net_device
>> *netdev, u32 data)
>>      } else {
>>          netdev->features &= ~NETIF_F_TSO;
>>          netdev->features &= ~NETIF_F_TSO6;
>> +        /* disable TSO on all VLANs if they're present */
>> +        if (!adapter->vlgrp)
>> +            goto tso_out;
>> +        for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
>> +            v_netdev = vlan_group_get_device(adapter->vlgrp, i);
>> +            if (!v_netdev)
>> +                continue;
>> +
>> +            v_netdev->features &= ~NETIF_F_TSO;
>> +            v_netdev->features &= ~NETIF_F_TSO6;
>> +            vlan_group_set_device(adapter->vlgrp, i, v_netdev);
>>   
> 
> What exactly is this supposed to fix? If this simply wants
> to propagate feature changes, I think it should use
> netdev_feat_change and handle that within the VLAN code.

I asked PJ and got this reply:

//
VLAN devices didn't get the parent's feature flags on creation.  I went
to fix this in the kernel, people pushed back that some devices couldn't
support both VLAN tag insertion offload and TSO, so I didn't push the
issue.  I worked around the issue by copying the flags in the driver.
The downside is when we turn off TSO using ethtool, we need to remove
TSO from all VLAN devices, since the hardware segmenter is no longer
available if the parent device doesn't have it enabled as a feature.  We
were seeing stack-based panics with gso_segment(), which was corrected
by removing the TSO flag from all VLAN devices.

I can't seem to find netdev_feat_change anywhere in the kernel, or
variants of that name, so I'm not sure what Patrick is pointing us at.

-PJ
//

