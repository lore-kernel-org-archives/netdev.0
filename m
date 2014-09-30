From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Tue, 30 Sep 2014 14:37:00 -0700
Message-ID: <20140930143700.3dffac4d@urahara>
References: <1411962607-27878-1-git-send-email-therbert@google.com>
	<CAJ3xEMi-TRXevenx87UM7JnKqRQQATW4MBjbz8JdnQE9gk3KZw@mail.gmail.com>
	<CA+mtBx8r05=qs2J58LFq56762tFB7wF4Dsr3C5TC9w5qQP5jGw@mail.gmail.com>
	<CAJ3xEMhf6b75TQDFqEPMSXCpL9ToWG1q0OMPtrEuHNSm=-PSwQ@mail.gmail.com>
	<CA+mtBx_6HcZh5Ys1FJFBXkZ2bWX1gP6bTcjY7gbR6RG_TOy50Q@mail.gmail.com>
	<CAJ3xEMi0biCWTNtLOJ=0HWZYjOWi6pN2bw2=EWajp6XnpoyVRw@mail.gmail.com>
	<CA+mtBx-sP6g9hXAYGfHKCPYkCtjgCFM0srueh1uhoNnC2ACr1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin Shelar <pshelar@nicira.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Andy Zhou <azhou@nicira.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:44190 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753986AbaI3ViE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 17:38:04 -0400
Received: by mail-pa0-f47.google.com with SMTP id rd3so9910887pab.34
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 14:38:03 -0700 (PDT)
In-Reply-To: <CA+mtBx-sP6g9hXAYGfHKCPYkCtjgCFM0srueh1uhoNnC2ACr1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Sep 2014 08:34:14 -0700
Tom Herbert <therbert@google.com> wrote:

> On Tue, Sep 30, 2014 at 7:30 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> > On Tue, Sep 30, 2014 at 12:38 AM, Tom Herbert <therbert@google.com> wrote:
> >> On Mon, Sep 29, 2014 at 2:10 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> >>> On Mon, Sep 29, 2014 at 11:53 PM, Tom Herbert <therbert@google.com> wrote:
> >>>> On Mon, Sep 29, 2014 at 12:59 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> >>>>> On Mon, Sep 29, 2014 at 6:50 AM, Tom Herbert <therbert@google.com> wrote:
> >>>>>> Add ndo_gso_check which a device can define to indicate whether is
> >>>>>> is capable of doing GSO on a packet. This funciton would be called from
> >>>>>> the stack to determine whether software GSO is needed to be done.
> >>>>>
> >>>>> please, no...
> >>>>>
> >>>>> We should strive to have a model/architecture under which the driver
> >>>>> can clearly advertize up something (bits, collection of bits,
> >>>>> whatever) which the stack can run through some dec-sion making code
> >>>>> and decide if to GSO yes/no, do it ala SW or ala HW. As life, this
> >>>>> model need not be perfect and can be biased towards being
> >>>>> simple/robust/conservative and developed incrementally.
> >
> >>>> Please make a specific proposal then.
> >
> > OK
> >
> >>> We 1st need to bring the system back into a consistent state, see my
> >>> band-aid proposal. BTW, this band-aid might turn to be the basis for
> >>> the longer term solution too. I admit that saying "no" is ten (100)
> >>> times harder vs. say "let's do it this way", but IMHO the fm10k call
> >>> chain I pointed on is what you are suggesting more-or-less and is no-no
> >
> >> I'd much rather have drivers do this, than inflict the stack with more
> >> complexity. As you describe "the driver can clearly advertise up
> >> something (bits, collection of bits, whatever) which the stack can run
> >> through some dec-sion making code and decide if to GSO yes/no"-- seems
> >> very complex to me. My proposed alternative is to just ask the driver
> >
> > I see the point you are trying to make, but
> >
> >> and they can implement whatever policy they want, stack should doesn't
> >> care about the specifics, just needs an answer. Neither does this
> >> necessarily mean that driver needs to inspect packet, for instance I
> >> suspect that just be looking at inner header lengths and skb->protocol
> >> being TEB would be standard check to match VXLAN.
> >
> > I'm not sure how exactly this (inner protocol being Ethernet and inner
> > header lengths)
> > is going to work to differentiate between VXLAN and NVGRE (or @ least
> > the GRE-ing done
> > by OVS on guest Ethernet frames).
> >
> GSO processing for VXLAN and NVGRE should be identical. They both have
> a four byte header that needs to be copied per packet and both only
> carry Ethernet frames.
> 
> >> In any case, if you can formulate your proposal in a patch that would
> >> be very helpful.
> >
> > Quick idea is the following:
> >
> > It's common that when someone along the stack (e,g OVS vxlan/gre datapath logic)
> > encapsulates a packet, they do know what sort of encapsulation they are doing.
> >
> > So the encapsulating entity can color the packet skb and the driver
> > would advertize
> > to what colors (UDP encap types) they can do GSO. When we come to a
> > point where the
> > stack has to decide if go for SW or HW GSO, they attempt to match the colors.
> >
> This would be equivalent to adding more protocol specific GSO feature
> bits. I still don't see how this will scale. The number of protocols
> that we might want to encapsulate over UDP is vast-- even before FOU
> adding possibility of encapsulating any IP protocol in UDP. And, as
> already pointed out, devices might have other arbitrary limitations
> such as length of inner headers that wouldn't easily be represented in
> features.
> 
> Also, this does not benefit the stack or drivers that already support
> generic SKB_GSO_UDP_TUNNEL mechanism.
> 
> Would any other driver maintainers like to chime in on this?

I prefer the simplistic "yes I can do GSO" flag and let the
driver do software GSO for the cases where it detects "no never mind
that, I can't' do GSO on a Q-in-Q VLAN with NVGRE".

Software GSO at driver level is sometimes better anyway because it means driver can
enqueue a burst of packets into Tx ring.
