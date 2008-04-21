From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/5] e1000e: Allow TSO to trickle down to VLAN device
Date: Mon, 21 Apr 2008 16:24:25 +0200
Message-ID: <480CA399.50708@trash.net>
References: <20080414170557.23286.71580.stgit@localhost.localdomain> <20080414170609.23286.42880.stgit@localhost.localdomain> <4803903B.1020100@trash.net> <4807C516.90308@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42076 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756220AbYDUOYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 10:24:32 -0400
In-Reply-To: <4807C516.90308@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kok, Auke wrote:
> Patrick McHardy wrote:
>> Auke Kok wrote:
>>> Fix TSO over VLAN's by propagating settings to our VLAN devices.
>>>   
>> What exactly is this supposed to fix? If this simply wants
>> to propagate feature changes, I think it should use
>> netdev_feat_change and handle that within the VLAN code.
> 
> I asked PJ and got this reply:
> 
> //
> VLAN devices didn't get the parent's feature flags on creation.  I went
> to fix this in the kernel, people pushed back that some devices couldn't
> support both VLAN tag insertion offload and TSO, so I didn't push the
> issue.  I worked around the issue by copying the flags in the driver.
> The downside is when we turn off TSO using ethtool, we need to remove
> TSO from all VLAN devices, since the hardware segmenter is no longer
> available if the parent device doesn't have it enabled as a feature.  We
> were seeing stack-based panics with gso_segment(), which was corrected
> by removing the TSO flag from all VLAN devices.
> 
> I can't seem to find netdev_feat_change anywhere in the kernel, or
> variants of that name, so I'm not sure what Patrick is pointing us at.
> 
> -PJ
> //

That was a typo, I meant netdev_features_change(), which is invoked
by dev_ethtool() and calls the netdev notifier with NETDEV_FEAT_CHANGE,
on which the VLAN code could react. I wasn't aware of the TSO + VLAN
acceleration problems you've mentioned, do you have a pointer to more
information about this?

In any case I would prefer to avoid having drivers mess with VLAN
device flags. How about adding a device flag indicating that the
driver supports TSO + VLAN acceleration and using the
NETDEV_FEAT_CHANGE notification inside the VLAN code do adjust
the device's flags properly?

