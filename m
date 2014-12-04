From: Andrey Volkov <andrey.volkov@nexvision.fr>
Subject: Re: [PATCH 1/1] net: dsa: replacing the hard-coded sized array "dsa_switch"
 by dynamic one
Date: Thu, 04 Dec 2014 18:29:55 +0100
Message-ID: <54809A13.8080703@nexvision.fr>
References: <547DD1C6.2090304@nexvision.fr> <547E23C1.2040007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 15.mo1.mail-out.ovh.net ([188.165.38.232]:46924 "EHLO
	mo1.mail-out.ovh.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932164AbaLDRqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 12:46:04 -0500
Received: from mail140.ha.ovh.net (gw6.ovh.net [213.251.189.206])
	by mo1.mail-out.ovh.net (Postfix) with SMTP id 84A2EFFADF2
	for <netdev@vger.kernel.org>; Thu,  4 Dec 2014 18:30:00 +0100 (CET)
In-Reply-To: <547E23C1.2040007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Le 02/12/2014 21:40, Florian Fainelli a =C3=A9crit :
> On 02/12/14 06:50, Andrey Volkov wrote:
>> Hello,
>>
>> In time of developing one of our devices (with huge, more then 6, nu=
mber of onboard switches),
>> I've bumped with this ancient, I hope, restriction in the 'struct ds=
a_switch_tree' definition.=20
>> So this simple patch remove this restriction and make dsa_switch_tre=
e more scalable for=20
>> the "usual" 1-2 switches configuration too.
> Sounds reasonable to me, you probably want to resubmit and trim the
> "Hello" form your commit message.
>
>> P.S. I've plans to fix hardcoded number of ports too, but it is not =
so easy as with number of switches.
>> So if someone have any objections/suggestions I'll happy to discuss =
them.
> I think the number of ports in a switch is something that should come
> from the switch driver, and eventually intersected with what the
> platform configuration has provided.
Yes it's exactly what I've in my mind. Also in our project I need to ha=
ndle currently unsupported case:
when switches combined into the stacks by more than one hardwired links=
, i.e. some ports must be
configured as part of 'hard-coded' trunks.

> The difficulty is in case of sparse port number allocation because yo=
u
> still want to allocate e.g: 6 ports even though Port 0 and 5 are used=
, I
> don't think we want to introduce a logical to physical mapping, that
> would be too error prone.
Agree.


>
>> Signed-off-by: Andrey Volkov <andrey.volkov@nexvision.fr>           =
                                                                       =
                                                                       =
                          =20
>> ---                                                                 =
                                                                       =
                                                                       =
                          =20
>>  include/net/dsa.h |    3 +--                                       =
                                                                       =
                                                                       =
                          =20
>>  net/dsa/dsa.c     |    7 +++----                                   =
                                                                       =
                                                                       =
                          =20
>>  2 files changed, 4 insertions(+), 6 deletions(-)                   =
                                                                       =
                                                                       =
                          =20
>>                                                                     =
                                                                       =
                                                                       =
                          =20
>> diff --git a/include/net/dsa.h b/include/net/dsa.h                  =
                                                                       =
                                                                       =
                          =20
>> index ed3c34b..733db2e 100644                                       =
                                                                       =
                                                                       =
                          =20
>> --- a/include/net/dsa.h
>> +++ b/include/net/dsa.h
>> @@ -28,7 +28,6 @@ enum dsa_tag_protocol {
>>         DSA_TAG_PROTO_BRCM,
>>  };
>> =20
>> -#define DSA_MAX_SWITCHES       4
>>  #define DSA_MAX_PORTS          12
>> =20
>>  struct dsa_chip_data {
>> @@ -117,7 +116,7 @@ struct dsa_switch_tree {
>>         /*
>>          * Data for the individual switch chips.
>>          */
>> -       struct dsa_switch       *ds[DSA_MAX_SWITCHES];
>> +       struct dsa_switch       *ds[];
>>  };
>> =20
>>  struct dsa_switch {
>> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
>> index 322c778..c081a19 100644
>> --- a/net/dsa/dsa.c
>> +++ b/net/dsa/dsa.c
>> @@ -604,8 +604,6 @@ static int dsa_of_probe(struct platform_device *=
pdev)
>>         pdev->dev.platform_data =3D pd;
>>         pd->netdev =3D &ethernet_dev->dev;
>>         pd->nr_chips =3D of_get_child_count(np);
>> -       if (pd->nr_chips > DSA_MAX_SWITCHES)
>> -               pd->nr_chips =3D DSA_MAX_SWITCHES;
>> =20
>>         pd->chip =3D kcalloc(pd->nr_chips, sizeof(struct dsa_chip_da=
ta),
>>                            GFP_KERNEL);
>> @@ -717,7 +715,7 @@ static int dsa_probe(struct platform_device *pde=
v)
>>                 pd =3D pdev->dev.platform_data;
>>         }
>> =20
>> -       if (pd =3D=3D NULL || pd->netdev =3D=3D NULL)
>> +       if (pd =3D=3D NULL || pd->netdev =3D=3D NULL || pd->nr_chips=
 =3D=3D 0)
>>                 return -EINVAL;
>> =20
>>         dev =3D dev_to_net_device(pd->netdev);
>> @@ -732,7 +730,8 @@ static int dsa_probe(struct platform_device *pde=
v)
>>                 goto out;
>>         }
>> =20
>> -       dst =3D kzalloc(sizeof(*dst), GFP_KERNEL);
>> +       dst =3D kzalloc(sizeof(*dst) +
>> +                       sizeof(struct dsa_switch *) * pd->nr_chips, =
GFP_KERNEL);
>>         if (dst =3D=3D NULL) {
>>                 dev_put(dev);
>>                 ret =3D -ENOMEM;
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
