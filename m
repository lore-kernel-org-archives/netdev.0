From: Steve Hill <steve@navaho.co.uk>
Subject: Re: Conntrack leak (2.6.2rc2)
Date: Mon, 2 Feb 2004 13:36:07 +0000 (GMT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402021319440.5347@sorbus2.navaho>
References: <Pine.LNX.4.33.0402021316110.6508-100000@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
In-Reply-To: <Pine.LNX.4.33.0402021316110.6508-100000@blackhole.kfki.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 Feb 2004, Jozsef Kadlecsik wrote:

> To be precise, the destroy function is not called whenever a packet leaves
> the system: it gets called, when conntrack thinks the connection is
> completed. It can happen when whe explicitly know from the packet that it
> finishes the connection (ICMP reply for ICMP non-error messages, and a
> special case for TCP RST), or when the timer of the conntrack entry goes
> off.
> 
> So the destroy function is called when the system sees the ICMP reply
> packet from machine 3 (and there were so many request as reply packets so
> far) - otherwise it'll simply time out the connection.

Yes, this makes sense.  The fact that the connection is removed from the 
hash table indicates that conntrack thinks the connection has gone, but 
the destroy function was never called.  (The connection nolonger appears 
in /proc/net/ip_conntrack).

I turned on the debugging code and got:

----
ip_conntrack_in: new packet for ce8fae40
Altering reply tuple of ce8fae40 to tuple c0357de4: 1 172.16.0.1:5438 -> 
172.17.0.1:0
Altering reply tuple of ce8fae40 to tuple c0357cdc: 1 172.16.0.1:5438 -> 
172.17.0.1:0
Confirming conntrack ce8fae40
conntrack_put ce8faebc 4
conntrack_put ce8faebc 3
clean_from_lists(ce8fae40)
remove_expectations(ce8fae40)
conntrack_put ce8faeb4 3
conntrack_put ce8faec0 4
conntrack_put ce8faec0 3
----

(the conntrack_put debugging was added by me to the nf_conntrack_put() 
function - it shows the pointer to nfct and the usage count).

If it send a small packet through, which won't be fragmented I get:

----
ip_conntrack_in: new packet for ce8fa080
Altering reply tuple of ce8fa080 to tuple c0357de4: 1 172.16.0.1:39486 -> 
172.17.0.1:0
Altering reply tuple of ce8fa080 to tuple c0357d20: 1 172.16.0.1:39486 -> 
172.17.0.1:0
Confirming conntrack ce8fa080
conntrack_put ce8fa0fc 2
clean_from_lists(ce8fa080)
remove_expectations(ce8fa080)
conntrack_put ce8fa0f4 2
conntrack_put ce8fa100 1
destroy_conntrack(ce8fa080)
destroy_conntrack: returning ct=ce8fa080 to slab
----

As you can see, in both cases everything happens in a similar way, except 
when dealing with fragmented packets the usage count is > 1 when 
conntrack_put is called.  Nomatter how long it is left idle, conntrack_put 
is never called again for the packet, so the memory never gets freed.  
However, in both cases the connection is removed from the hash table.

> Machine 3 answers the ping requests, doesn't it? You ping the same IP
> address all the time?

Yes, the machine always responds to the pings and I'm always using the 
same addresses.  My setup is as follows:

[ Machine 1 ]
     | 172.17.0.1/24
     |
     | 172.17.0.254/24
[ Machine 2 ]
     | 172.16.0.254/24
     |
     | 172.16.0.1/24
[ Machine 3 ]

I am consistently testing by making pings from machine 1 to machine 3 - 
machine 3 always responds and there is no other routing in place, so both 
the echo request and the echo reply are being routed through machine 2..

- Steve Hill
Senior Software Developer                        Email: steve@navaho.co.uk
Navaho Technologies Ltd.                           Tel: +44-870-7034015

        ... Alcohol and calculus don't mix - Don't drink and derive! ...
