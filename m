From: Steve Hill <steve@navaho.co.uk>
Subject: Re: Conntrack leak (2.6.2rc2)
Date: Mon, 2 Feb 2004 11:58:13 +0000 (GMT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402021146370.5347@sorbus2.navaho>
References: <Pine.LNX.4.33.0402021154410.6508-100000@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
In-Reply-To: <Pine.LNX.4.33.0402021154410.6508-100000@blackhole.kfki.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 Feb 2004, Jozsef Kadlecsik wrote:

> Yes, once, on the whole packet. Or do you see the message two times, when
> issuing the ping command above once?

No, only once for the whole packet (sorry, I think I didn't do a good job 
of describing the problem).
init_conntrack() always gets called once for the whole packet (this seems 
right to me).  However, destroy never gets called for the whole packet if 
the packet was fragmented, which seems to be  the source of the leak - 
init_conntrack was called and allocated for the whole packet but that 
memory is never freed again if the packet was fragmented.

I've added some debugging code into nf_conntrack_put() and it seems that 
if it's called on a packet that was fragmented, the usage count is > 1 so 
it never gets freed.  I'm not sure if anything is actually using the 
packet at that point though or if something has just forgotten to 
decrement the usage count though - in any case, it never gets called with 
a usage count <= 1.

> >     [ Machine 1 ]----[ Machine 2 ]----[Machine 3]
> >
> >
> > Machines 1 and 3 are running the 2.4 kernel for me, but that shouldn't be
> > important.
> > Machine 2 is running 2.6.2rc2.
> 
> I have only Machine 1 and Machine 2, but that should make no difference.

Pinging from machine 1 to machine 2 didn't cause any problem for me.  

I have just tried pinging from machine 2 to machine 1 (or 3) and this also 
isn't causing a problem.  The leak is only showing itself if the machine 
is routing packets from one network segment to another, not if the machine 
itself is the source or destination.

> I'll setup an UML-net to test the forwarded case, but I expect negative
> results.

Thanks - I'm doing my best to debug the problem, but I'm not at all 
familiar with the networking code so I'm having to start at the ground and 
work my way up (which is good since I don't have any preconceptions about 
that way it _should_ work, but bad in the fact I'm having to learn it all 
from scratch which takes time).


- Steve Hill
Senior Software Developer                        Email: steve@navaho.co.uk
Navaho Technologies Ltd.                           Tel: +44-870-7034015

        ... Alcohol and calculus don't mix - Don't drink and derive! ...
