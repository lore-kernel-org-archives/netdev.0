From: Roman Gushchin <klamm@yandex-team.ru>
Subject: Re: [PATCH v3] net: sysctl for RA default route MTU
Date: Wed, 08 Apr 2015 22:03:56 +0300
Message-ID: <211371428519836@webcorp02f.yandex-team.ru>
References: <1427834148.979686.247747037.29964C1B@webmail.messagingengine.com>
	 <20150331.164923.229749666073516444.davem@davemloft.net>
	 <68621427882330@webcorp01g.yandex-team.ru>
	 <20150401.135532.1368728758929086692.davem@davemloft.net>
	 <1427916447.1816412.248215129.072B6ABF@webmail.messagingengine.com>
	 <36791427998117@webcorp02f.yandex-team.ru> <1428422310.2928.8.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428422310.2928.8.camel@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

07.04.2015, 18:58, "Hannes Frederic Sowa" <hannes@stressinduktion.org>:
> =9AOn Do, 2015-04-02 at 21:08 +0300, Roman Gushchin wrote:
>>>> =9A=9A=9AThe next question I have is about the behavior of the new=
 setting
>>>> =9A=9A=9Ain the presence of an RA MTU option. =9AIt seems like the=
 sysctl
>>>> =9A=9A=9Adoesn't override that RA MTU option, but rather just clam=
ps it.
>>>>
>>>> =9A=9A=9AAnd then if it's in range, this controls only whether the=
 default
>>>> =9A=9A=9Aroute has it's MTU adjusted.
>>>>
>>>> =9A=9A=9AThat doesn't make any sense to me if we then go and do th=
e
>>>> =9A=9A=9Art6_mtu_change() call unconditionally. =9AThe route metri=
c update
>>>> =9A=9A=9Aand the rt6_mtu_change() go hand in hand.
>>> =9A=9AAgreed but that gets interesting:
>>>
>>> =9A=9AI guess during testing the cnf.mtu6 value was equal to the ne=
wly
>>> =9A=9Aannounced mtu value, so the rt6_mtu_change call does not happ=
en. We
>>> =9A=9Aupdate cnf.mtu6 so a second RA packet would actually bring th=
e system
>>> =9A=9Ainto the desired state but we have a moment where the default=
 route
>>> =9A=9Acarries a too big MTU. That's not good.
>> =9A=9AAgreed.
>>> =9A=9AEasiest solution is to reorder those calls but that also leav=
es us with
>>> =9A=9Aa time frame where we carry the incorrect MTU on the default =
route.
>>> =9A=9AOtherwise we must conditionally filter out the default routes=
=2E
>>> =9A=9ARoman, any ideas?
>> =9A=9AI think, such approach will work on practise, but looks not ve=
ry beatiful.
>>
>> =9A=9AMay be, a better idea is to serarate per-route and per-device =
MTU,
>> =9A=9Aso an updating of per-device MTU will not affect per-route MTU=
=2E
>> =9A=9AActual MTU can always been calculated as min(route_mtu, device=
_mtu),
>> =9A=9Abut we wouldn't need to update mtu on each route on receiving =
RA MTU option,
>> =9A=9Afor instance.
>>
>> =9A=9ADo you see any problems with such approach?
> =9AIf I understood you correct this actually seems to be quite an int=
rusive
> =9Achange? :/ Can you show me some code how to do this?

Too intrusive, really)

> =9AI would also dislike adding a filtering capability to the route mt=
u
> =9Aupdates. Currently I don't have a god idea, sorry.

Hmm, I thought a bit more about this issue... And It seems to me now, t=
hat there is no issue at all.
If RA MTU is larger than ra_default_route_mtu, rt6_mtu_change() will no=
t update it,
because dst_mtu(&rt->dst) !=3D idev->cnf.mtu6 :
	if (rt->dst.dev =3D=3D arg->dev &&
	    !dst_metric_locked(&rt->dst, RTAX_MTU) &&
	    (dst_mtu(&rt->dst) >=3D arg->mtu ||
	     (dst_mtu(&rt->dst) < arg->mtu &&
	      dst_mtu(&rt->dst) =3D=3D idev->cnf.mtu6))) {
		dst_metric_set(&rt->dst, RTAX_MTU, arg->mtu);
	}
So, it's ok.

Otherwise, if RA MTU is lower than ra_default_route_mtu, rt6_mtu_change=
() will lower default route mtu, and it's ok too. There is a short peri=
od of time, when a newly created default route has too large MTU, but i=
t's not scary. And it's exactly as it works now if new RA advertise MTU=
 smaller than previous.

Do I miss something?

Thanks!

Regards,
Roman
