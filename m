From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Sun, 15 Nov 2009 08:48:27 +0100
Message-ID: <4AFFB24B.7050508@gmail.com>
References: <20091113233504.GQ19478@kvack.org> <20091113.185937.251557071.davem@davemloft.net> <20091115090604.331d75c2@opy.nosense.org> <200911150355.15204.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	David Miller <davem@davemloft.net>, bcrl@lhnet.ca,
	shemminger@vyatta.com, opurdila@ixiacom.com, netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44395 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817AbZKOHsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2009 02:48:35 -0500
In-Reply-To: <200911150355.15204.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko a =E9crit :
> On Sunday 15 November 2009 00:36:04 Mark Smith wrote:
>> On the occasions I've looked at whether a Linux box would be an
>> alternative to the Cisco BRAS platform we use, the last time I looke=
d
>> the number of sessions people were saying they were running was
>> 500. I don't consider Linux to be feasible in that role until you're
>> able to run at least 5000 sessions on a single box. I'm a bit unusua=
l
> I am running up to 3500 on single NAS, but there is only 3 biggest on=
e like=20
> this, and i am limited only by subscribers on this location (network =
is=20
> distributed over the country, and i have around 200 NAS servers runni=
ng in=20
> summary). And it is just PC bought from nearest supermarket with chea=
p PCI=20
> RTL8169, and similar quality LOM adapter e1000e. Everything running o=
n=20
> cheapest USB flash from same supermarket.
>=20
> For my case running Linux NAS on cheap PC's is only choice. It is 3rd=
 world=20
> country, and many reasons (i can explain each, but it is not technica=
l=20
> subject) doesn't let me to think, that "professional" equipment is fe=
asible=20
> for me.
>=20
> Here people build networks on cheapest unmanageable switches, same=20
> cost/quality 802.11b/g wireless networks, and only a way to terminate=
 them=20
> reliably is PPPoE. I know, it is also weak and easy to break, but it =
is=20
> single choice i have.
> I know also ISP's in Russia, who have somehow partially "managed" net=
works,=20
> but PPPoE letting them to drop running costs.
>=20
> And interface creation speed is important for me, when electricity go=
es down=20
> here, many customers disconnects (up to 500 on single NAS), and then =
join=20
> again to NAS. Load average was jumping to sky on such situations, jus=
t option=20
> to not create sysfs entries helped me a lot (was posted recently).
> Electricity outage is usual here, happens 2-3 times daily.

I found in my cases (not pppoe) that load was very high because of udev=
,
doing crazy loops of :

if (!rtnl_trylock())
     return restart_syscall();

About pppoe, we have a 16 slots hash table, protected by a single rwloc=
k.

This wont scale to 50000 sessions, unless we use larger hashtable and
maybe RCU as well.

About the dismantling phase, it is currently a synchronous thing
(as the resquester process has to wait for many rcu grace periods
for each netdevice to dismantle). Thats typically ~20 ms per device !

=46or 'anonymous' netdevices, we probably could queue them and use a
 worker thread to handle this queue using the new batch mode,
added in net-next-2.6.


