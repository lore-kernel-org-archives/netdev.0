From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] netif_rx: receive path optimization
Date: Thu, 31 Mar 2005 16:07:54 -0800
Message-ID: <424C90DA.7030600@hp.com>
References: <20050330132815.605c17d0@dxpl.pdx.osdl.net>	<20050331120410.7effa94d@dxpl.pdx.osdl.net>	<1112303431.1073.67.camel@jzny.localdomain> <424C6A98.1070509@hp.com>	<1112305084.1073.94.camel@jzny.localdomain> <424C7CDC.8050801@hp.com> <1112312206.1096.25.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
In-Reply-To: <1112312206.1096.25.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>Note Linux is quiet resilient to reordering compared to other OSes (as
>>>you may know) but avoiding this is a better approach - hence my
>>>suggestion to use NAPI when you want to do serious TCP.
>>
>>Would the same apply to NIC->CPU interrupt assignments? That is, bind the NIC to 
>>a single CPU.
>>
> 
> 
> No reordering there.

Ah, I wasn't clear - would someone doing serious TCP want to have the interrupts 
of a NIC go to a specific CPU.

>>>Dont think we can do that unfortunately: We are screwed by the APIC
>>>architecture on x86.
>>
>>The IPS and TOPS stuff was/is post-NIC-interrupt. Low-level driver processing 
>>still happened/s on a specific CPU, it is the higher-level processing which is 
>>done on another CPU.  The idea - with TOPS at least, is to try to access the ULP 
>>(TCP, UDP etc) structures on the same CPU as last accessed by the app to 
>>minimize that cache to cache migration.
>>
> 
> 
> But if interupt happens on "wrong" cpu - and you decide higher level
> processing is to be done on the "right" cpu (i assume queueing on some
> per CPU queue); then isnt that expensive? Perhaps IPIs involved even?

More expensive than if one were lucky enough to have the interrupt on the 
"right" CPU in the first place, but as the CPU count goes-up, the chances of 
that go down.  The main idea behind TOPS and prior to that IPS was to spread-out 
the processing of packets across as many CPUs as we could, as "correctly" as we 
could.  Lots of small packets meant/means that a NIC could saturate its 
interrupt CPU before the NIC was saturated.  You don't necessarily see that on 
say single-instance netperf TCP_STREAM (or basic FTP) testing, but certainly can 
on aggregate netperf TCP_RR testing.

IPS, being driven by the packet header info, was good enough for simple 
benchmarking, but once you had more than one connection per process/thread that 
wasn't going to cut it, and even with one connection per process telling the 
process where it should run wasn't terribly easy :)   It wasn't _that_ much more 
expensive than the queueing already happening - IPS was when HP-UX networking 
was BSDish and it was done when things were being queued to the netisr queue(s).

TOPS lets the process (I suppose the scheduler really) decide where some of the 
processing for the packet will happen - the part after the handoff.

rick
