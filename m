From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC][PATCH] Turn part of SNMP accounting macros into functions
Date: Thu, 28 Aug 2008 14:51:20 +0200
Message-ID: <48B69F48.5050308@cosmosbay.com>
References: <48B5815D.4010005@openvz.org> <48B589B5.7050303@cosmosbay.com> <48B68827.2060105@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.151]:28392 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752151AbYH1Mv1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 08:51:27 -0400
In-Reply-To: <48B68827.2060105@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov a =E9crit :
> Eric Dumazet wrote:
>>
>> I dont know, but passing all those "struct net *net" to every=20
>> network function in the kernel sounds overkill, especially for
>> !CONFIG_NET_NS users. This is pure bloat.
>>
>> We could define two macros so that function prototypes dont include
>> useless pointers, especially on arches where only first and second
>> parameter is passed in eax and edx register ;)
>>
>> #ifdef CONFIG_NET_NS
>> # define VNETPTR ,struct net *net
>> # define NETPTR  net
>> #else
>> # define VNETPTR
>> # defint NETPTR  &init_net
>> #endif
>>
>> ...
>> void TCP_DEC_STATS(int field VNETPTR);
>> ...
>> void TCP_DEC_STATS(int field VNETPTR)
>> {
>> 	SNMP_DEC_STATS((NETPTR)->mib.tcp_statistics, field);
>> }
>> ...
>=20
> I agree with this, but I've checked whether compiling out the first a=
rgument
> of XXX_STATS would help and found out that there's almost no differen=
ce (-9
> bytes) in the net/ipv4/built-in.o for NET_NS=3Dn case.=20
>=20
> After turning the macros into functions, compiling the first argument=
 out gives
> us 500 more bytes out. Good catch, but I have a question - the way yo=
u proposed
> to implement the function itself is rather nice, but how would you im=
plement
> the *call* to that function in order to make it variable-arguments de=
pending on
> the config option?
>=20
> I see the similar way:
>=20
> +#ifdef CONFIG_NET_NS
> +#define NET_ARG(net) net,
> +#else
> +#define NET_ARG(net)
> +#endif
> ...
> -	TCP_INC_STATS(sock_net(sk), field);
> +	TCP_INC_STATS(NET_ARG(sock_net(sk) field);
>=20
> but do these 500 bytes compensate for this ugly style?

500 bytes here, but what about other uses in kernel ?

Sometime I wonder if a *global* pointer ('current' pointer for example =
is not passed to every kernel function that want access to current stru=
ture) would save many kbytes in vmlinux text. This way, !CONFIG_NET_NS =
overhead would completely vanish.

Oh well...




