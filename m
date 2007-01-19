From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take33 10/10] kevent: Kevent based AIO (aio_sendfile()/aio_sendfile_path()).
Date: Fri, 19 Jan 2007 12:23:43 +0300
Message-ID: <20070119092343.GA14605@2ka.mipt.ru>
References: <11690154353959@2ka.mipt.ru> <11690154352501@2ka.mipt.ru> <20070117135142.GA24866@in.ibm.com> <20070117143950.GA19434@2ka.mipt.ru> <20070119062700.GA14705@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Suparna Bhattacharya <suparna@in.ibm.com>
Content-Disposition: inline
In-Reply-To: <20070119062700.GA14705@in.ibm.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 19, 2007 at 11:57:00AM +0530, Suparna Bhattacharya (suparna@in.ibm.com) wrote:
> > > Since you are implementing new APIs here, have you considered doing an
> > > aio_sendfilev to be able to send a header with the data ?
> > 
> > It is doable, but why people do not like corking?
> > With Linux less than microsecond syscall overhead it is better and more
> > flexible solution, doesn't it?
> 
> That is what I used to think as well. However ...
> 
> The problem as I understand it now is not about bunching data together, but
> of ensuring some sort of atomicity between the header and the data, when
> there can be multiple outstanding aio requests on the same socket - i.e
> ensuring strict ordering without other data coming in between, when data
> to be sent is not already in cache, and in the meantime another sendfile
> or aio write requests comes in for the same socket. Without having to lock
> the socket when reading data from disk.

No, socket locking is not solution at all here.
But the same applies to header - it will be copied into socket queue,
then socket will be unlocked and populated VFS data will be put into
that queue too, but there is a window between socket unlock after header
copy and file data copy. If we will hold socket lock after header is
copied, it is possible to lock it for too long - bad sectors on disk,
and reading might take forever.

> There are alternate ways to address this, aio_sendfilev is one of the options
> I have heard people requesting.

I bet those people worked with different Unix systems, which have much
slower syscalls, so they combine several operations into one call.

Only from this perspective I see any benefit from having header in the
syscall related to file transfer. Since I already "optimized" open()
syscall into file sending, things can not became worse if I will put there
header pointer too. I will schedule new kevent release with this change
somewhere after current work on M-on-N threading model.

> Regards
> Suparna

-- 
	Evgeniy Polyakov
