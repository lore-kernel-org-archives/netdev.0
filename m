From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: [PATCH v4 0/10] skb paged fragment destructors
Date: Tue, 10 Apr 2012 15:26:05 +0100
Message-ID: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Wei Liu <wei.liu2@citrix.com>,
	David VomLehn <dvomlehn@cisco.com>,
	Bart Van Assche <bvanassche@acm.org>,
	xen-devel <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:63911 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758878Ab2DJO0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 10:26:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think this is v4, but I've sort of lost count, sorry that it's taken
me so long to get back to this stuff.

The following series makes use of the skb fragment API (which is in 3.2
+) to add a per-paged-fragment destructor callback. This can be used by
creators of skbs who are interested in the lifecycle of the pages
included in that skb after they have handed it off to the network stack.

The mail at [0] contains some more background and rationale but
basically the completed series will allow entities which inject pages
into the networking stack to receive a notification when the stack has
really finished with those pages (i.e. including retransmissions,
clones, pull-ups etc) and not just when the original skb is finished
with, which is beneficial to many subsystems which wish to inject pages
into the network stack without giving up full ownership of those page's
lifecycle. It implements something broadly along the lines of what was
described in [1].

I have also included a patch to the RPC subsystem which uses this API to
fix the bug which I describe at [2].

I've also had some interest from David VemLehn and Bart Van Assche
regarding using this functionality in the context of vmsplice and iSCSI
targets respectively (I think).

Changes since last time:

      * Added skb_orphan_frags API for the use of recipients of SKBs who
        may hold onto the SKB for a long time (this is analogous to
        skb_orphan). This was pointed out by Michael. The TUN driver is
        currently the only user.
              * I can't for the life of me get anything to actually hit
                this code path. I've been trying with an NFS server
                running in a Xen HVM domain with emulated (e.g. tap)
                networking and a client in domain 0, using the NFS fix
                in this series which generates SKBs with destructors
                set, so far -- nothing. I suspect that lack of TSO/GSO
                etc on the TAP interface is causing the frags to be
                copied to normal pages during skb_segment().
      * Various fixups related to the change of alignment/padding in
        shinfo, in particular to build_skb as pointed out by Eric.
      * Tweaked ordering of shinfo members to ensure that all hotpath
        variables up to and including the first frag fit within (and are
        aligned to) a single 64 byte cache line. (Eric again)

I ran a monothread UDP benchmark (similar to that described by Eric in
e52fcb2462ac) and don't see any difference in pps throughput, it was
~810,000 pps both before and after.

Cheers,
Ian.

[0] http://marc.info/?l=linux-netdev&m=131072801125521&w=2
[1] http://marc.info/?l=linux-netdev&m=130925719513084&w=2
[2] http://marc.info/?l=linux-nfs&m=122424132729720&w=2
