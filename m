From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] net: napi fix
Date: Thu, 13 Dec 2007 21:16:12 +0100
Message-ID: <4761930C.3030504@gmail.com>
References: <47602B77.2090202@intel.com>	<20071213134953.GA3806@ff.dom.local> <20071213.055013.83963139.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, gallatin@myri.com, joonwpark81@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, shemminger@linux-foundation.org,
	jesse.brandeburg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:52325 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761715AbXLMUNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 15:13:52 -0500
Received: by nf-out-0910.google.com with SMTP id g13so666097nfb.21
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 12:13:50 -0800 (PST)
In-Reply-To: <20071213.055013.83963139.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, On 12/13/2007 02:50 PM:

> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Thu, 13 Dec 2007 14:49:53 +0100
> 
>> As a matter of fact, since it's "unlikely()" in net_rx_action() anyway,
>> I wonder what is the main reason or gain of leaving such a tricky
>> exception, instead of letting drivers to always decide which is the
>> best moment for napi_complete()? (Or maybe even, in such a case, they
>> should call some function with this list_move_tail() if it's so
>> useful?)
> 
> It is the only sane way to synchronize the list manipulations.
> 
> There has to be a way for ->poll() to tell net_rx_action() two things:
> 
> 1) How much work was completed, so we can adjust 'budget'


The 'budget' line would stay where it is. IMHO, it's only about this
list_move_tail(). (Probably also doing netpoll_poll_unlock()
during n->poll() could be considered to let the driver even destroy
napi just after napi_complete() - but it's another subject.)

> 2) Was the NAPI quota exhausted?  So that we know that
>    net_rx_action() still "owns" the polling context and
>    thus can do the list manipulation safely.
> 
> And these both need to be encoded into one single return value, thus
> the adopted convention that "work == weight" means that the device has
> not done a NAPI complete.

Of course, with some care and explanations to driver maintainers, like in
this case, this all should probably work like it is. But IMHO it would be
easier to remember and maintain if there are some simple rules with no
exceptions, so here e.g. driver always "owns" (with functions like
napi_schedule(), napi_complete(), and maybe napi_move_tail()), and
net_rx_action() only reads the list and runs these functions?!

I see in a nearby thread you would prefer to save some work to drivers
(like this netif_running() check), but I think this all is at the cost
of flexibility, and there will probably appear new problems, when a
driver simply can't wait till the next poll (which btw. looks strange
with all these hotplugging, usb and powersaving).

Regards,
Jarek P.
