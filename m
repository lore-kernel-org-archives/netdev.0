From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Thu, 14 Aug 2008 14:59:36 -0700
Message-ID: <1218751176.7444.51.camel@haakon2.linux-iscsi.org>
References: <adad4kfxm9v.fsf@cisco.com>
	 <200808121457.11356.divy@chelsio.com>
	 <20080812.150246.42068558.davem@davemloft.net>
	 <200808121521.10101.divy@chelsio.com> <48A32976.7060504@vlnb.net>
	 <48A33633.20800@pobox.com>  <48A4784B.7030500@vlnb.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	open-iscsi@googlegroups.com, rdreier@cisco.com, rick.jones2@hp.com,
	Steve Wise <swise@opengridcomputing.com>,
	Karen Xie <kxie@chelsio.com>, netdev@vger.kernel.org,
	michaelc@cs.wisc.edu, daisyc@us.ibm.com, wenxiong@us.ibm.com,
	bhua@us.ibm.com, Dimitrios Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vladislav Bolkhovitin <vst@vlnb.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <48A4784B.7030500@vlnb.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-08-14 at 22:24 +0400, Vladislav Bolkhovitin wrote:
> Jeff Garzik wrote:
> > Vladislav Bolkhovitin wrote:
> >> Divy Le Ray wrote:
> >>> On Tuesday 12 August 2008 03:02:46 pm David Miller wrote:
> >>>> From: Divy Le Ray <divy@chelsio.com>
> >>>> Date: Tue, 12 Aug 2008 14:57:09 -0700
> >>>>
> >>>>> In any case, such a stateless solution is not yet designed, whereas
> >>>>> accelerated iSCSI is available now, from us and other companies.
> >>>> So, WHAT?!
> >>>>
> >>>> There are TOE pieces of crap out there too.
> >>> Well, there is demand for accerated iscsi out there, which is the 
> >>> driving reason of our driver submission. 
> >> I'm, as an iSCSI target developer, strongly voting for hardware iSCSI 
> >> offload. Having possibility of the direct data placement is a *HUGE* 
> >> performance gain.
> > 
> > Well, two responses here:
> > 
> > * no one is arguing against hardware iSCSI offload.  Rather, it is a 
> > problem with a specific implementation, one that falsely assumes two 
> > independent TCP stacks can co-exist peacefully on the same IP address 
> > and MAC.
> > 
> > * direct data placement is possible without offloading the entire TCP 
> > stack onto a firmware/chip.
> > 
> > There is plenty of room for hardware iSCSI offload...
>
> Sure, nobody is arguing against that. My points are:
> 
> 1. All those are things not for near future. I don't think it can be 
> implemented earlier than in a year time, but there is a huge demand for 
> high speed and low CPU overhead iSCSI _now_.

Well, the first step wrt to this for us software folks is getting the
Slicing by 8 algoritim CRC32C into the kernel..  This would be a great
benefit for not just traditional iSCSI/TCP, but Linux/SCTP and
Linux/iWARP software codebases.

>  Nobody's satisfied by the 
> fact that with the latest high end hardware he can saturate 10GbE link 
> on only less than 50%(!). Additionally, for me, as an iSCSI target 
> developer, it looks especially annoying that hardware requirements for 
> _clients_ (initiators) are significantly higher than for _server_ 
> (target). This situation for me looks as a nonsense.
> 

I have always found this to be the historical case wrt iSCSI on x86
hardware.  The rough estimate was that given identical hardware and
network configuration, an iSCSI target talking to a SCSI subsystem layer
would be able to handle 2x throughput compared to an iSCSI Initiator,
obviously as long as the actual storage could handle it.

> 2. I believe, that iSCSI/TCP pair is sufficiently heavy weighted 
> protocol to be completely offloaded to hardware.

Heh, I think the period of designing news ASICs for traditional iSCSI
offload is probably slowing.  Aside from the actual difficulting of
doing this and competing with software iSCSI on commodity x86 4x & 8x
core (8x and 16x thread) micropressors with highly efficent software
implementation, that can do BOTH traditional iSCSI offload (where
available) and real deal OS independent connection recovery
(ErrorRecoveryLevel=2) between multiple stateless iSER iWARP/TCP
connections across both hardware *AND* software iWARP RNICs.

>  All partial offloads will never make it comparably efficient.

