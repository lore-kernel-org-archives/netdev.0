From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next 4/7] stmmac: allow mtu bigger than 1500 in case of
 normal desc (V3)
Date: Tue, 18 Oct 2011 11:26:10 +0200
Message-ID: <4E9D4632.3000808@st.com>
References: <1318927331-20855-1-git-send-email-peppe.cavallaro@st.com>  <1318927331-20855-5-git-send-email-peppe.cavallaro@st.com> <1318928605.2657.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Deepak SIKRI <deepak.sikri@st.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:58232 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751728Ab1JRJ0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 05:26:18 -0400
In-Reply-To: <1318928605.2657.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric,

On 10/18/2011 11:03 AM, Eric Dumazet wrote:
> Le mardi 18 octobre 2011 =C3=A0 10:42 +0200, Giuseppe CAVALLARO a =C3=
=A9crit :
>> This patch allows to set the mtu bigger than 1500
>> in case of normal descriptors.
>> This is helping some SPEAr customers.
>>
>> Signed-off-by: Deepak SIKRI <deepak.sikri@st.com>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> ---
>>  drivers/net/ethernet/stmicro/stmmac/norm_desc.c   |    8 +++++++-
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    4 ++--
>>  2 files changed, 9 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drive=
rs/net/ethernet/stmicro/stmmac/norm_desc.c
>> index 029c2a2..e13226b 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
>> @@ -126,6 +126,7 @@ static void ndesc_init_rx_desc(struct dma_desc *=
p, unsigned int ring_size,
>>  	for (i =3D 0; i < ring_size; i++) {
>>  		p->des01.rx.own =3D 1;
>>  		p->des01.rx.buffer1_size =3D BUF_SIZE_2KiB - 1;
>> +		p->des01.rx.buffer2_size =3D BUF_SIZE_2KiB - 1;
>>  		if (i =3D=3D ring_size - 1)
>>  			p->des01.rx.end_ring =3D 1;
>>  		if (disable_rx_ic)
>> @@ -183,7 +184,12 @@ static void ndesc_prepare_tx_desc(struct dma_de=
sc *p, int is_fs, int len,
>>  				  int csum_flag)
>>  {
>>  	p->des01.tx.first_segment =3D is_fs;
>> -	p->des01.tx.buffer1_size =3D len;
>> +
>> +	if (unlikely(len > BUF_SIZE_2KiB)) {
>> +		p->des01.etx.buffer1_size =3D BUF_SIZE_2KiB - 1;
>> +		p->des01.etx.buffer2_size =3D len - p->des01.etx.buffer1_size;
>> +	} else
>> +		p->des01.tx.buffer1_size =3D len;
>>  }
>> =20
>>  static void ndesc_clear_tx_ic(struct dma_desc *p)
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/dri=
vers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index d0af002..622b7ac 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -1412,10 +1412,10 @@ static int stmmac_change_mtu(struct net_devi=
ce *dev, int new_mtu)
>>  		return -EBUSY;
>>  	}
>> =20
>> -	if (priv->plat->has_gmac)
>> +	if (priv->plat->enh_desc)
>>  		max_mtu =3D JUMBO_LEN;
>>  	else
>> -		max_mtu =3D ETH_DATA_LEN;
>> +		max_mtu =3D BUF_SIZE_4KiB;
>> =20
>>  	if ((new_mtu < 46) || (new_mtu > max_mtu)) {
>>  		pr_err("%s: invalid MTU, max MTU is: %d\n", dev->name, max_mtu);
>=20
> Problem using big mtu around 4096 bytes is you end allocating (4096
> +NET_SKB_PAD + NET_IP_ALIGN + sizeof(struct skb_shared_info) bytes ->
> 8192 bytes : order-1 pages

yes.

>=20
> Maybe it would be better to limit your mtu to SKB_MAX_HEAD(NET_SKB_PA=
D),
> to have no more than one page per skb ?

ok! ;-)

> I would suggest changing netdev_alloc_skb_ip_align() done in
> init_dma_desc_rings() to use a variant allowing GFP_KERNEL allocation=
s
> and allow your driver to load even in case of memory pressure.
>=20
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/driv=
ers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index c0ee6b6..8ec8057 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -458,11 +458,12 @@ static void init_dma_desc_rings(struct net_devi=
ce *dev)
>  	for (i =3D 0; i < rxsize; i++) {
>  		struct dma_desc *p =3D priv->dma_rx + i;
> =20
> -		skb =3D netdev_alloc_skb_ip_align(dev, bfsize);
> +		skb =3D __netdev_alloc_skb(dev, bfsize + NET_IP_ALIGN, GFP_KERNEL)=
;
>  		if (unlikely(skb =3D=3D NULL)) {
>  			pr_err("%s: Rx init fails; skb is NULL\n", __func__);
>  			break;
>  		}
> +		skb_reserve(skb, NET_IP_ALIGN);
>  		priv->rx_skbuff[i] =3D skb;
>  		priv->rx_skbuff_dma[i] =3D dma_map_single(priv->device, skb->data,
>  						bfsize, DMA_FROM_DEVICE);
>=20
>=20
>=20


Agree! I'm reviewing the patches and send all again.

Many thanks
Regards
Peppe
