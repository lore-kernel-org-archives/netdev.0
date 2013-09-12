From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH] ipv6: Do route updating for redirect in ndisc layer
Date: Wed, 11 Sep 2013 21:16:52 -0400
Message-ID: <52311604.6080507@redhat.com>
References: <522D7444.20505@cn.fujitsu.com> <20130910225023.GB4794@order.stressinduktion.org> <52301603.7030906@cn.fujitsu.com> <20130911231721.GA24195@order.stressinduktion.org>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>, davem@davemloft.net,
	netdev@vger.kernel.org, dborkman@redhat.com, vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56034 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750974Ab3ILBRN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Sep 2013 21:17:13 -0400
In-Reply-To: <20130911231721.GA24195@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/11/2013 07:17 PM, Hannes Frederic Sowa wrote:
> [added Cc to Daniel and Vlad because of ipv6/sctp/redirect problem]
>
> On Wed, Sep 11, 2013 at 03:04:35PM +0800, Duan Jiong wrote:
>> =E4=BA=8E 2013=E5=B9=B409=E6=9C=8811=E6=97=A5 06:50, Hannes Frederic=
 Sowa =E5=86=99=E9=81=93:
>>> On Mon, Sep 09, 2013 at 03:09:56PM +0800, Duan Jiong wrote:
>>>> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
>>>> index 5c71501..61fe8e5 100644
>>>> --- a/net/ipv6/tcp_ipv6.c
>>>> +++ b/net/ipv6/tcp_ipv6.c
>>>> @@ -382,14 +382,6 @@ static void tcp_v6_err(struct sk_buff *skb, s=
truct inet6_skb_parm *opt,
>>>>
>>>>   	np =3D inet6_sk(sk);
>>>>
>>>> -	if (type =3D=3D NDISC_REDIRECT) {
>>>> -		struct dst_entry *dst =3D __sk_dst_check(sk, np->dst_cookie);
>>>> -
>>>> -		if (dst)
>>>> -			dst->ops->redirect(dst, sk, skb);
>>>> -		goto out;
>>>> -	}
>>>> -
>>>
>>> You dropped the "goto out" here in case of an NDISC_REDIRECT, so th=
is sends an
>>> EPROTO further up the socket layer. Was this intended?
>>>
>>
>> I'm sorry, i didn't notice the variable err was assigned to EPROTO.
>> I only thought that message should be sent to the socket layer, beca=
use
>> i found that in function sctp_v6_err().
>>
>> In addition, the rfc 4443 said the Redirect Message is not the ICMPv=
6 Error
>> Message, so i think we shouldn't call those err_handler function, in=
 other
>> words we shouldn't call the icmpv6_notify().
>>
>> How do you think of this?
>
> Hm, thats hard.
>
> First of, when the kernel started publishing these errors it had a
> contract with user-space we cannot break now. This includes all error
> handling functions which call ipv6_icmp_error. So we only have to car=
e
> about INET6_PROTO_FINAL protocols, bbecause they mostly operate in so=
cket
> space (in this case these are the raw and the udp protocol and curren=
tly
> sctp). Especially I do think it is important to report the redirects
> to raw sockets. The other non-final protocols only need to be notifie=
d
> for mtu reduction currently. Maybe we could stop notifying non-final
> protocols for redirects, but I don't think this will improve things.
>
> Also we cannot know if the router sending the redirect discarded the
> original packet or if it forwarded it just notifying us of a better r=
oute,
> so we don't know if an actual error happend. So I would do the same t=
hing
> as IPv4 sockets, set sk_err to zero and queue up the icmp packet on t=
he
> socket's error queue (for udp and raw).
>
> Regarding notifying tcp sockets about the redirect seems wrong. It wo=
uld
> generate a poll notification and I do think it could even tear down
> the whole connection.  I guess sctp should also stop updating sk_err
> on redirects.  But let's Cc Daniel and Vlad about this. My guess is t=
hat
> sctp could go into some error recovery mode because of this which wou=
ld
> be wrong.

You are right.  SCTP shouldn't be setting sk_err on redirects as it
isn't an error condition.  it should be doing exactly what tcp is doing=
=20
and leaving the error handler without touching the socket.

Thanks
-vlad

>
> So, for this patch I would leave the logic as is and not change anyth=
ing
> at the error reporting. Maybe Daniel and Vlad could check if we shoul=
d
> suppress redirect information for ipv6 in sctp, too? But this should
> go into another patch.  Regarding the EPROTO problem in raw and udp,
> let's see if all the problems go away if we update icmpv6_err_convert
> to set *err to 0.
>
> Greetings,
>
>    Hannes
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
