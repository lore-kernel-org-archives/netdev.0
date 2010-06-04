From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 64-bit net_device_stats
Date: Fri, 04 Jun 2010 05:59:03 +0200
Message-ID: <1275623943.2533.116.camel@edumazet-laptop>
References: <AANLkTimRwNqPYh1MgXPhh3hHep7Koc3OJCCroEj_scqg@mail.gmail.com>
	 <20100525.161539.104072714.davem@davemloft.net>
	 <1275514469.2115.70.camel@achroite.uk.solarflarecom.com>
	 <20100604015956.GA10971@host-a-55.ustcsz.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, romieu@fr.zoreil.com,
	netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34378 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757338Ab0FDD7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 23:59:08 -0400
Received: by wyi11 with SMTP id 11so557584wyi.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 20:59:07 -0700 (PDT)
In-Reply-To: <20100604015956.GA10971@host-a-55.ustcsz.edu.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 04 juin 2010 =C3=A0 09:59 +0800, Junchang Wang a =C3=A9crit=
 :
> Hi Ben,
>=20
> On Wed, Jun 02, 2010 at 10:34:29PM +0100, Ben Hutchings wrote:
> >Changing the counter types to u64 for 32-bit architectures would rem=
ove
> >atomicity and expose half-updated counters to userland.  Changing th=
e
> >driver interface significantly so that atomicity is not needed would
> >require changes to hundreds of drivers.
> >
> >Assuming the above is all correct, I think we can only solve this wi=
th a
> >gradual change (as for net_device_ops).  The following might work:
> >
> I realized the network team doesn't care about 64-bit counters (espec=
ially rx_*) on 32-bit systems. A similar disscussion can be found here:
> http://www.gossamer-threads.com/lists/linux/kernel/282631?search_stri=
ng=3D64%20stats;#282631
>=20

Well, the outlined discussion is 8 years old. Some things changed so we
probably have more possibilities today. per_cpu infrastructure is prett=
y
cool now for example.

If stats are updated only by the NIC, we can have 64 bit stats with
nearly 0 cost.

Real problem is some stats are updated by software.

Upgrading them to 64 bits would need atomic64 to coordinate writers and
readers, or making sure reader use appropriate locks to serialize with
the writer.


> And Eric just gave a explanation why they stand by that point. Updati=
ng rx_* counters in core network will dirty a cache line.

Sorry, I realize I was a bit wrong in my last mail.

In txq_trans_update(txq) we only update the time (in jiffies) of last
transmission, using a txq field instead of dev->trans_start)

txq->tx_bytes, txq->tx_packets, txq->tx_dropped _might_ be used by
_drivers_ to update tx counters, instead of dev->stats{tx_bytes,
tx_packets, tx_dropped}, especially by multiqueue drivers.

txq->tx... updates are better because they are multiqueue compatable (n=
o
need to use atomic ops), and they use a cache line already dirtied
because we hold txq lock at transmission time (unless for LLTX drivers)

(For an example, check drivers/net/macvlan.c, macvlan_start_xmit() and
commit 2c11455321f3)


