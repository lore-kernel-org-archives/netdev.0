From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: Re: [PATCH] tcp: properly update lost_cnt_hint during shifting
Date: Wed, 28 Sep 2011 16:55:10 +0800
Message-ID: <4E82E0EE.1050600@intel.com>
References: <4E82C0DD.6010304@intel.com> <alpine.DEB.2.00.1109281103410.21709@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61207 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751170Ab1I1IzL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Sep 2011 04:55:11 -0400
In-Reply-To: <alpine.DEB.2.00.1109281103410.21709@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2011 04:17 PM, Ilpo J=E4rvinen wrote:
> On Wed, 28 Sep 2011, Yan, Zheng wrote:
>=20
>> lost_skb_hint is used by tcp_mark_head_lost() to mark the first
>> unhandled skb. lost_cnt_hint is the number of sacked packets before
>> the lost_skb_hint. tcp_shifted_skb() shouldn't increase lost_cnt_hin=
t
>> when shifting a sacked skb that is before the lost_skb_hint, because
>> packets in it are already counted.
>>
>> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
>> ---
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index 21fab3e..f712ace 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -1390,9 +1390,14 @@ static int tcp_shifted_skb(struct sock *sk, s=
truct sk_buff *skb,
>>  	BUG_ON(!pcount);
>> =20
>>  	/* Tweak before seqno plays */
>> -	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint &&
>> -	    !before(TCP_SKB_CB(tp->lost_skb_hint)->seq, TCP_SKB_CB(skb)->s=
eq))
>> -		tp->lost_cnt_hint +=3D pcount;
>> +	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint) {
>> +		if (skb =3D=3D tp->lost_skb_hint)
>> +			tp->lost_cnt_hint +=3D pcount;
>> +		else if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) &&
>> +			 before(TCP_SKB_CB(skb)->seq,
>> +				TCP_SKB_CB(tp->lost_skb_hint)->seq))
>> +			tp->lost_cnt_hint +=3D pcount;
>> +	}
>=20
> Ah right, the hole filled case which shifts not only the newly SACKed=
=20
> skb but also the next, already SACKed skb?
>=20
> I fail to see why you needed to change !before into two checks though=
:
>  skb =3D=3D tp->lost_skb_hint and before(params reversed) ? Shouldn't=
 the=20
> equality that is provided by the negation cover for the =3D=3D check =
(and the=20
> params reversion isn't necessary in any case)? In fact, isn't the skb=
 =3D=3D=20
> tp->lost_skb_hint check strictly wrong without the same TCPCB_SACKED_=
ACKED=20
> guard (though I'm not sure, I didn't check, if the hint can ever poin=
t to=20
> such a segment in the first place)?

Thanks you for your reply.

skb =3D=3D tp->lost_skb_hint is special.

If the skb is sacked and we shift 'pcount' packets to previous skb,
these packets will not be counted by future tcp_mark_head_lost() call.
So we should increase lost_cnt_hint.

If the skb is not sacked, the skb will be sacked soon by tcp_sacktag_on=
e(),
So we should not increase lost_cnt_hint.

I didn't think out the second case. I think the correct patch should be=
:
---

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 21fab3e..dcc2411 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1390,9 +1390,15 @@ static int tcp_shifted_skb(struct sock *sk, stru=
ct sk_buff *skb,
 	BUG_ON(!pcount);
=20
 	/* Tweak before seqno plays */
-	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint &&
-	    !before(TCP_SKB_CB(tp->lost_skb_hint)->seq, TCP_SKB_CB(skb)->seq)=
)
-		tp->lost_cnt_hint +=3D pcount;
+	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint) {
+		if ((TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) &&
+		    skb =3D=3D tp->lost_skb_hint)
+			tp->lost_cnt_hint +=3D pcount;
+		else if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) &&
+			 before(TCP_SKB_CB(skb)->seq,
+				TCP_SKB_CB(tp->lost_skb_hint)->seq))
+			tp->lost_cnt_hint +=3D pcount;
+	}
=20
 	TCP_SKB_CB(prev)->end_seq +=3D shifted;
 	TCP_SKB_CB(skb)->seq +=3D shifted;
---


>=20
> Added Cc to Nandita as they're hunting (possibly other) bug in=20
> tcp_mark_head_lost.
>=20
