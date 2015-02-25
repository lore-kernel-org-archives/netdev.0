From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Wed, 25 Feb 2015 11:52:09 -0800
Message-ID: <1424893929.5565.122.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1424877322.git.daniel@iogearbox.net>
	 <cd3e70163920753c7f1a492e6df253cff9b1b080.1424877322.git.daniel@iogearbox.net>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAED36D@AcuExch.aculab.com>
	 <54EDEE55.8050605@iogearbox.net>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAED3A1@AcuExch.aculab.com>
	 <54EDF4DD.1060709@iogearbox.net>
	 <1424886096.5565.104.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54EE1AC8.6060206@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:40978 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644AbbBYTwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 14:52:11 -0500
Received: by iecrd18 with SMTP id rd18so7984110iec.8
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 11:52:11 -0800 (PST)
In-Reply-To: <54EE1AC8.6060206@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-25 at 19:56 +0100, Daniel Borkmann wrote:
> On 02/25/2015 06:41 PM, Eric Dumazet wrote:
> ...
> > There is no need to track number of elements, using either an atomic_t
> > or percpu_counter. This adds unnecessary burden.
> >
> > 1) Automatic shrinking is a non issue. This will free very little
> > memory, compared to previous peak usage (including objects put in
> > rhashtable). If hash grown to a certain point, it's likely it will grow
> > again later.
> 
> So you are saying that shrinking is most likely a rather undesirable
> use-case in rhashtable?

Main point of rhashtable is to start with a small/reasonable size,
and only big consumers need to _expand_ the table.

Like, instead of having 512000 slots in TCP hash table, start with a
2^10 size.

Like my laptop currently has :

TCP established hash table entries: 131072 (order: 8, 1048576 bytes)

Which is kind of ridiculous....

But if any workload had to grow the table to 2^20 slots, we had to
consume GB of memory anyway to hold sockets and everything.

Trying to shrink is simply not worth it, unless you expect your host
never reboots and you desperately need back these 8 MBytes of memory.
