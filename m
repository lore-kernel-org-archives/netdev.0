From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] unix: properly account for FDs passed over unix sockets
Date: Wed, 30 Dec 2015 09:58:42 +0100
Message-ID: <56839CC2.9080000@stressinduktion.org>
References: <20151228141435.GA13351@1wt.eu>
 <56829D4D.4090109@stressinduktion.org> <20151229203527.GA13826@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, socketpair@gmail.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151229203527.GA13826@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29.12.2015 21:35, Willy Tarreau wrote:
> On Tue, Dec 29, 2015 at 03:48:45PM +0100, Hannes Frederic Sowa wrote:
>> On 28.12.2015 15:14, Willy Tarreau wrote:
>>> It is possible for a process to allocate and accumulate far more FDs than
>>> the process' limit by sending them over a unix socket then closing them
>>> to keep the process' fd count low.
>>>
>>> This change addresses this problem by keeping track of the number of FDs
>>> in flight per user and preventing non-privileged processes from having
>>> more FDs in flight than their configured FD limit.
>>>
>>> Reported-by: socketpair@gmail.com
>>> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
>>> Signed-off-by: Willy Tarreau <w@1wt.eu>
>>
>> Thanks for the patch!
>>
>> I think this does not close the DoS attack completely as we duplicate
>> fds if the reader uses MSG_PEEK on the unix domain socket and thus
>> clones the fd. Have I overlooked something?
>
> I didn't know this behaviour. However, then the fd remains in flight, right ?
> So as long as it's not removed from the queue, the sender cannot add more
> than its FD limit. I may be missing something obvious though :-/

Yes, it remains in flight.

The MSG_PEEK code should not be harmful and the patch is good as is. I 
first understood from the published private thread, that it is possible 
for a program to exceed the rlimit of fds. But the DoS is only by 
keeping the fds in flight and not attaching them to any program.

__alloc_fd, called on the receiver side, does check for the rlimit 
maximum anyway, so I don't see a loophole anymore:

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Another idea would be to add the amount of memory used to manage the fds 
to sock_rmem/wmem but I don't see any advantages or disadvantages.

Thanks!
