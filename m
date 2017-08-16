From: David Lamparter <equinox@diac24.net>
Subject: [RFC net-next] VPLS support
Date: Wed, 16 Aug 2017 19:01:56 +0200
Message-ID: <20170816170202.456851-1-equinox@diac24.net>
Cc: amine.kherbouche@6wind.com, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:43686 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751531AbdHPRCM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 13:02:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,


triggered by Amine posting VPLS support earlier, this is what I had in
mind on my end.  You may note the patches share some bits, this is
because both series are derived from hacks I did at 33C3 in December
2016.

This patchset is different in the following ways:
- one vpls device encapsulates many pseudowires
- the pseudowire is learned in the bridge FDB as dst_metadata
- to do this, the bridge is extended to learn / keep dst metadata in its fdb
  on a per-entry level
- configuring pseudowires happens through the mpls LIB, through route
  add/delete commands
- the TX path is shared with normal MPLS forwarding
  - this also means this supports ECMP without any further work and without
    copypasta'ing it from af_mpls.c
- pseudowire control word is supported

iproute2 / FRR patches are at:
- https://github.com/eqvinox/vpls-iproute2
- https://github.com/opensourcerouting/frr/commits/vpls
while this patchset is also available at:
- https://github.com/eqvinox/vpls-linux-kernel
(but please be aware that I'm amending and rebasing commits)

I've tested some basic setups, the chain from LDP down into the kernel works
at least in these.  FRR has some testcases around from OpenBSD VPLS support,
I haven't wired that up to run against Linux / this patchset yet.

The patchset needs a lot of polishing (yes I left my TODO notes in the
commit messages), for now my primary concern is overall design feedback.
Roopa has already provided a lot of input (Thanks!);  the major topic I'm
expecting to get discussion on is the bridge FDB changes.

Note that there is a rather large spec difference to VXLAN;  VPLS has
no concept that is analog to a "VNI".  There is nothing to do on a
per-vlan basis.  (Don't get confused by "vlan pseudowire mode", that's
just a fixed tag insertion on a per-remote-endpoint level.)


Cheers / input & feedback appreciated,

-David


P.S.: For a little context on the bridge FDB changes - I'm hoping to find
some time to extend this to the MDB to allow aggregating dst metadata and
handing down a list of dst metas on TX.  This isn't specifically for VPLS
but rather to give sufficient information to the 802.11 stack to allow it to
optimize selecting rates (or unicasting) for multicast traffic by having the
multicast subscriber list known.  This is done by major commercial wifi
solutions (e.g. google "dynamic multicast optimization".)
