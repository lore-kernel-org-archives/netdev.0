From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH RFC 0/2] kproxy: Kernel Proxy
Date: Thu, 29 Jun 2017 21:54:02 +0200
Message-ID: <20170629195402.GA10048@1wt.eu>
References: <1498760825-8516-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:53815 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751666AbdF2TyJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 15:54:09 -0400
Content-Disposition: inline
In-Reply-To: <1498760825-8516-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Thu, Jun 29, 2017 at 11:27:03AM -0700, Tom Herbert wrote:
> Sidecar proxies are becoming quite popular on server as a means to
> perform layer 7 processing on application data as it is sent. Such
> sidecars are used for SSL proxies, application firewalls, and L7
> load balancers. While these proxies provide nice functionality,
> their performance is obviously terrible since all the data needs
> to take an extra hop though userspace.
> 
> Consider transmitting data on a TCP socket that goes through a
> sidecar paroxy. The application does a sendmsg in userpsace, data
> goes into kernel, back to userspace, and back to kernel. That is two
> trips through TCP TX, one TCP RX, potentially three copies, three
> sockets are touched, and three context switches. Using a proxy in the
> receive path would have a similarly long path.
> 
> 	 +--------------+      +------------------+
> 	 |  Application |      | Proxy            |
> 	 |              |      |                  |
> 	 |  sendmsg     |      | recvmsg sendmsg  |
> 	 +--------------+      +------------------+
> 	       |                    |       |
>                |                    ^       |
> ---------------V--------------------|-------|--------------
> 	       |                    |       |
> 	       +---->--------->-----+       V
>             TCP TX              TCP RX    TCP TX
>   
> The "boomerang" model this employs is quite expensive. This is
> even much worse in the case that the proxy is an SSL proxy (e.g.
> performing SSL inspection to implement and application firewall).

In fact that's not much what I observe in field. In practice, large
data streams are cheaply relayed using splice(), I could achieve
60 Gbps of HTTP forwarding via HAProxy on a 4-core xeon 2 years ago.
And when you use SSL, the cost of the copy to/from kernel is small
compared to all the crypto operations surrounding this.

Another point is that most HTTP requests are quite small (typically ~80%
20kB or less), and in this case the L7 processing and certain syscalls
significantly dominate the operations, data copies are comparatively
small. Simply parsing a HTTP header takes time (when you do it correctly).
You can hardly parse and index more than 800MB-1GB/s of HTTP headers
per core, which limits you to roughly 1-1.2 M req+resp per second for
a 400 byte request and a 400 byte response, and that's without any
processing at all. But when doing this, certain syscalls like connect(),
close() or epollctl() start to be quite expensive. Even splice() is
expensive to forward small data chunks because you need two calls, and
recv+send is faster. In fact our TCP stack has been so much optimized
for realistic workloads over the years that it becomes hard to gain
more by cheating on it :-)

In the end in haproxy I'm seeing about 300k req+resp per second in
HTTP keep-alive and more like 100-130k with close, when disabling
TCP quick-ack during accept() and connect() to save one ACK on each
side (just doing this generally brings performance gains between 7
and 10%).

Regarding kernel-side protocol parsing, there's an unfortunate trend
at moving more and more protocols to userland due to these protocols
evolving very quickly. At least you'll want to find a way to provide
these parsers from userspace, which will inevitably come with its set
of problems or limitations :-/

All this to say that while I can definitely imagine the benefits of
having in-kernel sockets for in-kernel L7 processing or filtering,
I'm having strong doubts about the benefits that userland may receive
by using this (or maybe you already have any performance numbers
supporting this ?).

Just my two cents,
Willy
