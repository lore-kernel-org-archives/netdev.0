From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next 0/2] netfilter: IPv4/v6 IPcomp match support
Date: Tue, 24 Dec 2013 14:19:57 +0800
Message-ID: <52B9278D.4020905@windriver.com>
References: <1386937082-30412-1-git-send-email-fan.du@windriver.com> <20131217130555.GA8874@localhost> <52B26841.40800@windriver.com> <20131220090419.GA5661@localhost> <52B40C01.7070406@windriver.com> <20131223121337.GA5373@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <steffen.klassert@secunet.com>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20131223121337.GA5373@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2013=E5=B9=B412=E6=9C=8823=E6=97=A5 20:13, Pablo Neira Ayuso wrote:
> Hi,
>
> On Fri, Dec 20, 2013 at 05:21:05PM +0800, Fan Du wrote:
> [...]
>>> AH is not the last header, so we still have to use ipv6_find_hdr() =
to
>>> find the good header instead of par->thoff. Note that the ip6_table=
s
>>> sets par->thoff to the last IPv6 extension header.
>>
>> I'm quite new to the internal of netfiler, especially about this par=
t.
>> I will take a look at the code later.
>>
>>> This rises some concerns regarding your ipcomp, I think that if you
>>> use this with ah and esp, the ordering of the headers is
>>> ah+ipcomp+esp, right?
>>
>> This depends on the user land configuration of encapsulation order.
>> It can be one of the three types only(ah, esp, ipcomp), the most com=
monly
>> used is ah(outer)+esp(inner).
>>
>> I barely see ipcomp used in production, but I remember RFC says ipco=
mp
>> should be done first before esp, because after encryption in esp, th=
e data
>> is polluted, i.e., not suitable for compressed anymore(I'm not sure =
the
>> details theory behind this statement.)
>
> In that case we have to use ipv6_find_hdr(..., IPPROTO_IPCOMP, ...),
> since par->thoff will point to the last header which is esp. After
> this change, the ipcomp ipv6 match will look very similar to what you
> have in ah_mt6(...) in net/ipv6/netfilter/ip6t_ah.c. Please, rework
> that in your ipcomp match patch and resend. Thanks.
>

Hi Pablo

I think we don't need to rework this patch set back to v1 by using ipv6=
_find_hdr
for IPv6 part, because IPcomp shared the same characteristic as esp, th=
at's hiding
upper layer protocol.

=46or a packet encapsulated in order of ah->esp->ah->original packet, a=
s you said
par->thoff is set at esp, that's why netfilter esp has a unified implem=
entation
in net/netfilter/xt_esp.c, because it's always the last parse header ne=
tfilter
can reach.

The same rule apply with IPcomp, for example,
(1) ah->ipcomp->original packet
          ^par->thoff
(2) ipcomp->ah->original packet
       ^par->thoff

Both cases (1) and (2) par->thoff can only point into IPcomp header, so=
 in such
circumstance, a unified implementation for both IPv4/6 is feasible, and=
 I have
tested (2) in such implementation, it works anyway.

IMO, a unified implementation suggested by you previous is ok for this =
round review.


--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
