From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next 3/3] xfrm: Restrict "level use" for IPComp configuration
Date: Fri, 13 Dec 2013 17:16:03 +0800
Message-ID: <52AAD053.8020204@windriver.com>
References: <1385607161-27597-1-git-send-email-fan.du@windriver.com> <1385607161-27597-4-git-send-email-fan.du@windriver.com> <20131209103856.GL31491@secunet.com> <52A67EF7.3070402@windriver.com> <20131210131158.GM31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:47973 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897Ab3LMJQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 04:16:23 -0500
In-Reply-To: <20131210131158.GM31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B412=E6=9C=8810=E6=97=A5 21:11, Steffen Klassert wrote:
> On Tue, Dec 10, 2013 at 10:39:51AM +0800, Fan Du wrote:
>>
>>
>> On 2013=E5=B9=B412=E6=9C=8809=E6=97=A5 18:38, Steffen Klassert wrote=
:
>>>
>>> I think this will make a lot of people unhappy. It was never requir=
ed
>>> to set 'optional' for ipcomp, and I'd bet that most users don't set
>>> it for ipcomp. I understand the problem, but we can't fix it like t=
hat.
>>
>> Instead of making this check, what about wire 'optional' to 1? it do=
esn't
>> breaking existing script.
>
> But it might change what a user expects to happen.
>
>>
>> Do you have any other way to cure this problem other than 'optional'=
=2E
>>
>
> I think the user can 'fix' the problem himself by setting 'optional'.
> This has also the advantage that he is aware about the change. Maybe
> this should be documented somewhere.
>

I suspect adding a WARN in here is not good, so how about below doc loo=
ks
like?


Documentation/networking/ipsec.txt

Here documents known IPsec corner cases which need to be keep in mind w=
hen
deploy various IPsec configuration in real world production environment=
=2E

1. IPcomp: Small IP packet won't get compressed at sender, and failed o=
n
	   policy check on receiver.

Quote from RFC3173:
2.2. Non-Expansion Policy

    If the total size of a compressed payload and the IPComp header, as
    defined in section 3, is not smaller than the size of the original
    payload, the IP datagram MUST be sent in the original non-compresse=
d
    form.  To clarify: If an IP datagram is sent non-compressed, no

    IPComp header is added to the datagram.  This policy ensures saving
    the decompression processing cycles and avoiding incurring IP
    datagram fragmentation when the expanded datagram is larger than th=
e
    MTU.

    Small IP datagrams are likely to expand as a result of compression.
    Therefore, a numeric threshold should be applied before compression=
,
    where IP datagrams of size smaller than the threshold are sent in t=
he
    original form without attempting compression.  The numeric threshol=
d
    is implementation dependent.

Current IPComp implementation is indeed by the book, while as in practi=
ce
when sending non-compressed packet to the peer(whether or not packet le=
n
is smaller than the threshold or the compressed len is large than origi=
nal
packet len), the packet is dropped when checking the policy as this pac=
ket
matches the selector but not coming from any XFRM layer, i.e., with no
security path. Such naked packet will not eventually make it to upper l=
ayer.
The result is much more wired to the user when ping peer with different
payload length.

One workaround is try to set "level use" for each policy if user observ=
ed
above scenario. The consequence of doing so is small packet(uncompresse=
d)
will skip policy checking on receiver.



--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
