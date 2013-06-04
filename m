From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC] vxlan: convert remote list to list_rcu
Date: Tue, 4 Jun 2013 15:02:26 -0400
Message-ID: <OF180D88FD.2197D607-ON85257B80.00649BFC-85257B80.00689768@us.ibm.com>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>	<20130530110948.GA10532@casper.infradead.org>
	<CAF1J0HP+Wu9HjEELDaXM2BMREMuKByWr_zz=PwHeNUt=EVbdvw@mail.gmail.com>	<20130530113739.GB10532@casper.infradead.org>
	<20130531091740.70b3e077@nehalam.linuxnetplumber.net>	<20130602102942.GA21706@zed>
	<20130603112616.3ad018e2@nehalam.linuxnetplumber.net>	<OFE7269995.C8314337-ON85257B7F.006B4FC1-85257B7F.006F87F8@us.ibm.com>
	<20130603134512.46ce434f@nehalam.linuxnetplumber.net>	<OFB0EFD290.FD0EF659-ON85257B7F.00733AF7-85257B7F.0077A32C@us.ibm.com>
	<CAF1J0HMD-N64Qb2v3oLF7ovsHqhbh0w730t3cWn4uD6wdcLY7Q@mail.gmail.com>	<OFB0D808A5.49ED47B9-ON85257B80.004098A5-85257B80.004651FC@us.ibm.com> <CAF1J0HPxqPinPnieVtw4oGJr9h9vdLg8EDYQmGicZKbrrJS1Qg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Thomas Graf <tgraf@suug.ch>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:40257 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750808Ab3FDTDQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 15:03:16 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Tue, 4 Jun 2013 15:03:15 -0400
In-Reply-To: <CAF1J0HPxqPinPnieVtw4oGJr9h9vdLg8EDYQmGicZKbrrJS1Qg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 06/04/2013 01:20:22 PM:

> From: Mike Rapoport <mike.rapoport@ravellosystems.com>
 
> If I've understood you right it would be something like this:
> 

All the tabs are removed in the code I got-- don't know if
it's your mailer or my reader....

> @@ -1025,13 +1027,10 @@ static netdev_tx_t vxlan_xmit_one(struct
> sk_buff *skb, struct net_device *dev,
>   vni = rdst->remote_vni;
>   dst = rdst->remote_ip;
> 
> - if (!dst) {
> - if (did_rsc) {
> - /* short-circuited back to local bridge */
> - vxlan_encap_bypass(skb, vxlan, vxlan);
> - return NETDEV_TX_OK;
> - }
> - goto drop;
> + if (did_rsc) {
> + /* short-circuited back to local bridge */
> + vxlan_encap_bypass(skb, vxlan, vxlan);
> + return NETDEV_TX_OK;
>   }

This isn't correct -- I led you into that one,
but the original code is what we'd need -- it isn't
"rdst NULL" this is checking, but really "dst == INADDR_ANY",
which is probably what it ought to be, instead of "0".
At any rate, the check there works and needs to stay;
dst == INADDR_ANY is a distinct case from rdst == NULL.

Also looks like you're missing a brace on the L2MISS check --
the miss and the drop are only if the all-zeroes lookup
fails.

But the general idea looks good. If you remove the 
is_zero_ether_addr() check in rtnl_fdb_add and rtnl_fdb_del,
then the existing fdb_add/fdb_append/fdb_del code code
would allow changes, including multiple destinations, to
the default destinations as well.

But there's more to it, too -- default_dst and all its references
would need to be replaced for joining groups and the netlink
part, and removed from vxlan_dev.

                                                        +-DLS
