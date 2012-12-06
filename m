From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 0/7] Allow to monitor multicast cache event via
 rtnetlink
Date: Thu, 6 Dec 2012 17:49:05 +0000
Message-ID: <20121206174905.GC16122@casper.infradead.org>
References: <50BE56D3.2030704@6wind.com>
 <50BF29DA.7020903@6wind.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B70DA@saturn3.aculab.com>
 <20121205.125453.1457654258131828976.davem@davemloft.net>
 <50C05AC2.1050504@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:43433 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932888Ab2LFRtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 12:49:12 -0500
Content-Disposition: inline
In-Reply-To: <50C05AC2.1050504@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/12 at 09:43am, Nicolas Dichtel wrote:
> Le 05/12/2012 18:54, David Miller a =E9crit :
> >From: "David Laight" <David.Laight@ACULAB.COM>
> >Date: Wed, 5 Dec 2012 11:41:33 -0000
> >
> >>Probably worth commenting that the 64bit items might only be 32bit =
aligned.
> >>Just to stop anyone trying to read/write them with pointer casts.
> >
> >Rather, let's not create this situation at all.
> >
> >It's totally inappropriate to have special code to handle every sing=
le
> >time we want to put 64-bit values into netlink messages.
> >
> >We need a real solution to this issue.
> >
> The easiest way is to update *_ALIGNTO values (maybe we can keep
> NLMSG_ALIGNTO to 4). But I think that many userland apps have these
> values hardcoded and, the most important thing, this may increase
> size of many netlink messages. Hence we need probably to find
> something better.

We can't do this, as you say, ALIGNTO is compiled into all the
binaries.

A simple backwards compatible workaround would be to include an
unknown, empty padding attribute if needed. That would be 4 bytes
in size and could be used to include padding as needed.

We could use nla_type =3D 0 as it is a reserved value that should
be available in all protocols. All readers (kernel and user space)
must ignore such an attribute just like any other unknown
attribute they encounter.

We could easily extend nla_put_u64() and variants to automatically
include such a padding attribute as needed.

The only situation that I can think of where this would not work
is if we have code like this:

   foo =3D nla_nest_start();
   for ([..])
      nla_put_u64([...])
   nla_nest_end([...])

and a reader would stupidly do a nla_for_each_attr() in user space
and assume all attributes found must be NLA_U64 without even
checking the length of the attribute.

I would say we take that risk and let such code die horribly.
