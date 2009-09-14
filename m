From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 1/8] networking/fanotify: declare fanotify socket
	numbers
Date: Mon, 14 Sep 2009 09:15:21 -0400
Message-ID: <1252934121.5766.54.camel@dogo.mojatatu.com>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
	 <20090911.114620.260824240.davem@davemloft.net>
	 <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com>
	 <1252704102.25158.36.camel@dogo.mojatatu.com>
	 <20090911214254.GB19901@shareable.org>
	 <1252709567.25158.61.camel@dogo.mojatatu.com>
	 <20090914000303.GA30621@shareable.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Paris <eparis@redhat.com>, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org, balbir@in.ibm.com
To: Jamie Lokier <jamie@shareable.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:48665 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbZINNRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 09:17:52 -0400
In-Reply-To: <20090914000303.GA30621@shareable.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-09-14 at 01:03 +0100, Jamie Lokier wrote:

> If you have enough memory to remember _what_ to retransmit, then you
> have enough memory to buffer a fixed-size message.  It just depends on
> how you do the buffering.  To say netlink drops the message and you
> can retry is just saying that the buffering is happening one step
> earlier, before netlink.  

it is the receiver that drops the message because of overruns
e.g. when receiver doesnt keep up..

> That's what I mean by netlink being a
> pointless complication for this, because you can just as easily write
> code which gets to the message to userspace without going through
> netlink and with no chance of it being dropped.
> 

Sure you can do that with netlink too. Whether it is overcomplicated
needs to be weighed out.

> Yes.  It uses positive acknowledge and flow control, because these
> match naturally with what fanotify does at the next higher level.
> 
> The process generating the multicast (e.g. trying to write a file) is
> blocked until the receiver gets the message, handles it and
> acknowledges with a "yes you can" or "no you can't" response.
> 
> That's part of fanotify's design.  The pattern conveniently has no
> issues with using unbounded memory for message, because the sending
> process is blocked.
> 

Ok, I understand better i think;-> So it is a synchronous type of
operation whereas in netlink type multicast, the optimization is to make
the operation async.

> True you only need one skb.  But netlink doesn't handle waiting for
> positive acknowledge responses from every receiver, and combining
> their value, does it?  

It is not netlink perse. It is how you use netlink for your app.
Classical one-to-many operations have the sender (kernel mostly)
do async sends to the listeners. It is up to the listener to catch
up if there are any holes. But this seems not what you want for
fanotify.

> You can't really take advantage of netlink's
> built in multicast, because to known when it has all the responses,
> the fanotify layer has to track the subscriber list itself anyway.

True, given my understanding so far fanotify has to track the subscriber
list. i.e something along the lines of:
- send a single multicast message to a set of listeners
- wait for response from all subscribers
- if no response from all subscribers given timeout then retransmit upto
max retransmit times

The chance of loosing a message in such a case is zero if the socket
buffer on each listener/receiver is larger than one fanotify event
message. You still have to alloc the message - and that may fail.

> What I'm saying is perhaps skbs are useful for fanotify, but I don't
> know that netlink's multicasting is useful.  But storing the messages
> in skbs for transmission, and using parts of netlink to manage them,
> and to provide some of the API, that might be useful.

The multicast-a-single-skb part is useful. Of course, its usefulness
diminishes as the number of listeners per subtree goes down (because it
reduces to one skb per listener). So all this depends on how fanotify is
going to be used.
The one thing i am not sure of is how you map a multicast group to a
subtree. In netlink groups to which multiple listeners subscribe to
are 32-bit identifiers. I suppose, one approach could be to register
for the event of interest, get an ID then use the ID to listen to a
multicast group of that ID. This way whoever is issuing the ID can also
factor in permissions and subtree overlap of the listener (and whether
the events are already being listened to in a known ID). 
Alternatively, to your statement above, if fanotify is keeping track of
all subsribers then it can replicast a single event instead and just
bump the refcount on the skb for each sent-to-user (and still use one
skb).. 

