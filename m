From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [0/3] POHMELFS high performance network filesystem. IPv6 support, documentation update.
Date: Fri, 25 Jul 2008 20:40:34 +0100
Message-ID: <20080725194033.GA16133@shareable.org>
References: <20080725190134.GA30685@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:51997 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbYGYTkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 15:40:35 -0400
Content-Disposition: inline
In-Reply-To: <20080725190134.GA30685@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>From the design notes,
> POHMELFS got full data and metadata cache coherency support.
>
> It was rather simple task due to async event processing support.
>
> Each time client creates, reads or writes object to server,
> information about its interest is stored on server. When any other
> client updates the same object (like changing attributes or writes
> data), all interested clients get notifications with new data (new
> attributes, or in case of writing possibly new size and flag, which
> page has to be fetched from the server, since it is not valid
> anymore). Writing happens during writeback as before, so commands like
> "echo Some_message > /mnt/file" immediately syncs size of the file to
> zero and after some time writes there actual data, when system will
> decide to start writeback.

I'm just going by what the notes say, which don't seem very clear.

Consider this:

   1. Client A reads FILE, and registers its interest in FILE.
         (Contents are not interesting, e.g. 'Hello_sister')
   2. Client B does "echo Some_message > /mnt/file".
       - Truncates the file, sending truncate message to server.
       - "Writing happes during writeback"...?
   3. Client B sends a message by back-channel to client A (e.g. ssh command).
   4. Client A reads FILE again.

Does client A always see 'Some_message' when it reads the file in step 4?
That's what I'd call coherence.

For that, the first truncate or write operation on client B must wait
until a synchronous invalidate request goes to the server, then the
server sends to all interested clients (A) and waits for a reply, then
reply to B, and only then can B return from the open()/write() system call.

And when client A reads the file in step 4, it must send a synchronous
message to the server which must ask B to write the delayed writeback
data immediately, and until then, the reply to A will be delayed.

Is that right?

Thanks,
-- Jamie
