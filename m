From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: Conntrack leak (2.6.2rc2)
Date: Mon, 2 Feb 2004 12:45:04 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0402021154410.6508-100000@blackhole.kfki.hu>
References: <Pine.LNX.4.58.0402021039540.5347@sorbus2.navaho>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Hill <steve@navaho.co.uk>
In-Reply-To: <Pine.LNX.4.58.0402021039540.5347@sorbus2.navaho>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 Feb 2004, Steve Hill wrote:

> > > >From my observations, init_conntrack() is being called for each packet
> > > (not fragment, packet), which seems right.
> >
> > No, that's not true (and would be bad). Please check the code.
>
> I have added to the top of init_conntrack():
>     printk("Init conntrack\n");
>
> Doing:
>     ping -n 172.16.0.1 -c 1 -s 2500
> through the machine now causes the kernel to output "Init conntrack",
> proving the function is being called.

Yes, once, on the whole packet. Or do you see the message two times, when
issuing the ping command above once?

> > Yes, because fragmented packets does not lead to conntrack entries -
> > there is nothing to be freed.
>
> If fragmented packets do not lead to conntrack entries, how are their
> connections tracked?  I was under the impression that fragmented packets
> were received by one NIC, defragged, pushed through all the netfilter code
> and then transmitted by another NIC (after being fragmented again if they
> are > MTU size)?

You described exactly what happens: fragmented packets received, defragged
by the stack, and as we get the complete packet, then it handled by
conntrack.

> > I could not reproduce it: test machine with 2.6.1 + patch-2.6.2-rc2,
> > ip_conntrack_max lowered to 10. From another machine, in a loop, 400
> > times:
> >
> > ping -c 1 -s 2500 test-machine
> >
> > No "ip_conntrack: table full, dropping packet" message on test-machine.
> > No problem shown up in /proc/slabinfo either.
>
> Just to confirm, you have your network set up like:
>
>     [ Machine 1 ]----[ Machine 2 ]----[Machine 3]
>
>
> Machines 1 and 3 are running the 2.4 kernel for me, but that shouldn't be
> important.
> Machine 2 is running 2.6.2rc2.

I have only Machine 1 and Machine 2, but that should make no difference.

> I am making > MTU sized pings from machine 1 to machine 3 and machine 2 is
> showing the leak.
>
> Pinging machine 2 from machine 1 does not show any such problems.

That's really, really strange! Both for local and forwarded packets
ip_conntrack_in is called, which first checks the fragments and calls
defragging, when required. If there were a leak when pinging
machine 3, then there should be a leak when pinging machine 2 as well.

I'll setup an UML-net to test the forwarded case, but I expect negative
results.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@sunserv.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
