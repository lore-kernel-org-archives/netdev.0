From: Cacophonix <cacophonix@yahoo.com>
Subject: Fwd: Re: Replace the Nagle Algorithm
Date: Mon, 20 Oct 2003 17:36:05 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031021003605.41403.qmail@web14002.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: JCONLIN@novell.com, cacophonix@yahoo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Thanks for the pointer, interesting idea. Some comments below.
cheers,
karthik


> --- "Joseph Conlin" <JCONLIN@n...> wrote:
> I see in the archives and the code that I have looked at (2.4.22,
> 2.6.0-test8) that the Minshall algorithm is being used to reduce the
> effects of Nagle/delayed ACK interaction.  I haven't seen any mention of
> the following solution, proposed as an IETF draft RFC by Joe Doupnik
> (jrd@c...).
> 
> http://netlab1.usu.edu/pub/misc/draft-doupnik-tcpimpl-nagle-mode-00.txt
> 
> 
> If anyone is interested, I have an Excel spreadsheet that shows some
> testing I did with FreeBSD using Nagle-off, Nagle-on, and Doupnik using
> HTTP requests.  It shows that Doupnik gets the same packet-size
> efficiency as Nagle-on while getting better throughput than having
> Nagle-off.  Let me know if you would like a copy.

Yes please, but only if you have some comparisons with Linux 2.4+ which implements
the Nagle+Minshall extensions, which should not have the perf problem reported in
the draft (which measures Linux 2.2).

Reading through the draft, the tradeoff the new proposal makes is in allowing greater
control to the transmitter to send packets at it's (application's) whim, at the risk
of larger number of small packets in transit at any point in time within the network.

For example, as quoted within the draft:

  "In an extreme case the application may perform
  single octet writes in massive succession before reading a response.
  If the network can drain data faster than the application can create
  data (a classical queueing problem) then massive quantities of tiny
  segments will appear on the network. That imposes a very heavy load
  on both hosts and network communications"

The current Linux Nagle+Minshall combo can have at most one "small" unacked packet
in transit in the network at any given time, while in the new approach, if the tcp
stack guesses application behavior incorrectly, it's possible that there could be
numerous small packets flooding the network. (For example, think someone typing fast
in a ssh/telnet session).

In addition, more packets means potentially increased interrupt processing on the
host (modulo napi or interrupt mitigation), thereby making me question the benefit
to the transmitter.

And IIRC, the whole point of Nagle was to conserve network bandwidth by not having
applications flood the network with small packets. If I read this draft correctly, it
tries to get the tcp stack to guess application behavior to accomplish the same result,
but is liable to get it wrong.

I'd love to see any perf numbers you have with linux 2.4. The intent of implementing
the Minshall extensions was to eliminate the kind of Nagle problems described in the
draft, and thus far, I haven't seen any reports of problems on linux-netdev (while
still being a good network citizen).




__________________________________
Do you Yahoo!?
The New Yahoo! Shopping - with improved product search
http://shopping.yahoo.com
