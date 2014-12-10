From: Luis Henriques <luis.henriques@canonical.com>
Subject: Re: [3.16.y-ckt stable] Patch "xen-netfront: Fix handling packets on
 compound pages with skb_linearize" has been added to staging queue
Date: Wed, 10 Dec 2014 17:54:52 +0000
Message-ID: <20141210175452.GE10463@hercules>
References: <1418232388-16853-1-git-send-email-luis.henriques@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Paul Durrant <paul.durrant@citrix.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
	"David S. Miller" <davem@davemloft.net>,
	Stefan Bader <stefan.bader@canonical.com>,
	kernel-team@lists.ubuntu.com
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1418232388-16853-1-git-send-email-luis.henriques@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 10, 2014 at 05:26:28PM +0000, Luis Henriques wrote:
> This is a note to let you know that I have just added a patch titled
>=20
>     xen-netfront: Fix handling packets on compound pages with skb_lin=
earize
>=20
> to the linux-3.16.y-queue branch of the 3.16.y-ckt extended stable tr=
ee=20
> which can be found at:
>=20
>  http://kernel.ubuntu.com/git?p=3Dubuntu/linux.git;a=3Dshortlog;h=3Dr=
efs/heads/linux-3.16.y-queue
>=20
> This patch is scheduled to be released in version 3.16.7-ckt3.
>=20
> If you, or anyone else, feels it should not be added to this tree, pl=
ease=20
> reply to this email.
>=20

Ups, sorry!  I thought I had this one dropped after David Vrabel
comment.  Now dropped for sure.

Cheers,
--
Lu=EDs


> For more information about the 3.16.y-ckt tree, see
> https://wiki.ubuntu.com/Kernel/Dev/ExtendedStable
>=20
> Thanks.
> -Luis
>=20
> ------
>=20
> From 079f869ca5082866d276b686721e89a649e622fe Mon Sep 17 00:00:00 200=
1
> From: Zoltan Kiss <zoltan.kiss@citrix.com>
> Date: Mon, 11 Aug 2014 18:32:23 +0100
> Subject: xen-netfront: Fix handling packets on compound pages with
>  skb_linearize
>=20
> commit 97a6d1bb2b658ac85ed88205ccd1ab809899884d upstream.
>=20
> There is a long known problem with the netfront/netback interface: if=
 the guest
> tries to send a packet which constitues more than MAX_SKB_FRAGS + 1 r=
ing slots,
> it gets dropped. The reason is that netback maps these slots to a fra=
g in the
> frags array, which is limited by size. Having so many slots can occur=
 since
> compound pages were introduced, as the ring protocol slice them up in=
to
> individual (non-compound) page aligned slots. The theoretical worst c=
ase
> scenario looks like this (note, skbs are limited to 64 Kb here):
> linear buffer: at most PAGE_SIZE - 17 * 2 bytes, overlapping page bou=
ndary,
> using 2 slots
> first 15 frags: 1 + PAGE_SIZE + 1 bytes long, first and last bytes ar=
e at the
> end and the beginning of a page, therefore they use 3 * 15 =3D 45 slo=
ts
> last 2 frags: 1 + 1 bytes, overlapping page boundary, 2 * 2 =3D 4 slo=
ts
> Although I don't think this 51 slots skb can really happen, we need a=
 solution
> which can deal with every scenario. In real life there is only a few =
slots
> overdue, but usually it causes the TCP stream to be blocked, as the r=
etry will
> most likely have the same buffer layout.
> This patch solves this problem by linearizing the packet. This is not=
 the
> fastest way, and it can fail much easier as it tries to allocate a bi=
g linear
> area for the whole packet, but probably easier by an order of magnitu=
de than
> anything else. Probably this code path is not touched very frequently=
 anyway.
>=20
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <Ian.Campbell@citrix.com>
> Cc: Paul Durrant <paul.durrant@citrix.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: xen-devel@lists.xenproject.org
> Signed-off-by: David S. Miller <davem@davemloft.net>
> Cc: Stefan Bader <stefan.bader@canonical.com>
> Signed-off-by: Luis Henriques <luis.henriques@canonical.com>
> ---
>  drivers/net/xen-netfront.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 055222bae6e4..23359aeb1ba0 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -628,9 +628,10 @@ static int xennet_start_xmit(struct sk_buff *skb=
, struct net_device *dev)
>  	slots =3D DIV_ROUND_UP(offset + len, PAGE_SIZE) +
>  		xennet_count_skb_frag_slots(skb);
>  	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
> -		net_alert_ratelimited(
> -			"xennet: skb rides the rocket: %d slots\n", slots);
> -		goto drop;
> +		net_dbg_ratelimited("xennet: skb rides the rocket: %d slots, %d by=
tes\n",
> +				    slots, skb->len);
> +		if (skb_linearize(skb))
> +			goto drop;
>  	}
>=20
>  	spin_lock_irqsave(&queue->tx_lock, flags);
