From: Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Subject: Re: QEMU PIC indirection patch for in-kernel APIC work
Date: Mon, 09 Apr 2007 16:38:18 +0300
Message-ID: <461A41CA.9080201@qumranet.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-reply-to: <1176111984.11664.90.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
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
> On Mon, 2007-04-09 at 10:10 +0300, Avi Kivity wrote:
>   
>> Rusty Russell wrote:
>>     
>>> 	I'm a little puzzled by your response.  Hmm...
>>>
>>> 	lguest's userspace network frontend does exactly as many copies as
>>> Ingo's in-host-kernel code.  One from the Guest, one to the Guest.
>>>       
>> kvm pvnet is suboptimal now.  The number of copies could be reduced by 
>> two (to zero), by constructing an skb that points to guest memory.  
>> Right now, this can only be done in-kernel.
>>     
>
> Sorry, you lost me here.  You mean both input and output copies can be
> eliminated?  Or are you talking about another two copies somewhere?
>   

On the transmit path, current kvm pvnet has two copies:

1.  on the guest side, the driver copies the skb data into the shared ring
2. on the host side, the device copies the data from the ring into a 
newly allocated skb

Both of these copies can be eliminated with a host-side kernel.  With 
current userspace interfaces, only one copy can be eliminated.

Similar logic applies to receive, except that one copy must remain.

> But I don't get this "we can enhance the kernel but not userspace" vibe
> 8(
>   

I've been waiting for network aio since ~2003.  If it arrives in the 
next few days, I'm all for it; much more than kvm can use it 
profitably.  But I'm not going to write that interface myself.

Moreover, some things just don't lend themselves to a userspace 
abstraction.  If we want to expose tso (tcp segmentation offload), we 
can easily do so with a kernel driver since the kernel interfaces are 
all tso aware.  Tacking on tso awareness to tun/tap is doable, but at 
the very least wierd.

>   
>> With current userspace networking interfaces, one cannot build a network 
>> device that has less than one copy on transmit, because sendmsg() *must* 
>> copy the data (as there is no completion notification).
>>     
>
> Why are you talking about sendmsg()?  Perhaps this is where we're
> getting tangled up.
>
> We're dealing with the tun/tap device here, not a socket.
>
>   

Hmm.  tun actually has aio_write implemented, but it seems synchronous.  
So does the read path.

If these are made truly asynchronous, and the write path is made in 
addition copyless, then we might have something workable.  I still 
cringe at having a pagetable walk in order to deliver a 1500-byte packet.


>>  sendfilev(), 
>> even if it existed, cannot be used: it is copyless, but lacks completion 
>> notification.  It is useful only on unchanging data like read-only files.
>>     
>
> Again, sendfile is a *much* harder problem than sending a single packet
> once, which is the question here.
>   

sendfile() is a *different* problem.  It doesn't need completion because 
the data is assumed not to change under it.

Consider that the guest may be issuing a megabyte-sized sendfile() which 
is broken into 17 tso frames.  We need to preserve the large structures 
as much as possible or we end up repeating the simple "single packet 
once" path 700 times.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