> You do get nothing unless you register interest.  The problem is
> there's no way to register interest on just a subtree, so the fanotify
> approach is let you register for events on the whole filesystem, and
> let the userspace daemon filter paths.  At least it's decisions can be
> cached, although I'm not sure how that works when multiple processes
> want to monitor overlapping parts of the filesystem.

I guess if the non-optimal part happens only once and subsequent cached
filters happen faster, then one could look at that as cost of setup.
I think, given that you are capable of creating such a cache, seems that
it would be cheaper to make such decision at registration time.

> It doesn't sound scalable to me, either, and that's why I don't like
> this part, and described a solution to monitoring subtrees - which
> would also solve the problem for inotify.  (Both use fsnotify under
> the hood, and that's where subtree notification would go).
>
> Eric's mentioned interest in a way to monitor subtrees, but that
> hasn't gone anywhere as far as I know.  He doesn't seem convinced by
> my solution - or even that scalability will be an issue.  I think
> there's a bit of vision lacking here, and I'll admit I'm more
> interested in the inotify uses of fsnotify (being able to detect
> changes) than the fanotify uses (being able to _block_ or _modify_
> changes).  I think both inotify and fanotify ought to benefit from the
> same improvements to file monitoring.
> 

The subtree overlap problem seems to invoke some well known computer
science algorithms, no? i.e tell me oracle given the event on nodeX of
this tree, which subscriber needs to be notified?


> I believe it would cause 10000 events, yes, even if they are files
> that userspace policy is not interested in.  Eric, is that right?
> 
> However I believe after the first grep, subsequent greps' decisions
> would be cached by marking the inodes.  I'm not sure what happens if
> two fanotify monitors both try marking the inodes.
>
> Arguably if a fanotify monitor is running before those files are in
> page cache anyway, then I/O may dominate, and when the files are
> cached, fanotify has already cached it's decisions in the kernel.
> However fanotify is synchronous: each new file access involves a round
> trip to the fanotify userspace and back before it can proceed, so
> there's quite a lot of IPC and scheduling too.  Without testing, it's
> hard to guess how it'll really perform.
> 

So if you can mark inodes, why not do it at register time?

> > > While skbs and netlink aren't that slow, I suspect they're an order of
> > > magnitude or two slower than, say, epoll or inotify at passing events
> > > around.
> > 
> > not familiar with inotify.
> 
> inotify is like dnotify, and like a signal or epoll: a message that
> something happened.  You register interest in individual files or
> directories only, and inotify does not (yet) provide a way to monitor
> the whole filesystem or a subtree.
> 
> fanotify is different: it provides access control, and can _refuse_
> attempts to read file X, or even modify the file before permitting the
> file to be read.
> 

Ok, I think i understood more about fanotify now. It is more of an
access control than a mass notification scheme (which is what i thought
of earlier).
Hrm, it does sound like something closer to selinux if it is simple
enough to require answers to simple questions like "should this
operation continue?"

> > Theres a difference between events which are abbreviated in the form
> > "hey some read happened on fd you are listening on" vs "hey a read
> > of file X for 16 bytes at offset 200 by process Y just occured while
> > at the same time process Z was writting at offset 2000". The later
> > (which netlink will give you) includes a lot more attribute details
> > which could be filtered or can be extended to include a lot
> > more. The former(what epoll will give you) is merely a signal.
> 
> Firstly, it's really hard to retain the ordering of userspace events
> like that in a useful way, given the non-determinstic parallelism
> going on with multiple processes doing I/O do the same file :-)
> 

Bad example ;->
That was not meant to be anything clever - rather to demonstrate that
netlink allows you to send many attributes with events and that you can
add as many as you want over a period of time (instead of hardcoding it
at design/coding time).

On a tangent: I would love to get more than simple events
(read/write/exception) on a file. Probably more on the writes
than on reads; example "offset X, length Y has been deleted" etc.
I would still love the option to exercise my rights to simple
events like read/write/exception

cheers,
jamal

