From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net] netlink: use jhash as hashfn for rhashtable
Date: Mon, 8 Dec 2014 09:20:06 -0800
Message-ID: <CAA93jw5bAqxbpxyOHEHd6XSEn4-HK0a9qw3Cb_Vecb8Nz=xbfg@mail.gmail.com>
References: <1418056230-8700-1-git-send-email-dborkman@redhat.com>
	<1418057780.29477.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Thomas Graf <tgraf@suug.ch>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:40580 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477AbaLHRUH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 12:20:07 -0500
Received: by mail-oi0-f49.google.com with SMTP id i138so3658306oig.22
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2014 09:20:06 -0800 (PST)
In-Reply-To: <1418057780.29477.12.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 8, 2014 at 8:56 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Mo, 2014-12-08 at 17:30 +0100, Daniel Borkmann wrote:
>> For netlink, we shouldn't be using arch_fast_hash() as a hashing
>> discipline, but rather jhash() instead.

I am not particularly happy with the amount of entropy in

static inline u32 ipv6_addr_hash(const struct in6_addr *a)
{
#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG =3D=
=3D 64
        const unsigned long *ul =3D (const unsigned long *)a;
        unsigned long x =3D ul[0] ^ ul[1];

        return (u32)(x ^ (x >> 32));
#else
        return (__force u32)(a->s6_addr32[0] ^ a->s6_addr32[1] ^
                             a->s6_addr32[2] ^ a->s6_addr32[3]);
#endif
}

is this worth improving somehow?

>> Since netlink sockets can be opened by any user, a local attacker
>> would be able to easily create collisions with the DPDK-derived
>> arch_fast_hash(), which trades off performance for security by
>> using crc32 CPU instructions on x86_64.
>>
>> While it might have a legimite use case in other places, it should
>> be avoided in netlink context, though. As rhashtable's API is very
>> flexible, we could later on still decide on other hashing discipline=
s,
>> if legitimate.
>>
>> Reference: http://thread.gmane.org/gmane.linux.kernel/1844123
>> Fixes: e341694e3eb5 ("netlink: Convert netlink_lookup() to use RCU p=
rotected hash table")
>> Cc: Herbert Xu <herbert@gondor.apana.org.au>
>> Cc: Thomas Graf <tgraf@suug.ch>
>> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>  net/netlink/af_netlink.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
>> index 0007b81..b6bf8e8 100644
>> --- a/net/netlink/af_netlink.c
>> +++ b/net/netlink/af_netlink.c
>> @@ -3130,7 +3130,7 @@ static int __init netlink_proto_init(void)
>>               .head_offset =3D offsetof(struct netlink_sock, node),
>>               .key_offset =3D offsetof(struct netlink_sock, portid),
>>               .key_len =3D sizeof(u32), /* portid */
>> -             .hashfn =3D arch_fast_hash,
>> +             .hashfn =3D jhash,
>>               .max_shift =3D 16, /* 64K */
>>               .grow_decision =3D rht_grow_above_75,
>>               .shrink_decision =3D rht_shrink_below_30,
>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>
> In net-next, some time soon, we should try to let all function pointe=
rs
> to jhash() use one non-inline version. The other arch_fast_hash patch
> adds __jhash for x86-only, we can move it over to lib/.
>
> Thanks,
> Hannes
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Dave T=C3=A4ht

http://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
