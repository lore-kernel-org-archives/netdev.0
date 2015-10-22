From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: sh_eth.c::sh_eth_rx(): mdp->rx_skbuff[entry] can be NULL
Date: Fri, 23 Oct 2015 00:17:54 +0300
Message-ID: <56295282.7070202@cogentembedded.com>
References: <87oafusy11.wl@dns1.atmark-techno.com>
 <5626A881.2080701@cogentembedded.com> <87eggosmvk.wl@dns1.atmark-techno.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yasushi SHOJI <yashi@atmark-techno.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:34506 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964833AbbJVVSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 17:18:00 -0400
Received: by lfaz124 with SMTP id z124so63035754lfa.1
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 14:17:58 -0700 (PDT)
In-Reply-To: <87eggosmvk.wl@dns1.atmark-techno.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/21/2015 10:26 AM, Yasushi SHOJI wrote:

> Thank your for your reply.

    Not at all, I'm virtually a maintainer for that driver now, so trying to 
filter out the related mails even if I don't have time to read thru all the 
netdev mail.

>> On 10/19/2015 06:01 PM, Yasushi SHOJI wrote:
>>
>>> I'm not that familiar with this code base so I'm note including any
>>> patch yet.  I appreciate if someone with insight in this code give a
>>> quick look and tell me that it's a real one or not.  if this is a real
>>> case, I can take a deep look.
>>
>>     If you got the oops, it's real. Thanks for the reporting. I guess I
>> should check the new ravb driver as well...
>>     Do you want to try fixing the bug yourself?

> Sure.  I can dive in to this.  I appreciate if someone who has worked
> on sh_eth.c give me some design advises or tell me the initial design
> thoughts / what was the intention when allocation if failed.

    Hm, well, I seem to have some time to spend on fixing the issues in this 
driver (I noticed a couple while doing the AVB driver), so spending time on 
your "education" would seem somewhat inefficient... :-)

> My idea right now is to simply invalidate the descriptor when
> netdev_alloc_skb() failed.

    Well, it depends. If you're talking about the second loop in sh_eth_rx(), 
that seems a good idea (and it's what I've done for the dma_mapping_error() 
case in the ravb driver -- I just set the descriptor's data size field to 0). 
The OOM case seems to have been un-addressed in both drivers so far... If we 
take sh_eth_ring_format(), I believe the best course of action is to just fail 
on OOM since the driver doesn't correctly handle that case anyway AFAIR; and 
that was implemented in the ravb driver.

> When next packet arrived, in near future,
> the driver can try again to allocate the buffer and update the
> corresponding descriptor if succeeds.

    It would be too late, unless you still mean the RX refilling loop in this 
function.

> If memory is not yet available
> when the controller is trying to use the invalid descriptor, the
> controller will see it and DMA will stop.

    That means leaving RACT=0 and that's what the driver is even doing...
    Hm, then I don't understand how the error you've described can occur, 
unless we encounter OOM during sh_eth_ring_format()...

> Is it acceptable path to go?

    I'm not seeing a bug in this function, perhaps I'm missing something?

> Here is how I understand this driver:

[...]

> The driver utilizes array of sk_buffs for tx and rx.  For rx, the
> driver has an array of pointers of sk_buffs, rx_skbuff[]. This
> rx_skbuff[] is filled with sk_buffs in sh_eth_ring_format() which is
> called when the driver is open()ed.
>
> The controller, the driver is targeted to, is GETHER.

    Well, it depends on your SoC, it may be 100 Mbps Ether.

> A receive descriptor corresponds to one sk_buff.  The controller
> expects array of descriptors in the system memory and treat it as a
> ring, meaning that the controller process each descriptor one by one.
> Once the controller finished the last descriptor, it will go back to
> the first one.

    Yes, it seems a correct description.

> To achieve zero copy, the driver push the sk_buffs filled with
> received packet to the netdev core with netif_receive_skb() then
> netdev_alloc_skb() sk_buffs in the sh_eth_rx(), the poll method of the
> driver, and update the corresponding descriptor.

> If the allocation failed, it just leave the function, leaving old
> pointer in the descriptor as is.

    Yes, but note that it also leaves RACT=0, which basically means an invalid 
descriptor, encountering which the reception should just stop.

> In some future, the controller will
> access the descriptor and writes to the old memory address. (I haven't
> checked the state of bits in the descriptor yet)

   Check it.

> BTW, if any one has a bit of time, I have questions regarding to the
> atomic allocation:

    Sorry, I'm constantly short of time. Someone else will have to answer 
that. :-)

MBR, Sergei
