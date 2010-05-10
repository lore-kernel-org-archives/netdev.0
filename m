From: Bijay Singh <Bijay.Singh@guavus.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Mon, 10 May 2010 14:55:40 +0000
Message-ID: <D1C2B1EC-ABE8-4D87-9227-6D0F1C1C8B77@guavus.com>
References: <1273085598.2367.233.camel@edumazet-laptop>
 <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
 <1273147586.2357.63.camel@edumazet-laptop>
 <20100506.220443.135536330.davem@davemloft.net>
 <1273210329.2222.42.camel@edumazet-laptop> <20100507101451.1b4286b7@nehalam>
 <1273252893.2261.84.camel@edumazet-laptop> <20100507103639.4f1a51fa@nehalam>
 <1273268446.2325.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	"<bhaskie@gmail.com>" <bhaskie@gmail.com>,
	"<bhutchings@solarflare.com>" <bhutchings@solarflare.com>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [204.232.241.167] ([204.232.241.167]:46861 "EHLO mx1.guavus.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751955Ab0EJOzn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 10:55:43 -0400
In-Reply-To: <1273268446.2325.53.camel@edumazet-laptop>
Content-Language: en-US
Content-ID: <9750f442-a2ea-49fd-8342-6d4274a494d0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I had noticed the corruption in the context and actually did what is me=
ntioned.

I allocated the context on the stack and plugged in the md5.c functions=
=2E I was able to temporarily solve the problem, all this before I got =
a response on this thread.

But now I have seeing another problem, when i change the MTU on the int=
erface from 1500 to 4470 none of the message from the peer get thru and=
 I get hash failed message. I am wondering if this is another bug getti=
ng hit in this scenario.

Regards,
Bijay

On 08-May-2010, at 3:10 AM, Eric Dumazet wrote:

> Le vendredi 07 mai 2010 =E0 10:36 -0700, Stephen Hemminger a =E9crit =
:
>> On Fri, 07 May 2010 19:21:33 +0200
>> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>=20
>>> Le vendredi 07 mai 2010 =E0 10:14 -0700, Stephen Hemminger a =E9cri=
t :
>>>=20
>>>> Forget the per cpu data; the pool should just be scrapped.
>>>>=20
>>>> The only reason the pool exists is that the crypto hash state whic=
h
>>>> should just be moved into the md5_info (88 bytes).  The pseudo
>>>> header can just be generated on the stack before passing to the cr=
ypto
>>>> code.
>>>=20
>>>=20
>>> Sure, but I'm afraid there is no generic API do do that (if we want=
 to
>>> reuse crypto/md5.c code).
>>=20
>> It looks like the pool is just an optimization to avoid opening too
>> many crypto API connections.  This should only be an issue if offloa=
ding
>> MD5.
>=20
> You mean we could allocate two contexts per socket, one for tx path, =
one
> for rx path, but TCP-MD5 implementors chose to use percpu allocations=
 to
> factorize them. They should have allocated two contexts per cpu (one =
for
> process context, preemption disabled, one for BH context)
>=20
> As you said, this could be allocated on stack, with some changes to
> crypto API I guess. Since TCP is not a module, md5 is also static, so
> there is no module loading involved.
>=20
> struct crypto_tfm *__crypto_alloc_tfm(struct crypto_alg *alg, u32
> type,u32 mask)
>=20
> -->
>=20
> struct crypto_tfm *__crypto_alloc_tfm_onstack(struct crypto_alg *alg,
> u32 type, u32 mask, void *storage, size_t storage_max_length)
>=20
>=20
> Or a direct plug to crypto/md5.c functions and hand crafted context.
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

