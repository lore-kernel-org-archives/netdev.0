From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for single TCP session balancing
Date: Wed, 02 Feb 2011 09:57:33 -0800
Message-ID: <32505.1296669453@death>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru> <4D35A9B4.7030701@gmail.com> <4D35B1B0.2090905@yandex-team.ru> <4D35BED5.7040301@gmail.com> <28837.1295382268@death> <4D370DC7.6000500@yandex-team.ru> <4D3745AF.5040808@gmail.com> <4D399062.3060004@yandex-team.ru> <19551.1296268113@death> <4D4929BB.2000403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Oleg V. Ukhno" <olegu@yandex-team.ru>,
	John Fastabend <john.r.fastabend@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?us-ascii?Q?=3D=3FUTF-8=3FB=3FTmljb2xhcyBkZSBQZXNsb8O8YW4=3D=3F=3D?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:51786 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754767Ab1BBR5k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 12:57:40 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p12HpOJU004391
	for <netdev@vger.kernel.org>; Wed, 2 Feb 2011 10:51:24 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p12Hvack217474
	for <netdev@vger.kernel.org>; Wed, 2 Feb 2011 10:57:37 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p12HvaAS006043
	for <netdev@vger.kernel.org>; Wed, 2 Feb 2011 10:57:36 -0700
In-reply-to: <4D4929BB.2000403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan <nicolas.2p.debian@gmail.com> wrote:

>Le 29/01/2011 03:28, Jay Vosburgh a =C3=A9crit :
>> 	I've thought about this whole thing, and here's what I view as
>> the proper way to do this.
>>
>> 	In my mind, this proposal is two separate pieces:
>>
>> 	First, a piece to make round-robin a selectable hash for
>> xmit_hash_policy.  The documentation for this should follow the patt=
ern
>> of the "layer3+4" hash policy, in particular noting that the new
>> algorithm violates the 802.3ad standard in exciting ways, will resul=
t in
>> out of order delivery, and that other 802.3ad implementations may or=
 may
>> not tolerate this.
>>
>> 	Second, a piece to make certain transmitted packets use the
>> source MAC of the sending slave instead of the bond's MAC.  This sho=
uld
>> be a separate option from the round-robin hash policy.  I'd call it
>> something like "mac_select" with two values: "default" (what we do n=
ow)
>> and "slave_src_mac" to use the slave's real MAC for certain types of
>> traffic (I'm open to better names; that's just what I came up with w=
hile
>> writing this).  I believe that "certain types" means "everything but
>> ARP," but might be "only IP and IPv6."  Structuring the option in th=
is
>> manner leaves the option open for additional selections in the futur=
e,
>> which a simple "on/off" option wouldn't.  This option should probabl=
y
>> only affect a subset of modes; I'm thinking anything except balance-=
tlb
>> or -alb (because they do funky MAC things already) and active-backup=
 (it
>> doesn't balance traffic, and already uses fail_over_mac to control
>> this).  I think this option also needs a whole new section down in t=
he
>> bottom explaining how to exploit it (the "pick special MACs on slave=
s to
>> trick switch hash" business).
>>
>> 	Comments?
>
>Looks really sensible to me.
>
>I just propose the following option and option values : "src_mac_selec=
t"
>(instead of mac_select), with "default" and "slave_mac" (instead of
>slave_src_mac) as possible values. In the future, we might need a
>"dst_mac_select" option... :-)

	I originally thought of using the nomenclature you propose; my
thinking for doing it the way I ended up with is to minimize the number
of tunable knobs that bonding has (so, the dst_mac would be a setting
for mac_select).  That works as long as there aren't a lot of settings
that would be turned on simultaneously, since each combination would
have to be a separate option, or the options parser would have to handl=
e
multiple settings (e.g., mac_select=3Dsrc+dst or something like that).

	Anyway, after thinking about it some more, in the long run it's
probably safer to separate these two, so, Oleg, use the above naming
("src_mac_select" with "default" and "slave_mac").

>Also, are there any risks that this kind of session load-balancing won=
't
>properly cooperate with multiqueue (as explained in "Overriding
>Configuration for Special Cases" in Documentation/networking/bonding.t=
xt)?
>I think it is important to ensure we keep the ability to fine tune the
>egress path selection

	I think the logic for the mac_select (or src_mac_select or
whatever) just has to be done last, after the slave selection is done b=
y
the multiqueue stuff.  That's probably a good tidbit to put in the
documentation as well.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
