From: "Jon Fraser" <J_Fraser@bit-net.com>
Subject: RE: Poor gige performance with 2.4.20-pre*
Date: Mon, 30 Sep 2002 17:21:59 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <010c01c268c7$69f48b90$3701020a@CONCORDIA>
References: <200209292054.g8TKsQv14870@vindaloo.ras.ucalgary.ca>
Reply-To: <J_Fraser@bit-net.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
In-Reply-To: <200209292054.g8TKsQv14870@vindaloo.ras.ucalgary.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Hello,

	I'm new to this list, so please bear with me.


	I'm doing similar tests with gige and am seeing similar
issues.  I have two different but similar test machines, both running 2.4.18

	Dell 1550
		dual  1 ghz PIII, 256k cache
		serverworks HE chipset
		intel E1000, 82542 chipset

	embedded card

		dual 1.266 ghz PIII, 512k cache
		serverworks HE chipset
		embedded intel E1000, 28543 chipset

We're using IXIA test gear to source/sink the packets.  The systems are
just ip-forwarding the traffic back out the same interface.  That is, we
have the gige setup with aliases so it is on two different nets.

I'm trying to find the bottlenecks in small packet performance.  With large
packets, we can exceed 900 mpbs on the embedded card, so that's not an
issue.
The Dell 1550 seems to run out of bus bandwidth before reaching that level.

With 64 byte packets, we can achive 250 kpps running dual processor.
This consumes about 65% of each cpu.  Can't go faster without dropping
a significant percentage of the packets.

If we run with the 28543 intrrupts tied to a single processor, we can
achieve
about 285 kpps, at which point we're using 95% of the single cpu.

Running a uniprocessor kernel, we top out around 350 kpps.

There's nothing else running on the boxes.


I'm perplexed by a couple of issues.

The network performance of the SMP kernel with the gige bound to single
processor is only
about 80% of the UP kernel.  Is this typical?  Are the causes of the
performance degradation
well known?


With the gige running on both processors, we get rather poor performance.
We can't even reach the same number of pps on two processors that we can
with one.
Using cpu performance measurement counters, we seem to reach a point where
there is as much time being spent doing cache invalidates as there is doing
real work.
All the queues and statistics are per-cpu in the 2.14.18 kernel.  Are there
other known problems causing excessive cache invalidates?  Are there any
significant
improvements in later kernels?


	Thanks in advance,

	Jon Fraser





> -----Original Message-----
> From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com]On
> Behalf Of Richard Gooch
> Sent: Sunday, September 29, 2002 4:54 PM
> To: Ben Greear
> Cc: netdev@oss.sgi.com
> Subject: Re: Poor gige performance with 2.4.20-pre*
>
>
> Ben Greear writes:
> > Richard Gooch wrote:
> > > Ben Greear writes:
> > >
> > >>Richard Gooch wrote:
> > >>
> > >>>  Hi, all. For a while now I've noticed poor performance
> with gige
> > >>>cards under 2.4.19 and 2.4.20-pre*. At first I thought
> it was because
> > >>>of the cheap-ass Addtron cards I bought (these use the
> ns83820 chip).
> > >>>But now that the Intel E1000 cards are pretty cheap too,
> I've grabbed
> > >>>a couple (part number: PWLA8390MT) and see the same
> problem. In fact,
> > >>>the E1000 cards are no better than the Addtron cards.
> I'm using the
> > >>>D-Link DGS-1008T 8-port gige switch. MTU=1500 bytes.
> > >>
> > >>Try setting the TxDescriptors=4096 RxDescriptors=1024
> when loading the
> > >>e1000 module, that helps tremendously when using smaller packets.
> > >
> > > Didn't help at all. Just to summarise, I've got:
> > > options e1000 TxDescriptors=4096 RxDescriptors=1024
> > > net.ipv4.tcp_rmem = 262144 262144 262144
> > > net.ipv4.tcp_wmem = 262144 262144 262144
> > > MTU=1500
> > >
> > > I'm doing read(2)/write(2) to/from a user-space buffer over a TCP
> > > socket with 256 KiB buffer size.
> > >
> > > Is the E1000 supposed to have hardware interrupt mitigation (thus
> > > avoiding the need for NAPI)?
> >
> > NAPI did not greatly improve the performance I saw with
> larger packets,
> > but it did help with smaller (say, 60 byte) packets.
>
> My packets should be 1500 bytes, or close to it.
>
> > One other thing I saw with TCP connections: They started off slow,
> > but after a few seconds they were reacing their peak throughput.
> > How long are you running your test?
>
> I normally send 100 MB, so that's around 2 seconds or more. Sending
> 1 GB doesn't change anything (other than the test taking 20 seconds or
> more).
>
> Oh, BTW: some possibly relevant config options:
> CONFIG_M686=y
> CONFIG_HIGHMEM4G=y
> # CONFIG_HIGHMEM64G is not set
> CONFIG_HIGHMEM=y
> CONFIG_HIGHIO=y
> CONFIG_SMP=y
> CONFIG_E1000=m
>
> 				Regards,
>
> 					Richard....
> Permanent: rgooch@atnf.csiro.au
> Current:   rgooch@ras.ucalgary.ca
>
>
