From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/4] netfilter: xt_connlimit: fix daddr connlimit in SNAT
 scenario
Date: Tue, 15 Mar 2011 02:16:45 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1103150210370.21929@obet.zrqbmnf.qr>
References: <1300085414-27275-1-git-send-email-xiaosuo@gmail.com> <alpine.LNX.2.01.1103141310140.27542@obet.zrqbmnf.qr> <AANLkTi=QgVBVAPcTmb_La=VJOLq5LmGPqMfw7bbCuByP@mail.gmail.com> <alpine.LNX.2.01.1103141955180.21929@obet.zrqbmnf.qr>
 <AANLkTimBV9x7Y-tUez5VMDoU+8mtaw1f48GV1yxgZ71c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimBV9x7Y-tUez5VMDoU+8mtaw1f48GV1yxgZ71c@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2011-03-15 00:49, Changli Gao wrote:
>>>the final tuples will be:
>>>src =3D home dst =3D router src=3D1.2.3.4 dst=3D192.168.0.1
>>>
>>>However, the tuple saved by connlimit is src=3D1.2.3.4 dst=3Dhome, s=
o this
>>>conn will be removed later as there isn't any conntrack, which has
>>>this tuple in any direction.
>>
>> But I don't yet see how your patch #1 can help. At the time
>> conn->tuple=C2=A0=3D *tuple is done, *tuple still contains the non-S=
NATed
>> tuple, and it is never updated again.
>
>In this patch, conn->addr is used to save the destination/source
>address instead of conn->tuple.src.u3, so the conn->tuple is used for
>conntrack lookup only. Just as the original tuple isn't updated, we
>can use it to looking up the associated conntrack all the time.

The original tuple may not be updated, but the reply tuple is.
And we are taking the reply tuple in

	tuple_ptr =3D &ct->tuplehash[IP_CT_DIR_REPLY].tuple;

which is subsequently copied to conn->tuple on the first invocation.

Afterwards, SNAT will update ct->tuplehash[reply].tuple, and so
conn->tuple is outdated. Calling nf_conntrack_find_get(conn->tuple)
in count_them would then fail, would it not?
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
