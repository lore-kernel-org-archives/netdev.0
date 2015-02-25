From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Wed, 25 Feb 2015 09:41:36 -0800
Message-ID: <1424886096.5565.104.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1424877322.git.daniel@iogearbox.net>
	 <cd3e70163920753c7f1a492e6df253cff9b1b080.1424877322.git.daniel@iogearbox.net>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAED36D@AcuExch.aculab.com>
	 <54EDEE55.8050605@iogearbox.net>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAED3A1@AcuExch.aculab.com>
	 <54EDF4DD.1060709@iogearbox.net>
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
Received: from mail-ig0-f180.google.com ([209.85.213.180]:38875 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852AbbBYRli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 12:41:38 -0500
Received: by mail-ig0-f180.google.com with SMTP id b16so7788209igk.1
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 09:41:38 -0800 (PST)
In-Reply-To: <54EDF4DD.1060709@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-25 at 17:14 +0100, Daniel Borkmann wrote:

> The nelems can be a percpu_counter where we have a batched sync
> point and can make that dependent on the current table shift as
> we don't need to be overly precise, we can just read the sync'ed
> value. Currently, nelems are also being used by rhashtable users
> outside of the core code to track if we are still allowed to
> insert new elements, but I think we might also want to address
> that at some point.

There is no need to track number of elements, using either an atomic_t
or percpu_counter. This adds unnecessary burden.

1) Automatic shrinking is a non issue. This will free very little
memory, compared to previous peak usage (including objects put in
rhashtable). If hash grown to a certain point, it's likely it will grow
again later.

2) Growing can be triggered when any bucket has more than X elems, and
that is given for free at insert time.
X could be log2(buckets)/2 I guess. (aka shift/2)

A global limit on number of elements should be controlled by rhashtable
users - if needed -, not in the rhashtable itself.
