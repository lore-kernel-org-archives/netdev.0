From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH v2 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Tue, 5 Apr 2016 09:45:51 -0700
Message-ID: <CAKgT0UcfMeULGsh+EuJ+A1X7n5b6vYdn3eHY=+Ev17=5_cAQXA@mail.gmail.com>
References: <20160404162545.14332.653.stgit@localhost.localdomain>
	<20160404162818.14332.1076.stgit@localhost.localdomain>
	<20160405034437.GA9322@gondor.apana.org.au>
	<CAKgT0UfcqBUTY1SxawwKdnzS7qW7XggjzpKNcfT3cTSZ9DHMmA@mail.gmail.com>
	<20160405043209.GA9822@gondor.apana.org.au>
	<CAKgT0Uc=9MMzSHWgZib5+EwPCQokjSSnC9vfOtWKULvmwUQpdQ@mail.gmail.com>
	<1459873806.6473.358.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Jesse Gross <jesse@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:35391 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615AbcDEQpw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 12:45:52 -0400
Received: by mail-io0-f179.google.com with SMTP id g185so25775607ioa.2
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 09:45:52 -0700 (PDT)
In-Reply-To: <1459873806.6473.358.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 5, 2016 at 9:30 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> On Tue, 2016-04-05 at 08:52 -0700, Alexander Duyck wrote:
>
>>
>> I disagree I think it will have to be part of the default
>> configuration.  The problem is the IP ID is quickly becoming
>> meaningless.  When you consider that a 40Gb/s link can wrap the IP I=
D
>> value nearly 50 times a second using a 1500 MTU the IP ID field shou=
ld
>> just be ignored anyway because you cannot guarantee that it will be
>> unique without limiting the Tx window size.  That was the whole poin=
t
>> of RFC6864.  Basically the IP ID field is so small that as we push
>> into the higher speeds you cannot guarantee that the field will have
>> any meaning so for any case where you don't need to use it you
>> shouldn't because it will likely not provide enough useful data.
>
> Just because a few flows reach 40Gbit , we should remind that vast
> majority of the Internet runs with < 50Mbits flows.
>
> I prefer the argument of IPv6 not having ID ;)

Okay, maybe I'll try to use that argument more often then.. :-)

> We should do our best to keep interoperability, this is the selling
> point.
>
> And quite frankly your last patch makes perfect sense to me :

Yes.  It was a compromise, though I might still have to go through and
refine it more.  It might make sense for the IP header associated with
the TCP flow, but for outer headers it actually is worse because we
end up blocking several different possibilities.  What I might need to
do is capture the state of the DF bit as we work a flow up through the
stack and once it is in the list of GRO SKBs use that DF bit as a flag
to indicate if we support a incrementing or fixed pattern for the
values.  That way tunnels can optionally ignore the IP ID if the DF
bit is set since their values may not be as clean as that of TCP.

> The aggregation is done only if the TCP headers of consecutive packet=
s
> matches. So who cares of IPv4 ID really ?
> This is a very minor detail. The possible gains outperform the
> theoretical 'problem'
>
> GRO already reorder flows, it never had a guarantee of being '=C3=ADn=
visible'
> as Herbert claims.

I can see what he is trying to get at.  I just think it is a bit too
strict on the interpretation of what values have to be maintained.  My
plan going forward is to add a sysctl that will probably allow us some
wiggle room in regards to IP ID for GRO and GSO so that when it is
disabled we will not perform GSO partial nor allow for repeating IP ID
in GRO on devices that cannot get the IP ID right.

- Alex
