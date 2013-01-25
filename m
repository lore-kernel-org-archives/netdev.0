From: Nick Jones <nick.jones@network-box.com>
Subject: Re: [PATCH 0/5]: soreuseport: Bind multiple sockets to the same port
Date: Fri, 25 Jan 2013 13:06:14 +0800
Message-ID: <510212C6.6060303@network-box.com>
References: <alpine.DEB.2.00.1301221142300.26333@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from erika.network-box.com ([202.52.42.180]:36130 "EHLO
	nbmailscanhq1.network-box.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751502Ab3AYFl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 00:41:59 -0500
In-Reply-To: <alpine.DEB.2.00.1301221142300.26333@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, January 23, 2013 03:49 AM, Tom Herbert wrote:
...
>
> The motivating case for so_resuseport in TCP would be something like
> a web server binding to port 80 running with multiple threads, where
> each thread might have it's own listener socket.  This could be done
> as an alternative to other models: 1) have one listener thread which
> dispatches completed connections to workers. 2) accept on a single
> listener socket from multiple threads.  In case #1 the listener thread
> can easily become the bottleneck with high connection turn-over rate.
> In case #2, the proportion of connections accepted per thread tends
> to be uneven under high connection load (assuming simple event loop:
> while (1) { accept(); process() }, wakeup does not promote fairness
> among the sockets.  We have seen the  disproportion to be as high
> as 3:1 ratio between thread accepting most connections and the one
> accepting the fewest.  With so_reusport the distribution is
> uniform.
>

There is another model for accepting connections in a multi threaded 
application that I experimented with: dup the listener fd one time for 
each thread, then each thread register the fd in its own epoll set, then 
listen and accept independently.

Has anyone had experience with this strategy?  I'm sure that the 
SO_REUSEPORT feature will lead to much better performance, I'm just 
asking from the point of view of one who doesn't have that feature 
available.  I wonder if this strategy is like a poor mans SO_REUSEPORT?

The advantages of this approach were not fully proved in practise, I 
didn't produce any hard figures, but in theory it was appealing:
- no bottleneck of using a single thread for accepting then distributing 
connections (in addition to latency of waiting for the job handling 
thread to receive the event and start its work)
- connections were used in the thread in which they were accepted, thus 
locality was maintained (am I exaggerating this benefit?)
- when a new connection was received, all threads woke up to activity on 
their respective fd copies, and started accepting, I assume from the 
same connection queue.  This was a disadvantage at low load levels as 
threads would often wake and find nothing to do, but as loads got 
higher, strace showed that less threads would awake to disappointment.
- this approach was able to handle stress tests from a hardware packet 
generator, which showed no dropped or unhandled connections.

One disadvantage I imagined was that the single socket and all of its 
duplicates may find themselves attached to one cpu core or hardware 
queue on the network adapter, I don't know enough about the core net 
internals to say for sure, but as a precaution the dup was done in the 
context of the thread that would use the copy.

Just sharing and seeking comments.
