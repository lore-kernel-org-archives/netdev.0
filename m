From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next] {selinux, af_key} Rework pfkey_sadb2xfrm_user_sec_ctx
Date: Thu, 17 Oct 2013 09:34:53 +0800
Message-ID: <525F3EBD.80406@windriver.com>
References: <1381904114-29556-1-git-send-email-fan.du@windriver.com> <1541456.gnvYckRYYL@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:41622 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761285Ab3JQBhC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 21:37:02 -0400
In-Reply-To: <1541456.gnvYckRYYL@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B410=E6=9C=8816=E6=97=A5 23:15, Paul Moore wrote:
> On Wednesday, October 16, 2013 02:15:14 PM Fan Du wrote:
>> Taking advantages of sadb_x_sec_ctx and xfrm_user_sec_ctx share the =
same
>> structure arrangement, rework pfkey_sadb2xfrm_user_sec_ctx by castin=
g
>> sadb_x_sec_ctx into xfrm_user_sec_ctx with minor len fix.
>>
>> Then we can:
>>   -Avoid kmalloc/free memory for xfrm_user_sec_ctx, sadb_x_sec_ctx w=
ould be
>>    fine.
>>   -Fix missing return value check bug for pfkey_compile_policy when
>>    kmalloc fails
>>
>> Signed-off-by: Fan Du<fan.du@windriver.com>
>> ---
>>   net/key/af_key.c |   33 +--------------------------------
>>   1 file changed, 1 insertion(+), 32 deletions(-)
>>
>> diff --git a/net/key/af_key.c b/net/key/af_key.c
>> index 9d58537..c7d304d 100644
>> --- a/net/key/af_key.c
>> +++ b/net/key/af_key.c
>> @@ -435,22 +435,9 @@ static inline int verify_sec_ctx_len(const void=
 *p)
>>
>>   static inline struct xfrm_user_sec_ctx *pfkey_sadb2xfrm_user_sec_c=
tx(const
>> struct sadb_x_sec_ctx *sec_ctx) {
>> -	struct xfrm_user_sec_ctx *uctx =3D NULL;
>> -	int ctx_size =3D sec_ctx->sadb_x_ctx_len;
>> -
>> -	uctx =3D kmalloc((sizeof(*uctx)+ctx_size), GFP_KERNEL);
>> -
>> -	if (!uctx)
>> -		return NULL;
>> +	struct xfrm_user_sec_ctx *uctx =3D (struct xfrm_user_sec_ctx *)sec=
_ctx;
>>
>>   	uctx->len =3D pfkey_sec_ctx_len(sec_ctx);
>> -	uctx->exttype =3D sec_ctx->sadb_x_sec_exttype;
>> -	uctx->ctx_doi =3D sec_ctx->sadb_x_ctx_doi;
>> -	uctx->ctx_alg =3D sec_ctx->sadb_x_ctx_alg;
>> -	uctx->ctx_len =3D sec_ctx->sadb_x_ctx_len;
>> -	memcpy(uctx + 1, sec_ctx + 1,
>> -	       uctx->ctx_len);
>> -
>>   	return uctx;
>>   }
>
> The fact that you are now changing sadb_x_sec_ctx->sadb_x_sec_len whe=
never
> pfkey_sadb2xfrm_user_sec_ctx() is called raises an eyebrow.  Can you =
elaborate
> on why this is not a problem?
>
Thanks for your attention, Paul.

sadb_x_sec_ctx is extra headers passed down from user space, the usage =
of
of this data structure falls down to one of pfkey_funcs function only f=
or
one time, more specifically speaking, it's only used by SELINUX for sec=
urity
checking for each operation. In other words, sadb_x_sec_ctx involves wi=
th a
one shot business here. So the original codes seems do a lots of extra =
job
which could easily be avoid using casting operation.

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
