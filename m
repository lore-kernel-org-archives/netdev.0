From: Gregory Carter <gcarter@aesgi.com>
Subject: Re: NIC emulation with built-in rate limiting?
Date: Tue, 11 Sep 2012 14:05:58 -0500
Message-ID: <504F8B96.7070302@aesgi.com>
References: <504F7DCB.3050401@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	Lee Schermerhorn <Lee.Schermerhorn@hp.com>,
	Brian Haley <Brian.Haley@hp.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <504F7DCB.3050401@hp.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You can not model TCP/IP accurately in a KVM VM environment.

Too much background machinations are going on to make that plausible.

I would use a small network with actual hardware for the testing model. 
You will have to use the actual gear in place and test and tweak there 
if you are doing bandwidth sharing, multi-channel with qdiscs stochastic 
queuing.

However, you can model various protocols using single channel qdiscs 
fairly well, certainly well enough to use the data to direct your build 
outs.

Application behavior works pretty well, if you are simply limiting 
bandwidth sharing using single channel qdiscs such as discovering lower 
end acceptable transmission rates for VoIP traffic etc.  I have had 
really good success with various codecs tested with single channel rate 
limited qdiscs to answer various questions about latency and 
bandwidth/quality issues in transmission of audio/video, yielding 
numbers that reveal useful behavior in the design planning phases of 
network services.

May I suggest allocating one channel to one qdisc.

Also, you have to strip the machine down if you want accurate results.  
Do not have X running or anything other than the virtual machines 
required as part of your testing process.  Strip the process queue on 
the testing gear to only running the VM's and Virtual network in question.

The lower you go in the network VM's connections, the more chaotic and 
useless your numbers are going to be.  In certain situations, if you 
strip your test bed down far enough, you can predict how certain kernel 
processes will affect your monitoring and screen those out of the data sets.

I use stripped down source built kernels by the way for many of these 
questions because a lot of junk in the kernel such as I/O queing and 
scheduling I turn off, specifically building kernels for running complex 
VM point to point virtualized networks with as little background noise 
as I can get.

After a while, if you standardize your network setup, you can screen out 
a lot of background noise, and get some useful answers to how 
applications and limited bandwidth connected endpoints will fair.

-gc

On 09/11/2012 01:07 PM, Rick Jones wrote:
> Are there NIC emulations in the kernel with built-in rate limiting?  
> Or is that supposed to be strictly the province of qdiscs/filters?
>
> I've been messing about with netperf in a VM using virtio_net, to 
> which rate limiting has been applied to its corresponding vnetN 
> interface - rate policing on vnetN ingress (the VM's outbound) and htb 
> on the vnetN egress (the VM's inbound).
>
> Looking at the "demo mode" output of netperf and a VM throttled to 800 
> Mbit/s in each direction I see that inbound to the VM is quite steady 
> over time - right at about 800 Mbit/s.  However, looking at that same 
> sort of data for outbound from the VM shows considerable variability 
> ranging anywhere from 700 to 900 Mbit/s (though the bulk of the 
> variability is clustered more like 750 to 850.
>
> I was thinking that part of the reason may stem from the lack of 
> direct feedback to the VM since the policing is on the vnetN interface 
> and wondered if it might be "better" if the VM's outbound network rate 
> were constrained not by an ingress policing filter on the vnetN 
> interface but by the host/hypervisor/emulator portion of the NIC and 
> how quickly it pulls packets from the tx queue.  That would allow the 
> queue which built-up to be in the VM itself and would more accurately 
> represent what a "real NIC" of that bandwidth would do.
>
> happy benchmarking,
>
> rick jones
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

