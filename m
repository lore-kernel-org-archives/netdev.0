From: Parav Pandit <parav-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: RE: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Mon, 15 May 2017 01:58:05 +0000
Message-ID: <VI1PR0502MB3008AAFB2888EBB88F69DFEAD1E10@VI1PR0502MB3008.eurprd05.prod.outlook.com>
References: <20170514055848.GA23149@lst.de>
        <20170514.115116.499149210596634881.davem@davemloft.net>
        <1494788929.21774.1.camel@sandisk.com>
 <20170514.204404.1844909849561204299.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org" <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170514.204404.1844909849561204299.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> -----Original Message-----
> From: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org [mailto:linux-rdma-
> owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org] On Behalf Of David Miller
> Sent: Sunday, May 14, 2017 7:44 PM
> To: Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org
> Cc: hch-jcswGhMUV9g@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
> Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory
> exposure
>=20
> From: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
> Date: Sun, 14 May 2017 19:08:50 +0000
>=20
> > What is your plan to avoid that applications start using and depending
> > on AF_SMC?
>=20

status =3D socket(AF_SMC, field, IPPROT_TCP);
Here,
- AF_SMC actually means AF_INET IPv4 addresses!
- IPPROTO_TCP means TCP and RDMA both when socket is AF_SMC.
- When creating socket addresses, use AF_INET based addresses.
-  When invoking bind(), listen(), connect() APIs, use AF_INET addresses in=
stead.
- Supporting IPv6 is TBD with AF_SMC sockets.
- At user level get_addrinfo will continue to return AF_INET addresses.

Such explanation for socket APIs doesn't sound correct.

The primary motivation for SMC protocol was to simplify the applications an=
d library to make use of RDMA.
This kind of API is against such simplicity and creates more confusion.
RFC only gives example and doesn't asks to create new socket family.
I can provide more data, but a simple grep in get_addrinfo() and friend fun=
ctions in user space has heavy dependence on AF_INET and AF_INET6.

> The API is out there already so we are out of luck, and neither you nor I=
 nor
> anyone else can "stop" this from happening.

I think it is still not too late to fix this API. SMC is released in v4.11 =
very recently.
v4.12 is still not out.
Given the limitation of protocol being RoCEv1 only, we might not have many =
users whose applications will stop functioning.
(Which will anyway won't work for RoCEv2, and IPv6 addresses).

I propose,
(a) AF_SMC socket 43 can be marked reserved in future kernel versions to av=
oid use.
(b) New protocol family that represents TCP and RDMA protocol, may be named=
 IPPROTO_SMC even though it is not a protocol in IP header.

We can possibly target to have this fix in 4.13 kernel timeframe.

> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in =
the
> body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org More majordomo info
> at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
