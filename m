From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: [PATCH v5 0/9] skb paged fragment destructors
Date: Thu, 3 May 2012 15:55:15 +0100
Message-ID: <1336056915.20716.96.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"David VomLehn" <dvomlehn@cisco.com>,
	Bart Van Assche <bvanassche@acm.org>,
	xen-devel <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:62970 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755113Ab2ECOzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 10:55:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

      * The big change is that the patches now explicitly align the
        "nr_frags" member of the shinfo, as suggested by Alexander
        Duyck. This ensures that the placement is optimal irrespective
        of page size (in particular the variation of MAX_SKB_FRAGS). It
        is still the case that for 4k pages a maximum MTU frame +
        SKB_PAD + shinfo, still fit within 2048k.
              * As part of the preceeding I squashed the patches
                manipulating the shinfo layout and alignment into a
                single patch (which is far more coherent than the
                piecemeal approach used previously)
      * I crushed "net: only allow paged fragments with the same
        destructor to be coalesced." into the baseline patch (Ben
        Hutchings)
      * Added and used skb_shinfo_init to centralise several copies of
        that code.
      * Reduced CC list on "net: add paged frag destructor support to
        kernel_sendpage", it was rather long and seemed a bit overly
        spammy on the non-netdev recipients.

Changes since time before:

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
