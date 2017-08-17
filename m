From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH 2/2] xdp: adjust xdp redirect tracepoint to include return
 error code
Date: Thu, 17 Aug 2017 12:43:18 -0700
Message-ID: <5995F1D6.8040103@gmail.com>
References: <150298692691.6608.11908184719252996949.stgit@firesoul>     <150298695758.6608.7128764985631537683.stgit@firesoul>  <5995E472.70609@gmail.com> <20170817212857.1de3f557@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:38075 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753165AbdHQTn2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 15:43:28 -0400
Received: by mail-pg0-f68.google.com with SMTP id 123so11326893pga.5
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 12:43:28 -0700 (PDT)
In-Reply-To: <20170817212857.1de3f557@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2017 12:28 PM, Jesper Dangaard Brouer wrote:
> 
> On Thu, 17 Aug 2017 11:46:10 -0700 John Fastabend <john.fastabend@gmail.com> wrote:
> 
>> On 08/17/2017 09:22 AM, Jesper Dangaard Brouer wrote:
>>> The return error code need to be included in the tracepoint
>>> xdp:xdp_redirect, else its not possible to distinguish successful or
>>> failed XDP_REDIRECT transmits.
>>>
>>> XDP have no queuing mechanism. Thus, it is fairly easily to overrun a
>>> NIC transmit queue.  The eBPF program invoking helpers (bpf_redirect
>>> or bpf_redirect_map) to redirect a packet doesn't get any feedback
>>> whether the packet was actually transmitted.
>>>
>>> Info on failed transmits in the tracepoint xdp:xdp_redirect, is
>>> interesting as this opens for providing a feedback-loop to the
>>> receiving XDP program.
>>>
>>> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>>> ---  
>>
>> [...]
>>
>>> @@ -2532,12 +2535,14 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
>>>  	ri->map = NULL;
>>>  	if (unlikely(!fwd)) {
>>>  		bpf_warn_invalid_xdp_redirect(index);

I think we should drop the warn_invalid now that we have a tracepoint.
The tracepoint is much nicer for debugging vs a warning for what might
be a valid case depending on xdp program.

>>> -		return -EINVAL;
>>> +		err = -EINVAL;
>>> +		goto out;  
>>
>> It doesn't look like there is a check in trace_xdp_redirect to
>> avoid dereferencing a NULL fwd pointer here (*to in trace code
>> path). Did I miss something?
> 
> Nice that you spotted this in your review, but the __string() macro
> used in trace code already takes case of this, see output:
> 
>  xdp:xdp_redirect: prog=39cf08f65683838a from=ixgbe2 to=(null) action=REDIRECT err=-22

Great thanks.
