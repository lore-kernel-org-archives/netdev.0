From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] netif_rx: receive path optimization
Date: 31 Mar 2005 16:38:04 -0500
Message-ID: <1112305084.1073.94.camel@jzny.localdomain>
References: <20050330132815.605c17d0@dxpl.pdx.osdl.net>
	 <20050331120410.7effa94d@dxpl.pdx.osdl.net>
	 <1112303431.1073.67.camel@jzny.localdomain>  <424C6A98.1070509@hp.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <424C6A98.1070509@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-31 at 16:24, Rick Jones wrote:
> > The repurcassions of going from per-CPU-for-all-devices queue
> > (introduced by softnet) to per-device-for-all-CPUs maybe huge in my
> > opinion especially in SMP. A closer view of whats there now maybe
> > per-device-per-CPU backlog queue.
> > I think performance will be impacted in all devices. imo, whatever needs
> > to go in needs to have some experimental data to back it
> 
> Indeed.
> 
> At the risk of again chewing on my toes (yum), if multiple CPUs are pulling 
> packets from the per-device queue there will be packet reordering. 

;-> This happens already _today_ on Linux on non-NAPI.

Take the following scenario in non-NAPI. 
-packet 1 arrives 
-interupt happens, NIC bound to CPU0
- in the meantime packets 2,3 arrive
- 3 packets put on queue for CPU0
- interupt processing done

- packet 4 arrives, interupt, CPU1 is bound to NIC
- in the meantime packets 5,6 arrive
- CPU1 backlog queue used.
- interupt processing done

Assume CPU0 is overloaded with other systenm work and CPU1 rx processing
kicks in first ... 
TCP sees packet 4, 5, 6 before 1, 2, 3 ..

Note Linux is quiet resilient to reordering compared to other OSes (as
you may know) but avoiding this is a better approach - hence my
suggestion to use NAPI when you want to do serious TCP.

Of course NAPI is not all that panacea under low traffic eating a little
bit more CPU (but you have CPU issues under low load you are in some
other deep shit)

>  HP-UX 10.0 
> did just that and it was quite nasty even at low CPU counts (<=4).  It was 
> changed by HP-UX 10.20 (ca 1995) to per-CPU queues with queue selection computed 
> from packet headers (hash the IP and TCP/UDP header to pick a CPU) It was called 
> IPS for Inbound Packet Scheduling.  11.0 (ca 1998) later changed that to "find 
> where the connection last ran and queue to that CPU" That was called TOPS - 
> Thread Optimized Packet Scheduling.
> 

Dont think we can do that unfortunately: We are screwed by the APIC
architecture on x86.

cheers,
jamal
