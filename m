From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [PATCH net] act_ife: Add support for machines with
 hard_header_len != mac_len
Date: Fri, 23 Sep 2016 05:49:06 +0000
Message-ID: <DB3PR05MB0764D20F281FA6AEC643D744ACC80@DB3PR05MB0764.eurprd05.prod.outlook.com>
References: <1474462453-37668-1-git-send-email-yotamg@mellanox.com>
 <9850b403-34b2-4a4a-7d50-8e935f3f35a2@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0040.outbound.protection.outlook.com ([104.47.2.40]:23136
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1757585AbcIWFtJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 01:49:09 -0400
In-Reply-To: <9850b403-34b2-4a4a-7d50-8e935f3f35a2@mojatatu.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Jamal Hadi Salim [mailto:jhs@mojatatu.com]
>Sent: Friday, September 23, 2016 1:40 AM
>To: Yotam Gigi <yotamg@mellanox.com>; davem@davemloft.net;
>netdev@vger.kernel.org; Roman Mashak <mrv@mojatatu.com>
>Subject: Re: [PATCH net] act_ife: Add support for machines with hard_heade=
r_len
>!=3D mac_len
>
>On 16-09-21 08:54 AM, Yotam Gigi wrote:
>> Without that fix, the following could occur:
>>  - On encode ingress, the total amount of skb_pushes (in lines 751 and
>>    753) was more than specified in cow.
>>  - On machines with hard_header_len > mac_len, the packet format was not
>
>Just curious: What hardware would this be?

On mlxsw, in order to send a packet there needed to be added small tx heade=
r. In=20
order to tell the kernel to reserve that space in the allocated skb, we set=
 that=20
hard_header_len field to include the tx header in addition to the mac heade=
r.

>
>
>> Fixes: ef6980b6becb ("net sched: introduce IFE action")
>> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
>> ---
>>  net/sched/act_ife.c | 34 +++++++++++++++++++++++++---------
>>  1 file changed, 25 insertions(+), 9 deletions(-)
>>
>> diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
>> index e87cd81..27b19ca 100644
>> --- a/net/sched/act_ife.c
>> +++ b/net/sched/act_ife.c
>> @@ -708,11 +708,13 @@ static int tcf_ife_encode(struct sk_buff *skb, con=
st
>struct tc_action *a,
>>  	   where ORIGDATA =3D original ethernet header ...
>>  	 */
>>  	u16 metalen =3D ife_get_sz(skb, ife);
>> -	int hdrm =3D metalen + skb->dev->hard_header_len + IFE_METAHDRLEN;
>> -	unsigned int skboff =3D skb->dev->hard_header_len;
>>  	u32 at =3D G_TC_AT(skb->tc_verd);
>> -	int new_len =3D skb->len + hdrm;
>>  	bool exceed_mtu =3D false;
>> +	unsigned int skboff;
>> +	int total_push;
>> +	int reserve;
>> +	int new_len;
>> +	int hdrm;
>>  	int err;
>>
>>  	if (at & AT_EGRESS) {
>> @@ -724,6 +726,22 @@ static int tcf_ife_encode(struct sk_buff *skb, cons=
t struct
>tc_action *a,
>>  	bstats_update(&ife->tcf_bstats, skb);
>>  	tcf_lastuse_update(&ife->tcf_tm);
>>
>> +	if (at & AT_EGRESS) {
>> +		/* on egress, reserve space for hard_header_len instead of
>> +		 * mac_len
>> +		 */
>> +		skb_reset_mac_len(skb);
>
>The skb_reset_mac_len() above is unneeded.
>
>> +		hdrm =3D metalen + skb->mac_len + IFE_METAHDRLEN;
>
>Can you move this line outside of the if? It appears on the else
>so factoring it out is useful.
>
>> +		total_push =3D hdrm;
>> +		reserve =3D metalen + skb->dev->hard_header_len +
>IFE_METAHDRLEN;
>> +	} else {
>> +		/* on ingress, push mac_len as it already get parsed from tc */
>> +		hdrm =3D metalen + skb->mac_len + IFE_METAHDRLEN;
>> +		total_push =3D hdrm + skb->mac_len;
>> +		reserve =3D total_push;
>> +	}
>> +	new_len =3D  skb->len + hdrm;
>> +
>>  	if (!metalen) {		/* no metadata to send */
>>  		/* abuse overlimits to count when we allow packet
>>  		 * with no metadata
>> @@ -742,19 +760,17 @@ static int tcf_ife_encode(struct sk_buff *skb, con=
st
>struct tc_action *a,
>>
>>  	iethh =3D eth_hdr(skb);
>>
>> -	err =3D skb_cow_head(skb, hdrm);
>> +	err =3D skb_cow_head(skb, reserve);
>>  	if (unlikely(err)) {
>>  		ife->tcf_qstats.drops++;
>>  		spin_unlock(&ife->tcf_lock);
>>  		return TC_ACT_SHOT;
>>  	}
>>
>> -	if (!(at & AT_EGRESS))
>> -		skb_push(skb, skb->dev->hard_header_len);
>> -
>> -	__skb_push(skb, hdrm);
>> +	__skb_push(skb, total_push);
>>  	memcpy(skb->data, iethh, skb->mac_len);
>>  	skb_reset_mac_header(skb);
>> +	skboff +=3D skb->mac_len;
>
>Above looks dangerous. Did the compiler not warn?
>Maybe init skboff to skb->mac_len at the top.

That's look weird. I will fix it and repost in the next couple of days.

>
>Otherwise the ingress bits look good. Thanks!
>
>Please fix above and resend with:
>Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
>cheers,
>jamal
