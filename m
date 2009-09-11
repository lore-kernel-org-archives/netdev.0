From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 1/8] networking/fanotify: declare fanotify socket
	numbers
Date: Fri, 11 Sep 2009 18:52:47 -0400
Message-ID: <1252709567.25158.61.camel@dogo.mojatatu.com>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
	 <20090911.114620.260824240.davem@davemloft.net>
	 <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com>
	 <1252704102.25158.36.camel@dogo.mojatatu.com>
	 <20090911214254.GB19901@shareable.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Paris <eparis@redhat.com>, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org, balbir@in.ibm.com
To: Jamie Lokier <jamie@shareable.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090911214254.GB19901@shareable.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-09-11 at 22:42 +0100, Jamie Lokier wrote:

> One of the uses of fanotify is as a security or auditing mechanism.
> That can't tolerate gaps.
> 
> It's fundemantally different from inotify in one important respect:
> inotify apps can recover from losing events by checking what they are
> watching.
> 
> The fanotify application will know that it missed events, but what
> happens to the other application which _caused_ those events?  Does it
> get to do things it shouldn't, or hide them from the fanotify app, by
> simply overloading the system?  Or the opposite, does it get access
> denied - spurious file errors when the system is overloaded?
> 
> There's no way to handle that by dropping events.  A transport
> mechanism can be dropped (say skbs), but the event itself has to be
> kept, and then retried.
> 
>
> Since you have to keep an event object around until it's handled,
> there's no point tying it to an unreliable delivery mechanism which
> you'd have to wrap a retry mechanism around.
> 
> In other words, that part of netlink is a poor match.  It would match
> inotify much better.
> 

Reliability is something that you should build in. Netlink provides you
all the necessary tools. What you are asking for here is essentially 
reliable multicasting.  You dont have infinite memory, therefore there
will be times when you will overload one of the users, and they wont
have sufficient buffer space and then you have to retransmit. You have
to factor in processing speed mismatch between the different listeners.
As an example, you could ensure that all users receive the message and
if user #49 didnt, then you wait until they do before multicasting the
next message to all 50 listeners.
Is the current proposed mechanism capable of reliably multicasting
without need for retransmit?


> Speaking of skbs, how fast and compact are they for this?

They are largish relative to say if you trimmed down to basic necessity.
But then you get a lot of the buffer management aspects for free.
In this case, the concept of multicasting is built in so for one event
to be sent to X users - you only need one skb.

> Eric's explained that it would be normal for _every_ file operation on
> some systems to trigger a fanotify event and possibly wait on the
> response, or at least in major directory trees on the filesystem.
> Even if it's just for the fanotify app to say "oh I don't care about
> that file, carry on".
> 

That doesnt sound very scalable. Should it not be you get nothing unless
you register for interest in something?

> File performance is one of those things which really needs to be fast
> for a good user experience - and it's not unusual to grep the odd
> 10,000 files here or there (just think of what a kernel developer
> does), or to replace a few thousand quickly (rpm/dpkg) and things like
> that.
> 

So grepping 10000 files would cause 10000 events? I am not sure how the
scheme works; filtering of what events get delivered sounds more
reasonable if it happens in the kernel.

> While skbs and netlink aren't that slow, I suspect they're an order of
> magnitude or two slower than, say, epoll or inotify at passing events
> around.
> 

not familiar with inotify. Theres a difference between events which are
abbreviated in the form "hey some read happened on fd you are listening
on" vs "hey a read of file X for 16 bytes at offset 200 by process Y
just occured while at the same time process Z was writting at offset
2000". The later (which netlink will give you) includes a lot more
attribute details which could be filtered or can be extended to include
a lot more. The former(what epoll will give you) is merely a signal.

cheers,
jamal

