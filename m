From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH ipsec] xfrm: prevent ipcomp scratch buffer race condition
Date: Tue, 15 Oct 2013 16:59:04 +0800
Message-ID: <525D03D8.7060802@windriver.com>
References: <20131014160334.BCCDDE8A31@unicorn.suse.cz> <20131015083348.GW7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Kubecek <mkubecek@suse.cz>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54524 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753362Ab3JOJBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 05:01:08 -0400
In-Reply-To: <20131015083348.GW7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B410=E6=9C=8815=E6=97=A5 16:33, Steffen Klassert wrote:
> On Mon, Oct 14, 2013 at 06:03:34PM +0200, Michal Kubecek wrote:
>> In ipcomp_compress(), sortirq is enabled too early, allowing the
>> per-cpu scratch buffer to be rewritten by ipcomp_decompress()
>> (called on the same CPU in softirq context) between populating
>> the buffer and copying the compressed data to the skb.
>>
>> Add similar protection into ipcomp_decompress() as it can be
>> called from process context as well (even if such scenario seems
>> a bit artificial).
>>
>> Signed-off-by: Michal Kubecek<mkubecek@suse.cz>
>> ---
>>   net/xfrm/xfrm_ipcomp.c | 8 ++++++--
>>   1 file changed, 6 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
>> index 2906d52..96946fb 100644
>> --- a/net/xfrm/xfrm_ipcomp.c
>> +++ b/net/xfrm/xfrm_ipcomp.c
>> @@ -48,9 +48,11 @@ static int ipcomp_decompress(struct xfrm_state *x=
, struct sk_buff *skb)
>>   	const int cpu =3D get_cpu();
>>   	u8 *scratch =3D *per_cpu_ptr(ipcomp_scratches, cpu);
>>   	struct crypto_comp *tfm =3D *per_cpu_ptr(ipcd->tfms, cpu);
>> -	int err =3D crypto_comp_decompress(tfm, start, plen, scratch,&dlen=
);
>> +	int err;
>>   	int len;
>>
>> +	local_bh_disable();
>
> Maybe we could disable the BHs before we fetch the percpu pointers.
> Then we can use smp_processor_id() to get the cpu. With that we
> could get rid of a (now useless) preempt_disable()/preempt_enable()
> pair. Same could be done in ipcomp_compress().

Is it possible that two tasks race scratch buffer when both of them try=
ing to compress data
without preempt disabled? for example, when task A working on compressi=
on, then task B
with higher priority preempts task A, and try to touch scratch buffer, =
which leaves stale
data for task A after then.

I think we needs preempt disabled for such case, otherwise I overlook c=
odes in somewhere else.

> Looks ok otherwise. Thanks!
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
