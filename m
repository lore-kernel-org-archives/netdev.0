From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: Conntrack leak (2.6.2rc2)
Date: Mon, 2 Feb 2004 11:34:22 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0402021121540.6508-100000@blackhole.kfki.hu>
References: <Pine.LNX.4.58.0402020937030.4127@sorbus2.navaho>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Hill <steve@navaho.co.uk>
In-Reply-To: <Pine.LNX.4.58.0402020937030.4127@sorbus2.navaho>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 Feb 2004, Steve Hill wrote:

> > init_conntrack is called only when we have full, non-fragmented
> > packets: ip_conntrack_in explicitly calls the proper function to gather
> > the fragments before calling init_conntrack. There is no memory leak
> > there.
>
> >From my observations, init_conntrack() is being called for each packet
> (not fragment, packet), which seems right.

No, that's not true (and would be bad). Please check the code.

> destroy_conntrack() is, however, _not_ being called for any packets
> that are fragmented

Yes, because fragmented packets does not lead to conntrack entries -
there is nothing to be freed.

> There _is_ a memory leak here - it is observable and completely
> reproducable.  If I make a number of > MTU sized pings from a machine
> connected to one NIC to a machine connected another NIC (i.e. the packets
> will be fragmented), ip_conntrack_count grows until it reaches
> ip_conntrack_max, at which point it starts dropping new connections.  the
> ip_conntrack memory listed in /proc/slabinfo also grows.  Neither the
> memory or the connection count ever shrink again.

I could not reproduce it: test machine with 2.6.1 + patch-2.6.2-rc2,
ip_conntrack_max lowered to 10. From another machine, in a loop, 400
times:

ping -c 1 -s 2500 test-machine

No "ip_conntrack: table full, dropping packet" message on test-machine.
No problem shown up in /proc/slabinfo either.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@sunserv.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
