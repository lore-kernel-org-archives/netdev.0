From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [RFC][PATCH] Turn part of SNMP accounting macros into functions
Date: Thu, 28 Aug 2008 15:12:39 +0400
Message-ID: <48B68827.2060105@openvz.org>
References: <48B5815D.4010005@openvz.org> <48B589B5.7050303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56466 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751677AbYH1LMz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2008 07:12:55 -0400
In-Reply-To: <48B589B5.7050303@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Pavel Emelyanov a =E9crit :
>> After turning IP_XXX_STATS, TCP_XXX_STATS and NET_XXX_STATS from
>> macros into functions the net/ipv4/built-in.o shrank significantly:
>>
>> add/remove: 14/0 grow/shrink: 0/67 up/down: 482/-2246 (-1764)
>>
>> Turning the CONFIG_NET_NS option on makes this shrink even larger:
>>
>> add/remove: 14/0 grow/shrink: 0/67 up/down: 478/-2646 (-2168)
>>
>> So the question is - what was the reason to keep those as macros?
>> I thought about the possible performance questions, but netperf
>> didn't show any (I admit I just cannot cook it properly).
>>
>> The sample patch is here, but it's not good (EXPORTs for ipv6
>> and a better place for functions rather than net/ipv4/af_inet.c
>> are required).
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>>
>=20
>=20
> I dont know, but passing all those "struct net *net" to every=20
> network function in the kernel sounds overkill, especially for
> !CONFIG_NET_NS users. This is pure bloat.
>=20
> We could define two macros so that function prototypes dont include
> useless pointers, especially on arches where only first and second
> parameter is passed in eax and edx register ;)
>=20
> #ifdef CONFIG_NET_NS
> # define VNETPTR ,struct net *net
> # define NETPTR  net
> #else
> # define VNETPTR
> # defint NETPTR  &init_net
> #endif
>=20
> ...
> void TCP_DEC_STATS(int field VNETPTR);
> ...
> void TCP_DEC_STATS(int field VNETPTR)
> {
> 	SNMP_DEC_STATS((NETPTR)->mib.tcp_statistics, field);
> }
> ...

I agree with this, but I've checked whether compiling out the first arg=
ument
of XXX_STATS would help and found out that there's almost no difference=
 (-9
bytes) in the net/ipv4/built-in.o for NET_NS=3Dn case.=20

After turning the macros into functions, compiling the first argument o=
ut gives
us 500 more bytes out. Good catch, but I have a question - the way you =
proposed
to implement the function itself is rather nice, but how would you impl=
ement
the *call* to that function in order to make it variable-arguments depe=
nding on
the config option?

I see the similar way:

+#ifdef CONFIG_NET_NS
+#define NET_ARG(net) net,
+#else
+#define NET_ARG(net)
+#endif
=2E..
-	TCP_INC_STATS(sock_net(sk), field);
+	TCP_INC_STATS(NET_ARG(sock_net(sk) field);

but do these 500 bytes compensate for this ugly style?
