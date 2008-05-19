From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: Question about VLAN + checksum offloading
Date: Mon, 19 May 2008 10:36:09 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329051AC07F@orsmsx414.amr.corp.intel.com>
References: <1210924374.5136.94.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Naohiro Ooiwa" <nooiwa@miraclelinux.com>
To: "Ichiro Suzuki" <isuzuki@miraclelinux.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15867 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755930AbYESRgL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 13:36:11 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1210924374.5136.94.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi,
> 
>   Looking in oprofile log, I observed
> 	csum_partial_copy_generic()
> is invoked for a 802.1Q VLAN device created on e1000, This 
> suggests checksum offloading is not in effect.
> The offloading works fine when e1000 is used directly.
> Attached one liner patch fixes this. But, it seems too 
> obvious to be a correct answer.

You would think so.

>   My questions are,
> o Is it right to expect checksum offloading should work  on 
> VLAN devices?

It should, but perhaps not.  Another feature is TSO + VLAN.  This was
something I proposed to patch earlier, in the same fashion you have
here.  However, some hardware out there may not be able to handle both
hardware offloads at the same time.  I'm not aware of which hardware
that would be, but it was hinted to me that such hardware exists.

> o If so, is there any mechanism to propagate  
> real_dev->features flags in vlan.c?

There isn't an explicit way.  I had written patches into e1000, igb,
e1000e, and ixgbe to propogate the VLAN flags within the driver when the
VLAN device was created.  The trick though is if you remove a feature
flag with ethtool, say checksum offload, on your main device, you
probably should turn it off on your VLAN devices.  Patrick McHardy
pointed me at netdev_feature_change() to use within the driver.  I'll
admit I haven't had the time to fix my drivers to use this call, but it
certainly looks like the way to go.  Please see the (middle) of the
thread here: http://marc.info/?l=linux-netdev&m=120878809806631&w=2

> o If such mechanism doesn't exist, is my patch reasonable?

I would say yes, halfway.  The issue is you probably want to remove the
feature flag from the VLAN device if you removed the flag from the
parent device as well.

Cheers,

-PJ Waskiewicz
<peter.p.waskiewicz.jr@intel.com>
