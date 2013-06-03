From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC] vxlan: convert remote list to list_rcu
Date: Mon, 3 Jun 2013 17:46:46 -0400
Message-ID: <OFB0EFD290.FD0EF659-ON85257B7F.00733AF7-85257B7F.0077A32C@us.ibm.com>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>	<1369821617-29098-3-git-send-email-mike.rapoport@ravellosystems.com>
	<20130530110948.GA10532@casper.infradead.org>	<CAF1J0HP+Wu9HjEELDaXM2BMREMuKByWr_zz=PwHeNUt=EVbdvw@mail.gmail.com>
	<20130530113739.GB10532@casper.infradead.org>	<20130531091740.70b3e077@nehalam.linuxnetplumber.net>
	<20130602102942.GA21706@zed>	<20130603112616.3ad018e2@nehalam.linuxnetplumber.net>
	<OFE7269995.C8314337-ON85257B7F.006B4FC1-85257B7F.006F87F8@us.ibm.com> <20130603134512.46ce434f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:44581 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758570Ab3FCVqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 17:46:52 -0400
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Mon, 3 Jun 2013 15:46:52 -0600
In-Reply-To: <20130603134512.46ce434f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>

> 
> Just being safe. need to audit to make sure not possible for all
> destinations to be removed from FDB entry via netlink.

        In the original code, you can't delete destinations at all.
Because the netlink API only had fdb-entry-level operations, you
can add with the NLM_F_APPEND flag to add new destinations to
existing entries (it's an "add/create" if it didn't exist, and it
appends the new dest if it did exist and has NLM_F_APPEND set),
but an fdb delete deletes the entire fdb entry, and all destinations.
So, you can't delete individual destinations, you can only delete
all of them and rebuild it with appends to not include the entry
you don't want.
        This was for compatibility rather than adding new add/del of
destinations within an fdb, it uses the existing fdb add/del and
the existing exclusive/append flag. Deleting individual destinations
from an fdb entry would require extensions for the generic fdb
management, or a separate set of netlink handlers.

> > 
> > Again, if rdst == NULL, why are we sending anything? It should never
> > happen, so should be an error case if you check at all, shouldn't it?
> 
> It maybe possible to create or modify existing fdb entry so no 
destinatons
> left.

        It shouldn't be (by design). The only way you can shorten an fdb
entry's destination list is by deleting it and rebuilding it with fewer
entries. And all fdb_add's require an NDA_DST, though that can be
0.0.0.0.
 
> > This ignores the return value of vxlan_xmit_one(); the original
> > code returns an error if any of the destinations fail, while this
> > code ignores errors for all but the last destination.
> 
> Return value doesn't really matter here anyway, and certainly not
> in the fanout case.

        My intention in the code was to count any loss in the multiple
destinations as a "drop", for the purposes of drawing attention to
an admin. This new code reports only the sate of the last destination
and ignores any errors from all the other destinations-- I don't
agree with that. If it didn't work perfectly as intended, it should
show up in stats for admin investigation.

But i don't think any of this fdb code relates to the default
destination directly, since the generic fdb code does not support
default, or any other aggregate matching. VXLAN can define the
netlink API for default destinations without affecting anything
else, because it is already a per-device feature.

                                                        +-DLS
