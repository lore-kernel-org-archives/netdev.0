From: Andi Kleen <ak@muc.de>
Subject: Re: Intel and TOE in the news
Date: 21 Feb 2005 12:50:06 +0100
Message-ID: <20050221115006.GB87576@muc.de>
References: <20050220230713.GA62354@muc.de> <200502210332.j1L3WkDD014744@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'rick jones'" <rick.jones2@hp.com>, netdev@oss.sgi.com,
        "'Alex Aizman'" <alex@neterion.com>
Date: Mon, 21 Feb 2005 12:50:06 +0100
To: Leonid Grossman <leonid.grossman@neterion.com>
Content-Disposition: inline
In-Reply-To: <200502210332.j1L3WkDD014744@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Feb 20, 2005 at 07:31:55PM -0800, Leonid Grossman wrote:
> Yes, this is what we currently do; I was rather thinking about the option to
> indicate multiple packets in a single call (say as a linked list). 

For the non NAPI case the packet is just put into a queue 
anyways. If you want to process packets as lists then just the consumer 
of the queue would need to be changed. I agree that it would be a good 
idea to lower locking overhead. That would only help much though
if all the packets in a list belong to the same stream, otherwise
you need multiple locks anyways for different sockets and it would be useless.

For NAPI there would need to be some higher level changes for this.

The main problem is that someone has to go through all the protocol layers
and make sure they can process lists. Also it needs careful handling
in netfilter.

> > Most interesting would be to use per CPU TX completion 
> > interrupts using MSI-X and avoid bouncing packets around between CPUs.
> 
> Do you mean indicating rx packets to the same cpu that tx (for the same
> session) came from, or something else?

Just freeing TX packets on the same CPU as they were submitted.
This way the skb will always stay in the per CPU slab cache.

Should be straight forward: you hash the CPU number to the 8 transmit
queues in dev_queue_xmit, then give each queue an own TX MSI and set the 
irq affinity of its interrupt to its CPUs. 

If you have more than 8 CPUs there will be still some bouncing,
but e.g. on a NUMA system you could keep it at least node local
or near in the machine topology (2.6 has the necessary topology
information in the kernel for this now; just distance information
has to be still gotten from ACPI) 

Should be all possible to do from the driver without stack changes.

Using it usefully in RX is probably much harder and would need stack changes.

-Andi
