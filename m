From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Wrong network usage reported by /proc
Date: Tue, 05 May 2009 07:22:16 +0200
Message-ID: <49FFCD08.7050600@cosmosbay.com>
References: <20090504171408.3e13822c@python3.es.egwn.lan> <49FF2BB2.4030700@cosmosbay.com> <20090504211151.74622f29@python3.es.egwn.lan> <20090505050435.GK570@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matthias Saou
	<thias@spam.spam.spam.spam.spam.spam.spam.egg.and.spam.freshrpms.net>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60683 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbZEEFW6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 01:22:58 -0400
In-Reply-To: <20090505050435.GK570@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willy Tarreau a =E9crit :
> On Mon, May 04, 2009 at 09:11:51PM +0200, Matthias Saou wrote:
>> Eric Dumazet wrote :
>>
>>> Matthias Saou a =E9crit :
>>>> Hi,
>>>>
>>>> I'm posting here as a last resort. I've got lots of heavily used R=
HEL5
>>>> servers (2.6.18 based) that are reporting all sorts of impossible
>>>> network usage values through /proc, leading to unrealistic snmp/ca=
cti
>>>> graphs where the outgoing bandwidth used it higher than the physic=
al
>>>> interface's maximum speed.
>>>>
>>>> For some details and a test script which compares values from /pro=
c
>>>> with values from tcpdump :
>>>> https://bugzilla.redhat.com/show_bug.cgi?id=3D489541
>>>>
>>>> The values collected using tcpdump always seem realistic and match=
 the
>>>> values seen on the remote network equipments. So my obvious conclu=
sion
>>>> (but possibly wrong given my limited knowledge) is that something =
is
>>>> wrong in the kernel, since it's the one exposing the /proc interfa=
ce.
>>>>
>>>> I've reproduced what seems to be the same problem on recent kernel=
s,
>>>> including the 2.6.27.21-170.2.56.fc10.x86_64 I'm running right now=
=2E The
>>>> simple python script available here allows to see it quite easily =
:
>>>> https://www.redhat.com/archives/rhelv5-list/2009-February/msg00166=
=2Ehtml
>>>>
>>>>  * I run the script on my Workstation, I have an FTP server enable=
d
>>>>  * I download a DVD ISO from a remote workstation : The values mat=
ch
>>>>  * I start ping floods from remote workstations : The values repor=
ted
>>>>    by /proc are much higher than the ones reported by tcpdump. I u=
sed
>>>>    "ping -s 500 -f myworkstation" from two remote workstations
>>>>
>>>> If there's anything flawed in my debugging, I'd love to have someo=
ne
>>>> point it out to me. TIA to anyone willing to have a look.
>>>>
>>>> Matthias
>>>>
>>> I could not reproduce this here... what kind of NIC are you using o=
n
>>> affected systems ? Some ethernet drivers report stats from card its=
elf,
>>> and I remember seeing some strange stats on some hardware, but I ca=
nnot
>>> remember which one it was (we were reading NULL values instead of
>>> real ones, once in a while, maybe it was a firmware issue...)
>> My workstation has a Broadcom BCM5752 (tg3 module). The servers whic=
h
>> are most affected have Intel 82571EB (e1000e). But the issue is that
>> with /proc, the values are a lot _higher_ than with tcpdump, and the
>> tcpdump values seem to be the correct ones.
>=20
> the e1000 chip reports stats every 2 seconds. So you have to collect
> stats every 2 seconds otherwise you get "camel-looking" stats.
>=20

I looked at e1000e driver, and apparently tx_packets & tx_bytes are com=
puted
by the TX completion routine, not by the chip.

static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
{
=2E..

                        if (cleaned) {
                                struct sk_buff *skb =3D buffer_info->sk=
b;
                                unsigned int segs, bytecount;
                                segs =3D skb_shinfo(skb)->gso_segs ?: 1=
;
                                /* multiply data chunks by size of head=
ers */
                                bytecount =3D ((segs - 1) * skb_headlen=
(skb)) +
                                            skb->len;
// maybe bytecount is wrong on some skbs ?
                                total_tx_packets +=3D segs;
                                total_tx_bytes +=3D bytecount;
                        }

=2E..
    adapter->net_stats.tx_bytes +=3D total_tx_bytes;
    adapter->net_stats.tx_packets +=3D total_tx_packets;
=2E..
}

and driver get_stats() does return this adapter->net_stats structure to=
 caller

static struct net_device_stats *e1000_get_stats(struct net_device *netd=
ev)=20
{
	struct e1000_adapter *adapter =3D netdev_priv(netdev);

	/* only return the current stats */
	return &adapter->net_stats;
}

Could be converted to use netdev->stats... Oh well...

