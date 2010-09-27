From: David Stevens <dlstevens@us.ibm.com>
Subject: Re:
Date: Mon, 27 Sep 2010 15:01:18 -0700
Message-ID: <OF9D99FA29.B3F53176-ON882577AB.00780023-882577AB.0078FAAE@us.ibm.com>
References: <20100927200500.GB25879@obsidianresearch.com> <OF056C7E7C.A9A5EFC7-ON882577AB.006E6B89-882577AB.006F2C1E@us.ibm.com> <alpine.DEB.2.00.1009271521510.14117@router.home> <4CA1048C.8020508@rincon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Christoph Lameter <cl@linux.com>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>
To: Bob Arendt <rda@rincon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:33874 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865Ab0I0WBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 18:01:37 -0400
In-Reply-To: <4CA1048C.8020508@rincon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bob Arendt <rda@rincon.com> wrote on 09/27/2010 01:54:36 PM:
 
> On 09/27/10 13:23, Christoph Lameter wrote:
> > On Mon, 27 Sep 2010, David Stevens wrote:
> >
> >>          Because a querier can set the robustness value and
> >> query interval to anything you want. In the original report,
> >> he's not running a querier. The fact that it's a new group
> >> doesn't matter -- these are per-interface.
> >
> > The per interface settings are used to force an IGMP version 
overriding
> > any information by the queriers. You would not want to enable that 
because
> > it disables support for other IGMP versions. Without the override
> > different version of IGMP can be handled per MC group.
> >
> If a network vlan has IGMPv3 capability, then it should be able
> to support both v2 and v3 Joins (clients).  But if the vlan is
> IGMPv2 only, then an initial Join from a Linux client might go out
> as v3 (if it hasn't seen a query yet) and be ignored.  I believe
> this is the case that force_igmp_version really addresses.

        Not really. It's for the case where there is no querier at all,
but a snooping switch that only supports IGMPv2. After any query has
put an interface in IGMPv2 mode (or IGMPv1), the initial report for
all joins will use the earlier protocol. It isn't per-group, it's
per interface, and you cannot mix versions of IGMP on the same network.

> 
> And it turns out that  force_igmp_version=2 doesn't fully work.
> If the host sees a IGMPv3 query, it still responds with a v3 Join
> despite the flag.  Bug report and candidate patch here:
> https://bugzilla.kernel.org/show_bug.cgi?id=18212

        This is a special case. The "correct" alternative is to drop
the query and not send any report at all. Sending an answer in the
originating protocol doesn't hurt anything here, because MC routers
are required to use the earlier version too; there should be no such
thing as an "IGMPv3-only querier" as in that report. IGMPv3 compliance
*requires* falling back to IGMPv2 if there is a v2 query by another
router. 
        By answering instead of dropping, it allows fuller filter
information from a manual query to be returned even if the network
is using v2 MC routers, but dropping and ignoring the query as
required by RFC does not fix the bug & patch submitter's problem.
Which is why I also NACKed that patch.

                                                        +-DLS


