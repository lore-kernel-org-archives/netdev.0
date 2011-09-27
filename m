From: David Miller <davem@redhat.com>
Subject: Re: [RFC PATCH] net: Always fire at least one linkwatch event
Date: Tue, 27 Sep 2011 14:59:43 -0400 (EDT)
Message-ID: <20110927.145943.1365764295978178226.davem@redhat.com>
References: <1316634689-15083-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jfeeney@redhat.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15465 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752472Ab1I0S7s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Sep 2011 14:59:48 -0400
In-Reply-To: <1316634689-15083-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 21 Sep 2011 15:51:29 -0400

> It was recently noted that the tg3 driver had a problem in that after boot a
> kernel and if-upping the tg3 interface the sysfs operstate attribute continued
> to read 'unkown'.  This was happening because tg3 assumes the default carrier
> state (which is to say the __LINK_STATE_NOCARRIER bit is clear) is correct.
> That said, when the device is if-upped, and the open path, calls
> netif_carrier_on, the test_and_set_bit call in that function returns false
> (since the bit was previously zero from its initial state).  This means that
> netif_carrier_on call never generates a linkwatch event, and as a result
> dev->operstate never gets recomputed.  This could be fixed by unconditionally
> calling netif_carrier_off in the probe routine, to simply force a state change
> on that bit, but that seems like a sub-par solution, given that many drivers may
> have this error.  Instead it seems like it might be better to burn an extra bit
> in the state field to indicate that the CARRIER bit is still in the initial
> state and our first call to netif_carrier_[off|on] should always fire a
> linkwatch event.

I'm finding this analysis hard to follow.

tg3_open() does netif_carrier_off(), and this will set the
__LINK_STATE_NOCARRIER bit.

And since the registration state of the device is not
NETREG_UNINITIALIZED it will fire off a linkwatch event too.

So whenever the netif_carrier_on() happens later, the bit will be set
when the test_and_clear_bit() happens there.  So the
test_and_clear_bit() will not return false.

The registration state is not NETREG_UNINITIALIZED, so (again) that
will not block the linkwatch event from firing.
