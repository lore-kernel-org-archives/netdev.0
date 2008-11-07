From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] net: introduce read_pnet() and write_pnet() functions
Date: Fri, 7 Nov 2008 21:07:38 +0300
Message-ID: <20081107180738.GA3657@x200.localdomain>
References: <49146265.8040301@cosmosbay.com> <20081107174100.GA3469@x200.localdomain> <49147FAC.8070306@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.178]:2878 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbYKGSET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 13:04:19 -0500
Received: by ik-out-1112.google.com with SMTP id c29so1159624ika.5
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2008 10:04:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <49147FAC.8070306@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 07, 2008 at 06:49:32PM +0100, Eric Dumazet wrote:
> Alexey Dobriyan a =E9crit :
>> On Fri, Nov 07, 2008 at 04:44:37PM +0100, Eric Dumazet wrote:
>>> CONFIG_NET_NS is not a widespread option, we can reduce kernel size
>>> not declaring useless "struct net" pointers in several structures.
>>
>> This can be done separatedly for each offending "struct net *".
>
> Sure I can split the patch if you think its too complex. I also can l=
eave
> #ifdef CONFIG_NET_NS all over if you like them.
>
>>
>>> This patch declares three helper to clean various "ifdef CONFIG_NET=
_NS"
>>> that we have in many places.
>>
>> There is an implicit assumption, that all such ifdefs are bad, while=
 if fact
>> there are nothing wrong with them:
>
> Well... we can hide the ugly details.
>
> Especially with #ifdef in C files.

They are ugly when embedded in C if/else constructs, like this:

	const struct user_regset_view *task_user_regset_view(struct task_struc=
t *task)
	{
	#ifdef CONFIG_IA32_EMULATION
	        if (test_tsk_thread_flag(task, TIF_IA32))
	#endif
	#if defined CONFIG_X86_32 || defined CONFIG_IA32_EMULATION
	                return &user_x86_32_view;
	#endif
	#ifdef CONFIG_X86_64
	        return &user_x86_64_view;
	#endif
	}

>> 	#ifdef CONFIG_NET_NS
>> 		struct net *ct_net;
>> 	#endif
>>
>>> #ifdef CONFIG_NET_NS
>>>
>>> #define DECLARE_PNET(name) struct net *name;
>>
>> One more macro, instead of immediately understandable thing.
>
> DECLARE_PNET() ?
> Did you check DECLARE_RWSEM, DECLARE_WAITQUEUE, DECLARE_PER_CPU,=20
> DECLARE_BITMAP ... ???

Yes, DECLARE_PNET. The rest exists because of complex initialization
sometimes dependent on debugging options which all users would have
zero chance to fill correctly. struct net is one C assignment regardles
of anything.

>>> static inline void write_pnet(struct net **pnet, struct net *net)
>>> {
>>>        *pnet =3D net;
>>> }
>>>
>>> static inline struct net *read_pnet(struct net * const *pnet)
>>> {
>>>        return *pnet;
>>> }
>>> #else
>>>
>>> #define DECLARE_PNET(name)
>>> #define write_pnet(pnet, net)   do { (void)(net);} while (0)
>>> #define read_pnet(pnet)         (&init_net)
>>>
>>> #endif
>>>
>>> In particular, using these helpers permits a shrink of inet_bind_bu=
cket
>>> (16 bytes instead of 32 on 32bit arches, and 32 bytes instead of 64=
 on 64bits)
>>
>> Why not just fix exactly bind bucket issue.
>
> Another #ifdef ?=20

Another localized ifdef in header.

>> As I posted earlier, ->dst_net can go after IPv6 dst_ops can be embe=
dded
>> directly into struct netns_ipv6, but header dependencies aren't triv=
ial.
>>
>> As for netns comparisons, use net_eq() to amortize the cost somewhat=
=2E
>>
>>
>
> I believe all "struct net*" parameter passing could disappear with ap=
propriate macros.
>
> This stuff currently eat a precious register on i386/x86_64/... archi=
tectures.

BTW, it'd be nice to check with current most popupar netdev benchmark :=
-)
