From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Dynamically classifying flows?
Date: Mon, 7 Mar 2005 21:34:50 +0100
Message-ID: <20050307203450.GX31837@postel.suug.ch>
References: <7bca1cb505030709502316f9b8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Asim Shankar <asimshankar@gmail.com>
Content-Disposition: inline
In-Reply-To: <7bca1cb505030709502316f9b8@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Asim Shankar <7bca1cb505030709502316f9b8@mail.gmail.com> 2005-03-07 11:50
> Okay, so qdiscs can be run in various ways - FIFO, Round Robin (SFQ, PRIO),
> HTB etc. Grossly oversimplified, I see all these strategies as allowing
> administrators to statically define packet classes and class priorities, and
> then possibly ensuring fairness amongst packets with equal class priotities.
> 
> This "staticness" of class priorities *may* lead to some problems (well, I'm
> going to ask if they can). Consider a huge, popular file on an HTTP server.
> Due to its popularity, requests for small pages may suffer. Similarly,
> consider an SSH/SFTP server where SFTP traffic for large, popular files may
> choke the SSH terminal connections (especially if the application doesn't set
> the TOS bits or routers along the way ignore them). So we have interactive
> flows (like someone SSHing to do some 'ls'es or many clients viewing a small
> web-page) and bulk flows (downloads). By "flow" I mean a connection, not
> necessarily an explicit TCP connection but a loose definition - say something
> that "ip_conntrack" tracks.

The example of SSH is bad because it behaves very well. A scp/sftp will have
different DSCP flags than "normal" SSH sessions.

> Question 1: Can the number of and speed with which bulk flow packets are
> generated adversely affect the interactive flows - i.e., can too many large
> file downloads make the 'ls' or the small page downloads slow? Is this a
> _likely_ scenario?

It is a likely scenario but usually not a problem because you can classify this
kind of bulk packets by their size. u32 can be used use for such things or the
newly added meta ematch.

A much worse scenarios is a high amount of new, short living connections
because it is hard to classify those on non-static patterns and they pollute
all your queues. A real world scenario for this is a bunch of bittorrent users
in your network.

> Question 2: Does the idea of _dynamically_ classifying traffic as interactive
> or bulk make any sense at all? Or does the TOS field work well enough for
> dynamic classification to not be of any practical interest?

Yes it does and that's exactly the direction the ematch API is going to.

> Question 3: Has work already been along along these lines? If so, any pointers
> would be appreciated.

Quite a few papers but most of them don't work in practice for me.

> Can we use ideas from process scheduling to be kinder to the interactive
> flows? A "process" becomes a "flow", the "CPU" becomes the "NIC" and "time"
> becomes "bytes". Process scheduling tries to keep system responsiveness high
> by dynamically classifying processes as interactive or bulk and then making
> interactive process priorities higher than non-interactive. A similar strategy
> at the qdisc would mean that when the interactive flow has something to send,
> it will get a higher priority. Flows will be dynamically assigned priorities
> based on the history of traffic they generate.

In order to prioritize there must be a queue, and for remote terminal protocols
you want to avoid queues at any cost because it will introduce latency in any
case. Even on overloaded lines with full queues, the queues are rarely bigh
enough to really apply any sort of priority queues.

Another problem that arises is that usually you want different queue parameters
depending on the type of traffic it holds. I'm not sure if it would help to
determine those more dynamically, intuitively I'd say it doesn't make too much
sense but feel free to prove me wrong.
