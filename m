From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [RFC PATCH] net: don't set __LINK_STATE_START until after
 dev->open() call
Date: Wed, 9 Aug 2017 20:00:55 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5882A3F62D@ORSMSX115.amr.corp.intel.com>
References: <20170807222421.11897-1-jacob.e.keller@intel.com>
 <20170808.181649.1810988621520678130.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:18518 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751890AbdHIUBA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Aug 2017 16:01:00 -0400
In-Reply-To: <20170808.181649.1810988621520678130.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
> Behalf Of David Miller
> Sent: Tuesday, August 08, 2017 6:17 PM
> To: Keller, Jacob E <jacob.e.keller@intel.com>
> Cc: netdev@vger.kernel.org
> Subject: Re: [RFC PATCH] net: don't set __LINK_STATE_START until after dev->open()
> call
> 
> From: Jacob Keller <jacob.e.keller@intel.com>
> Date: Mon,  7 Aug 2017 15:24:21 -0700
> > I am wondering whether the proposed change is acceptable here, or
> > whether some ndo_open handlers rely on __LINK_STATE_START being true
> > prior to their being called?
> 
> I think this has the potential to break a bunch of drivers, but I
> cannot prove this.
> 
> A lot of drivers have several pieces of state setup when they bring
> the device up.  And these routines are also invoked from other code
> paths like suspend/resume, PCI-E error recovery, etc. and they
> probably do netif_running() calls here and there.
> 
> This behavior has been this way for a very long time, so the risk is
> quite high I think.

That's what I am worried about. However, I think there are problems with leaving it. A lot of drivers rely on netif_running() to determine whether or not the device is open, but they may be using it relying on all the changes caused by the .ndo_open() handler are finished. The current system there is a race, since you set the __LINK_STATE_START before .ndo_open is called.

This is what I found when attempting to debug a race in i40evf_open and i40evf_reset. The reset ended up running at the same time as open and the two flows collided because reset relied on netif_running() under the assumption that it would not return true until the device was actually open. However, it was running at the same time as open was, so it was trying to shutdown things at the same time as the open call was trying to bring them up.

Any location which uses rtnl_lock() will be safe, since the dev_open call is under rtnl_lock() so all callers of netif_running() under lock are serialized to see only the flag before or after dev_open completes. This is the majority of the callers I think.

Unfortunately, I can't really hold the rtnl_lock() during reset, since this caused a deadlock when I tried it due to lock ordering problems. I'm not sure if I could fix that or not.

I think there are other places which are incorrect, but haven't yet run into an issue. The only place I can see where the functionality might be changed for the worse is if a .dev_open handler actually relies on checking netif_running() during its call, which seems incredibly silly to me....

Thanks,
Jake

P.S. I apologize for the typo in this patch, if there is more discussion I can send a v2 which fixes it.
