From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH 3/3] sctp: fix association hangs due to reassembly/ordering
 logic
Date: Wed, 20 Feb 2013 15:13:54 -0500
Message-ID: <51252E82.2060902@gmail.com>
References: <1361374996.3450.3.camel@laptop.lroberts> <D64EC45690EF85409BA6C4730E0162244310CBC1@G4W3231.americas.hpqcorp.net> <5125108D.3010508@gmail.com> <D64EC45690EF85409BA6C4730E0162244310CC65@G4W3231.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Roberts, Lee A." <lee.roberts@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <D64EC45690EF85409BA6C4730E0162244310CC65@G4W3231.americas.hpqcorp.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/20/2013 02:24 PM, Roberts, Lee A. wrote:
> Vlad,
>
>> -----Original Message-----
>> From: Vlad Yasevich [mailto:vyasevich@gmail.com]
>> Sent: Wednesday, February 20, 2013 11:06 AM
>> To: Roberts, Lee A.
>> Cc: linux-sctp@vger.kernel.org; netdev@vger.kernel.org; linux-
>> kernel@vger.kernel.org
>> Subject: Re: [PATCH 3/3] sctp: fix association hangs due to
>> reassembly/ordering logic
>>
>> Hi Lee
>>
>> On 02/20/2013 10:56 AM, Roberts, Lee A. wrote:
>>> From: Lee A. Roberts <lee.roberts@hp.com>
>>>
>>> Resolve SCTP association hangs observed during SCTP stress
>>> testing.  Observable symptoms include communications hangs
>>> with data being held in the association reassembly and/or lobby
>>> (ordering) queues.  Close examination of reassembly queue shows
>>> missing packets.
>>
>> As a general note for this patch series, you could really benefit
>> from a cover letter that describes the symptoms and all the differen=
t
>> issues you found.
>>
>> Also, please title your patches based on the context of the patch.
>> Giving them all the same title is very confusing and at quick glance
>> makes appear that the same patch was applied 3 times.
>>
>>>
>>> In sctp_eat_data(), enter partial delivery mode only if the
>>> data on the head of the reassembly queue is at or before the
>>> cumulative TSN ACK point.
>>>
>>> In sctp_ulpq_retrieve_partial() and sctp_ulpq_retrieve_first(),
>>> correct message reassembly logic for SCTP partial delivery.
>>> Change logic to ensure that as much data as possible is sent
>>> with the initial partial delivery and that following partial
>>> deliveries contain all available data.
>>>
>>> In sctp_ulpq_renege(), adjust logic to enter partial delivery
>>> only if the incoming chunk remains on the reassembly queue
>>> after processing by sctp_ulpq_tail_data().  Remove call to
>>> sctp_tsnmap_mark(), as this is handled correctly in call to
>>> sctp_ulpq_tail_data().
>>>
>>> Patch applies to linux-3.8 kernel.
>>>
>>> Signed-off-by: Lee A. Roberts <lee.roberts@hp.com>
>>> ---
>>>    net/sctp/sm_statefuns.c |   12 ++++++++++--
>>>    net/sctp/ulpqueue.c     |   33 ++++++++++++++++++++++++++-------
>>>    2 files changed, 36 insertions(+), 9 deletions(-)
>>>
>>> diff -uprN -X linux-3.8-vanilla/Documentation/dontdiff linux-3.8-SC=
TP
>>> +2/net/sctp/sm_statefuns.c linux-3.8-SCTP+3/net/sctp/sm_statefuns.c
>>> --- linux-3.8-SCTP+2/net/sctp/sm_statefuns.c	2013-02-18
>>> 16:58:34.000000000 -0700
>>> +++ linux-3.8-SCTP+3/net/sctp/sm_statefuns.c	2013-02-20
>>> 08:31:51.092132884 -0700
>>> @@ -6090,7 +6090,8 @@ static int sctp_eat_data(const struct sc
>>>    	size_t datalen;
>>>    	sctp_verb_t deliver;
>>>    	int tmp;
>>> -	__u32 tsn;
>>> +	__u32 tsn, ctsn;
>>> +	struct sk_buff *skb;
>>>    	struct sctp_tsnmap *map =3D (struct sctp_tsnmap *)&asoc-
>>> peer.tsn_map;
>>>    	struct sock *sk =3D asoc->base.sk;
>>>    	struct net *net =3D sock_net(sk);
>>> @@ -6160,7 +6161,14 @@ static int sctp_eat_data(const struct sc
>>>    		/* Even if we don't accept this chunk there is
>>>    		 * memory pressure.
>>>    		 */
>>> -		sctp_add_cmd_sf(commands, SCTP_CMD_PART_DELIVER,
>> SCTP_NULL());
>>> +		skb =3D skb_peek(&asoc->ulpq.reasm);
>>> +		if (skb !=3D NULL) {
>>> +			ctsn =3D sctp_skb2event(skb)->tsn;
>>> +			if (TSN_lte(ctsn,
>>> +				sctp_tsnmap_get_ctsn(&asoc->peer.tsn_map)))
>>> +				sctp_add_cmd_sf(commands,
>>> +					SCTP_CMD_PART_DELIVER, SCTP_NULL());
>>> +		}
>>
>> What if the tsn you are currently processing will advance the
>> CUM TSN?  You may still need to eneter PD.  This is why
>> sctp_eat_data() is not the right place to place this check.
>>
>> The more I look at the SCTP_CMD_PART_DELIVERY the more I am thinking
>> that it has to come after the current TSN has been delivered to the
>> queue.  That way, if we are currently processing the first fragment,
>> we'll queue it, then enter PD and pull it off the queue properly.
>> If we are processing the middle or last, it will get queued first, a=
nd
>> then PD will be entered to fetch anything that we can fetch.
>>
>> In fact, the above is what happens when we issue a RENEGE command, b=
ut
>> the order is reversed is RENEGE is skipped for some reason.  I am st=
ill
>> trying to figure out if it's possible to enter PD without RENEGE, bu=
t I
>> did notice the above aberration.
>>
>
> The current code enters partial delivery by calling sctp_ulpq_partial=
_delivery()
> in two locations.  In sctp_cmd_interpreter() [located in ../net/sctp/=
sm_sideeffect.c],
> as a result of the code in sctp_eat_data() [located in ../net/sctp/sc=
tp_statefuns.c]:
>
> 1675                 case SCTP_CMD_PART_DELIVER:
> 1676                         sctp_ulpq_partial_delivery(&asoc->ulpq, =
GFP_ATOMIC)     ;
> 1677                         break;
>
> and in sctp_ulpq_renege() [located in ../net/sctp/ulpqueue.c]
>
>
> 1055         /* If able to free enough room, accept this chunk. */
> 1056         if (chunk && (freed >=3D needed)) {
> 1057                 __u32 tsn;
> 1058                 tsn =3D ntohl(chunk->subh.data_hdr->tsn);
> 1059                 sctp_tsnmap_mark(&asoc->peer.tsn_map, tsn, chunk=
->transport     );
> 1060                 sctp_ulpq_tail_data(ulpq, chunk, gfp);
> 1061
> 1062                 sctp_ulpq_partial_delivery(ulpq, gfp);
> 1063         }
>
> Neither location checks to see whether the tsn on the head of the rea=
ssembly queue
> is less than or equal to the cumulative TSN ACK point.  Perhaps a bet=
ter solution
> is to put this check in the beginning of sctp_ulpq_partial_delivery()=
 and abort the
> partial delivery attempt if this condition isn't met.  I'll try this.

I don't really think you need do any of that.  What you needs to happen=
=20
is that sctp_ulpq_retrieve_first() and sctp_ulpq_retrieve_partial() nee=
d=20
code in them to make sure we don't use a fragment that has
TSN > CUM_TSN.

PD is not really entered if sctp_ulpq_retrieve_first() returns NULL so=20
we are ok.

>
> The code in sctp_eat_data() involving SCTP_CMD_PART_DELIVER may be be=
tter if invoked
> after the current packet is handled, but that is probably an optimiza=
tion.  As is,
> the partial delivery may not start until another packet arrives.
>

What I was saying is that have the possibilities of the following 2=20
sequences of commands:

	SCTP_CMD_PART_DELIVER  - calls sctp_ulpq_partial_delivery
	SCTP_CMD_RENEGE - calls sctp_ulpq_tail_data followed by=20
sctp_ulpq_partial_delivery

or
	SCTP_CMD_PART_DELIVER  - calls sctp_ulpq_partial_delivery
	SCTP_CMD_CHUNK_ULP - calls sctp_ulpq_tail_data


What I am saying is that in the first sequence, we call=20
sctp_ulpq_partial_delivery twice which is more then useless.  It is=20
actually wrong.  We may Partial Deliver first and may not even need to=20
reneg at all after that.

In the second case, we have the order reversed.  We should put the data=
=20
of the uplq first and then if needed attempt PD since now we have a=20
higher chance of it succeeding.

>>
>>>    	}
>>>
>>>    	/* Spill over rwnd a little bit.  Note: While allowed, this spi=
ll
>> over
>>> diff -uprN -X linux-3.8-vanilla/Documentation/dontdiff linux-3.8-SC=
TP
>>> +2/net/sctp/ulpqueue.c linux-3.8-SCTP+3/net/sctp/ulpqueue.c
>>> --- linux-3.8-SCTP+2/net/sctp/ulpqueue.c	2013-02-20
>> 08:17:53.679233365
>>> -0700
>>> +++ linux-3.8-SCTP+3/net/sctp/ulpqueue.c	2013-02-20
>> 08:27:02.785042744
>>> -0700
>>> @@ -540,14 +540,19 @@ static struct sctp_ulpevent *sctp_ulpq_r
>>>    		ctsn =3D cevent->tsn;
>>>
>>>    		switch (cevent->msg_flags & SCTP_DATA_FRAG_MASK) {
>>> +		case SCTP_DATA_FIRST_FRAG:
>>> +			if (!first_frag)
>>> +				return NULL;
>>> +			goto done;
>>>    		case SCTP_DATA_MIDDLE_FRAG:
>>>    			if (!first_frag) {
>>>    				first_frag =3D pos;
>>>    				next_tsn =3D ctsn + 1;
>>>    				last_frag =3D pos;
>>> -			} else if (next_tsn =3D=3D ctsn)
>>> +			} else if (next_tsn =3D=3D ctsn) {
>>>    				next_tsn++;
>>> -			else
>>> +				last_frag =3D pos;
>>> +			} else
>>>    				goto done;
>>>    			break;
>>>    		case SCTP_DATA_LAST_FRAG:
>>
>> This may still allow you to skip over a gap if the first middle
>> fragment
>> in the queue starts after the gap.  We need to make sure that
>> TSN of the current chunk is less then equal to
>> sctp_tsnmap_get_ctsn(map).
>>
>
>
>   594         if (!ulpq->pd_mode)
>   595                 retval =3D sctp_ulpq_retrieve_reassembled(ulpq)=
;
>   596         else {
>   597                 __u32 ctsn, ctsnap;
>   598
>   599                 /* Do not even bother unless this is the next t=
sn to
>   600                  * be delivered.
>   601                  */
>   602                 ctsn =3D event->tsn;
>   603                 ctsnap =3D sctp_tsnmap_get_ctsn(&ulpq->asoc->pe=
er.tsn_map);
>   604                 if (TSN_lte(ctsn, ctsnap))
>   605                         retval =3D sctp_ulpq_retrieve_partial(u=
lpq);
>   606         }
>
> This is the only place we call sctp_ulpq_retrieve_partial().

