From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [PATCH RFC] 2/2 huawei_cdc_ncm: introduce new TX ncm stack
Date: Sat, 27 Jun 2015 07:40:58 +0200 (CEST)
Message-ID: <alpine.LNX.2.20.1506270723080.1195@localhost.localdomain>
References: <1435012335-6055-1-git-send-email-mrkiko.rs@gmail.com> <1435012335-6055-3-git-send-email-mrkiko.rs@gmail.com> <1435225769.28594.13.camel@suse.com> <alpine.LNX.2.20.1506251327570.25021@localhost.localdomain> <1435239526.28594.24.camel@suse.de>
 <alpine.LNX.2.20.1506251543240.16582@localhost.localdomain> <1435306442.2914.8.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:38028 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755227AbbF0FlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jun 2015 01:41:03 -0400
In-Reply-To: <1435306442.2914.8.camel@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Oliver!
I wish sincerely to thank you again for your time and patience.

On Fri, 26 Jun 2015, Oliver Neukum wrote:

> Date: Fri, 26 Jun 2015 10:14:02
> From: Oliver Neukum <oneukum@suse.com>
> To: Enrico Mioso <mrkiko.rs@gmail.com>
> Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
> Subject: Re: [PATCH RFC] 2/2 huawei_cdc_ncm: introduce new TX ncm stack
> 
> On Thu, 2015-06-25 at 17:19 +0200, Enrico Mioso wrote:
>> Hi Oliver! And thank you again.
>>
>> I like / recommend the usage of open messaging standards: my preferred XMPP ID
>> (JID) is: mrkiko@jit.si.
>>
>> On Thu, 25 Jun 2015, Oliver Neukum wrote:
>>
>>> Date: Thu, 25 Jun 2015 15:38:46
>>> From: Oliver Neukum <oneukum@suse.de>
>>> To: Enrico Mioso <mrkiko.rs@gmail.com>
>>> Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
>>> Subject: Re: [PATCH RFC] 2/2 huawei_cdc_ncm: introduce new TX ncm stack
>>>
>>> On Thu, 2015-06-25 at 13:44 +0200, Enrico Mioso wrote:
>>>
>>>> On Thu, 25 Jun 2015, Oliver Neukum wrote:
>>>
>>>>> Is there any advantage in keeping this in a single function?
>>>>>
>>>> I did this choice in the light of the fact I think the tx_fixup function will
>>>> become more complex than it is now, when aggregating frames.
>>>
>>> Yes, but that is a reason to split the helpers up not the opposite.
>> Right - I understood only now your observation.
>>
>> the only reason to write the manager that way was that it shouldn't become very
>> complex - it should simply do things to frames, helping out in building valid
>> NCM packages.
>>
>>>
>>>> I answer here your other message to make it more convenient to read: my
>>>> intention for the tx_fixup function would be to:
>>>> - aggregate frames
>>>> - send them out when:
>>>>  	- a timer expires
>>>
>>> How would you do that in tx_fixup()? If a timer is required then you
>>> need a separate function.
>>>
>> Sure. I meant: I will adapt it in case needed, and expectin the code to become
>> a little bit more convoluted.
>
> You cannot become any more convoluted even if you try.
>
>>>>  	OR
>>>>  	- we have enough data in the aggregate, and cannot add more.
>>>
>>> Yes.
>>>
>>> You need a third case:
>>> 	- the interface is taken down.
>>>
>>> But in general the logic for that is already there. So can you explain
>>> what additional goals you have?
>> regarding the "timer logic" I saw it in cdc_ncm.c, but I should study it in
>> more detail to understand it and implement it here where needed in case.
>
> It is involved. Basically a timer for transmission creates locking
> issues. cdc-ncm uses an hrtimer which calls a bottom half which
> calls xmit with a NULL skb.
>
>        /* if there is a remaining skb, it gets priority */
>        if (skb != NULL) {
>                swap(skb, ctx->tx_rem_skb);
>                swap(sign, ctx->tx_rem_sign);
>        } else {
>                ready2send = 1;
>        }
>
> The else branch here is the timer triggering.
> The actual transmission is done in usbnet if cdc_ncm_fill_tx_frame()
> returns an skb.
>
> I doubt you can can come up with anything more convoluted
> but it simplifies locking.
>
>>> Well, no, but it supposes a matched commit phase. Can you guarantee
>>> that? I was under the oppression that in that phase you want to actually
>>> give a frame over to the hardware.
>> No. When Italk about committing, I think about "writing things to out skb".
>> another reason why i found confortable writing the code this way was to
>> maintain a kind of statefullness in a more "clean" way.
>> But I understand this is kind of agruable, and I can if needed break it up as
>> desired.
>>
>> Regarding the commit phase - I am not sure I understand your comment, sorry
>> about that.
>> However, my intention would be to allow the caller to do calls in sequences
>> like:
>> - init frame
>> - ncm update
>> - ncm update
>> - ncm update
>> ...
>> - ncm update
>> - ncm commit
>>
>> (to work in "huawei" mode)
>>
>> OR
>>
>> - ncm init frame
>> - ncm commit
>> - ncm update
>> - ncm update
>> - ncm update
>> - ncm update
>> - finalize nth
>>
>> (to work in "cdc_ncm.c"-mode)..
>
> Sounds like a plan.
>
>> But to prevent usbnet from submittinx RX'd packets, I should be doing something
>> nasty here. And unfortunately don't understand why.
>
>        // some devices want funky USB-level framing, for
>        // win32 driver (usually) and/or hardware quirks
>        if (info->tx_fixup) {
>                skb = info->tx_fixup (dev, skb, GFP_ATOMIC);
>                if (!skb) {
>                        /* packet collected; minidriver waiting for more
> */
>                        if (info->flags & FLAG_MULTI_PACKET)
>                                goto not_drop;
>
> So you just return NULL if you are ready to queue more. But you
> need the FLAG_MULTI_PACKET flag.
>
Unfortuantely I might have not explained myself better.
I should thank you for this illumination on the timer part: since I know I'll need this.
But what's stopping me right now is actually the RX, not the TX part.
Sure, the RX function I am using comes from cdc_ncm.c and works fine: unfortunately, usbnet will not call it.
Infact, my dmesg ends up FULL of 
"kevent 2 may have been dropped" messages.
And looking around I discovered I end up triggering a memory check in usbnet.c, 
at line 475

 	skb = __netdev_alloc_skb_ip_align(dev->net, size, flags);
 	if (!skb) { /* triggered */
 		netif_dbg(dev, rx_err, dev->net, "no rx skb\n");
 		usbnet_defer_kevent (dev, EVENT_RX_MEMORY);
 		usb_free_urb (urb);
 		return -ENOMEM;
 	}

And genuinely, I can't understand why.
To test what I was doing wrong, I started with the stock huawei_cdc_ncm.c that 
works fine.
then I started allocating the temporary NDP in the bind function: and the 
problem started triggering, so I can't RX.
Allocating and deallocating the temporary NDP as-neede as happens now, triggers 
the problem inevitably after some packets: ping works for a while.

I was investigating on calls to obtain "private memory" as it happens in the 
hso.c driver and others, but wanted some feedback.

What happens then is I get a worker thread using all the CPU and ksoftirqs/0 
going mad.
Googling around resulted mainly in people complaining about this same problem 
with the drivers/net/usb/smsc95xx.c driver, used in the Raspberry PI for the 
Ethernet card.

I imagine in my case what's doing wrong could be terrible but I am not abe to 
tell right now.
I tried thinking how to avoid allocating the temporary NDP somehow: without a 
solution. And nowI would like to understand what's going wrong even for my 
personal kwoledge.

> 	Regards
> 		Oliver
>
>
>

Thank you again, and have a good weekend.
Enrico
