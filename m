From: "Gregory Haskins" <ghaskins@novell.com>
Subject: Re: [PATCH 4/7] vbus-proxy: add a pci-to-vbus bridge
Date: Fri, 07 Aug 2009 09:44:25 -0600
Message-ID: <4A7C13990200005A00051DCD@sinclair.provo.novell.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net>
 <200908070057.54795.arnd@arndb.de>
 <4A7B78580200005A00051D50@sinclair.provo.novell.com>
 <200908071657.32858.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <alacrityvm-devel@lists.sourceforge.net>,
	"Ira W. Snyder" <iws@ovro.caltech.edu>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Arnd Bergmann" <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <200908071657.32858.arnd@arndb.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 8/7/2009 at 10:57 AM, in message <200908071657.32858.arnd@arndb.de>, Arnd
Bergmann <arnd@arndb.de> wrote: 
> On Friday 07 August 2009, Gregory Haskins wrote:
>> >>> Arnd Bergmann <arnd@arndb.de> wrote: 
>> > On Thursday 06 August 2009, Gregory Haskins wrote:
>> > 
>> > >     2b) I also want to collapse multiple interrupts together so as to 
>> > > minimize the context switch rate (inject + EIO overhead).  My design 
>> > > effectively has "NAPI" for interrupt handling.  This helps when the system 
> 
>> > > needs it the most: heavy IO.
>> > 
>> > That sounds like a very useful concept in general, but this seems to be a
>> > detail of the interrupt controller implementation. If the IO-APIC cannot
>> > do what you want here, maybe we just need a paravirtual IRQ controller
>> > driver, like e.g. the PS3 has.
>> 
>> Yeah, I agree this could be a function of the APIC code.  Do note that I
>> mentioned this in passing to Avi a few months ago but FWIW he indicated
>> at that time that he is not interested in making the APIC PV.
>> 
>> Also, I almost forgot an important one.  Add:
>> 
>>    2c) Interrupt prioritization.  I want to be able to assign priority
>>    to interrupts and handle them in priority order.
> 
> I think this part of the interface has developed into the wrong direction
> because you confused two questions:
> 
> 1. should you build an advanced interrupt mechanism for virtual drivers?
> 2. how should you build an advanced interrupt mechanism for virtual drivers?
> 
> My guess is that when Avi said he did not want a paravirtual IO-APIC,
> he implied that the existing one is good enough (maybe Avi can clarify that
> point himself) answering question 1, while you took that as an indication
> that the code should live elsewhere instead, answering question 2.
> 
> What you built with the shm-signal code is essentially a paravirtual nested
> interrupt controller by another name, and deeply integrated into a new
> bigger subsystem. I believe that this has significant disadvantages
> over the approach of making it a standard interrupt controller driver:
> 
> * It completely avoids the infrastructure that we have built into Linux
>   to deal with interrupts, e.g. /proc/interrupts statistics, IRQ
>   balancing and CPU affinity.
> 
> * It makes it impossible to quantify the value of the feature to start with,
>   which could be used to answer question 1 above.
> 
> * Less importantly, it does not work with any other drivers that might
>   also benefit from a new interrupt controller -- if it is indeed better
>   than the one we already have.
> 
> 	Arnd <><

Hi Arnd,

I don't strongly disagree with anything you said (except for perhaps that I confused the question).  I agree that the PCI-bridge effectively implements something akin to an interrupt controller.  I agree that this interrupt controller, if indeed superior (I believe it is), can only benefit devices inherently behind the bridge instead of all of KVM (this in of itself doesnt bother me, as I plan on all my performance work to be based on that bus, but I digress.  Also note that this is not dissimilar to other bridge+bus (think usb, scsi) operation).  I agree that a potentially more ideal solution would be if we had a proper generic PV interrupt controller that exhibited similar traits as to what I describe (priority, inject+EIO overhead reduction, etc) so that all of KVM benefited.

The issue wasn't that I didn't know these things.  The issue is that I have no control over whether such an intrusive change to KVM (and the guest arch code) is accepted (and at least one relevant maintainer expressed dissatisfaction (*) at the idea when proposed) Conversely, I am the maintainer of AlacrityVM, so I do have control over the bridge design. ;)  Also note that this particular design decision is completely encapsulated within alacrityvm's components.  IOW, I am not foisting my ideas on the entire kernel tree:  If someone doesn't like what I have done, they can choose not to use alacrity and its like my ideas never existed.  The important thing with this distinction is I am not changing how core linux or core kvm works in the process, only the one little piece of the world that 
 particularly interests me.

That said, if attitudes about some of these ideas have changed, I may be able to break that piece out and start submitting it to kvm@ as some kind of pv interrupt controller.  I would only be interested in doing so if Avi et. al. express an openness to the idea...I.e.. I don't want to waste my time any more than any one elses.

Kind Regards,
-Greg

(*) I think Avi said something to the effect of "you are falling into the 'lets PV the world' trap"

