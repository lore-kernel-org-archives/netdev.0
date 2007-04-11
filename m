From: Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Subject: Re: QEMU PIC indirection patch for in-kernel APIC work
Date: Wed, 11 Apr 2007 17:28:40 +0300
Message-ID: <461CF098.3090003@qumranet.com>
References: <4613B438.60107@codemonkey.ws> <4613B89F.8090806@qumranet.com>	
	<4613BC6B.1070708@codemonkey.ws> <4613BF07.50606@qumranet.com>	
	<4613C993.9020405@codemonkey.ws> <4613CC01.1090500@qumranet.com>	
	<4613CDB2.4000903@codemonkey.ws> <4613D001.3040606@qumranet.com>	
	<20070404200112.GA6070@elte.hu> <4614098F.2030307@us.ibm.com>	
	<20070404212103.GA19026@elte.hu>	
	<1175728768.12230.593.camel@localhost.localdomain>	
	<4614A294.3000607@qumranet.com>	
	<1175821357.12230.642.camel@localhost.localdomain>	
	<46187F4E.1080807@qumranet.com>	
	<1176087018.11664.65.camel@localhost.localdomain>	
	<4619E6DC.3010804@qumranet.com>	
	<1176111984.11664.90.camel@localhost.localdomain>	
	<461A41CA.9080201@qumranet.com>	
	<1176263593.26372.84.camel@localhost.localdomain>	
	<461C6360.1060908@qumranet.com>
	<1176297794.14322.72.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1176297794.14322.72.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=kvm-devel>
List-Post: <mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Rusty Russell wrote:
> On Wed, 2007-04-11 at 07:26 +0300, Avi Kivity wrote:
>   
>> Nope.  Being async is critical for copyless networking:
>>
>> - in the transmit path, so need to stop the sender (guest) from touching
>> the memory until it's on the wire.  This means 100% of packets sent will
>> be blocked.
>>     
>
> Hi Avi,
>
> 	You keep saying stuff like this, and I keep ignoring it.  OK, I'll
> bite:
>
> 	Why would we try to prevent the sender from altering the packets?
>
>   

To avoid data corruption.

The guest wants to send a packet.  It calls write(), which causes an skb 
to be allocated, data to be copied into it, the entire networking stack 
gets into gear, and the guest-side driver instructs the "device" to send 
the packet.

With async operations, the saga continues like this: the host-side 
driver allocates an skb, get_page()s and attaches the data to the new 
skb, this skb crosses the bridge, trickles into the real ethernet 
device, gets queued there, sent, interrupts fire, triggering async 
completion.  On this completion, we send a virtual interrupt to the 
guest, which tells it to destroy the skb and reclaim the pages attached 
to it.

Without async operations, we don't have a hook to notify the guest when 
to reclaim the skb.  If we do it too soon, the skb can be reclaimed and 
the memory reused before the real device gets to see it, so we end up 
sending data that we did not intend.  The only way to avoid it is to 
copy the data somewhere safe, but that is exactly what we don't want to do.

>> - multiple packets per operation (for interrupt mitigation) (like
>> lio_listio)
>>     
>
> The benefits for interrupt mitigation are less clear to me in a virtual
> environment (scheduling tends to make it happen anyway); I'd want to
> benchmark it.
>
>   

Yes, the guest will probably submit multiple packets in one hypercall.  
It would be nice for the userspace driver to be able to submit them to 
the host kernel in one syscall.

> Some kind of batching to reduce syscall overhead, perhaps, but TSO would
> go a fair way towards that anyway (probably not enough).
>
>   

For some workloads, sure.


>> - scatter/gather packets (iovecs)
>>     
>
> Yes, and this is already present in the tap device.  Anthony suggested a
> slightly nasty hack for multiple sg packets in one writev()/readv, which
> could also give us batching.
>
>   

No need for hacks if we get list aio support one day.

>> - configurable wakeup (by packet count/timeout) for queue management
>>     
>
> I'm not convinced that this is a showstopper, though.
>   

It probably isn't.  It's free with aio though.

>   
>> - hacks (tso)
>>     
>
> I'd usually go for a batch interface over TSO, but if the card we're
> sending to actually does TSO then TSO will probably win.
>   

Sure, if tso helps a regular host then it should help one that happens 
to be running a virtual machine.

>   
>> Most of these can be provided by a combination of the pending aio work,
>> the pending aio/fd integration, and the not-so-pending tap aio work.  As
>> the first two are available as patches and the third is limited to the
>> tap device, it is not unreasonable to try it out.  Maybe it will turn
>> out not to be as difficult as I predicted just a few lines above.
>>     
>
> Indeed, I don't think we're asking for a revolution a-la VJ-style
> channels.  But I'm still itching to get back to that, and this might yet
> provide an excuse 8)
>   

I'll be happy if this can be made to work.  It will make the paravirt 
guest-side driver work in kvm-less setups, which are useful for testing, 
and of course reduction in kernel code is beneficial.  It will be slower 
that in-kernel, but if we get the batching right, perhaps not 
significantly slower.  I'm mostly concerned that this depends on code 
that has eluded merging for such a long time.


-- 
error compiling committee.c: too many arguments to function


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
