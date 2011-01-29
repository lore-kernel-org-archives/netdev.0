From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for single TCP session balancing
Date: Fri, 28 Jan 2011 18:28:33 -0800
Message-ID: <19551.1296268113@death>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru> <4D35A9B4.7030701@gmail.com> <4D35B1B0.2090905@yandex-team.ru> <4D35BED5.7040301@gmail.com> <28837.1295382268@death> <4D370DC7.6000500@yandex-team.ru> <4D3745AF.5040808@gmail.com> <4D399062.3060004@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?us-ascii?Q?=3D=3FUTF-8=3FB=3FTmljb2xhcyBkZSBQZXNsb8O8YW4=3D=3F=3D?=
	<nicolas.2p.debian@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:46424 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753168Ab1A2C2h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 21:28:37 -0500
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0T2JTpK025584
	for <netdev@vger.kernel.org>; Fri, 28 Jan 2011 21:19:29 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 35C6E4DE8041
	for <netdev@vger.kernel.org>; Fri, 28 Jan 2011 21:28:10 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0T2SZO32388150
	for <netdev@vger.kernel.org>; Fri, 28 Jan 2011 21:28:35 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0T2SZhu024788
	for <netdev@vger.kernel.org>; Sat, 29 Jan 2011 00:28:35 -0200
In-reply-to: <4D399062.3060004@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oleg V. Ukhno <olegu@yandex-team.ru> wrote:

>On 01/19/2011 11:12 PM, Nicolas de Peslo=C3=BCan wrote:
>
>> If you have time for that, then yes, please, do the same test using
>> balance-rr+vlan to segregate path. With those results, we whould hav=
e
>> the opportunity to enhance the documentation with some well tested c=
ases
>> of TCP load balancing on a LAN, not limited to 802.3ad automatic set=
up.
>> Both setups make sense, and assuming the results would be similar is
>> probably true, but not reliable enough to assert it into the documen=
tation.
>>
>> Thanks,
>>
>> Nicolas.
>>
>Nicolas,
>I've ran similar tests for VLAN tunneling scenario. Results are identi=
cal,
>as I expected. The only significat difference is link failure
>handling. 802.3ad mode allows almost painless load reditribution,
>balance-rr causes packet loss.
>The only question for me now is if my patch could be applied to upstre=
am
>version - fixing issues with adaptftion to net-next code aren't the
>problem, if nobody objects

	I've thought about this whole thing, and here's what I view as
the proper way to do this.

	In my mind, this proposal is two separate pieces:

	First, a piece to make round-robin a selectable hash for
xmit_hash_policy.  The documentation for this should follow the pattern
of the "layer3+4" hash policy, in particular noting that the new
algorithm violates the 802.3ad standard in exciting ways, will result i=
n
out of order delivery, and that other 802.3ad implementations may or ma=
y
not tolerate this.

	Second, a piece to make certain transmitted packets use the
source MAC of the sending slave instead of the bond's MAC.  This should
be a separate option from the round-robin hash policy.  I'd call it
something like "mac_select" with two values: "default" (what we do now)
and "slave_src_mac" to use the slave's real MAC for certain types of
traffic (I'm open to better names; that's just what I came up with whil=
e
writing this).  I believe that "certain types" means "everything but
ARP," but might be "only IP and IPv6."  Structuring the option in this
manner leaves the option open for additional selections in the future,
which a simple "on/off" option wouldn't.  This option should probably
only affect a subset of modes; I'm thinking anything except balance-tlb
or -alb (because they do funky MAC things already) and active-backup (i=
t
doesn't balance traffic, and already uses fail_over_mac to control
this).  I think this option also needs a whole new section down in the
bottom explaining how to exploit it (the "pick special MACs on slaves t=
o
trick switch hash" business).

	Comments?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
