From: =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 00000000000000a0
Date: Wed, 23 Jun 2010 23:34:18 +0300
Message-ID: <4C226FCA.2030604@iki.fi>
References: <AANLkTilf41JrFwN1veRDifNA78S2LQ6SO0g3YLOONd2W@mail.gmail.com>	 <20100623141622.GC15205@tuxdriver.com>  <4C223DCA.5090704@gmail.com> <1277314167.2469.1144.camel@edumazet-laptop> <4C224E06.40806@iki.fi> <4C22508A.8060002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"John W.Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	davem@davemloft.net
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C22508A.8060002@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/23/2010 09:20 PM, Justin P. Mattock wrote:
> On 06/23/10 11:10, Timo Ter=C3=A4s wrote:
>> On 06/23/2010 08:29 PM, Eric Dumazet wrote:
>>  =20
>>> Le mercredi 23 juin 2010 =C3=A0 10:00 -0700, Justin P. Mattock a =C3=
=A9crit :
>>>    =20
>>>> o.k. the bisect is pointing to the below results..
>>>> (I tried git revert xxx but this commit is too big
>>>> so I'll(hopefully)manually revert it on the latest HEAD to
>>>> see if this is the actual problem im experiencing)
>>>>
>>>> 80c802f3073e84c956846e921e8a0b02dfa3755f is the first bad commit
>>>> commit 80c802f3073e84c956846e921e8a0b02dfa3755f
>>>> Author: Timo Ter=C3=83=C2=A4s<timo.teras@iki.fi>
>>>> Date:   Wed Apr 7 00:30:05 2010 +0000
>>>>
>>>>       xfrm: cache bundles instead of policies for outgoing flows
>>>>
>>>>       __xfrm_lookup() is called for each packet transmitted out of
>>>>       system. The xfrm_find_bundle() does a linear search which ca=
n
>>>>       kill system performance depending on how many bundles are
>>>>       required per policy.
>>>>
>>>>       This modifies __xfrm_lookup() to store bundles directly in
>>>>       the flow cache. If we did not get a hit, we just create a ne=
w
>>>>       bundle instead of doing slow search. This means that we can =
now
>>>>       get multiple xfrm_dst's for same flow (on per-cpu basis).
>>>>
>>>>       Signed-off-by: Timo Teras<timo.teras@iki.fi>
>>>>       Signed-off-by: David S. Miller<davem@davemloft.net>
>>>>
>>>> :040000 040000 d8e60f5fa4c1329f450d9c7cdf98b34e6a177f22
>>>> 9f576e68e5bf4ce357d7f0305aee5f410250dfe2 M      include
>>>> :040000 040000 f2876df688ee36907af7b4123eea96592faaed3e
>>>> a3f6f6f94f0309106856cd99b38ec90b024eb016 M      net
>>>>       =20
>>> Thanks a lot for bisecting Jutin, this is really appreciated.
>>>
>>> crash is in xfrm_bundle_ok()
>>>
>>> if (xdst->policy_genid !=3D atomic_read(&xdst->pols[0]->genid))
>>>     return 0;
>>>
>>> xdst->pols[0] contains a NULL pointer
>>>     =20
>> That does not really make sense, if we get this far; there's a valid
>> xfrm_state with the bundle. This means that there existed a policy w=
ith
>> it too.
>>
>> I'll take a deeper look at this tomorrow. Would it be possible to se=
e
>> your xfrm policies?
>>
>> - Timo
>>
>>   =20
>=20
> @Eric sure no problem doing the bisect...
>=20
> as for the xfrm policy here is the link that I used to setup ipsec:
> http://www.linuxfromscratch.org/hints/downloads/files/ipsec.txt
> (just change the keys if doing real world work..(but for me just test=
ing).
>=20
> below is a temporary fix for me to get this working, tcpdump reports
> everything is doing what it should be
> 11:16:32.496166 IP xxxxx > xxxxx: AH(spi=3D0x00000200,seq=3D0x1090):
> ESP(spi=3D0x00000201,seq=3D0x1090), length 56
> 11:16:32.496212 IP xxxxx > xxxxx: AH(spi=3D0x00000200,seq=3D0x1091):
> ESP(spi=3D0x00000201,seq=3D0x1091), length 56
> 11:16:32.496259 IP xxxxx > xxxxx: AH(spi=3D0x00000200,seq=3D0x1092):
> ESP(spi=3D0x00000201,seq=3D0x1092), length 56
>=20
> (tested a few mins ago, but not the right fix..)

Yes, that would break some other obscure scenarios.

Looks like it's ah inside esp. So you get chain of bundles. And only th=
e
first bundle gets a policy. Should have thought of that. Does the below
fix it for you?

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4bf27d9..af1c173 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2300,7 +2300,8 @@ int xfrm_bundle_ok(struct xfrm_policy *pol, struc=
t
xfrm_dst *first,
 			return 0;
 		if (xdst->xfrm_genid !=3D dst->xfrm->genid)
 			return 0;
-		if (xdst->policy_genid !=3D atomic_read(&xdst->pols[0]->genid))
+		if (xdst->num_pols > 0 &&
+		    xdst->policy_genid !=3D atomic_read(&xdst->pols[0]->genid))
 			return 0;

 		if (strict && fl &&
