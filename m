From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] netif_rx: receive path optimization
Date: Thu, 31 Mar 2005 14:42:36 -0800
Message-ID: <424C7CDC.8050801@hp.com>
References: <20050330132815.605c17d0@dxpl.pdx.osdl.net>	<20050331120410.7effa94d@dxpl.pdx.osdl.net>	<1112303431.1073.67.camel@jzny.localdomain> <424C6A98.1070509@hp.com> <1112305084.1073.94.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
In-Reply-To: <1112305084.1073.94.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>At the risk of again chewing on my toes (yum), if multiple CPUs are pulling 
>>packets from the per-device queue there will be packet reordering. 
> 
> 
> ;-> This happens already _today_ on Linux on non-NAPI.
> 
> Take the following scenario in non-NAPI. 
> -packet 1 arrives 
> -interupt happens, NIC bound to CPU0
> - in the meantime packets 2,3 arrive
> - 3 packets put on queue for CPU0
> - interupt processing done
> 
> - packet 4 arrives, interupt, CPU1 is bound to NIC
> - in the meantime packets 5,6 arrive
> - CPU1 backlog queue used.
> - interupt processing done
> 
> Assume CPU0 is overloaded with other systenm work and CPU1 rx processing
> kicks in first ... 
> TCP sees packet 4, 5, 6 before 1, 2, 3 ..

I "never" see that because I always bind a NIC to a specific CPU :)  Just about 
every networking-intensive benchmark report I've seen has done the same.

> Note Linux is quiet resilient to reordering compared to other OSes (as
> you may know) but avoiding this is a better approach - hence my
> suggestion to use NAPI when you want to do serious TCP.

Would the same apply to NIC->CPU interrupt assignments? That is, bind the NIC to 
a single CPU.

>> HP-UX 10.0 
>>did just that and it was quite nasty even at low CPU counts (<=4).  It was 
>>changed by HP-UX 10.20 (ca 1995) to per-CPU queues with queue selection computed 
>>from packet headers (hash the IP and TCP/UDP header to pick a CPU) It was called 
>>IPS for Inbound Packet Scheduling.  11.0 (ca 1998) later changed that to "find 
>>where the connection last ran and queue to that CPU" That was called TOPS - 
>>Thread Optimized Packet Scheduling.
>>
> 
> 
> Dont think we can do that unfortunately: We are screwed by the APIC
> architecture on x86.

The IPS and TOPS stuff was/is post-NIC-interrupt. Low-level driver processing 
still happened/s on a specific CPU, it is the higher-level processing which is 
done on another CPU.  The idea - with TOPS at least, is to try to access the ULP 
(TCP, UDP etc) structures on the same CPU as last accessed by the app to 
minimize that cache to cache migration.

rick jones
