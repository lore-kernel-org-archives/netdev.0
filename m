From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: fix insmod failure when multiple
 NICs are plugged in
Date: Wed, 17 May 2017 14:50:29 -0400 (EDT)
Message-ID: <20170517.145029.507361457936948797.davem@davemloft.net>
References: <20170516181450.GA1014@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35478 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750838AbdEQSud (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 14:50:33 -0400
In-Reply-To: <20170516181450.GA1014@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Tue, 16 May 2017 11:14:50 -0700

> From: Rick Farrington <ricardo.farrington@cavium.com>
> 
> When multiple liquidio NICs are plugged in, the first insmod of the PF
> driver succeeds.  But after an rmmod, a subsequent insmod fails.  Reason is
> during rmmod, the PF driver resets the Octeon of only one of the NICs; it
> neglects to reset the Octeons of the other NICs.
> 
> Fix the insmod failure by adding the missing Octeon resets at rmmod.  Keep
> a per-NIC refcount that indicates the number of active PFs in a given NIC.
> When the refcount goes to zero, then reset the Octeon of that NIC.
> 
> Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

I'm applying this but I'm really not happy with how this driver handles
probing.

There is no reason to have arbitrary limits to the number of adapters,
everything should be dynamic and allow arbitrary numbers of instances
even if that is not physically possible with current hardware.

Also, the driver should be able to load even if something isn't reset
properly.  A boot loader or some other entity could have programmed
the device or something like a kdump kernel could leave it in an
indeterminate state.

So you must be able to probe the device even if it has not been soft
reset properly.  In fact, the soft reset probably should happen during
probe not during shutdown.
