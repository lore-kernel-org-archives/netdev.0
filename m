From: Jonathan Day <imipak@yahoo.com>
Subject: Re: Dynamically classifying flows?
Date: Mon, 7 Mar 2005 15:17:10 -0800 (PST)
Message-ID: <20050307231710.52440.qmail@web31510.mail.mud.yahoo.com>
References: <7bca1cb505030709502316f9b8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Asim Shankar <asimshankar@gmail.com>, netdev@oss.sgi.com
In-Reply-To: <7bca1cb505030709502316f9b8@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It depends a bit on what OS you are using, as to the
best strategy to follow.

Linux has Layer 7 packet classification, so it should
be possible to identify the more troublesome
applications and have them in seperate queues. I don't
think BSD's ALTQ has that capability, but I could be
wrong. Other Operating Systems are anybody's guess.

If applications are likely to misbehave, and in a
manner that is unpredictable, then something in the
"Fair Queueing" family would seem a good place to
start. Your primary goal is not to impose bounds on
the traffic as much as it is to place bounds on the
penalties imposed, so it's not clear that you'd
necessarily need to know whether something is bulk or
interactive, you'd just need to know if it would cause
problems if it were given greater bandwidth.

RED is good under certain conditions, not so good
under others. There are many members of the RED
family, so you might want to shop around a little.
There may be something that is perfect for your
situation.

I'd suggest ECN, but most applications don't pay
attention to notifications. Worth a look, though - the
OS might understand ECN and throttle the application
on its behalf. (Sounds sadistic.)

If you definitely want classful QoS, then I'd say make
two classes - everything definitely known & needing
high bandwidth, and everything else. Configure it so
that your second class can NEVER steal used bandwidth
from the first, but CAN be loaned it if there's
insufficient interactive traffic to fill the quota it
has been given. That way, you needn't care about
"unknown" stuff, or whatever, because it'll all be
lumped into the second class, unless it is
specifically designated as being in the first class.



--- Asim Shankar <asimshankar@gmail.com> wrote:

> Hi,
> 
> I was looking into various queueing disciplines and
> had some thoughts/queries.
> This email is going to be fairly high-level and
> somewhat long, so I'd be
> grateful if you can bear with me.
> 
> Okay, so qdiscs can be run in various ways - FIFO,
> Round Robin (SFQ, PRIO),
> HTB etc. Grossly oversimplified, I see all these
> strategies as allowing
> administrators to statically define packet classes
> and class priorities, and
> then possibly ensuring fairness amongst packets with
> equal class priotities.
> 
> This "staticness" of class priorities *may* lead to
> some problems (well, I'm
> going to ask if they can). Consider a huge, popular
> file on an HTTP server.
> Due to its popularity, requests for small pages may
> suffer. Similarly,
> consider an SSH/SFTP server where SFTP traffic for
> large, popular files may
> choke the SSH terminal connections (especially if
> the application doesn't set
> the TOS bits or routers along the way ignore them).
> So we have interactive
> flows (like someone SSHing to do some 'ls'es or many
> clients viewing a small
> web-page) and bulk flows (downloads). By "flow" I
> mean a connection, not
> necessarily an explicit TCP connection but a loose
> definition - say something
> that "ip_conntrack" tracks.
> 
> Question 1: Can the number of and speed with which
> bulk flow packets are
> generated adversely affect the interactive flows -
> i.e., can too many large
> file downloads make the 'ls' or the small page
> downloads slow? Is this a
> _likely_ scenario?
> 
> Diffserv already in effect tries to classify traffic
> as interactive or
> bulk. However, this classification is still static
> and requires application
> cooperation, which may not always be available or
> may be overridden. Web
> servers for example don't change the TOS fields
> depending on whether the
> file requested was a 700MB CD-image or a 2K
> homepage.
> 
> Question 2: Does the idea of _dynamically_
> classifying traffic as interactive
> or bulk make any sense at all? Or does the TOS field
> work well enough for
> dynamic classification to not be of any practical
> interest?
> 
> If it does make sense,
> 
> Question 3: Has work already been along along these
> lines? If so, any pointers
> would be appreciated.
> 
> Can we use ideas from process scheduling to be
> kinder to the interactive
> flows? A "process" becomes a "flow", the "CPU"
> becomes the "NIC" and "time"
> becomes "bytes". Process scheduling tries to keep
> system responsiveness high
> by dynamically classifying processes as interactive
> or bulk and then making
> interactive process priorities higher than
> non-interactive. A similar strategy
> at the qdisc would mean that when the interactive
> flow has something to send,
> it will get a higher priority. Flows will be
> dynamically assigned priorities
> based on the history of traffic they generate.
> 
> Applying process scheduling would be somewhat
> expensive (we're keeping track
> of connections). RED on the other hand does
> something *like* this by making
> the probability of a packet drop of a particular
> flow proportional to the
> traffic generated by the flow, of course it does so
> without any explicit
> notion of flows. This leads to:
> 
> Question 5: Does RED provide *everything* this
> process-scheduling strategy
> would? i.e., how would you compare the two?
> 
> Well, I guess that completes my question list for
> now.
> Thanks for reading (and replying :-)),
> Regards,
> 
> -- Asim
> 
> 


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
