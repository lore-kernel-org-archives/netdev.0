From: Andreas Gruenbacher <agruen@linbit.com>
Subject: Re: [RFC] [TCP 0/3] Receive from socket into bio without copying
Date: Mon, 02 Jul 2012 18:06:31 +0200
Message-ID: <1341245191.2177.40.camel@schurl.lan>
References: <1341237299.22621.88.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341237299.22621.88.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-07-02 at 15:54 +0200, Eric Dumazet wrote:
> On Mon, 2012-07-02 at 15:02 +0200, Andreas Gruenbacher wrote:
> > bio_vec's have some alignment requirements that must be met, and
> > anything that doesn't meet those requirements can't be passed to the
> > block layer (without copying it first). Additional layers between
> > the
> > network and block layers, like a pipe, won't make that problem go
> > away.
> >
> 
> What are the "some alignment requirements" exactly, and how do you use
> TCP exactly to meet them ? (MSS= multiple of 512 ?)

Sectors of 512 bytes must be contiguous; some devices have additional
requirements (like 4k sectors).  I'm not sure if sectors always need to be
aligned, but if buffers are allocated page wise and handed out as half /
full pages, you get that automatically.

> I believe you try to escape from the real problem.
> 
> If the NIC driver provides non aligned data, neither splice() or your
> new stuff will magically align it. You _need_ a copy in either cases.

Yes, the NIC must provide aligned data.  A prerequisite for that is that the
NIC knows how to align things.  With no knowledge of the application protocol,
the NIC can only use the packet boundaries as hints.  I'm trying to get tcp
to start new packets at specific points in the protocol so that the packet
boundaries will coincide with alignment boundaries.  With that, NICs that do
header splitting can receive packets into appropriately aligned buffers, and
the problem is solved.

> If NIC driver provides aligned data, splice(socket -> pipe) will keep
> this alignment for you at 0 cost.

Yes of course.  That is not the real issue here though.

> > It's not already there, it requires the alignment issue to be
> > addresses first.
> 
> There is no guarantee TCP payload is aligned to a bio, ever, in linux
> ethernet/ip/tcp stack.
> 
> Really, your patches work for you, by pure luck, because you use one
> particular NIC driver that happens to prepare things for you
> (presumably doing header split). Nothing guarantee this wont change even
> for the same hardware in linux-3.8

NICs with header splitting are common enough that you don't have to resort
to pure luck to get one.

> So I will just say no to your patches, unless you demonstrate the
> splice() problems, and how you can fix the alignment problem in a new
> layer instead of in the existing zero copy standard one.

Again, splice or not is not the issue here. It does not, by itself, allow zero
copy from the network directly to disk but it could likely be made to support
that if we can get the alignment right first.  The proposed MSG_NEW_PACKET flag
helps with that, but maybe someone has a better idea.

This doesn't have to work with arbitrary NICs and it most likely will hurt with
small MTUs, but then you can still choose not to use it.  It just has to almost
always work with some particular NICs and with large MTUs.

Andreas
