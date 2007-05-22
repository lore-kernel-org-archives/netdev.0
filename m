From: Milton Miller <miltonm@bga.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100 rx: or s and el bits)
Date: Tue, 22 May 2007 11:51:23 -0500
Message-ID: <53c44b6f03973eb1b28f221859d3002c@bga.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net> <46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com> <463BA906.30205@roinet.com> <85f07fc58d5ed2147d5214d0f0b4fe32@bga.com> <4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com> <464D21B6.2000208@intel.com> <464DB336.2030003@roinet.com> <464DB619.3070900@roinet.com> <464DC676.90504@intel.com> <464DCA97.3070405@roinet.com> <464DCD5E.50003@intel.com> <464DDE3E.9010400@roinet.com> <e3819b7a866b1117fd5a69e6a85e0784@bga.com> <4651DAC1.7050604@intel.com>
Mime-Version: 1.0 (Apple Message framework v624)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Scott Feldman <sfeldma@pobox.com>,
	e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, David Acker <dacker@roinet.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mercury.realtime.net ([205.238.132.86]:44867 "EHLO
	ruth.realtime.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755571AbXEVQwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 12:52:20 -0400
In-Reply-To: <4651DAC1.7050604@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On May 21, 2007, at 12:45 PM, Kok, Auke wrote:

> Milton Miller wrote:
>> On May 18, 2007, at 12:11 PM, David Acker wrote:
>>> Kok, Auke wrote:
>>>> First impression just came in: It seems RX performance is dropped 
>>>> to 10mbit. TX is unaffected and runs at 94mbit/tcp, but RX the new 
>>>> code seems to misbehave and  fluctuate, dropping below 10mbit after 
>>>> a few netperf runs and staying there...
>>>> ideas?
>>> I found the problem.  Another casualty of working with two different 
>>> kernels at once...arg.
>>> The blank rfd needs to have its el-bit clear now.  Here is the new 
>>> and improved patch.
...
>> Proceeding with the review:
>> Coding style:
>> (1) if body on seperate line.
>> (2) space after if before (
>> (3) The other enums in this driver are not ALL_CAPS
>> (4) This driver doesn't do CONSTANT != value but value != enum
>>      (see nic->mac for examples)
>
> I sent Milton my copy of this patch which has these style issues 
> corrected and
> applies cleanly to a recent git tree. If anyone else specifically 
> wants a copy
> let me know.
>
> Auke

It addressed 1 and 2, and applies, but did not address 3 and 4.


But the bigger point is it didn't address the holes I identified.

I think we need to change the logic to reclaim the size from 0
only if we are restarting, and make rx_indicate look ahead to
rx->next if it encounters a !EL size 0 buffer.  Without this we
are doing a "prohibited" rx_start to a running machine.  The
device can still see this size 0 !EL state.  Also we will get
stuck when the device finds the window between the two writes.

We can remove some register pressure by finding old_before_last_rfd
when we are ready to use it, just comparing old_before_last_rx
to new.

Also, as I pointed out, the rx_to_start change to start_reciever
is compicated and unnecessary, as rx_to_clean can always be used
and it was the starting point before the changes.

As far as the RU_SUSPENDED, I don't think we need it, instead
we should poll the device.

Here is my proposal:
rx_indicate can stop when it hits the packet with EL.  If it
hits a packet with size 0, look ahead to rx->next to see if
it is complete, if so complete this one otherwise leave it
as next to clean.  After the rx_indicate loop, try to allocate
more skbs.  If we are successful, then fixup the before-next
as we do now.  Then check the device status for RNR, and if
its stopped then set rx_to_clean rfd size back to ETH_LEN
and restart the reciever.

This does have a small hole: if we only add one packet at
a time we will end up with all size 0 descriptors in the
lopp.   We can detect that and not remove EL from the old
before-next unless we are restarting.  That would imply
moving the status poll before we allocate the list.

milton

