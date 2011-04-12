From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel panic when using bridge
Date: Tue, 12 Apr 2011 09:31:09 +0200
Message-ID: <1302593469.3603.44.camel@edumazet-laptop>
References: <4D9E62D9.5010400@scotdoyle.com>
	 <20110408121700.0aad53fe@nehalam>	<4D9FE5BE.6060600@scotdoyle.com>
	 <20110409161908.a2aca120.shimoda.hiroaki@gmail.com>
	 <4DA39330.2030102@scotdoyle.com> <20110411183105.46e86684@nehalam>
	 <4DA3CB4B.9090506@scotdoyle.com> <1302581384.3603.14.camel@edumazet-laptop>
	 <1302582172.3603.18.camel@edumazet-laptop> <4DA3E074.5090603@scotdoyle.com>
	 <1302587490.3603.22.camel@edumazet-laptop> <4DA3F909.5020609@scotdoyle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org
To: Scot Doyle <lkml@scotdoyle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64279 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756732Ab1DLHbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 03:31:15 -0400
Received: by wya21 with SMTP id 21so5438557wya.19
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 00:31:14 -0700 (PDT)
In-Reply-To: <4DA3F909.5020609@scotdoyle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 avril 2011 =C3=A0 02:02 -0500, Scot Doyle a =C3=A9crit :
> On 04/12/2011 12:51 AM, Eric Dumazet wrote:
> >
> > Oh well, sorry (not enough time these days to even test patches)
> >
> > 	if (!skb_dst(skb)) {
>=20
> --- br_netfilter.c.a    2011-04-01 02:37:53.000000000 -0500
> +++ br_netfilter.c.b    2011-04-12 00:29:00.000000000 -0500
> @@ -221,6 +221,7 @@ static int br_parse_ip_options(struct sk
>       struct ip_options *opt;
>       struct iphdr *iph;
>       struct net_device *dev =3D skb->dev;
> +    struct rtable *rt;
>       u32 len;
>=20
>       iph =3D ip_hdr(skb);
> @@ -255,6 +256,16 @@ static int br_parse_ip_options(struct sk
>           return 0;
>       }
>=20
> +    /* Associate bogus bridge route table */
> +    if (!skb_dst(skb)) {
> +        rt =3D bridge_parent_rtable(dev);
> +        if (!rt) {
> +            kfree_skb(skb);
> +            return 0;
> +        }
> +        skb_dst_set_noref(skb,&rt->dst);
> +    }
> +
>       opt->optlen =3D iph->ihl*4 - sizeof(struct iphdr);
>       if (ip_options_compile(dev_net(dev), opt, skb))
>           goto inhdr_error;
>=20
>=20
> Now we are making progress! With the patch above from Stephen and Eri=
c,=20
> I cannot make the kernel panic when sending packets to the IP address=
 of=20
> the bridge.
>=20
> However, if a guest virtual machine is sharing the bridge with the ho=
st=20
> via a tap device, I can cause a host panic by targeting the IP addres=
s=20
> of the guest. Is this an unrelated problem?
>=20
> Here are two kernel panics. The guest virtual machine was pingable=20
> before being attacked with IP Stack Checker's tcpsic command. Spannin=
g=20
> Tree Protocol was off during the first panic and on during the second=
=2E
>=20


I wonder if you are not running out of free stack space...

And it might be because of inet_getpeer() calling cleanup_once()

# objdump64 -d net/ipv4/inetpeer.o | scripts/checkstack.pl
0x0317 cleanup_once [inetpeer.o]:			344
0x03d6 cleanup_once [inetpeer.o]:			344
0x0680 inet_getpeer [inetpeer.o]:			344
0x071d inet_getpeer [inetpeer.o]:			344
0x0004 inet_initpeers [inetpeer.o]:			112


