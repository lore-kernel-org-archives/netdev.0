From: Luca Tettamanti <kronos.it@gmail.com>
Subject: Re: [PATCH] af_key: fix netns ops ordering on module load/unload
Date: Mon, 1 Feb 2010 14:50:02 +0100
Message-ID: <68676e01002010550l2654208dged864973a996c381@mail.gmail.com>
References: <20100129094822.GA8294@nb-core2.darkstar.lan>
	 <b6fcc0a1001290217l4edb0a0btbafa0c26b6f14ad5@mail.gmail.com>
	 <1264778549.3184.28.camel@edumazet-laptop>
	 <1264782806.3184.42.camel@edumazet-laptop>
	 <20100130125327.GA4258@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100130125327.GA4258@x200>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 30, 2010 at 1:53 PM, Alexey Dobriyan <adobriyan@gmail.com> =
wrote:
> On Fri, Jan 29, 2010 at 05:33:26PM +0100, Eric Dumazet wrote:
>> @@ -3807,21 +3807,24 @@ static int __init ipsec_pfkey_init(void)
>> =C2=A0 =C2=A0 =C2=A0 if (err !=3D 0)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
>>
>> - =C2=A0 =C2=A0 err =3D sock_register(&pfkey_family_ops);
>> - =C2=A0 =C2=A0 if (err !=3D 0)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_unregister_key_=
proto;
>> =C2=A0 =C2=A0 =C2=A0 err =3D xfrm_register_km(&pfkeyv2_mgr);
>> =C2=A0 =C2=A0 =C2=A0 if (err !=3D 0)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_sock_unregister=
;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_unregister_key_=
proto;
>> +
>> =C2=A0 =C2=A0 =C2=A0 err =3D register_pernet_subsys(&pfkey_net_ops);
>> =C2=A0 =C2=A0 =C2=A0 if (err !=3D 0)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_xfrm_unreg=
ister_km;
>> +
>> + =C2=A0 =C2=A0 err =3D sock_register(&pfkey_family_ops);
>> + =C2=A0 =C2=A0 if (err !=3D 0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_unregister_pern=
et;
>> =C2=A0out:
>> =C2=A0 =C2=A0 =C2=A0 return err;
>> +
>> +out_unregister_pernet:
>> + =C2=A0 =C2=A0 unregister_pernet_subsys(&pfkey_net_ops);
>> =C2=A0out_xfrm_unregister_km:
>> =C2=A0 =C2=A0 =C2=A0 xfrm_unregister_km(&pfkeyv2_mgr);
>> -out_sock_unregister:
>> - =C2=A0 =C2=A0 sock_unregister(PF_KEY);
>> =C2=A0out_unregister_key_proto:
>> =C2=A0 =C2=A0 =C2=A0 proto_unregister(&key_proto);
>> =C2=A0 =C2=A0 =C2=A0 goto out;
>
> ACK analysis, except this is not enough.
>
> Here is patch which survived netns start/stop/modprobe/rmmod cycles.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Alexey, who still doesn't get why bug repr=
oduces so easily for bug reporter.
>
> Luca, please confirm.

Seems to work fine.

> [PATCH] af_key: fix netns ops ordering on module load/unload
>
> 1. After sock_register() returns, it's possible to create sockets,
> =C2=A0 even if module still not initialized fully (blame generic modu=
le code
> =C2=A0 for that!)
> 2. Consequently, pfkey_create() can be called with pfkey_net_id still=
 not
> =C2=A0 initialized which will BUG_ON in net_generic():
> =C2=A0 =C2=A0 =C2=A0 =C2=A0kernel BUG at include/net/netns/generic.h:=
43!
> 3. During netns shutdown, netns ops should be unregistered after
> =C2=A0 key manager unregistered because key manager calls can be trig=
gered
> =C2=A0 from xfrm_user module:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0general protection fault: 0000 [#1] PREEMP=
T SMP DEBUG_PAGEALLOC
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pfkey_broadcast+0x111/0x210 [af_key]
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pfkey_send_notify+0x16a/0x300 [af_key]
> =C2=A0 =C2=A0 =C2=A0 =C2=A0km_state_notify+0x41/0x70
> =C2=A0 =C2=A0 =C2=A0 =C2=A0xfrm_flush_sa+0x75/0x90 [xfrm_user]
> 4. Unregister netns ops after socket ops just in case and for symmetr=
y.
>
> Reported by Luca Tettamanti.
>
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Tested-by: Luca Tettamanti <kronos.it@gmail.com>

thanks,
Luca
