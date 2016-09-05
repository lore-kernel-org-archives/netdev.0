From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH net-next 4/9] rxrpc: Randomise epoch and starting client conn ID values
Date: Mon, 05 Sep 2016 17:24:23 +0100
Message-ID: <3378.1473092663@warthog.procyon.org.uk>
References: <063D6719AE5E284EB5DD2968C1650D6DB00F48DE@AcuExch.aculab.com> <147302294435.28597.15007422228950187972.stgit@warthog.procyon.org.uk> <147302297165.28597.8317497494192917329.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-afs@lists.infradead.org" <linux-afs@lists.infradead.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
        Jeffrey Altman <jaltman@auristor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59568 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932312AbcIEQY0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 12:24:26 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB00F48DE@AcuExch.aculab.com>
Content-ID: <3377.1473092663.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[cc'ing Jeff Altman for comment]

David Laight <David.Laight@ACULAB.COM> wrote:

> > Create a random epoch value rather than a time-based one on startup and set
> > the top bit to indicate that this is the case.
> 
> Why set the top bit?
> There is nothing to stop the time (in seconds) from having the top bit set.
> Nothing else can care - otherwise this wouldn't work.

This is what I'm told I should do by purveyors of other RxRPC solutions.

> > Also create a random starting client connection ID value.  This will be
> > incremented from here as new client connections are created.
> 
> I'm guessing this is to make duplicates less likely after a restart?

Again, it's been suggested that I do this, but I would guess so.

> You may want to worry about duplicate allocations (after 2^32 connects).

It's actually a quarter of that, but connection != call, so a connection may
be used for up to ~16 billion RPC operations before it *has* to be flushed.

> There are id allocation algorithms that guarantee not to generate duplicates
> and not to reuse values quickly while still being fixed cost.
> Look at the code NetBSD uses to allocate process ids for an example.

I'm using idr_alloc_cyclic()[*] with a fixed size "window" on the active conn
ID values.  Client connections with IDs outside of that window are discarded
as soon as possible to keep the memory consumption of the tree down (and to
force security renegotiation occasionally).  However, given that there are a
billion IDs to cycle through, it will take quite a while for reuse to become
an issue.

I like the idea of incrementing the epoch every time we cycle through the ID
space, but I'm told that a change in the epoch value is an indication that the
client rebooted - with what consequences I cannot say.

[*] which is what Linux uses to allocate process IDs.

David
