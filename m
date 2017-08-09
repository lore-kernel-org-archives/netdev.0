From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: don't set __LINK_STATE_START until after
 dev->open() call
Date: Tue, 08 Aug 2017 18:16:49 -0700 (PDT)
Message-ID: <20170808.181649.1810988621520678130.davem@davemloft.net>
References: <20170807222421.11897-1-jacob.e.keller@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jacob.e.keller@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58430 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751919AbdHIBQu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 21:16:50 -0400
In-Reply-To: <20170807222421.11897-1-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>
Date: Mon,  7 Aug 2017 15:24:21 -0700

> Fix an issue with relying on netif_running() which could be true during
> when dev->open() handler is being called, even if it would exit with
> a failure. This ensures the state does not get set and removed with
> a narrow race for other callers to read it as open when infact it never
> finished opening.
> 
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> ---
> I found this as a result of debugging a race condition in the i40evf
> driver, in which we assumed that netif_running() would not be true until
> after dev->open() had been called and succeeded. Unfortunately we can't
> hold the rtnl_lock() while checking netif_running() because it would
> cause a deadlock between our reset task and our ndo_open handler.
> 
> I am wondering whether the proposed change is acceptable here, or
> whether some ndo_open handlers rely on __LINK_STATE_START being true
> prior to their being called?

I think this has the potential to break a bunch of drivers, but I
cannot prove this.

A lot of drivers have several pieces of state setup when they bring
the device up.  And these routines are also invoked from other code
paths like suspend/resume, PCI-E error recovery, etc. and they
probably do netif_running() calls here and there.

This behavior has been this way for a very long time, so the risk is
quite high I think.
