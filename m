From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] Question about potential problem in net/ipv4/route.c
Date: Thu, 12 Oct 2006 07:48:20 +0200
Message-ID: <452DD724.4030502@cosmosbay.com>
References: <20061011090504.GC2938@mellanox.co.il>
 <20061011.022015.63051509.davem@davemloft.net>
 <200610111511.19028.dada1@cosmosbay.com>
 <20061011.220506.76273501.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604003mt.neufgp.fr ([84.96.92.56]:21423 "EHLO smTp.neuf.fr")
	by vger.kernel.org with ESMTP id S1161374AbWJLFsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 01:48:17 -0400
Received: from [192.168.30.203] ([88.137.140.131]) by sp604003mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0J7000MWXDGFX281@sp604003mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Thu, 12 Oct 2006 07:48:16 +0200 (CEST)
In-reply-to: <20061011.220506.76273501.davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 11 Oct 2006 15:11:18 +0200
>=20
>> Using memcmp(ptr1, ptr2, sizeof(SOMEFIELD)) is dangerous because=20
>> sizeof(SOMEFIELD) can be larger than the underlying object, because =
of=20
>> alignment constraints.
>>
>> In this case, sizeof(fl1->nl_u.ip4_u) is 16, while fl1->nl_u.ip4_u i=
s :
>>
>>                 struct {
>>                         __u32                   daddr;
>>                         __u32                   saddr;
>>                         __u32                   fwmark;
>>                         __u8                    tos;
>>                         __u8                    scope;
>>                 } ip4_u;
>>
>> So 14 bytes are really initialized, and 2 padding bytes might contai=
n random=20
>> values...
>=20
> We always explicitly initialize the flows, and even for local stack
> assignment based initialization, gcc zeros out the padding bytes
> always.  For non-stack-local cases we do explicit memset()'s over the
> entire object.  So I think while not perfect, we're very much safe
> here.
>=20

Not on my gcc here (gcc version 3.4.4) : It wont zeros out the padding =
bytes

# cat bug.c
struct s1 {
     long d;
     char c;
};

void bar()
{
struct s1 s =3D { .d =3D 123, .c =3D 'a'};
foo(&s, sizeof(s));
}
# gcc -O2 -S bug.c
# more bug.s
=2Eglobl bar
         .type   bar, @function
bar:
=2ELFB2:
         subq    $24, %rsp
=2ELCFI0:
         movl    $16, %esi
         xorl    %eax, %eax
         movq    %rsp, %rdi
         movq    $123, (%rsp)
         movb    $97, 8(%rsp)
         call    foo
         addq    $24, %rsp
         ret

So 9(%rsp) -> 15(%rsp) are not initialized

Same on more recent gcc (4.1.1)

>> fast comparison, we should do some clever long/int XOR operations to=
 avoid=20
>> many test/branches, like the optim we did in compare_ether_addr())
>>
>> As shown in profiles, "repz cmpsb" is really a dog... (and its use o=
f=20
>> esi/edi/ecx registers a high pressure for the compiler/optimizer)
>=20
> Yes, for the fast comparisons it is almost certainly worth it to do
> something saner in compare_keys().
>=20
> But looking at this further, compare_keys() is only used in hotpath
> situations where we are optimizing for a miss, such as during hash
> insert.  The optimization therefore might be less justified as a
> result.

Well, on this machine I have these oprofile numbers :

<rt_intern_hash>: /* rt_intern_hash total: 993464  0.3619 */

  31751  0.0116 :ffffffff803e8d26:   repz cmpsb %es:(%rdi),%ds:(%rsi)
433438  0.1579 :ffffffff803e8d28:   jne    ffffffff803e8f80 <rt_intern_=
hash+0x310>

Eric



