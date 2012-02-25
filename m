From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net] macvlan: Disable LRO on lowerdev; warn if it's turned back on
Date: Sat, 25 Feb 2012 14:07:55 -0800
Message-ID: <87fwdytvlw.fsf@xmission.com>
References: <1329851622.2689.6.camel@bwh-desktop> <4F43F816.6070908@intel.com>
	<1329856136.2689.46.camel@bwh-desktop>
	<4F4410C7.2000500@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Shradha Shah <sshah@solarflare.com>,
	Patrick McHardy <kaber@trash.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58762 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753871Ab2BYWIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Feb 2012 17:08:02 -0500
In-Reply-To: <4F4410C7.2000500@candelatech.com> (Ben Greear's message of "Tue,
	21 Feb 2012 13:46:47 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> writes:

> On 02/21/2012 12:28 PM, Ben Hutchings wrote:
>> On Tue, 2012-02-21 at 12:01 -0800, John Fastabend wrote:
>>> On 2/21/2012 11:13 AM, Ben Hutchings wrote:
>>>> Large Receive Offload (LRO) is only appropriate for packets that are
>>>> destined for the host, and should be disabled if received packets may
>>>> be forwarded.
>>>>
>>>> Further, macvtap_skb_to_vnet_hdr() will BUG() on a packet received
>>>> with LRO (but not GRO).
>>>>
>>>> Signed-off-by: Ben Hutchings<bhutchings@solarflare.com>
>>>> ---
>>>> I'm not really familiar with macvlan so I'm not certain that this should
>>>> be applied to all modes.
>>>>
>>>> Ben.
>>>>
>>>>   drivers/net/macvlan.c |    7 +++++++
>>>>   1 files changed, 7 insertions(+), 0 deletions(-)
>>>>
>>>
>>> But this patch assumes the macvlan is forwarding traffic to a guest
>>> via macvtap. Which is an assumption that may not be true.
>>>
>>> It seems more appropriate for the macvtap driver to do these checks
>>> after all its the driver that may BUG() with LRO.
>>
>> That's what I thought at first, but then I looked through what macvlan
>> was doing and it certainly appears to re-transmit skbs in all modes.
>> That's not valid when gso_size != 0 and gso_type == 0.
>
> You can put an IP on a mac-vlan and receive packets on it like
> normal Ethernet interfaces.  They wouldn't be re-transmitted
> in that case, would they?

Long story short.

With the macvlan driver the normal case is not to turn packets around
but to go directly to the nic or to come directly from the nic.

In the case where packets are turned around and packets go from one
software interface the design is that the drivers are supposed to
do software emulation of hardware features like gro so that we don't
have to take a performance hit when it happens.

If we are not doing proper software emulation of features like gro
in macvtap that is a problem.

I am fuzzy about all of the details but last I looked we were doing
proper software emulation of the features when just macvlan was
involved.  I also remember that the macvtap driver really wanted
gro so that it could work efficiently with emulated hardware.

So I don't know why people are having a problem, but the correct
solution is not to give up but to fix the silly software side of
the drivers to actually handle things properly.

Disabling LRO on the lowerdev just so we can avoid writing the
support in macvtap just sounds sad.

Eric
