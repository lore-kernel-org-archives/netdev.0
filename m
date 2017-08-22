From: David Lamparter <equinox@diac24.net>
Subject: Re: [RFC net-next v2] bridge lwtunnel, VPLS & NVGRE
Date: Tue, 22 Aug 2017 13:24:51 +0200
Message-ID: <20170822112451.GA773745@eidolon>
References: <20170821171523.951260-1-equinox@diac24.net>
 <CAJieiUiz2EmzeaREa4PAd_=2J_MBWUMVh_4abS2HdtcmK30EBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        bridge@lists.linux-foundation.org,
        Amine Kherbouche <amine.kherbouche@6wind.com>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:42766 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932350AbdHVLYy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 07:24:54 -0400
Content-Disposition: inline
In-Reply-To: <CAJieiUiz2EmzeaREa4PAd_=2J_MBWUMVh_4abS2HdtcmK30EBQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 09:43:15PM -0700, Roopa Prabhu wrote:
> > This is relevant to the discussion because it's a feature which is
> > non-obvious (to me) on how to do with the VXLAN model of having an
> > entirely separate FDB.  Meanwhile, with this architecture, the proof of
> > concept / hack is coming in at a measly cost of:
> > 8 files changed, 176 insertions(+), 15 deletions(-)
> 
> David, what is special about the vpls igmp/mld snooping code ?...do
> you have to snoop vpls attrs ?.

It just needs to snoop which tunnel endpoint[s] a multicast group is
subscribed on.

> in the vxlan model.., the vxlan driver can snoop its own attrs eg
> vxlan-id, remote dst etc.
> and the pkt is passed up to the bridge where it will hit the normal
> bridge igmp/mpld snooping code.
> can you pls elaborate ?

Yes, that's exactly what the hack I have is doing, it's snooping the
driver-specific attrs into a metadata_dst, passing it up to the bridge,
which puts the metadata_dst on the MDB entry.

What I'm arguing against is duplicating the entire MDB into all of the
drivers.

The snooping machinery is a pretty complex piece of code which holds
information as a cartesian combination of MAC * VLAN * Group.  It has
several configuration knobs and can even send its own packets.  It's
complex enough to have been the subject of several CVEs over its history
(e.g. CVE-2013-4129, CVE-2013-2636.)

> keeping vpls specific code and api in a separate vpls driver allows
> for cleanly extending it in the future.

That's exactly my point: it's not VPLS specific.  It's exactly the same
functionality for VXLAN, VPLS, NVGRE and 802.11.  The functionality is
"remember the tunnel endpoint."
It's the same bits as lwtunnel uses, which is why the 2nd patch in this
series reuses the existing lwtunnel netlink encapsulation functions.


-David
