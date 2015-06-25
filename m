From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [PATCH RFC] 2/2 huawei_cdc_ncm: introduce new TX ncm stack
Date: Thu, 25 Jun 2015 17:19:26 +0200 (CEST)
Message-ID: <alpine.LNX.2.20.1506251543240.16582@localhost.localdomain>
References: <1435012335-6055-1-git-send-email-mrkiko.rs@gmail.com> <1435012335-6055-3-git-send-email-mrkiko.rs@gmail.com> <1435225769.28594.13.camel@suse.com> <alpine.LNX.2.20.1506251327570.25021@localhost.localdomain> <1435239526.28594.24.camel@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="8323328-889077312-1435245569=:16582"
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36416 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbbFYPTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 11:19:32 -0400
In-Reply-To: <1435239526.28594.24.camel@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--8323328-889077312-1435245569=:16582
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8BIT

Hi Oliver! And thank you again.

I like / recommend the usage of open messaging standards: my preferred XMPP ID
(JID) is: mrkiko@jit.si.

On Thu, 25 Jun 2015, Oliver Neukum wrote:

> Date: Thu, 25 Jun 2015 15:38:46
> From: Oliver Neukum <oneukum@suse.de>
> To: Enrico Mioso <mrkiko.rs@gmail.com>
> Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
> Subject: Re: [PATCH RFC] 2/2 huawei_cdc_ncm: introduce new TX ncm stack
> 
> On Thu, 2015-06-25 at 13:44 +0200, Enrico Mioso wrote:
>
>> On Thu, 25 Jun 2015, Oliver Neukum wrote:
>
>>> Is there any advantage in keeping this in a single function?
>>>
>> I did this choice in the light of the fact I think the tx_fixup function will
>> become more complex than it is now, when aggregating frames.
>
> Yes, but that is a reason to split the helpers up not the opposite.
Right - I understood only now your observation.

the only reason to write the manager that way was that it shouldn't become very 
complex - it should simply do things to frames, helping out in building valid 
NCM packages.

>
>> I answer here your other message to make it more convenient to read: my
>> intention for the tx_fixup function would be to:
>> - aggregate frames
>> - send them out when:
>>  	- a timer expires
>
> How would you do that in tx_fixup()? If a timer is required then you
> need a separate function.
>
Sure. I meant: I will adapt it in case needed, and expectin the code to become 
a little bit more convoluted.
>>  	OR
>>  	- we have enough data in the aggregate, and cannot add more.
>
> Yes.
>
> You need a third case:
> 	- the interface is taken down.
>
> But in general the logic for that is already there. So can you explain
> what additional goals you have?
regarding the "timer logic" I saw it in cdc_ncm.c, but I should study it in 
more detail to understand it and implement it here where needed in case.
And sure, the "interface goes down" case is important: didn't think about it.
Thanks for the point.

the only other additional goal is to use the manager in such a way that NDP 
will be disposed after frames.

I think that this split between NCM management and tx_fixup makes things more 
flexible in general: this is the reason for re-writing it.

>> This is something done in cdc_ncm.c for example.
>> But here I have a question: by reading the comment in file
>> drivers/net/usb/rndis_host.c at line 572, there seem to be different opinions
>> in this matter.
>
> That is a very old comment written for much slower devices.
> rndis_host doesn't get much love nowadays.
Fine.
>
>> What to do ?
>>
>>>> +int
>>>> +huawei_ncm_mgmt(struct usbnet *dev,
>>>> +		struct huawei_cdc_ncm_state *drvstate, struct sk_buff *skb_out, int mode) {
>>>> +	struct usb_cdc_ncm_nth16 *nth16 = (struct usb_cdc_ncm_nth16 *)skb_out->data;
>>>> +	struct cdc_ncm_ctx *ctx = drvstate->ctx;
>>>> +	struct usb_cdc_ncm_ndp16 *ndp16 = NULL;
>>>> +	int ret = -EINVAL;
>>>> +	u16 ndplen, index;
>>>> +
>>>> +	switch (mode) {
>>>> +	case NCM_INIT_FRAME:
>>>> +
>>>> +		/* Write a new NTH16 header */
>>>> +		nth16 = (struct usb_cdc_ncm_nth16 *)memset(skb_put(skb_out, sizeof(struct usb_cdc_ncm_nth16)), 0, sizeof(struct usb_cdc_ncm_nth16));
>>>> +		if (!nth16) {
>>>> +			ret = -EINVAL;
>>>> +			goto error;
>>>> +		}
>>>> +
>>>> +		/* NTH16 signature and header length are known a-priori. */
>>>> +		nth16->dwSignature = cpu_to_le32(USB_CDC_NCM_NTH16_SIGN);
>>>> +		nth16->wHeaderLength = cpu_to_le16(sizeof(struct usb_cdc_ncm_nth16));
>>>> +
>>>> +		/* TX sequence numbering */
>>>> +		nth16->wSequence = cpu_to_le16(ctx->tx_seq++);
>>>> +
>>>> +		/* Forget about previous SKB NDP */
>>>> +		drvstate->skb_ndp = NULL;
>>>
>>> This is probably better done after you know you cannot fail.
>> Sure. Thank you.
>>>
>>>> +
>>>> +		/* Allocate a new NDP */
>>>> +		ndp16 = kzalloc(ctx->max_ndp_size, GFP_NOIO);
>>>
>>> Where is this freed?
>> The intention wqas to free it in the NCM_COMMIT_NDP case.
>> Infact after allocating the pointer, I make a copy of it in the driver state
>> (drvstate) variable, and get back to it later.
>> Is this wrong?
>
> Well, no, but it supposes a matched commit phase. Can you guarantee
> that? I was under the oppression that in that phase you want to actually
> give a frame over to the hardware.
No. When Italk about committing, I think about "writing things to out skb".
another reason why i found confortable writing the code this way was to 
maintain a kind of statefullness in a more "clean" way.
But I understand this is kind of agruable, and I can if needed break it up as 
desired.

Regarding the commit phase - I am not sure I understand your comment, sorry
about that.
However, my intention would be to allow the caller to do calls in sequences 
like:
- init frame
- ncm update
- ncm update
- ncm update
...
- ncm update
- ncm commit

(to work in "huawei" mode)

OR

- ncm init frame
- ncm commit
- ncm update
- ncm update
- ncm update
- ncm update
- finalize nth

(to work in "cdc_ncm.c"-mode)..


But to prevent usbnet from submittinx RX'd packets, I should be doing something 
nasty here. And unfortunately don't understand why.
Infact, this problem manifested itself even more aggressively when I kzallocìed 
in the _bind() function and kfreed in _unbind. I searched around this "kevent 2 
may have been dropped" (rx memory exhaustion) problem, but without finding 
significant hints.
Any idea would be welcome.
>
>
>

Thank you Oliver,
everyone.
Enrico
--8323328-889077312-1435245569=:16582--
