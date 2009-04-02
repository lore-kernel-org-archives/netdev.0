From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 16:45:53 +0300
Message-ID: <49D4C191.2070502@redhat.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <49D3D7EE.4080202@novell.com> <49D46089.5040204@redhat.com> <49D497A1.4090900@novell.com> <49D4A4EB.8020105@redhat.com> <49D4AE0C.3000604@novell.com> <49D4B2C0.5060906@redhat.com> <49D4B594.6080703@novell.com> <49D4B8B4.4020003@redhat.com> <49D4BF70.1060301@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54427 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754133AbZDBNqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2009 09:46:13 -0400
In-Reply-To: <49D4BF70.1060301@novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gregory Haskins wrote:
> Avi Kivity wrote:
>   
>> Gregory Haskins wrote:
>>     
>>> Avi Kivity wrote:
>>>  
>>>       
>>>> My 'prohibitively expensive' is true only if you exit every packet.
>>>>
>>>>
>>>>     
>>>>         
>>> Understood, but yet you need to do this if you want something like iSCSI
>>> READ transactions to have as low-latency as possible.
>>>   
>>>       
>> Dunno, two microseconds is too much?  The wire imposes much more.
>>
>>     
>
> No, but thats not what we are talking about.  You said signaling on
> every packet is prohibitively expensive.  I am saying signaling on every
> packet is required for decent latency.  So is it prohibitively expensive
> or not?
>   

We're heading dangerously into the word-game area.  Let's not do that.

If you have a high throughput workload with many packets per seconds 
then an exit per packet (whether to userspace or to the kernel) is 
expensive.  So you do exit mitigation.  Latency is not important since 
the packets are going to sit in the output queue anyway.

If you have a request-response workload with the wire idle and latency 
critical, then there's no problem having an exit per packet because (a) 
there aren't that many packets and (b) the guest isn't doing any 
batching, so guest overhead will swamp the hypervisor overhead.

If you have a low latency request-response workload mixed with a high 
throughput workload, then you aren't going to get low latency since your 
low latency packets will sit on the queue behind the high throughput 
packets.  You can fix that with multiqueue and then you're back to one 
of the scenarios above.

> I think most would agree that adding 2us is not bad, but so far that is
> an unproven theory that the IO path in question only adds 2us.   And we
> are not just looking at the rate at which we can enter and exit the
> guest...we need the whole path...from the PIO kick to the dev_xmit() on
> the egress hardware, to the ingress and rx-injection.  This includes any
> and all penalties associated with the path, even if they are imposed by
> something like the design of tun-tap.
>   

Correct, we need to look at the whole path.  That's why the wishing well 
is clogged with my 'give me a better userspace interface' emails.

> Right now its way way way worse than 2us.  In fact, at my last reading
> this was more like 3060us (3125-65).  So shorten that 3125 to 67 (while
> maintaining line-rate) and I will be impressed.  Heck, shorten it to
> 80us and I will be impressed.
>   

The 3060us thing is a timer, not cpu time.  We aren't starting a JVM for 
each packet.  We could remove it given a notification API, or 
duplicating the sched-and-forget thing, like Rusty did with lguest or 
Mark with qemu.

-- 
error compiling committee.c: too many arguments to function

