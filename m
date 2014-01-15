From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv3 net-next 2/5] {IPv4,xfrm} Add ESN support for AH ingress
 part
Date: Wed, 15 Jan 2014 15:12:14 +0800
Message-ID: <52D634CE.8020501@windriver.com>
References: <1389663552-29638-1-git-send-email-fan.du@windriver.com> <1389663552-29638-3-git-send-email-fan.du@windriver.com> <20140114095425.GH31491@secunet.com> <52D50AFC.6030302@windriver.com> <20140114100900.GI31491@secunet.com> <52D50EB6.3010301@windriver.com> <20140114103426.GJ31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:50649 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbaAOHMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 02:12:22 -0500
In-Reply-To: <20140114103426.GJ31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2014=E5=B9=B401=E6=9C=8814=E6=97=A5 18:34, Steffen Klassert wrote:
> On Tue, Jan 14, 2014 at 06:17:26PM +0800, Fan Du wrote:
>>
>>
>> On 2014=E5=B9=B401=E6=9C=8814=E6=97=A5 18:09, Steffen Klassert wrote=
:
>>> On Tue, Jan 14, 2014 at 06:01:32PM +0800, Fan Du wrote:
>>>>
>>>>
>>>> On 2014=E5=B9=B401=E6=9C=8814=E6=97=A5 17:54, Steffen Klassert wro=
te:
>>>>> On Tue, Jan 14, 2014 at 09:39:09AM +0800, Fan Du wrote:
>>>>>> @@ -381,7 +393,14 @@ static int ah_input(struct xfrm_state *x, s=
truct sk_buff *skb)
>>>>>>   	sg_init_table(sg, nfrags);
>>>>>>   	skb_to_sgvec(skb, sg, 0, skb->len);
>>>>>>
>>>>>> -	ahash_request_set_crypt(req, sg, icv, skb->len);
>>>>>> +	if (x->props.flags&    XFRM_STATE_ESN) {
>>>>>> +		sg_unmark_end(&sg[nfrags - 1]);
>>>>>> +		/* Attach seqhi sg right after packet payload */
>>>>>> +		*seqhi =3D htonl(XFRM_SKB_CB(skb)->seq.output.hi);
>>>>>
>>>>> This is ah_input(), so you should use the high bits of the input
>>>>> sequence number here. The ipv6 patch has the same problem.
>>>>
>>>> ok, I will fix this.
>>>>
>>>>>
>>>>>> +		sg_init_table(seqhisg, sglists);
>>>>>
>>>>> Why do you add a separate SG table for this?
>>>>
>>>> It just initialize a single seqhisg, which is actually followed be=
hind packet payload sg table.
>>>> initialized seqhisg actually mark itself as the end of sg list.
>>>>
>>>
>>> Why don't you just add this entry to the existing SG table?
>>>
>>
>> Do you mean scatterwalk_crypto_chain ?
>
> No, I mean something like:
>
> sg_init_table(sg, nfrags + sglists)
>
> if (x->props.flags&  XFRM_STATE_ESN) {
> 	*seqhi =3D XFRM_SKB_CB(skb)->seq.input.hi;
> 	sg_set_buf(sg + nfrags, seqhi, seqhi_len);
> }
>

Calling skb_to_sgvec to map first part of payload into global sg list w=
ill mark the sg
which contains last data of payload as new end, that's side effect of s=
kb_to_sgvec.
This doesn't work well unless calling sg_unmark_end again to revert suc=
h effect.

Here we need another method to map payload to sg list without changing =
the end sg.

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