Ok, you are right.  We are seem to be ok here, but I am not really craz=
y=20
about doing the checks ouside these functions.  the functions themselve=
s=20
should be smart enough to return the right data.

>
>>> @@ -651,6 +656,14 @@ static struct sctp_ulpevent *sctp_ulpq_r
>>>    			} else
>>>    				goto done;
>>>    			break;
>>> +
>>> +		case SCTP_DATA_LAST_FRAG:
>>> +			if (!first_frag)
>>> +				return NULL;
>>> +			else
>>> +				goto done;
>>> +			break;
>>> +
>>>    		default:
>>>    			return NULL;
>>
>> Same thing here.  Both, FIRST and MIDDLE fragments need to be valida=
ted
>> against sctp_tsnmap_get_ctsn(), otherwise you may be stepping over a
>> gap.
>>
>
> If we check that the head of the reassembly queue is at or below the =
cumulative tsn
> before entering partial delivery, we should be OK.

But you have to do it everywhere you try to enter PD instead of just in=
=20
once place that actually iterates and checks tsns.

>
> In sctp_ulpq_retrieve_first(), we expect the first packet on the reas=
sembly queue
> will be a FIRST.  (If not, something went wrong somewhere else.)

Not necessarily wrong.  It may have just been still lost on the network=
=2E=20
  It is perfectly ok that we may still be waiting for this FIRST fragme=
