From: Dominique Martinet <dominique.martinet@cea.fr>
Subject: Re: [V9fs-developer] [PATCH] net: trans_rdma: remove unused
 function
Date: Fri, 26 Jul 2013 17:17:37 +0200
Message-ID: <20130726151737.GA24757@nautica>
References: <1374497956-32104-1-git-send-email-andi@etezian.org>
 <20130724.154646.2283898956674234778.davem@davemloft.net>
 <1374707387.29835.23.camel@x61.thuisdomein>
 <20130724.164514.393667021861625699.davem@davemloft.net>
 <20130725061411.GA8579@nautica>
 <20130725064802.GA12569@nautica>
 <CAFkjPTm1FH24EfWMDrXTh7DmU8WAb0ji-jkUgkayqMzfWj9O0A@mail.gmail.com>
 <20130725190506.GA32375@nautica>
 <CAFkjPTkr5JYf6qc=pjcG8rSoocFekU-cTw450SujTvpCp33cyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Latchesar Ionkov <lucho@ionkov.net>, pebolle@tiscali.nl,
	netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>, andi@etezian.org,
	V9FS Developers <v9fs-developer@lists.sourceforge.net>,
	rminnich@sandia.gov, David Miller <davem@davemloft.net>
To: Eric Van Hensbergen <ericvh@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAFkjPTkr5JYf6qc=pjcG8rSoocFekU-cTw450SujTvpCp33cyw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Van Hensbergen wrote on Fri, Jul 26, 2013 :
> It depends on the flags you use with 9p.  If you mount with nodevmap it'll
> treat them like normal files.  Alternatively you can use synthetics from
> fuse or even 9p file systems from Plan 9 port.

Ok, thank you for the explanation. Now I need to see if my server
supports this :)

> I need to go back and refresh more of my RDMA knowledge, I thought you
> could provide a better more direct coupling between the request and
> response buffers (similar to what we do in virtio).  In such a case, you'd
> simply need to reclaim the "skipped" buffer not shuffle everything around.
> Ultimately that would seem to work against the point of having "zero copy"
> RDMA.

What I said next was wrong, but the queue really isn't something you can
control this finely. Once something is posted, you can't take it back,
and you can't know which buffer will come back for which reply (but it's
easy enough to read the tag from the reply and associate it back)

For flush, I'm honestly not sure on how to deal with the possibility of
the servers processing the original query and sending a reply after
we've tagged our own buffer as free again, but I think there might
actually be a problem even on sucessful flush if the next post is from a
different tag (that has its own rc buffer) -- as far as I understand it,
this one's reply will be considered duplicate reply in handle_recv.
But I really need to do some more precise testing, I'll try playing with
nodevmap, if I get the flush functions to be called I'll get this
fixed.


> > I haven't found how to reproduce this perfectly yet, but a dd with
> > blocksize 1MB and one with blocksize 10B in parallel brought the
> > mountpoint down (and the whole server was completely unavailable for the
> > duration of the dd - TCP sessions timed out, I even got IO errors on the
> > local disk :D)
> >
> 
> Sounds like you ran out of memory and things didn't degrade gracefully.

I think it's actually "just" in the debug, there are two p9_debug printk
in p9_client_cb which are called from an rdma irq handler, and it gets
messy once the kernel buffer is full and it wants to flush to the
console.
I've got a short patch that adds an argument to p9_client_cb with an
indication that it shouldn't output messages, I'll send it to the v9fs
mailing list for comments if you think the idea is acceptable.

>  Which server are you using?

I know of two servers out there which handle 9P/RDMA - diod (
http://code.google.com/p/diod/ ) and nfs-ganesha (
https://github.com/nfs-ganesha/nfs-ganesha )
I wrote the RDMA implementation for ganesha and am mostly running tests
on that, but both should somewhat work with their quirks :)

Regards,
-- 
Dominique Martine
