From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: Fix compiler warning.
Date: Thu, 10 Dec 2009 05:25:36 +0100
Message-ID: <4B207840.7080603@gmail.com>
References: <pvmhbrzboyb.fsf@chavey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: chavey@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52489 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932287AbZLJEZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 23:25:37 -0500
In-Reply-To: <pvmhbrzboyb.fsf@chavey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/12/2009 02:25, chavey@google.com a =E9crit :
> Fix compiler warning "discards qualifiers from pointer target type".
> The function prototype defines parameters as pointer to a constant.
> Such parameters should not have their content modified in the
> function.
>=20
> Signed-off-by: Laurent Chavey <chavey@google.com>

This is not the right fix IMHO.

We want an unique timestamp for the whole netfilter matches, because se=
veral 'time' rules
could get 'interesting' effects.

The 'const' attribute is a debugging aid, and the skb->tstamp 'write-on=
ce' is a valid exception.

Read again the comment in time_mt() :

vi +163 net/netfilter/xt_time.c

static bool
time_mt(const struct sk_buff *skb, const struct xt_match_param *par)
{
        const struct xt_time_info *info =3D par->matchinfo;
        unsigned int packet_time;
        struct xtm current_time;
        s64 stamp;

        /*
         * We cannot use get_seconds() instead of __net_timestamp() her=
e.
         * Suppose you have two rules:
         *      1. match before 13:00
         *      2. match after 13:00
         * If you match against processing time (get_seconds) it
         * may happen that the same packet matches both rules if
         * it arrived at the right moment before 13:00.
         */
        if (skb->tstamp.tv64 =3D=3D 0)
                __net_timestamp((struct sk_buff *)skb);

