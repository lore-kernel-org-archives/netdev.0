From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [RFC] net: napi fix
Date: Thu, 13 Dec 2007 14:02:25 -0500
Message-ID: <476181C1.3060204@myri.com>
References: <47602B77.2090202@intel.com>	<b25c3fa70712122341q3ba282cdqda3fa56901b14484@mail.gmail.com>	<47613E22.6060705@myri.com>	<20071213.061938.86541759.davem@davemloft.net> <20071213102233.3727e9a0@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, joonwpark81@gmail.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	jesse.brandeburg@intel.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1889 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760780AbXLMTKu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 14:10:50 -0500
In-Reply-To: <20071213102233.3727e9a0@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Thu, 13 Dec 2007 06:19:38 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Andrew Gallatin <gallatin@myri.com>
>> Date: Thu, 13 Dec 2007 09:13:54 -0500
>>
>>> If the netif_running() check is indeed required to make a device break
>>> out of napi polling and respond to an ifconfig down, then I think the
>>> netif_running() check should be moved up into net_rx_action() to avoid
>>> potential for driver complexity and bugs like the ones you found.
>> That, or something like it, definitely sounds reasonable and much
>> better than putting the check into every driver :-)
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> It is not possible to do netif_running() check in generic code as currently
> written because of the case of devices where a single NAPI object is
> being used to handle two devices. The association between napi and netdevice
> is M to N.  There are cases like niu that have multiple NAPI's and one
> netdevice; and devices like sky2 that can have one NAPI and 2 netdevice's.

Ah, now I see.  I forgot that not every device has a 1:1::napi:netdev
relationship.

Could we make an optional *dev_state field in the napi structure.
It would be initialized to __LINK_STATE_START.  Devices which have
a 1:1 NAPI:netdevice relationship would set it to &netdev->state.
The generic code would then do a test_bit(__LINK_STATE_START, 
napi->dev_state), and 1:1 drivers could remove this check.
M:N drivers would pay for a useless (to them) test_bit, and would
have to provide their own netif_running check to get termination
under heavy load.

Just an idea, perhaps there is a better way which is less hacky.

Or perhaps we should just leave things as is.

Drew