With traditional iSCSI, I definately agree on this.

With iWARP and iSER however, I believe the end balance of simplicity is
greater for both hardware and software, and allows both hardware and
software to scale more effectively because  The simple gain of having a
Framed PDU on top of legacy TCP with RFC 504[0-4] in order to determine
the offload of the received packet that will be mapped to storage
subsystem later memory for eventual hardware DMA on a vast array of
Linux supported storage hardware and CPU architectures.


>  It still would consume a lot of 
> CPU. For example, consider digests. Even if they computed by new CRC32C 
> instruction, the computation still would need a chunk of CPU power. I 
> think, at least as much as to copy the computed block to new location. 
> Can we save it? Sure, with hardware offload.

So yes, we are talking about quite a few possible cases:

I) Traditional iSCSI:

1) Complete hardware offload for legacy HBAs

2) Hybrid of hardware/software 

As mentioned, reducing application layer checksum overhead for current
software implementations is very important for our quickly increase user
base.  Using the Slicing by 8 CRC32C will help the current code, but I
think the only other real optimization by network ASIC design folks
would be to do something along the lines with traditional iSCSI with the
application layer that the say the e1000 driver does with transport and
network layer checksums today.  I believe the complexity and time to
market considerations of a complete traditional iSCSI offload solution
compared to highly optimized software iSCSI on dedicated commodity cores
still outweighs the benefit IMHO.

Not that I am saying there is no room for improvement from the current
set iSCSI Initiator TOEs.  Again I could build a children's fortress
from iSCSI TOE's and their retail boxes that I have in my office that I
have gotten over the years.   I would definately like to see them
running on the LIO production fabric and VHACS bare-metal storage clouds
at some point for validation purposes, et al.  But as for new designs,
this is still a very difficult proposition,  I am glad to see it being
discussed here..

II) iWARP/TCP and iSER

1) Hardware RNIC w/ iWARP/TCP with software iSER

2) Software RNIC w/ iWARP/TCP with software iSER

3) More possible iSER logic in hardware for latency/performance
optimizations (We won't know this until #1 and #2 happen)

Ahh, now this is the interesting case for scaling vendor independent IP
storage fabric to multiple port full duplex 10 Gb/sec fabrics.  As this
hardware on PCIe gets out (yes, I have some AMSO1100 goodness too
Steve :-), and iSER initiator/targets on iWARP/TCP come online, I
believe the common code between the different flavours of implemenations
will be much larger here.   For example, I previously mentioned ERL=2 in
the context of traditional iSCSI/iSER.  This logic is independent of
what RFC5045 knows a network fabric capable of of direct data placement.
I will also make this code independent in lio-target-2.6.git for my
upstream work.

>  The additional CPU load can 
> be acceptable if only data are transferred and there are no other 
> activities, but in real life this is quite rare. Consider, for instance, 
> a VPS server, like VMware. It always lacks CPU power and 30% CPU load 
> during data transfers makes a huge difference. Another example is a 
> target doing some processing of transferred data, like encryption or 
> de-duplication.

Well, I think alot of this depends on hardware.  For example, there is
the X3100 adapter from Neterion today that can do 10 Gb/sec line rate
with x86_64 virtualization.  Obviously, the Linux kernel (and my
project, Linux-iSCSI.org) wants to be able to support this as vendor
neutral as possible, which is why we make extensive use of multiple
technologies in our production fabrics, and in the VHACS stack. :-)

Also, the Nested Page Tables would be a big win for this particular
case, but I am not familar with the exact numbers..

> 
> Actually, in the Fibre Channel world from the very beginning the entire 
> FC protocol has been implemented on hardware and everybody have been 
> happy with that. Now FCoE is coming, which means that Linux kernel is 
> going to have implemented in software a big chunk of FC protocol. Then, 
> hopefully, nobody would declare all existing FC cards as a crap and 
> force FC vendors redesign their hardware to use Linux FC implementation 
> and make partial offloads for it? ;) Instead, several implementations 
> would live in a peace. The situation is the same with iSCSI. What we 
> need is only to find an acceptable way for two TCP implementations to 
> coexist. Then iSCSI on 10GbE hardware would have good chances to 
> outperform 8Gbps FC in both performance and CPU efficiency.
> 

<nod> :-)

--nab

> Vlad
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-scsi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

