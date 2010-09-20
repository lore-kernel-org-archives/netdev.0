From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression, bisected: reference leak with IPSec since ~2.6.31
Date: Mon, 20 Sep 2010 20:20:44 +0200
Message-ID: <1285006844.2323.17.camel@edumazet-laptop>
References: <20100920174443.GA5515@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Nick Bowler <nbowler@elliptictech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36760 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756714Ab0ITSUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 14:20:54 -0400
In-Reply-To: <20100920174443.GA5515@elliptictech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 septembre 2010 =C3=A0 13:44 -0400, Nick Bowler a =C3=A9crit=
 :
> Since 2.6.31, one of our UDP test programs has resulted in an SA leak=
: after
> running the test and flushing the SAD/SPD, the esp module is left wit=
h a
> non-zero reference count.  This reference is never released: closer
> inspection reveals that esp_destroy is never called on the SA.
>=20
> I've attached a simplified version of the test program which reproduc=
es the
> issue.  To reproduce:
>=20
>   (1) Create a Tx SA -- I used the following setkey script for my tes=
ts:
>=20
>        add 192.168.42.2 192.168.42.1 esp 0x327B23C6  -f seq-pad
>         -E rijndael-cbc 0x3D1B58BA507ED7AB2EB141F241B71EFB
>         -A null;
>       =20
>        spdadd 192.168.42.2 192.168.42.1 any -P out ipsec
>         esp/transport//require;
>=20
>   (2) lsmod | grep esp4
>       (note that the reference count is 1)
>=20
>   (3) run the test program, e.g. udp_burst 192.168.42.1 for the above=
 SA.
>=20
>   (4) setkey -F; setkey -P -F
>=20
>   (5) wait as long as you want.
>=20
>   (6) lsmod | grep esp4
>       (note that the reference count is still 1, not 0 as it should b=
e)
>=20
> You can repeat the test until the zombie SAs consume all available
> memory.  Cursory tests show similar problems with AH, IPv6 and Rx SAs=
,
> but I only really tested ESP Tx.
>=20
> Bisection implicates the following:
>=20
>   2b85a34e911bf483c27cfdd124aeb1605145dc80 is the first bad commit
>   commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
>   Author: Eric Dumazet <eric.dumazet@gmail.com>
>   Date:   Thu Jun 11 02:55:43 2009 -0700
>  =20
>       net: No more expensive sock_hold()/sock_put() on each tx
>      =20
>       One of the problem with sock memory accounting is it uses
>       a pair of sock_hold()/sock_put() for each transmitted packet.
>      =20
>       This slows down bidirectional flows because the receive path
>       also needs to take a refcount on socket and might use a differe=
nt
>       cpu than transmit path or transmit completion path. So these
>       two atomic operations also trigger cache line bounces.
>      =20
>       We can see this in tx or tx/rx workloads (media gateways for ex=
ample),
>       where sock_wfree() can be in top five functions in profiles.
>      =20
>       We use this sock_hold()/sock_put() so that sock freeing
>       is delayed until all tx packets are completed.
>      =20
>       As we also update sk_wmem_alloc, we could offset sk_wmem_alloc
>       by one unit at init time, until sk_free() is called.
>       Once sk_free() is called, we atomic_dec_and_test(sk_wmem_alloc)
>       to decrement initial offset and atomicaly check if any packets
>       are in flight.
>      =20
>       skb_set_owner_w() doesnt call sock_hold() anymore
>      =20
>       sock_wfree() doesnt call sock_put() anymore, but check if sk_wm=
em_alloc
>       reached 0 to perform the final freeing.
>      =20
>       Drawback is that a skb->truesize error could lead to unfreeable=
 sockets, or
