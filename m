From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] situation with csum_and_copy_... API
Date: Thu, 20 Nov 2014 14:53:55 -0800
Message-ID: <1416524035.8629.54.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+55aFyQR2gOzEDROcWFcQzLvTjOxyJRjFJXJ03JB5knd-Gsgg@mail.gmail.com>
	 <20141119.161744.1661940121298888832.davem@davemloft.net>
	 <20141119213006.GE7996@ZenIV.linux.org.uk>
	 <20141119.165340.2162829993279387495.davem@davemloft.net>
	 <20141120214753.GR7996@ZenIV.linux.org.uk>
	 <1416520542.8629.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141120222506.GS7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	target-devel@vger.kernel.org,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	Christoph Hellwig <hch@infradead.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <20141120222506.GS7996@ZenIV.linux.org.uk>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-11-20 at 22:25 +0000, Al Viro wrote:

> Yes, it is.  You are breaking several _other_ kernel_sendmsg() users.
> They are already slightly broken, but that'll make breakage much more
> common.
> 
> Please, don't - the right thing to do is to have iov_iter in msghdr
> (we already have the kernel and userland ones with different types and
> we do not assume their layouts to be identical - currently they are,
> but it's easy to change), keep iovec constant in all cases and advance
> ->msg_iter.  Also in all cases.
> 
> Note that direct manipulations of what's currently in ->msg_iov are
> wrong - all those loops over vector elements, etc., belong in low-level
> primitives.  The main missing ones right now are csum_and_copy_{from,to}_iter()
> - I have those in local queue, but I'm still trying to get a reasonably
> clean mm/iov_iter.c without ridiculous amounts of boilerplating.  A bit more
> massage is needed there...
> 
> Seriously, take a look at vfs.git#iov_iter-net; it's preparations for the
> one that'll introduce ->msg_iter.  Right now that branch has local iov_iter
> declared and initialized in several ->sendmsg() and ->recvmsg() instances and
> fed to primitives that work with it; after the conversion it'll be in
> msg->msg_iter and it will be initialized by sock_sendmsg()/sock_recvmsg().
> 
> The tricky part is how to get through that without temporary breaking the
> existing sendmsg/recvmsg users in the kernel *and* without a patch size from
> hell.  I more or less see how to carve the remaining steps into
> reasonably-sized chunks; iscsi is one of the tricky ones and it, AFAICS,
> is genuinely broken in mainline and will need fixes that can go into -stable.
> 
> And no, your solution doesn't work.  Sorry.  You'll break e.g. smb_send_kvec()
> that way.  ceph_tcp_sendmsg() as well, IIRC.

Nowhere in tcp_sendmsg() the iov had const qualifier.

If it was declared as const, this discussion would not happen,
we would know we are not allowed to modify it.

iov_iter is nice, but not a single time it is used in net/ 

Please make sure to add const where appropriate.

Thanks.
