From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC] vxlan: convert remote list to list_rcu
Date: Tue, 4 Jun 2013 08:48:06 -0400
Message-ID: <OFB0D808A5.49ED47B9-ON85257B80.004098A5-85257B80.004651FC@us.ibm.com>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>	<1369821617-29098-3-git-send-email-mike.rapoport@ravellosystems.com>
	<20130530110948.GA10532@casper.infradead.org>	<CAF1J0HP+Wu9HjEELDaXM2BMREMuKByWr_zz=PwHeNUt=EVbdvw@mail.gmail.com>
	<20130530113739.GB10532@casper.infradead.org>	<20130531091740.70b3e077@nehalam.linuxnetplumber.net>
	<20130602102942.GA21706@zed>	<20130603112616.3ad018e2@nehalam.linuxnetplumber.net>
	<OFE7269995.C8314337-ON85257B7F.006B4FC1-85257B7F.006F87F8@us.ibm.com>	<20130603134512.46ce434f@nehalam.linuxnetplumber.net>
	<OFB0EFD290.FD0EF659-ON85257B7F.00733AF7-85257B7F.0077A32C@us.ibm.com> <CAF1J0HMD-N64Qb2v3oLF7ovsHqhbh0w730t3cWn4uD6wdcLY7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Thomas Graf <tgraf@suug.ch>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:38444 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752893Ab3FDMsO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 08:48:14 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Tue, 4 Jun 2013 08:48:13 -0400
In-Reply-To: <CAF1J0HMD-N64Qb2v3oLF7ovsHqhbh0w730t3cWn4uD6wdcLY7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mike Rapoport <mike.rapoport@ravellosystems.com> wrote on 06/04/2013 
05:18:08 AM:

> > But i don't think any of this fdb code relates to the default
> > destination directly, since the generic fdb code does not support
> > default, or any other aggregate matching. VXLAN can define the
> > netlink API for default destinations without affecting anything
> > else, because it is already a per-device feature.
> >
> >                                                         +-DLS
> 
> The only relation is the 'struct vxlan_rdst' which I intended to use
> for default destinations list. So, until there's a consensus about
> remote destinations list in fdb, I cannot continue to work on multiple
> default destinations.

Yes, I agree with that.

I'd expect we could just either add a lock for the default to do
deletes, or overload vxlan_dev->hash_lock and acquire it for deletes
of the default list. [overload probably simplest]

Actually, we could make it an fdb and also have "use" and "updated"
stats that way, and/or use the existing fdb code and add an entry
with MAC "00:00:00:00:00:00" [which is disallowed via the generic
fdb code, so can't be in the fdb table otherwise].

So something like:
        f = vxlan_find_mac(vxlan, mac);
        did_rsc = false;

        if (f && (f->flags & NTF_ROUTER ... {
                ...
        }

        if (f == NULL) {
                f = vxlan_find_mac(vxlan, ALL_ZEROS_MAC);
                if (f == NULL) {
^^^^^^^^^^^^^^^^^^^^^^^^^^^
do these two lines instead of checking "default_dst" for INADDR_ANY

                    if (vxlan->flags & VXLAN_F_L2MISS &&
                        ..
                                vxlan_fdb_miss(...);
                        dev->stats.tx_dropped++;
                        dev_kfree_skb(skb);
                        return NETDEV_TX_OK;
                }
        }

        rc = NETDEV_TX_OK;

and the default will then use the same code as the fdb; can
then remove the NULL dst check in vxlan_xmit_one(), and do
fdb_adds/fdb_append/fdb_del with ALL_ZEROS_MAC as in the fdb,
but get there with a device-specific netlink message. If there
is no default, delete the all-zeros MAC fdb entry, like any
other fdb entry.

Or even extend the generic rtnetlink fdb code to not check
for all-zeros and just treat the all-zeros mac, if there, as a
default destination and use all the same code as fdb to
manage the default.

                                                +-DLS
