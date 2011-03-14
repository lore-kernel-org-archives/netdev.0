From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/4] netfilter: xt_connlimit: fix daddr connlimit in SNAT
 scenario
Date: Mon, 14 Mar 2011 20:00:07 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1103141955180.21929@obet.zrqbmnf.qr>
References: <1300085414-27275-1-git-send-email-xiaosuo@gmail.com> <alpine.LNX.2.01.1103141310140.27542@obet.zrqbmnf.qr> <AANLkTi=QgVBVAPcTmb_La=VJOLq5LmGPqMfw7bbCuByP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=QgVBVAPcTmb_La=VJOLq5LmGPqMfw7bbCuByP@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 2011-03-14 13:42, Changli Gao wrote:

>On Mon, Mar 14, 2011 at 8:26 PM, Jan Engelhardt <jengelh@medozas.de> w=
rote:
>> On Monday 2011-03-14 07:50, Changli Gao wrote:
>>
>>>We use the reply tuples when limiting the connections by the destina=
tion
>>>addresses, however, in SNAT scenario, the final reply tuples won't b=
e
>>>ready until SNAT is done in POSTROUING or INPUT chain
>>
>> If I am not mistaken: if you do daddr counting, SNAT is irrelevant.
>> Consider ruleset
>> =C2=A0-t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to 1.2.3.4:80
>> =C2=A0-t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to 1.2.3.5:4=
43
>>
>> The tuple will first be (as per conntrack -L):
>> =C2=A0src=3Dhome dst=3Drouter src=3Drouter dst=3Dhome
>> After DNAT:
>> =C2=A0src=3Dhome dst=3Drouter src=3D1.2.3.4 dst=3Dhome
>>
>> Thus looking at the src of the reply tuple seems correct =E2=80=94 a=
t least this
>> is what was wanted, counting per stashed servers (=3D1 customer), no=
t per
>> globally visible address.
>>
>
>Yes, you are correct only when there is no SNAT rule. If there is an=20
>SNAT rule:
>
>-t nat -A POSTROUTING -p tcp --dport 80 -j SNAT --to-source 192.168.0.=
1
>
>the final tuples will be:
>src =3D home dst =3D router src=3D1.2.3.4 dst=3D192.168.0.1
>
>However, the tuple saved by connlimit is src=3D1.2.3.4 dst=3Dhome, so =
this
>conn will be removed later as there isn't any conntrack, which has
>this tuple in any direction.

But I don't yet see how your patch #1 can help. At the time=20
conn->tuple=C2=A0=3D *tuple is done, *tuple still contains the non-SNAT=
ed=20
tuple, and it is never updated again.


(Patrick: patches 2-4 are ok)

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
