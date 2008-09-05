From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Fri, 5 Sep 2008 17:16:18 +0400
Message-ID: <20080905131618.GB12246@2ka.mipt.ru>
References: <7e0dd21a0809030858h7fdc454dj33acc6be25a0aab@mail.gmail.com> <20080903164346.GA6729@2ka.mipt.ru> <7e0dd21a0809031330i1363c4aema9c57ef06a3d5279@mail.gmail.com> <20080903220347.GA22395@2ka.mipt.ru> <7e0dd21a0809040744q3ee65695uc33f6cc26a1fe4dd@mail.gmail.com> <20080905071754.GA25998@2ka.mipt.ru> <7e0dd21a0809050216r65b8f08fm1ad0630790a13a54@mail.gmail.com> <7e0dd21a0809050217v33ecb8fvcadd5e65118d6afe@mail.gmail.com> <20080905113112.GA29926@2ka.mipt.ru> <7e0dd21a0809050544m47deaf0dsf1f31805890ac09@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:45060 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752432AbYIENQ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 09:16:59 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0809050544m47deaf0dsf1f31805890ac09@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann.

On Fri, Sep 05, 2008 at 02:44:47PM +0200, Johann Baudy (johaahn@gmail.com) wrote:
> I was talking about vmsplice()/splice() which seems to me the only way
> to send user buffer (pages) to socket without copy.

Yes, and we found, that vmsplice() is slow, so unacceptible.
What about single big enough file being sent via sendfile()?
Can it saturate the link in your setup?

> >> No SIGIO. But FYI, I use PREEMPT_RT patch.
> >
> > Does it also push softirq processing into threads?
> >
> I don't understand your point, how can I check?
> I'm not handling any IRQ in this test software.

You do - receiving network processing happens in softirq context.
As far as I heared, RT patchset pushes processing into threads and thus
softirqs will be pushed there too. In your particular case it should not
be an issue because of UDP usage and likely no replies, and even if it
would, it affected both packet socket ring processing and higher level
ones. I pointed it not to show a slowdown.

> > This worries me a lot: sendfile should be a single syscall which very
> > optimally creates network packets getting into account MTU and hardware
> > capabilities. I do belive it is a problem with userspace code.
> 
> Yes, and this is what it does (only one single syscall).
> No printf, only one sendfile of 10MB file over TCP socket
> 
> To resume ongoing test status:
> with vmsplice()/splice() I need to do multiple call of vmsplice() and
> one call of splice() - ratio seems to be limited to the pipe capacity
> (16 pages: 64K)
>                                       - vmsplice call specify the size
> of the udp packet which means 1 syscall per packet :(
>                                       - In UDP, Bitrate is  < 20MB/s
> 
> 
> with sendfile() only one system call of 10MB  in TCP (in UDP I have to
> split in 61440 bytes).
>                                       - In TCP bitrate is limited due to remote
>                                       - In UDP,  this 61440 bytes
> limit which  is really inferior to my 7200*40 packets that allows me
> to saturate the link (during 2ms only...) with my circular buffer.
>                                      - Bitrate is  < 20MB/s

It looks like you are sending data in chunks, which you should not do.
Why do you splice input file into 60k chunks for UDP?
sendfile() should iterate over whole file in page chunks, pack them
into splice buffer (16 pages), send them, then get next set of pages
and so on... udp_sendpage() will properly allocate skbs for the given
MTU, or append data to the end of the skb if there is a place.

You should _not_ manually interrupt this process and call sendfile()
multiple times with different offsets and small sizes.

-- 
	Evgeniy Polyakov
