From: Levi Pearson <levipearson@gmail.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Mon, 2 Oct 2017 12:45:46 -0600
Message-ID: <CAEYbN3STY+7ZOodQLaP4MfbvwCovWsav52PXBmjHND7QOO=srg@mail.gmail.com>
References: <DM2PR0401MB1389A950EAC6FB54D4186B9C927E0@DM2PR0401MB1389.namprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Vinicius Costa Gomes <vinicius.gomes@intel.com>,
        Henrik Austad <henrik@austad.us>, richardcochran@gmail.com,
        jesus.sanchez-palencia@intel.com, andre.guedes@intel.com
To: Rodney Cummings <rodney.cummings@ni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:54058 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751910AbdJBSps (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 14:45:48 -0400
Received: by mail-wm0-f46.google.com with SMTP id q132so12430330wmd.2
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 11:45:47 -0700 (PDT)
In-Reply-To: <DM2PR0401MB1389A950EAC6FB54D4186B9C927E0@DM2PR0401MB1389.namprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rodney,

Some archives seem to have threaded it, but I have CC'd the
participants I saw in the original discussion thread since they may
not otherwise notice it amongst the normal traffic.

On Fri, Sep 29, 2017 at 2:44 PM, Rodney Cummings <rodney.cummings@ni.com> wrote:
> Hi,
>
> I am posting my reply to this thread after subscribing, so I apologize
> if the archive happens to attach it to the wrong thread.
>
> First, I'd like to say that I strongly support this RFC.
> We need Linux interfaces for IEEE 802.1 TSN features.
>
> Although I haven't looked in detail, the proposal for CBS looks good.
> My questions/concerns are more related to future work, such for 802.1Qbv
> (scheduled traffic).
>
> 1. Question: From an 802.1 perspective, is this RFC intended to support
> end-station (e.g. NIC in host), bridges (i.e. DSA), or both?
>
> This is very important to clarify, because the usage of this interface
> will be very different for one or the other.
>
> For a bridge, the user code typically represents a remote management
> protocol (e.g. SNMP, NETCONF, RESTCONF), and this interface is
> expected to align with the specifications of 802.1Q clause 12,
> which serves as the information model for management. Historically,
> a standard kernel interface for management hasn't been viewed as
> essential, but I suppose it wouldn't hurt.

I don't think the proposal was meant to cover the case of non-local
switch hardware, but in addition to dsa and switchdev switch ICs
managed by embedded Linux-running SoCs, there are SoCs with embedded
small port count switches or even plain multiple NICs with software
bridging. Many of these embedded small port count switches have FQTSS
hardware that could potentially be configured by the proposed cbs
qdisc. This blurs the line somewhat between what is a "bridge" and
what is an "end-station" in 802.1Q terminology, but nevertheless these
devices exist, sometimes acting as an endpoint + a real bridge and
sometimes as just a system with multiple network interfaces.

> For an end station, the user code can be an implementation of SRP
> (802.1Q clause 35), or it can be an application-specific
> protocol (e.g. industrial fieldbus) that exchanges data according
> to P802.1Qcc clause 46. Either way, the top-level user interface
> is designed for individual streams, not queues and shapers. That
> implies some translation code between that top-level interface
> and this sort of kernel interface.
>
> As a specific end-station example, for CBS, 802.1Q-2014 subclause
> 34.6.1 requires "per-stream queues" in the Talker end-station.
> I don't see 34.6.1 represented in the proposed RFC, but that's
> okay... maybe per-stream queues are implemented in user code.
> Nevertheless, if that is the assumption, I think we need to
> clarify, especially in examples.

You're correct that the FQTSS credit-based shaping algorithm requires
per-stream shaping by Talker endpoints as well, but this is in
addition to the per-class shaping provided by most hardware shaping
implementations that I'm aware of in endpoint network hardware. I
agree that we need to document the need to provide this, but it can
definitely be built on top of the current proposal.

I believe the per-stream shaping could be managed either by a user
space application that manages all use of a streaming traffic class,
or through an additional qdisc module that performs per-stream
management on top of the proposed cbs qdisc, ensuring that the
frames-per-observation interval aspect of each stream's reservation is
obeyed. This becomes a fairly simple qdisc to implement on top of a
per-traffic class shaper, and could even be implemented with the help
of the timestamp that the SO_TXTIME proposal adds to skbuffs, but I
think keeping the layers separate provides more flexibility to
implementations and keeps management of various kinds of hardware
offload support simpler as well.

> 2. Suggestion: Do not assume that a time-aware (i.e. scheduled)
> end-station will always use 802.1Qbv.
>
> For those who are subscribed to the 802.1 mailing list,
> I'd suggest a read of draft P802.1Qcc/D1.6, subclause U.1
> of Annex U. Subclause U.1 assumes that bridges in the network use
> 802.1Qbv, and then it poses the question of what an end-station
> Talker should do. If the end-station also uses 802.1Qbv,
> and that end-station transmits multiple streams, 802.1Qbv is
> a bad implementation. The reason is that the scheduling
> (i.e. order in time) of each stream cannot be controlled, which
> in turn means that the CNC (network manager) cannot optimize
> the 802.1Qbv schedules in bridges. The preferred technique
> is to use "per-stream scheduling" in each Talker, so that
> the CNC can create an optimal schedules (i.e. best determinism).
>
> I'm aware of a small number of proprietary CNC implementations for
> 802.1Qbv in bridges, and they are generally assuming per-stream
> scheduling in end-stations (Talkers).
>
> The i210 NIC's LaunchTime can be used to implement per-stream
> scheduling. I haven't looked at SO_TXTIME in detail, but it sounds
> like per-stream scheduling. If so, then we already have the
> fundamental building blocks for a complete implementation
> of a time-aware end-station.
>
> If we answer the preceding question #1 as "end-station only",
> I would recommend avoiding 802.1Qbv in this interface. There
> isn't really anything wrong with it per-se, but it would lead
> developers down the wrong path.

In some situations, such as device nodes that each incorporate a small
port count switch for the purpose of daisy-chaining a segment of the
network, "end stations" must do a limited subset of local bridge
management as well. I'm not sure how common this is going to be for
industrial control applications, but I know there are audio and
automotive applications built this way.

One particular device I am working with now provides all network
access through a DSA switch chip with hardware Qbv support in addtion
to hardware Qav support. The SoC attached to it has no hardware timed
launch (SO_TXTIME) support. In this case, although the proposed
interface for Qbv is not *sufficient* to make a working time-aware end
station, it does provide a usable building block to provide one. As
with the credit-based shaping system, Talkers must provide an
additional level of per-stream shaping as well, but this is largely
(absent the jitter calculations, which are sort of a middle-level
concern) independent of what sort of hardware offload of the
scheduling is provided.

Both Qbv windows and timed launch support do roughly the same thing;
they *delay* the launch of a hardware-queued frame so it can egress at
a precisely specified time, and at least with the i210 and Qbv, ensure
that no other traffic will be in-progress when that time arrives. For
either to be used effectively, the application still has to prepare
the frame slightly ahead-of-time and thus must have the same level of
time-awareness. This is, again, largely independent of what kind of
hardware offloading support is provided and is also largely
independent of the network stack itself. Neither queue window
management nor SO_TXTIME help the application present its
time-sensitive traffic at the right time; that's a matter to be worked
out with the application taking advantage of PTP and the OS scheduler.
Whether you rely on managed windows or hardware launch time to provide
the precisely correct amount of delay beyond that is immaterial to the
application. In the absence of SO_TXTIME offloading (or even with it,
and in the presence of sufficient OS scheduling jitter), an additional
layer may need to be provided to ensure different applications' frames
are queued in the correct order for egress during the window. Again,
this could be a purely user-space application multiplexer or a
separate qdisc module.

I wholeheartedly agree with you and Richard that we ought to
eventually provide application-level APIs that don't require users to
have deep knowledge of various 802.1Q intricacies. But I believe that
the hardware offloading capability being provided now, and the variety
of the way things are hooked up in real hardware, suggests that we
ought to also build the support for the underlying protocols in layers
so that we don't create unnecessary mismatches between offloading
capability (which can be essential to overall network performance) and
APIs, such that one configuration of offload support is privileged
above others even when comparable scheduling accuracy could be
provided by either.

In any case, only the cbs qdisc has been included in the post-RFC
patch cover page for its last couple of iterations, so there is plenty
of time to discuss how time-aware shaping, preemption, etc. management
should occur beyond the cbs and SO_TXTIME proposals.


Levi
