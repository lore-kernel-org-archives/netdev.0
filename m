From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC net-next v2] bridge lwtunnel, VPLS & NVGRE
Date: Mon, 21 Aug 2017 17:01:51 -0700
Message-ID: <20170821170151.5b12a392@xeon-e3>
References: <20170821171523.951260-1-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
        amine.kherbouche@6wind.com, roopa@cumulusnetworks.com
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:38485 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753979AbdHVAB7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 20:01:59 -0400
Received: by mail-pg0-f54.google.com with SMTP id m133so26165553pga.5
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 17:01:59 -0700 (PDT)
In-Reply-To: <20170821171523.951260-1-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Aug 2017 19:15:17 +0200
David Lamparter <equinox@diac24.net> wrote:

> Hi all,
> 
> 
> this is an update on the earlier "[RFC net-next] VPLS support".  Note
> I've changed the subject lines on some of the patches to better reflect
> what they really do (tbh the earlier subject lines were crap.)
> 
> As previously, iproute2 / FRR patches are at:
> - https://github.com/eqvinox/vpls-iproute2
> - https://github.com/opensourcerouting/frr/commits/vpls
> while this patchset is also available at:
> - https://github.com/eqvinox/vpls-linux-kernel
> (but please be aware that I'm amending and rebasing commits)
> 
> The NVGRE implementation in the 3rd patch in this series is actually an
> accident - I was just wiring up gretap as a reference;  only after I was
> done I noticed that that sums up to NVGRE, more or less.  IMHO, it does
> serve well to demonstrate the bridge changes are not VPLS-specific.
> 
> To refer some notes from the first announce mail:
> > I've tested some basic setups, the chain from LDP down into the kernel
> > works at least in these.  FRR has some testcases around from OpenBSD
> > VPLS support, I haven't wired that up to run against Linux / this
> > patchset yet.  
> 
> Same as before (API didn't change).
> 
> > The patchset needs a lot of polishing (yes I left my TODO notes in the
> > commit messages), for now my primary concern is overall design
> > feedback.  Roopa has already provided a lot of input (Thanks!);  the
> > major topic I'm expecting to get discussion on is the bridge FDB
> > changes.  
> 
> Got some useful input;  but still need feedback on the bridge FDB
> changes (first 2 patches).  I don't believe it to have a significant
> impact on existing bridge operation, and I believe a multipoint tunnel
> driver without its own FDB (e.g. NVGRE in this set) should perform
> better than one with its own FDB (e.g. existing VXLAN).
> 
> > P.S.: For a little context on the bridge FDB changes - I'm hoping to
> > find some time to extend this to the MDB to allow aggregating dst
> > metadata and handing down a list of dst metas on TX.  This isn't
> > specifically for VPLS but rather to give sufficient information to the
> > 802.11 stack to allow it to optimize selecting rates (or unicasting)
> > for multicast traffic by having the multicast subscriber list known.
> > This is done by major commercial wifi solutions (e.g. google "dynamic
> > multicast optimization".)  
> 
> You can find hacks at this on:
> https://github.com/eqvinox/vpls-linux-kernel/tree/mdb-hack
> Please note that the patches in that branch are not at an acceptable
> quality level, but you can see the semantic relation to 802.11.
> 
> I would, however, like to point out that this branch has pseudo-working
> IGMP/MLD snooping for VPLS, and it'd be 20-ish lines to add it to NVGRE
> (I'll do that as soon as I get to it, it'll pop up on that branch too.)
> 
> This is relevant to the discussion because it's a feature which is
> non-obvious (to me) on how to do with the VXLAN model of having an
> entirely separate FDB.  Meanwhile, with this architecture, the proof of
> concept / hack is coming in at a measly cost of:
> 8 files changed, 176 insertions(+), 15 deletions(-)
> 
> 
> Cheers,
> 
> -David
> 
> 
> --- diffstat:
> include/linux/netdevice.h      |  18 ++++++
> include/net/dst_metadata.h     |  51 ++++++++++++++---
> include/net/ip_tunnels.h       |   5 ++
> include/uapi/linux/lwtunnel.h  |   8 +++
> include/uapi/linux/neighbour.h |   2 +
> include/uapi/linux/rtnetlink.h |   5 ++
> net/bridge/br.c                |   2 +-
> net/bridge/br_device.c         |   4 ++
> net/bridge/br_fdb.c            | 119 ++++++++++++++++++++++++++++++++--------
> net/bridge/br_input.c          |   6 +-
> net/bridge/br_private.h        |   6 +-
> net/core/lwtunnel.c            |   1 +
> net/ipv4/ip_gre.c              |  40 ++++++++++++--
> net/ipv4/ip_tunnel.c           |   1 +
> net/ipv4/ip_tunnel_core.c      |  87 +++++++++++++++++++++++------
> net/mpls/Kconfig               |  11 ++++
> net/mpls/Makefile              |   1 +
> net/mpls/af_mpls.c             | 113 ++++++++++++++++++++++++++++++++------
> net/mpls/internal.h            |  44 +++++++++++++--
> net/mpls/vpls.c                | 550 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> 20 files changed, 990 insertions(+), 84 deletions(-)

I know the bridge is an easy target to extend L2 forwarding, but it is not
the only option. Have you condidered building a new driver (like VXLAN does)
which does the forwarding you want. Having all features in one driver
makes for worse performance, and increased complexity.
