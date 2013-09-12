From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] ipv6: Do route updating for redirect in ndisc layer
Date: Thu, 12 Sep 2013 14:07:05 +0200
Message-ID: <5231AE69.4050704@redhat.com>
References: <522D7444.20505@cn.fujitsu.com> <20130910225023.GB4794@order.stressinduktion.org> <52301603.7030906@cn.fujitsu.com> <20130911231721.GA24195@order.stressinduktion.org> <52311604.6080507@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Duan Jiong <duanj.fnst@cn.fujitsu.com>, davem@davemloft.net,
	netdev@vger.kernel.org, vyasevich@gmail.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27846 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753093Ab3ILMHY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 08:07:24 -0400
In-Reply-To: <52311604.6080507@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2013 03:16 AM, Vlad Yasevich wrote:
> On 09/11/2013 07:17 PM, Hannes Frederic Sowa wrote:
>> [added Cc to Daniel and Vlad because of ipv6/sctp/redirect problem]
>>
>> On Wed, Sep 11, 2013 at 03:04:35PM +0800, Duan Jiong wrote:
>>> =E4=BA=8E 2013=E5=B9=B409=E6=9C=8811=E6=97=A5 06:50, Hannes Frederi=
c Sowa =E5=86=99=E9=81=93:
>>>> On Mon, Sep 09, 2013 at 03:09:56PM +0800, Duan Jiong wrote:
>>>>> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
>>>>> index 5c71501..61fe8e5 100644
>>>>> --- a/net/ipv6/tcp_ipv6.c
>>>>> +++ b/net/ipv6/tcp_ipv6.c
>>>>> @@ -382,14 +382,6 @@ static void tcp_v6_err(struct sk_buff *skb, =
struct inet6_skb_parm *opt,
>>>>>
>>>>>       np =3D inet6_sk(sk);
>>>>>
>>>>> -    if (type =3D=3D NDISC_REDIRECT) {
>>>>> -        struct dst_entry *dst =3D __sk_dst_check(sk, np->dst_coo=
kie);
>>>>> -
>>>>> -        if (dst)
>>>>> -            dst->ops->redirect(dst, sk, skb);
>>>>> -        goto out;
>>>>> -    }
>>>>> -
>>>>
>>>> You dropped the "goto out" here in case of an NDISC_REDIRECT, so t=
his sends an
>>>> EPROTO further up the socket layer. Was this intended?
>>>>
>>>
>>> I'm sorry, i didn't notice the variable err was assigned to EPROTO.
>>> I only thought that message should be sent to the socket layer, bec=
ause
>>> i found that in function sctp_v6_err().
>>>
>>> In addition, the rfc 4443 said the Redirect Message is not the ICMP=
v6 Error
>>> Message, so i think we shouldn't call those err_handler function, i=
n other
>>> words we shouldn't call the icmpv6_notify().
>>>
>>> How do you think of this?
>>
>> Hm, thats hard.
>>
>> First of, when the kernel started publishing these errors it had a
>> contract with user-space we cannot break now. This includes all erro=
r
>> handling functions which call ipv6_icmp_error. So we only have to ca=
re
>> about INET6_PROTO_FINAL protocols, bbecause they mostly operate in s=
ocket
>> space (in this case these are the raw and the udp protocol and curre=
ntly
>> sctp). Especially I do think it is important to report the redirects
>> to raw sockets. The other non-final protocols only need to be notifi=
ed
>> for mtu reduction currently. Maybe we could stop notifying non-final
>> protocols for redirects, but I don't think this will improve things.
>>
>> Also we cannot know if the router sending the redirect discarded the
>> original packet or if it forwarded it just notifying us of a better =
route,
>> so we don't know if an actual error happend. So I would do the same =
thing
>> as IPv4 sockets, set sk_err to zero and queue up the icmp packet on =
the
>> socket's error queue (for udp and raw).
>>
>> Regarding notifying tcp sockets about the redirect seems wrong. It w=
ould
>> generate a poll notification and I do think it could even tear down
>> the whole connection.  I guess sctp should also stop updating sk_err
>> on redirects.  But let's Cc Daniel and Vlad about this. My guess is =
that
>> sctp could go into some error recovery mode because of this which wo=
uld
>> be wrong.
>
> You are right.  SCTP shouldn't be setting sk_err on redirects as it
> isn't an error condition.  it should be doing exactly what tcp is doi=
ng and leaving the error handler without touching the socket.

Yep, probably something like ...

diff --git a/net/sctp/input.c b/net/sctp/input.c
index 5f20686..98b69bb 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -634,8 +634,7 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
                 break;
         case ICMP_REDIRECT:
                 sctp_icmp_redirect(sk, transport, skb);
-               err =3D 0;
-               break;
+               /* Fall through to out_unlock. */
         default:
                 goto out_unlock;
         }
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 4f52e2c..e7b2d4f 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -183,7 +183,7 @@ static void sctp_v6_err(struct sk_buff *skb, struct=
 inet6_skb_parm *opt,
                 break;
         case NDISC_REDIRECT:
                 sctp_icmp_redirect(sk, transport, skb);
-               break;
+               goto out_unlock;
         default:
                 break;
         }

> Thanks
> -vlad
>
>>
>> So, for this patch I would leave the logic as is and not change anyt=
hing
>> at the error reporting. Maybe Daniel and Vlad could check if we shou=
ld
>> suppress redirect information for ipv6 in sctp, too? But this should
>> go into another patch.  Regarding the EPROTO problem in raw and udp,
>> let's see if all the problems go away if we update icmpv6_err_conver=
t
>> to set *err to 0.
>>
>> Greetings,
>>
>>    Hannes
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
