From: Steve Hill <steve@navaho.co.uk>
Subject: Re: Conntrack leak (2.6.2rc2)
Date: Mon, 2 Feb 2004 09:46:19 +0000 (GMT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402020937030.4127@sorbus2.navaho>
References: <Pine.LNX.4.33.0402021016450.6508-100000@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
In-Reply-To: <Pine.LNX.4.33.0402021016450.6508-100000@blackhole.kfki.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 Feb 2004, Jozsef Kadlecsik wrote:

> init_conntrack is called only when we have full, non-fragmented
> packets: ip_conntrack_in explicitly calls the proper function to gather
> the fragments before calling init_conntrack. There is no memory leak
> there.

>From my observations, init_conntrack() is being called for each packet 
(not fragment, packet), which seems right.  destroy_conntrack() is, 
however, _not_ being called for any packets that are fragmented (i.e. it 
is not being called for the complete packet).  This is leading to the 
memory never being freed, and the conntrack count never being decremented 
even though the connection has been removed from the hash table.

There _is_ a memory leak here - it is observable and completely 
reproducable.  If I make a number of > MTU sized pings from a machine 
connected to one NIC to a machine connected another NIC (i.e. the packets 
will be fragmented), ip_conntrack_count grows until it reaches 
ip_conntrack_max, at which point it starts dropping new connections.  the 
ip_conntrack memory listed in /proc/slabinfo also grows.  Neither the 
memory or the connection count ever shrink again.

- Steve Hill
Senior Software Developer                        Email: steve@navaho.co.uk
Navaho Technologies Ltd.                           Tel: +44-870-7034015

        ... Alcohol and calculus don't mix - Don't drink and derive! ...