nt.

Also, what if the FIRST fragment you have here is bigger then=20
cum_tsn_ack_point?  I guess this is why you check before calling into=20
partial delivery functions, but you call before fully processing the TS=
N=20
sometimes.  It is more correct to have these functions do the validatio=
n=20
and return proper results that have the callers do validation.  It is=20
simpler to miss call sights and you duplicate code.


> If we find another
> FIRST, we know that we've gone too far.  If the second packet is a MI=
DDLE, we check
> that it has the correct tsn.  We keep processing MIDDLE packets as lo=
ng as the tsn
> values are sequential.  If the packet is a MIDDLE and the tsn isn't r=
ight, we've
> gone too far.  In sctp_ulpq_retreive_first(), we don't return a LAST,=
 by definition,
> since that wouldn't be a partial delivery.
>
> In sctp_ulpq_retrieve_partial(), we expect that the first packet on t=
he reassembly queue
> is not a FIRST.  We're looking for MIDDLE or LAST fragments to comple=
te the message.
> Since we know that the head of the reassembly queue is at or before t=
he cumulative TSN,
> we shouldn't have a gap.  We want to pick up MIDDLE packets until we =
see a tsn gap
> or until we find the right LAST packet.  When we find the right LAST =
packet, we set
> MSG_EOR and exit from partial delivery.
>
>>>    		}
>>> @@ -1054,6 +1067,7 @@ void sctp_ulpq_renege(struct sctp_ulpq *
>>>    		      gfp_t gfp)
>>>    {
>>>    	struct sctp_association *asoc;
>>> +	struct sk_buff *skb;
>>>    	__u16 needed, freed;
>>>
>>>    	asoc =3D ulpq->asoc;
>>> @@ -1074,12 +1088,17 @@ void sctp_ulpq_renege(struct sctp_ulpq *
>>>    	}
>>>    	/* If able to free enough room, accept this chunk. */
>>>    	if (chunk && (freed >=3D needed)) {
>>> -		__u32 tsn;
>>> +		__u32 tsn, ctsn;
>>>    		tsn =3D ntohl(chunk->subh.data_hdr->tsn);
>>> -		sctp_tsnmap_mark(&asoc->peer.tsn_map, tsn, chunk-
>>> transport);
>>> -		sctp_ulpq_tail_data(ulpq, chunk, gfp);
>>> -
>>> -		sctp_ulpq_partial_delivery(ulpq, gfp);
>>> +		if (sctp_ulpq_tail_data(ulpq, chunk, gfp) =3D=3D 0) {
>>> +			skb =3D skb_peek(&ulpq->reasm);
>>> +			if (skb !=3D NULL) {
>>> +				ctsn =3D sctp_skb2event(skb)->tsn;
>>> +				if (TSN_lte(ctsn, tsn))
>>> +					sctp_ulpq_partial_delivery(ulpq, chunk,
>>> +						gfp);
>>> +			}
>>> +		}
>>>    	}
>>
>> I am not sure this hunk is really needed.
>>
>> You are trying to use this code make sure that you start PD with
>> something to deliver, but the PD code already takes care of that.
>> You also get some basic cum_tsn checking for the current chunk becau=
se
>> of how renege is called, but you still don't do the checks for
>> subsequent chunks in the queue as I stated above, so you are still
>> subject to possible hangs.
>>
>> -vlad
>>
>
> If our incoming packet completes a message, the call to sctp_ulpq_tai=
l_data()
> should cause it to be delivered.  If so, the whole message is gone, s=
o we shouldn't
> need to enter partial delivery.  We don't want to enter partial deliv=
ery
> unnecessarily, since it can block delivery on other streams.

OK.  Then it might be nice to have some status from=20
sctp_ulpq_tail_data() of whether EOR has been reached or not.  If not=20
EOR , then do partial deliver. If EOR, then you may want to consider=20
calling sctp_ulpq_reasm_drain() to see you can pull get more fully=20
reassembled events.

-vlad

>
>
>>>
>>>    	sk_mem_reclaim(asoc->base.sk);
>>>
>>> N=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDr=EF=BF=BD=EF=BF=BDy=EF=
=BF=BD=EF=BF=BD=EF=BF=BDb=EF=BF=BDX=EF=BF=BD=EF=BF=BD=C7=A7v=EF=BF=BD^=EF=
=BF=BD)=DE=BA{.n=EF=BF=BD+=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD{=EF=BF=BD=
=EF=BF=BD=EF=BF=BDi=EF=BF=BD{ay=EF=BF=BD=1D=CA=87=DA=99=EF=BF=BD,j
> =EF=BF=BD=EF=BF=BDf=EF=BF=BD=EF=BF=BD=EF=BF=BDh=EF=BF=BD=EF=BF=BD=EF=BF=
=BDz=EF=BF=BD=1E=EF=BF=BDw=EF=BF=BD=EF=BF=BD=EF=BF=BD
>>
>> =EF=BF=BD=EF=BF=BD=EF=BF=BDj:+v=EF=BF=BD=EF=BF=BD=EF=BF=BDw=EF=BF=BD=
j=EF=BF=BDm=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD
> =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDzZ+=EF=BF=BD=EF=BF=BD=DD=A2j"=EF=BF=
=BD=EF=BF=BD!tml=3D
>>>
>
