From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH] netfilter: Fix compiler warning.
Date: Thu, 10 Dec 2009 09:50:43 -0800
Message-ID: <97949e3e0912100950u51f627c9r515d9b69a02430f4@mail.gmail.com>
References: <pvmhbrzboyb.fsf@chavey.mtv.corp.google.com> <4B207840.7080603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B207840.7080603@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 9, 2009 at 8:25 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le 10/12/2009 02:25, chavey@google.com a =E9crit :
>> Fix compiler warning "discards qualifiers from pointer target type".
>> The function prototype defines parameters as pointer to a constant.
>> Such parameters should not have their content modified in the
>> function.
>>
>> Signed-off-by: Laurent Chavey <chavey@google.com>
>
> This is not the right fix IMHO.
>
> We want an unique timestamp for the whole netfilter matches, because =
several 'time' rules
> could get 'interesting' effects.
>
> The 'const' attribute is a debugging aid, and the skb->tstamp 'write-=
once' is a valid exception.
>
> Read again the comment in time_mt() :

good point.  I  agree with the need for the exception, I would just
like it to be more explicit
in the code itself (like a turn off check around that particular
statement) so we do not have to
scrub thru the compiler output to filter out good / bad warning.
question:
  why do we not force the timestamp in the skb before going thru the
chain ? it looks to me
  that the check for (skb->tstamp.tv64 =3D=3D 0) should be done once
>
> vi +163 net/netfilter/xt_time.c
>
> static bool
> time_mt(const struct sk_buff *skb, const struct xt_match_param *par)
> {
> =A0 =A0 =A0 =A0const struct xt_time_info *info =3D par->matchinfo;
> =A0 =A0 =A0 =A0unsigned int packet_time;
> =A0 =A0 =A0 =A0struct xtm current_time;
> =A0 =A0 =A0 =A0s64 stamp;
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * We cannot use get_seconds() instead of __net_timest=
amp() here.
> =A0 =A0 =A0 =A0 * Suppose you have two rules:
> =A0 =A0 =A0 =A0 * =A0 =A0 =A01. match before 13:00
> =A0 =A0 =A0 =A0 * =A0 =A0 =A02. match after 13:00
> =A0 =A0 =A0 =A0 * If you match against processing time (get_seconds) =
it
> =A0 =A0 =A0 =A0 * may happen that the same packet matches both rules =
if
> =A0 =A0 =A0 =A0 * it arrived at the right moment before 13:00.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (skb->tstamp.tv64 =3D=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__net_timestamp((struct sk_buff *)skb)=
;
>
>
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
