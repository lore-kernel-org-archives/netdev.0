From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [0/3] POHMELFS high performance network filesystem. IPv6 support, documentation update.
Date: Sat, 26 Jul 2008 00:35:13 +0400
Message-ID: <20080725203512.GA10873@2ka.mipt.ru>
References: <20080725190134.GA30685@2ka.mipt.ru> <20080725194033.GA16133@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:41136 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751739AbYGYUfP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 16:35:15 -0400
Content-Disposition: inline
In-Reply-To: <20080725194033.GA16133@shareable.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamie.

On Fri, Jul 25, 2008 at 08:40:34PM +0100, Jamie Lokier (jamie@shareable.org) wrote:
> Consider this:
> 
>    1. Client A reads FILE, and registers its interest in FILE.
>          (Contents are not interesting, e.g. 'Hello_sister')
>    2. Client B does "echo Some_message > /mnt/file".
>        - Truncates the file, sending truncate message to server.
>        - "Writing happes during writeback"...?
>    3. Client B sends a message by back-channel to client A (e.g. ssh command).
>    4. Client A reads FILE again.
> 
> Does client A always see 'Some_message' when it reads the file in step 4?
> That's what I'd call coherence.

If 4. happens after writeback of the client B, then it will see the new
content, otherwise it will see empty page. There are no locks (even
implicit like what is expected in POSIX in exactly this case) in
POHMELFS so far.

> For that, the first truncate or write operation on client B must wait
> until a synchronous invalidate request goes to the server, then the
> server sends to all interested clients (A) and waits for a reply, then
> reply to B, and only then can B return from the open()/write() system call.
> 
> And when client A reads the file in step 4, it must send a synchronous
> message to the server which must ask B to write the delayed writeback
> data immediately, and until then, the reply to A will be delayed.
> 
> Is that right?

It _can_ be done that way. But I'm still thinking on how the really
scalable locking (this is a locking mechanism, just implicit) should be
implemented. It is possible to send a message on every write_begin,
which will invalidate appropriate message and every _read_ from that
area will require all writers to flush theirs data. It will be kind of
ME(O)SI cache coherency CPU protocol. It is simple task in current
design, but I'm not yet convinced myself that this is a really scalable
approach. So, there are no locks in POHMELFS _yet_.

-- 
	Evgeniy Polyakov
