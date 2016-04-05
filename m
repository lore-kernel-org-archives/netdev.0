From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH v2 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Tue, 5 Apr 2016 08:52:12 -0700
Message-ID: <CAKgT0Uc=9MMzSHWgZib5+EwPCQokjSSnC9vfOtWKULvmwUQpdQ@mail.gmail.com>
References: <20160404162545.14332.653.stgit@localhost.localdomain>
	<20160404162818.14332.1076.stgit@localhost.localdomain>
	<20160405034437.GA9322@gondor.apana.org.au>
	<CAKgT0UfcqBUTY1SxawwKdnzS7qW7XggjzpKNcfT3cTSZ9DHMmA@mail.gmail.com>
	<20160405043209.GA9822@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Jesse Gross <jesse@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:33714 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143AbcDEPwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 11:52:14 -0400
Received: by mail-io0-f178.google.com with SMTP id o126so1578620iod.0
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 08:52:13 -0700 (PDT)
In-Reply-To: <20160405043209.GA9822@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 4, 2016 at 9:32 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Mon, Apr 04, 2016 at 09:26:55PM -0700, Alexander Duyck wrote:
>>
>> The problem is right now we are mangling the IP ID for outer headers
>> on tunnels.  We end up totally ignoring the delta between the values
>> so if you have two flows that get interleaved over the same tunnel GRO
>> will currently mash the IP IDs for the two tunnels so that they end up
>> overlapping.
>
> Then it should be fixed.  I never reviewed those patches or I would
> have objected at the time.

The problem is what you are proposing is much larger than I am
comfortable proposing for a net patch so I will probably go back to
targeting net-next.

>> The reason why I keep referencing RFC 6864 is because it specifies
>> that the IP ID field must not be read if the DF bit is set, and that
>> if we are manipulating headers we can handle the IP ID as though we
>> are the transmitting station.  What this means is that if DF is not
>> set we have to have unique values per packet, otherwise we can ignore
>> the values if DF is set.
>
> As I said GRO itself should not be visible.  The fact that it is
> for tunnels is a bug.

Right.  But the fact that we are even trying to get reliable data out
of IP ID is also a bug.  The fact is the IP ID isn't going to be
linear in the case of tunnels.  There is a good liklihood that the IP
ID will jump around if we are doing encapsulation using a third party
device such as a switch.  That was one of the reasons why my first
implementation just completely ignored the IP ID in the case that the
DF bit is set.  Honestly I am leaning more toward taking the approach
of going back to that implementation and adding a sysctl that would
let you disable it.  Maybe something like net.ipv4.gro.rfc6864 since
that is the RFC that spells out that we should treat IP ID as a
floating input/output if DF is set.  Basically we need to be able to
do that if the GSO partial code is going to work.

>> The question I would have is what are you really losing with increment
>> from 0 versus fixed 0?  From what I see it is essentially just garbage
>> in/garbage out.
>
> GRO is meant to be lossless, that is, you should not be able to
> detect its presence from the outside.  If you lose information then
> you're breaking this rule and people will soon start asking for it
> to be disabled in various situations.

Right.  But in this case we technically aren't losing information.
That is the thing I have been trying to point out with RFC 6864.  It
calls out that you MUST not read IP ID if the DF bit is set.

> I'm not against doing this per se but it should not be part of the
> default configuration.

I disagree I think it will have to be part of the default
configuration.  The problem is the IP ID is quickly becoming
meaningless.  When you consider that a 40Gb/s link can wrap the IP ID
value nearly 50 times a second using a 1500 MTU the IP ID field should
just be ignored anyway because you cannot guarantee that it will be
unique without limiting the Tx window size.  That was the whole point
of RFC6864.  Basically the IP ID field is so small that as we push
into the higher speeds you cannot guarantee that the field will have
any meaning so for any case where you don't need to use it you
shouldn't because it will likely not provide enough useful data.

- Alex
