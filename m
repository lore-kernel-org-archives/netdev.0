From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Wed, 12 May 2010 15:22:07 -0700
Message-ID: <20100512152207.0e0c321a@nehalam>
References: <1273085598.2367.233.camel@edumazet-laptop>
	<i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
	<1273147586.2357.63.camel@edumazet-laptop>
	<20100506.220443.135536330.davem@davemloft.net>
	<1273210329.2222.42.camel@edumazet-laptop>
	<20100507101451.1b4286b7@nehalam>
	<1273252893.2261.84.camel@edumazet-laptop>
	<20100507103639.4f1a51fa@nehalam>
	<1273268446.2325.53.camel@edumazet-laptop>
	<D1C2B1EC-ABE8-4D87-9227-6D0F1C1C8B77@guavus.com>
	<1273504693.2221.17.camel@edumazet-laptop>
	<AAFABD0F-C66F-44C2-8BDC-FB489EA8655F@guavus.com>
	<1273611036.2512.18.camel@edumazet-laptop>
	<1273634421.2512.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bijay Singh <Bijay.Singh@guavus.com>,
	David Miller <davem@davemloft.net>,
	"<bhaskie@gmail.com>" <bhaskie@gmail.com>,
	"<bhutchings@solarflare.com>" <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Ilpo =?ISO-8859-1?B?SuRydmluZW4=?= <ilpo.jarvinen@helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37949 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756798Ab0ELWWK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 18:22:10 -0400
In-Reply-To: <1273634421.2512.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 May 2010 05:20:21 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mardi 11 mai 2010 =E0 22:50 +0200, Eric Dumazet a =E9crit :
> > Le mardi 11 mai 2010 =E0 04:08 +0000, Bijay Singh a =E9crit :
> > > Hi Eric,
> > >=20
> > > I guess that makes me the enviable one. So I am keen to test out =
this feature completely, as long as I know what to do as a next step, d=
irections, patches.
> > >=20
> > > Thanks
> >=20
> >=20
> > I believe third problem comes from commit 4957faad
> > (TCPCT part 1g: Responder Cookie =3D> Initiator), from William Alle=
n
> > Simpson.
>=20
> And a fourth problem might be that tcp_md5_hash_skb_data() is not
> frag_list aware ?
>=20
>=20
>=20
>=20
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 8ce2974..56ee0f2 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2985,6 +2985,7 @@ int tcp_md5_hash_skb_data(struct tcp_md5sig_poo=
l *hp,
>  	const unsigned head_data_len =3D skb_headlen(skb) > header_len ?
>  				       skb_headlen(skb) - header_len : 0;
>  	const struct skb_shared_info *shi =3D skb_shinfo(skb);
> +	struct sk_buff *frag_iter;
> =20
>  	sg_init_table(&sg, 1);
> =20
> @@ -2999,6 +3000,10 @@ int tcp_md5_hash_skb_data(struct tcp_md5sig_po=
ol *hp,
>  			return 1;
>  	}
> =20
> +	skb_walk_frags(skb, frag_iter)
> +		if (tcp_md5_hash_skb_data(hp, frag_iter, 0))
> +			return 1;
> +
>  	return 0;
>  }

Yes, that looks like a possible bug, not sure what hardware
generates frag_list.

