From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [3/4] kevent: AIO, aio_sendfile() implementation.
Date: Wed, 26 Jul 2006 14:19:21 +0400
Message-ID: <20060726101919.GB2715@2ka.mipt.ru>
References: <1153905495613@2ka.mipt.ru> <11539054952574@2ka.mipt.ru> <20060726100431.GA7518@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:9153 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932166AbWGZKUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 06:20:16 -0400
To: Christoph Hellwig <hch@infradead.org>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20060726100431.GA7518@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 26, 2006 at 11:04:31AM +0100, Christoph Hellwig (hch@infradead.org) wrote:
> On Wed, Jul 26, 2006 at 01:18:15PM +0400, Evgeniy Polyakov wrote:
> > 
> > This patch includes asynchronous propagation of file's data into VFS
> > cache and aio_sendfile() implementation.
> > Network aio_sendfile() works lazily - it asynchronously populates pages
> > into the VFS cache (which can be used for various tricks with adaptive
> > readahead) and then uses usual ->sendfile() callback.
> 
> And please don't base this on sendfile.  Please make the splice infrastructure
> aynschronous without duplicating all the code but rather make the existing
> code aynch and the existing synchronous call wait on them to finish, similar
> to how we handle async/sync direct I/O.  And to be honest, I don't think
> adding all this code is acceptable if it can't replace the existing aio
> code while keeping the interface.  So while you interface looks pretty
> sane the implementation needs a lot of work still :)

Kevent was created quite before splice and friends, so I used what there
were :)

I stopped to work on AIO, since neither existing, nor mine
implementation were able to outperform sync speeds (one of the major problems
in my implementation is get_user_pages() overhead, which can be
completely eliminated with physical memory allocation being done in
advance in userspace, like Ulrich described).
My personal opinion on existing AIO is that it is not the right design.
Benjamin LaHaise agree with me (if I understood him right), but he
failed to move AIO outside repeated-call model (2.4 had state machine
based one, and out-of-the tree 2.6 patches have that design too).
In theory existing AIO (with all posix userspace API) can be replaced
with kevent (it will even take less space), but I would present it as a
TODO item, since kevent itself has nothing to do with AIO.

Kevent is a generic event processing mechanism, AIO, network AIO and all
others are just kernel users of it's functionality.

-- 
	Evgeniy Polyakov
