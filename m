From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: mpd client timeouts (bisected) 2.6.35-rc3
Date: Sun, 13 Jun 2010 22:50:46 +0200
Message-ID: <1276462246.2448.17.camel@edumazet-laptop>
References: <20100612102802.GA1782@arch.tripp.de>
	 <20100612.145835.123986343.davem@davemloft.net>
	 <4C149147.3080808@intel.com>  <4C15414E.5090201@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"markus@trippelsdorf.de" <markus@trippelsdorf.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, alex.shi@intel.com,
	tim.c.chen@intel.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C15414E.5090201@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 13 juin 2010 =C3=A0 13:36 -0700, John Fastabend a =C3=A9cri=
t :
> John Fastabend wrote:
> > David Miller wrote:
> >> From: Markus Trippelsdorf <markus@trippelsdorf.de>
> >> Date: Sat, 12 Jun 2010 12:28:02 +0200
> >>
> >>> Commit 597a264b1a9c7e36d1728f677c66c5c1f7e3b837:
> >>> =C2=BBnet: deliver skbs on inactive slaves to exact matches=C2=AB
> >>>
> >>> causes large timeouts when mpd clients try to connect to a locall=
y
> >>> running mpd (music player demon) on my machine. This makes it=20
> >>> impossible to control mpd.
> >>>
> >>> I bisected this down to the commit mentioned above.
> >>> Reverting the commit from 2.6.35-rc3 also solves the problem.
> >> John, find an easy and fast way to fix this or else I am
> >> going to revert.
> >>
> >> Thanks.
> >=20
> > Looks like skbs are hitting loopback_xmit() with deliver_no_wcard s=
et.  Then in=20
> > the receive path these skbs are only delivered to exact matches.  N=
ot sure why=20
> > this bit is set here, I'll track this down first thing tomorrow.
> >=20
> > Thanks,
> > John.
> > --
>=20
> Needed to set the wcard bit in copy_skb_header otherwise it will not =
be cleared=20
> when called from skb_clone.  Which then hits the loopback device gets=
 pushed=20
> into the rx path and is eventually dropped. The following patch fixes=
 this.=20
> Hopefully, this is easy and fast enough for you Dave.
>=20
>=20
> [PATCH] net: fix deliver_no_wcard regression on loopback device
>=20
> deliver_no_wcard is not being set in skb_copy_header.
> In the skb_cloned case it is not being cleared and
> may cause the skb to be dropped when the loopback device
> pushes it back up the stack.
>=20
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>=20
>   net/core/skbuff.c |    1 +
>   1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 9f07e74..bcf2fa3 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -532,6 +532,7 @@ static void __copy_skb_header(struct sk_buff *new=
, const=20
> struct sk_buff *old)
>   	new->ip_summed		=3D old->ip_summed;
>   	skb_copy_queue_mapping(new, old);
>   	new->priority		=3D old->priority;
> +	new->deliver_no_wcard	=3D old->deliver_no_wcard;
>   #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
>   	new->ipvs_property	=3D old->ipvs_property;
>   #endif
> --

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

BTW, David, it seems there is a double rxhash copy...

[PATCH] net: rxhash already set in __copy_skb_header

No need to copy rxhash again in __skb_clone()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9f07e74..a58e63b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -569,7 +569,6 @@ static struct sk_buff *__skb_clone(struct sk_buff *=
n, struct sk_buff *skb)
 	C(len);
 	C(data_len);
 	C(mac_len);
-	C(rxhash);
 	n->hdr_len =3D skb->nohdr ? skb_headroom(skb) : skb->hdr_len;
 	n->cloned =3D 1;
 	n->nohdr =3D 0;
