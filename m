From: Auke Kok <sofar@foo-projects.org>
Subject: Re: e1000_down and tx_timeout worker race cleaning the transmit buffers
Date: Wed, 26 Apr 2006 21:55:03 -0700
Message-ID: <44504EA7.5050901@foo-projects.org>
References: <1145578214.3195.6.camel@rh4>	 <E1FWlWa-0007hN-00@gondolin.me.apana.org.au>	 <20060421024024.GA29644@gondor.apana.org.au>	 <1145582676.3195.18.camel@rh4>	 <20060421132758.GA26161@gospo.rdu.redhat.com>	 <1145633287.3194.10.camel@rh4>	 <bdfc5d6e0604211301k682b35d1r52a52cd3fec80ddc@mail.gmail.com>	 <1145646031.3843.5.camel@rh4>	 <bdfc5d6e0604211346n50b15f56g4ebc2fe5fe88a63a@mail.gmail.com> <7bb8b8de0604261714h2471420xa06bb6639ddb6cea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Michael Chan <mchan@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	davem@davemloft.net, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:24749 "EHLO
	mail6.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S964931AbWD0EzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 00:55:06 -0400
To: Shaw <shawvrana@gmail.com>
In-Reply-To: <7bb8b8de0604261714h2471420xa06bb6639ddb6cea@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shaw wrote:
> On 4/21/06, Andy Gospodarek <andy@greyhouse.net> wrote:
>> On 4/21/06, Michael Chan <mchan@broadcom.com> wrote:
>>> On Fri, 2006-04-21 at 16:01 -0400, Andy Gospodarek wrote:
>>>
>>>> I just hate to see extra resources used to solve problems that good
>>>> coding can solve (not that my suggestion is necessarily a 'good' one),
>>>> so I was trying to think of a way to resolve this without explicitly
>>>> adding another workqueue.
>>> If you don't want to add another workqueue, then look at tg3, bnx2, and
>>> one of the smc drivers on how to effectively wait for the driver's
>>> workqueue task to finish without deadlocking with linkwatch_event.
>>>
>> I agree 100%.  I just hope others can manage to figure that out too.
> 
> Ok, here's another attempt.  The goal here is to serialize attempts to
> clean the tx and rx buffers, and ensure that e1000_close is called
> after the tx_timeout_task has completed running and/or that the task
> is safe to run after e1000_close hasrun.
> 
> I'm concerned about the addition of the netif_running check to
> e1000_down.  While something like this is needed, I'm not familiar
> enough w/ the code to know if this is okay.
> All explanations and comments are greatly appreciated.

I apologise for not getting back on this earlier but Jesse Brandeburg and I 
have been digging into this for two days and making some big progress. One of 
the main fixes will be that we're taking out a watchdog reset task completely 
and doing down/up cycles instead, which removes a large portion of the race 
conditions at this stage completely (the tx_timeout triggers a watchdog reset 
which can happen during an e1000_down causing a double free interrupt, or a 
double allocation).

We're making good progress with this and are now working on removing the last 
race between the ioctl path and the ifdn/ifup stuff, where the last remaining 
race location is in the ethtool test which does all sorts of funny lowlevel 
driver stuff that can seriously OOPS if you're running ethtool tests while 
ifup/downing your interface.

While I appreciate patches ;^) I think we're on a better path by making these 
cleanups, and actually reducing the code in large places. I hope to be able to 
push something out for RFC soon. Added benefit will be that we're dropping a 
whole bunch of irq operations where we didn't need to (soft resets).

Cheers,

Auke



