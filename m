From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [RFC] vxlan: convert remote list to list_rcu
Date: Wed, 5 Jun 2013 15:53:30 +0300
Message-ID: <CAF1J0HOpsbD-4ZPd3kJPE9YmUy4ihmWr5TSou9HuHzFNA1Wy=Q@mail.gmail.com>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
	<20130530110948.GA10532@casper.infradead.org>
	<CAF1J0HP+Wu9HjEELDaXM2BMREMuKByWr_zz=PwHeNUt=EVbdvw@mail.gmail.com>
	<20130530113739.GB10532@casper.infradead.org>
	<20130531091740.70b3e077@nehalam.linuxnetplumber.net>
	<20130602102942.GA21706@zed>
	<20130603112616.3ad018e2@nehalam.linuxnetplumber.net>
	<OFE7269995.C8314337-ON85257B7F.006B4FC1-85257B7F.006F87F8@us.ibm.com>
	<20130603134512.46ce434f@nehalam.linuxnetplumber.net>
	<OFB0EFD290.FD0EF659-ON85257B7F.00733AF7-85257B7F.0077A32C@us.ibm.com>
	<CAF1J0HMD-N64Qb2v3oLF7ovsHqhbh0w730t3cWn4uD6wdcLY7Q@mail.gmail.com>
	<OFB0D808A5.49ED47B9-ON85257B80.004098A5-85257B80.004651FC@us.ibm.com>
	<CAF1J0HPxqPinPnieVtw4oGJr9h9vdLg8EDYQmGicZKbrrJS1Qg@mail.gmail.com>
	<OF180D88FD.2197D607-ON85257B80.00649BFC-85257B80.00689768@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Thomas Graf <tgraf@suug.ch>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog111.obsmtp.com ([74.125.245.90]:39692 "HELO
	na3sys010aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753543Ab3FEMxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 08:53:31 -0400
Received: by mail-ob0-f169.google.com with SMTP id up14so2530939obb.0
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 05:53:30 -0700 (PDT)
In-Reply-To: <OF180D88FD.2197D607-ON85257B80.00649BFC-85257B80.00689768@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 4, 2013 at 10:02 PM, David Stevens <dlstevens@us.ibm.com> wrote:
> netdev-owner@vger.kernel.org wrote on 06/04/2013 01:20:22 PM:
>
>> From: Mike Rapoport <mike.rapoport@ravellosystems.com>
>
>> If I've understood you right it would be something like this:
>>
>
> All the tabs are removed in the code I got-- don't know if
> it's your mailer or my reader....

My mailer, I afraid. Sorry about that.

> This isn't correct -- I led you into that one,
> but the original code is what we'd need -- it isn't
> "rdst NULL" this is checking, but really "dst == INADDR_ANY",
> which is probably what it ought to be, instead of "0".
> At any rate, the check there works and needs to stay;
> dst == INADDR_ANY is a distinct case from rdst == NULL.

Yeah, it looked wrong to me, but it was too late in the evening for me :)

> Also looks like you're missing a brace on the L2MISS check --
> the miss and the drop are only if the all-zeroes lookup
> fails.

I'm not sure if we can allow empty list of default destinations. I
think that the fdb entry for ALL_ZEROS_MAC should always contain at
least one entry corresponding to current default_dst.

> But the general idea looks good. If you remove the
> is_zero_ether_addr() check in rtnl_fdb_add and rtnl_fdb_del,
> then the existing fdb_add/fdb_append/fdb_del code code
> would allow changes, including multiple destinations, to
> the default destinations as well.

Yeah, but in this case 'fdb del 00:00:00:00:00:00' kills all the
defaults and makes userspace responsible to restore those that are
still valid.
Maybe in the case of 'fdb del 00:00:00:00:00:00' we should require
NDA_DST to be present...
Another issue with making default destinations fdb with ALL_ZEROS_MAC
is that vxlan_cleanup may eventually garbage collect it.

I'll experiment some more to see if maintaining separate list of
default destinations or making them fdb comes cleaner at the end.

> But there's more to it, too -- default_dst and all its references
> would need to be replaced for joining groups and the netlink
> part, and removed from vxlan_dev.

Again, there should always be at least one default destination. And if
the references for default_dst should be replaced, some defaults need
to be kept in vxlan_dev for fallbacks...

>                                                         +-DLS
>



--
Sincerely yours,
Mike.
