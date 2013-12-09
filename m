From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next 2/3] xfrm: clamp down spi range for IPComp when
 allocating spi
Date: Mon, 9 Dec 2013 14:27:43 +0800
Message-ID: <52A562DF.4090302@windriver.com>
References: <1385607161-27597-1-git-send-email-fan.du@windriver.com> <1385607161-27597-3-git-send-email-fan.du@windriver.com> <20131206114248.GG31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:64247 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932338Ab3LIG14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 01:27:56 -0500
In-Reply-To: <20131206114248.GG31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B412=E6=9C=8806=E6=97=A5 19:42, Steffen Klassert wrote:
> On Thu, Nov 28, 2013 at 10:52:40AM +0800, Fan Du wrote:
>> otherwise xfrm state can not be found properly by peers.
>>
>> Signed-off-by: Fan Du<fan.du@windriver.com>
>> ---
>>   net/xfrm/xfrm_state.c |   13 +++++++++++++
>>   1 file changed, 13 insertions(+)
>>
>> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
>> index 68c2f35..a6716d7 100644
>> --- a/net/xfrm/xfrm_state.c
>> +++ b/net/xfrm/xfrm_state.c
>> @@ -1506,6 +1506,19 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 =
low, u32 high)
>>   	__be32 maxspi =3D htonl(high);
>>   	u32 mark =3D x->mark.v&  x->mark.m;
>>
>> +	/* Compression Parameter Index(CPI) is 16bits wide
>> +	 * An 32 bits spi value will hash xfrm_state into wrong hash slot.
>> +	 * When the upper 16bits of spi values is used as CPI for the peer
>> +	 * to look up xfrm state, it would generate XfrmOutNoStates error,
>> +	 * as apparently we are looking for the wrong hash slot.
>> +	 *
>> +	 * So clamp down the spi range into only 16bits valid wide.
>> +	 */
>> +	if (x->id.proto =3D=3D IPPROTO_COMP) {
>> +		minspi =3D htonl(0xc00);
>> +		maxspi =3D htonl(0xff00);
>> +	}
>
> This does not make sense. The spi is chosen based on minspi only
> if minspi is equal to maxspi. This will be never the case for
> IPPROTO_COMP with your patch.
>
> Also, the spi range is user defined, we should respect the
> users configuration if the range is valid.

Ok, then, speaking of respect user defined range, how about below infor=
mal
patch which only check the validity of the range? My original thoughts =
is CPI
is only 16bits wide, kernel itself can keep the CPI's validity. btw, v2=
 will
also fix patch1/3 align issue.

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 6a9c402..2c6fb99 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1507,6 +1507,9 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low,=
 u32 high)

         err =3D -ENOENT;

+       if ((x->id.proto =3D=3D IPPROTO_COMP) && (high > 0xFFFF))
+               goto unlock;
+
         if (minspi =3D=3D maxspi) {
                 x0 =3D xfrm_state_lookup(net, mark, &x->id.daddr, mins=
pi, x->id.proto, x->props.family);
                 if (x0) {

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
