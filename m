From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [RFC PATCH] netlink: Increase netlink dump skb message size
Date: Wed, 27 Apr 2011 20:05:40 +0200
Message-ID: <1303927540.3166.129.camel@edumazet-laptop>
References: <20110425220157.2012.96707.stgit@gitlad.jf.intel.com>
	 <1303799597.2747.214.camel@edumazet-laptop>
	 <20110425.235600.104065244.davem@davemloft.net>
	 <43F901BD926A4E43B106BF17856F0755018DC497D4@orsmsx508.amr.corp.intel.com>
	 <1303834864.3358.58.camel@edumazet-laptop>
	 <4DB83A60.5040102@solarflare.com>
	 <1303921809.3166.90.camel@edumazet-laptop>
	 <43F901BD926A4E43B106BF17856F0755018DF59D32@orsmsx508.amr.corp.intel.com>
	 <1303925378.3166.99.camel@edumazet-laptop>
	 <43F901BD926A4E43B106BF17856F0755018DF59D81@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steve Hodgson <shodgson@solarflare.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54651 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427Ab1D0SFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 14:05:45 -0400
Received: by wya21 with SMTP id 21so1461815wya.19
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 11:05:44 -0700 (PDT)
In-Reply-To: <43F901BD926A4E43B106BF17856F0755018DF59D81@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 27 avril 2011 =C3=A0 10:39 -0700, Rose, Gregory V a =C3=A9c=
rit :

> Right, but when I look in rtnetlink I see the routine to calculate th=
e
> amount of buffer needed for VF info dump is the number of device
> parent (PF) VFs * the sizeof various IFLA_VF_INFO items.  The more th=
e
> VFs the bigger this gets, especially if you want to add more stuff to
> IFLA_VF_INFO.  So when the kernel dumps this all out it can get bigge=
r
> than the NLMSG_GOODSIZE (or DUMPSIZE) pretty quickly.
>=20
> >=20
> > BTW "ip" uses a 16384 bytes buffer, not a 8192 bytes one.
>=20
> I know, that's why I suffered some confusion about which size to use.
> The ip command uses 16K but the NLMSG_GOODSIZE can be as small as 371=
2
> bytes (depending on page size).  Despite the user buffer being 16k if
> the size calculated by if_nlmsg_size() in rtnetlink.c is bigger than
> NLMSG_GOODSIZE then you don't see the info for more than 40 or so VFs=
=2E
> More VFs than that and nothing gets displayed.
>=20

One solution is to change rtnl_dump_ifinfo() to call rtnl_fill_ifinfo()
once time per device (RTM_NEWLINK like now but no more VFINFO inside),
then call another function to provide vf/vlan informations (RTM_NEWVF),
using cb->args[2] as an index into VF space, so that we can stop if
current skb is filled, and next recvmsg() starts at previous saved
index.

Or implement a new "ip vf ..." dumper and only dumps RTM_NEWVF messages=
=2E



