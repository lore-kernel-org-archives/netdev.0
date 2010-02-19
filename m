From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NAT regression in next tree
Date: Fri, 19 Feb 2010 08:20:56 +0100
Message-ID: <1266564056.2877.15.camel@edumazet-laptop>
References: <20100216173658.519b6245@nehalam>
	 <201002171526.02493.arnd@arndb.de>	<20100218173633.30bb8c41@nehalam>
	 <4B7E2587.3050608@trash.net> <20100218215106.557be6b0@nehalam>
	 <4B7E386E.4070502@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B7E386E.4070502@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 19 f=C3=A9vrier 2010 =C3=A0 08:06 +0100, Patrick McHardy a =
=C3=A9crit :
> Stephen Hemminger wrote:
> > On Fri, 19 Feb 2010 06:45:43 +0100
> > Patrick McHardy <kaber@trash.net> wrote:
> >=20
> >> Stephen Hemminger wrote:
> >>> Something in net-next tree broke bridging of virtual nets.
> >>> My local VM's can no longer access external networks.
> >>>
> >>> It is a NAT problem. One of the recent netfilter changes is causi=
ng
> >>> the packets to not have there source address rewritten.
> >>>
> >>> I see:
> >>>     VM1  -- 192.168.100.0/24 -- HOST -- 192.168.1.0/24 -- ROUTER
> >>>                            virbr0    eth0
> >>>
> >>> Even a simple ping from VM1 doesn't get responded to because
> >>> the 192.168.100.X source address is not getting rewritten.
> >> I'll try to reproduce it locally. What is the HEAD of the broken
> >> tree you're running?
> >=20
> > commit 37ee3d5b3e979a168536e7e2f15bd1e769cb4122
> > Author: Patrick McHardy <kaber@trash.net>
> > Date:   Thu Feb 18 19:04:44 2010 +0100
> >=20
> >     netfilter: nf_defrag_ipv4: fix compilation error with NF_CONNTR=
ACK=3Dn
>=20
> This patch should fix it.
>=20
> pi=C3=A8ce jointe document texte brut (x)
> commit 4bac6b180771f7ef5275b1a6d88e630ca3a3d6f0
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Fri Feb 19 08:03:28 2010 +0100
>=20
>     netfilter: restore POST_ROUTING hook in NF_HOOK_COND
>    =20
>     Commit 2249065 ("netfilter: get rid of the grossness in netfilter=
=2Eh")
>     inverted the logic for conditional hook invocation, breaking the
>     POST_ROUTING hook invoked by ip_output().
>    =20
>     Correct the logic and remove an unnecessary initialization.
>    =20
>     Reported-by: Stephen Hemminger <shemminger@vyatta.com>
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
>=20
> diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
> index 7007945..89341c3 100644
> --- a/include/linux/netfilter.h
> +++ b/include/linux/netfilter.h
> @@ -212,8 +212,9 @@ NF_HOOK_COND(uint8_t pf, unsigned int hook, struc=
t sk_buff *skb,
>  	     struct net_device *in, struct net_device *out,
>  	     int (*okfn)(struct sk_buff *), bool cond)
>  {
> -	int ret =3D 1;
> -	if (cond ||
> +	int ret;
> +
> +	if (!cond ||
>  	    (ret =3D nf_hook_thresh(pf, hook, skb, in, out, okfn, INT_MIN) =
=3D=3D 1))
>  		ret =3D okfn(skb);
>  	return ret;

I dont quite get it

Original code was :


#define NF_HOOK_COND(pf, hook, skb, indev, outdev, okfn, cond)         =
       \
({int __ret;                                                           =
       \
if ((cond) || (__ret =3D nf_hook_thresh(pf, hook, (skb), indev, outdev,=
 okfn, INT_MIN)) =3D=3D 1)\
       __ret =3D (okfn)(skb);                                          =
         \
__ret;})


There was no condition inversion.



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
