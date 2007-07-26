From: Kyle Moffett <mrlinuxman@mac.com>
Subject: Re: [DRIVER SUBMISSION] DRBD wants to go mainline
Date: Wed, 25 Jul 2007 23:43:38 -0400
Message-ID: <B3CFC70C-ADBC-406A-A2C8-908530FED007@mac.com>
References: <20070721203819.GA10706@mail.linbit.com> <20070722213202.1f5d1cab.mrlinuxman@mac.com> <20070723133202.GB23495@mail.linbit.com> <a781481a0707230640h17e6d83l5c2359e41f3ec7b7@mail.gmail.com> <20070723211947.GD6477@mail.linbit.com> <a781481a0707241611v3c35f6bdsb7af97d382b9298f@mail.gmail.com> <20070725094638.GA2444@mail.linbit.com> <a781481a0707250512v29d41b1bh25bcd358e7381d38@mail.gmail.com> <Pine.LNX.4.64.0707251900410.21378@asgard.lang.hm>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Satyam Sharma <satyam.sharma@gmail.com>,
	Lars Ellenberg <lars.ellenberg@linbit.com>,
	Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@osdl.org>,
	LKML Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: david@lang.hm
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.mac.com ([17.250.248.173]:55422 "EHLO smtpout.mac.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756875AbXGZDnz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 23:43:55 -0400
In-Reply-To: <Pine.LNX.4.64.0707251900410.21378@asgard.lang.hm>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Jul 25, 2007, at 22:03:37, david@lang.hm wrote:
> On Wed, 25 Jul 2007, Satyam Sharma wrote:
>> On 7/25/07, Lars Ellenberg <lars.ellenberg@linbit.com> wrote:
>>> On Wed, Jul 25, 2007 at 04:41:53AM +0530, Satyam Sharma wrote:
>>>> [...]
>>>> But where does the "send" come into the picture over here -- a  
>>>> send won't block forever, so I don't foresee any issues  
>>>> whatsoever w.r.t.  kthreads conversion for that. [ BTW I hope  
>>>> you're *not* using any signals-based interface for your kernel  
>>>> thread _at all_. Kthreads disallow (ignore) all signals by  
>>>> default, as they should, and you really shouldn't need to write  
>>>> any logic to handle or >  do-certain-things-on-seeing a signal  
>>>> in a well designed kernel thread. ] and the sending latency is  
>>>> crucial to performance, while the recv will not timeout for the  
>>>> next few seconds.  Again, I don't see what sending latency has  
>>>> to do with a kernel_thread to kthread conversion. Or with  
>>>> signals, for that matter. Anyway, as Kyle Moffett mentioned  
>>>> elsewhere, you could probably look at other examples (say  
>>>> cifs_demultiplexer_thread() in fs/cifs/connect.c).
>>>
>>> the basic problem, and what we use signals for, is:  it is  
>>> waiting in recv, waiting for the peer to say something.  but I  
>>> want it to stop recv, and go send something "right now".
>>
>> That's ... weird. Most (all?) communication between any two  
>> parties would follow a protocol where someone recv's stuff, does  
>> something with it, and sends it back ... what would you send  
>> "right now" if you didn't receive anything?
>
> becouse even though you didn't receive anything you now have  
> something important to send.
>
> remember that both sides can be sitting in receive mode. this puts  
> them both in a position to respond to the other if the other has  
> something to say.

Why not just have 2 threads, one for "sending" and one for  
"receiving".  When your receiving thread gets data it takes  
appropriate locks and processes it, then releases the locks and goes  
back to waiting for packets.  Your sending thread would take  
appropriate locks, generate data to send, release locks, and transmit  
packets.  You don't have to interrupt the receive thread to send  
packets, so where's the latency problem, exactly?

If I were writing that in userspace I would have:

(A) The pool of IO-generating threads (IE: What would ordinarily be  
userspace)
(B) One or a small number of data-reception threads.
(C) One or a small number of data-transmission threads.

When you get packets to process in your network-reception thread(s),  
you queue appropriate disk IOs and any appropriate responses with  
your transmission thread(s).  You can basically just sit in a loop on  
tcp_recvmsg=>demultiplex=>do-stuff.  When your IO-generators actually  
make stuff to send you queue such data for disk IO, then packetize it  
and hand it off to your data-transmission threads.

If you made all your sockets and inter-thread pipes nonblocking then  
in userspace you would just epoll_wait() on the sockets and pipes and  
be easily able to react to any IO from anywhere.

In kernel space there are similar nonblocking interfaces, although it  
would probably be easier just to use a couple threads.

Cheers,
Kyle Moffett