>       even worse, prematurely calling __sk_free() on a live socket.
>      =20
>       Nice speedups on SMP. tbench for example, going from 2691 MB/s =
to 2711 MB/s
>       on my 8 cpu dev machine, even if tbench was not really hitting =
sk_refcnt
>       contention point. 5 % speedup on a UDP transmit workload (depen=
ds
>       on number of flows), lowering TX completion cpu usage.
>      =20
>       Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>       Signed-off-by: David S. Miller <davem@davemloft.net>
>  =20
>   :040000 040000 13fc48f3903764863486c4e557a50281e8d790e6 4801aa898e9=
06ad61729a84e33f1afb114abdf47 M	include
>   :040000 040000 042d86ad3f4d34cb96f137acb356c8251c2f8efc bd0698ec5bf=
8507c8ed1c5cf1e7791b4a5ed5596 M	net
>=20
>   git bisect start
>   # good: [4a6908a3a050aacc9c3a2f36b276b46c0629ad91] Linux 2.6.28
>   git bisect good 4a6908a3a050aacc9c3a2f36b276b46c0629ad91
>   # bad: [22763c5cf3690a681551162c15d34d935308c8d7] Linux 2.6.32
>   git bisect bad 22763c5cf3690a681551162c15d34d935308c8d7
>   # good: [37ecfd807b82bf547429fe1376e1fe7000ba7cff] Merge branch 'fo=
r-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/drzeus/mmc
>   git bisect good 37ecfd807b82bf547429fe1376e1fe7000ba7cff
>   # bad: [2187550525d7bcb8c87689e4eca41b1955bf9ac3] xfs: rationalize =
xfs_inobt_lookup*
>   git bisect bad 2187550525d7bcb8c87689e4eca41b1955bf9ac3
>   # bad: [9cbc1cb8cd46ce1f7645b9de249b2ce8460129bb] Merge branch 'mas=
ter' of master.kernel.org:/pub/scm/linux/kernel/git/torvalds/linux-2.6
>   git bisect bad 9cbc1cb8cd46ce1f7645b9de249b2ce8460129bb
>   # good: [8a1ca8cedd108c8e76a6ab34079d0bbb4f244799] Merge branch 'pe=
rfcounters-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/=
tip/linux-2.6-tip
>   git bisect good 8a1ca8cedd108c8e76a6ab34079d0bbb4f244799
>   # good: [2cf4d4514d5b43c1f3b64bd0ec8b9853bde8f1dc] Merge branch 'fo=
r-linus' of master.kernel.org:/home/rmk/linux-2.6-arm
>   git bisect good 2cf4d4514d5b43c1f3b64bd0ec8b9853bde8f1dc
>   # good: [267a90127472be70b02ab13cbd355b5013e2aa51] ath9k: Optimize =
TBTT/DTIM calculation for timers
>   git bisect good 267a90127472be70b02ab13cbd355b5013e2aa51
>   # good: [5b1a002ade68173f21b2126a778278df72202ba6] datagram: Use fr=
ag list abstraction interfaces.
>   git bisect good 5b1a002ade68173f21b2126a778278df72202ba6
>   # bad: [5b2c4b972c0226406361f83b747eb5cdab51e68e] net: fix network =
drivers ndo_start_xmit() return values (part 8)
>   git bisect bad 5b2c4b972c0226406361f83b747eb5cdab51e68e
>   # bad: [2b85a34e911bf483c27cfdd124aeb1605145dc80] net: No more expe=
nsive sock_hold()/sock_put() on each tx
>   git bisect bad 2b85a34e911bf483c27cfdd124aeb1605145dc80
>   # good: [558f6d3229ddb9f11ca4ffee0439046c283882ff] cfg80211: fix fo=
r duplicate response for driver reg request
>   git bisect good 558f6d3229ddb9f11ca4ffee0439046c283882ff
>   # good: [84503ddd65e804ccdeedee3f307b40d80ff793e6] Merge branch 'ma=
ster' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireles=
s-next-2.6
>   git bisect good 84503ddd65e804ccdeedee3f307b40d80ff793e6
>   # good: [87433bfc75f34599c38137e172b6bf8fd41971ba] r8169: use dev_k=
free_skb() instead of dev_kfree_skb_irq()
>   git bisect good 87433bfc75f34599c38137e172b6bf8fd41971ba
>   # good: [6811086899f2740c08d0ade26f8b9d705708e0cc] be2net: fix netd=
ev stats rx_errors and rx_dropped
>   git bisect good 6811086899f2740c08d0ade26f8b9d705708e0cc
>   # good: [a7a0ef31def6b6badd94fc96c8f17c2e18d91513] be2net: Fix earl=
y reset of rx-completion
>   git bisect good a7a0ef31def6b6badd94fc96c8f17c2e18d91513
>   # good: [f2333a014c1e13ac8e1b73a6fd77731c524eff78] netxen: No need =
to check vfree() pointer.
>   git bisect good f2333a014c1e13ac8e1b73a6fd77731c524eff78
>=20


Hi Nick

If you change your program to send small frames (so they are not
fragmented), is the problem still present ?

The commit you mention was buggy and a fix was added later in
sock_wfree()

(commit d99927f4d93f36553699573b279e0ff98ad7dea6
net: Fix sock_wfree() race)



