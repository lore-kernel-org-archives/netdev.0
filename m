From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net -v2] [BUGFIX] bonding: use local function pointer of
 bond->recv_probe in bond_handle_frame
Date: Wed, 19 Oct 2011 06:05:27 +0200
Message-ID: <1318997127.19139.14.camel@edumazet-laptop>
References: <20111013020429.3554.78679.stgit@ltc219.sdl.hitachi.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yrl.pp-manager.tt@hitachi.com,
	WANG Cong <xiyou.wangcong@gmail.com>
To: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111013020429.3554.78679.stgit@ltc219.sdl.hitachi.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 13 octobre 2011 =C3=A0 11:04 +0900, Mitsuo Hayasaka a =C3=A9cr=
it :
> The bond->recv_probe is called in bond_handle_frame() when
> a packet is received, but bond_close() sets it to NULL. So,
> a panic occurs when both functions work in parallel.
>=20
> Why this happen:
> After null pointer check of bond->recv_probe, an sk_buff is
> duplicated and bond->recv_probe is called in bond_handle_frame.
> So, a panic occurs when bond_close() is called between the
> check and call of bond->recv_probe.
>=20
> Patch:
> This patch uses a local function pointer of bond->recv_probe
> in bond_handle_frame(). So, it can avoid the null pointer
> dereference.
>=20
>=20
> Signed-off-by: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: Andy Gospodarek <andy@greyhouse.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: WANG Cong <xiyou.wangcong@gmail.com>
> ---
>=20
>  drivers/net/bonding/bond_main.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 6d79b78..de3d351 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1435,6 +1435,8 @@ static rx_handler_result_t bond_handle_frame(st=
ruct sk_buff **pskb)
>  	struct sk_buff *skb =3D *pskb;
>  	struct slave *slave;
>  	struct bonding *bond;
> +	void (*recv_probe)(struct sk_buff *, struct bonding *,
> +				struct slave *);
> =20
>  	skb =3D skb_share_check(skb, GFP_ATOMIC);
>  	if (unlikely(!skb))
> @@ -1448,11 +1450,12 @@ static rx_handler_result_t bond_handle_frame(=
struct sk_buff **pskb)
>  	if (bond->params.arp_interval)
>  		slave->dev->last_rx =3D jiffies;
> =20
> -	if (bond->recv_probe) {
> +	recv_probe =3D ACCESS_ONCE(bond->recv_probe);
> +	if (recv_probe) {
>  		struct sk_buff *nskb =3D skb_clone(skb, GFP_ATOMIC);
> =20
>  		if (likely(nskb)) {
> -			bond->recv_probe(nskb, bond, slave);
> +			recv_probe(nskb, bond, slave);
>  			dev_kfree_skb(nskb);
>  		}
>  	}
>=20

Sorry, I forgot to add my official ack. Even if not a perfect patch, it=
s
a step into right direction.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
