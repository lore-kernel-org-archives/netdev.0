From: Ilya Pashkovsky <ilya.pashkovsky@gmail.com>
Subject: [PATCH] port_reuse listen fix (allow simultaneous single listen + outgoing connects from same port)
Date: Fri, 10 Dec 2004 01:39:53 +0200
Message-ID: <fcb9aa2904120915397e3da851@mail.gmail.com>
References: <fcb9aa29041209032521899698@mail.gmail.com>
	 <8783be6604120907367db1fda5@mail.gmail.com>
	 <fcb9aa290412091010124f754@mail.gmail.com>
	 <8783be66041209103567bb3310@mail.gmail.com>
	 <fcb9aa290412091537b2215bd@mail.gmail.com>
Reply-To: Ilya Pashkovsky <ilya.pashkovsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <fcb9aa290412091537b2215bd@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

if the SYN of clientA is accepted before clientB called connect and
clientB is listening on that port, the connection will be accepted no
matter what, and this is the expected and good behavior. In process of
calling connect(), clientB will get an EADDRINUSE error and will stop
connecting.
In case the calls are already underway to connect (ports bound) then
the new packets will get into the new cross-connection by default and
not into the listening socket, since the new cross-connection tuple
exists. This is guaranteed by setting the connection state flag before
calling get_port.
Can still see no added ambiguities in this patch yet...If you can help
find some, it would be very nice of you indeed.

Thanks for comments up to now.




On Thu, 9 Dec 2004 13:35:54 -0500, Ross Biro <ross.biro@gmail.com> wrote:
> But what if the tuple is not taken.  This code exposes a race condition.
>
> Imagine if first you bind the servers and listne.
>
> Then you bind the clients.
>
> Then the clients send the syn packets.
>
> If the syn's cross on the wire, then the clients will connect to each
> other.  If one of the syns arrives before the other machine calls
> connect, then one machine will have a minisocket for the server, but
> the other will still be able to send a syn, which will cause a bogus
> reset and kill one of the connections.  I'm not 100% sure which one,
> but my guess would be the new one.
>
> In any event, you have a bunch of bad behaviour at the boundary and
> need to do something about it.
>
>    Ross
>
> On Thu, 9 Dec 2004 20:10:27 +0200, Ilya Pashkovsky
>
>
> <ilya.pashkovsky@gmail.com> wrote:
> > if this tuple (srcip,destip,srcport,destport) is already taken, you'll
> > get an EADDRINUSE error as you should. The fix only fixes the
> > behaviour of not allowing even a single listener to coexist with
> > outgoing connections from same port. In fact, SO_REUSEADDR on linux
> > should and does implement the behaviour of SO_REUSEPORT of BSD, except
> > for listener preemption (since its not useful and would require
> > several security checks).
> > The current fix allows piercing firewalls for the needing and maybe
> > TCP NAT traversal in the future (if some vendor produces a Full-cone
> > TCP NAT).
> >
> >
> >
> >
> > On Thu, 9 Dec 2004 10:36:08 -0500, Ross Biro <ross.biro@gmail.com> wrote:
> > > On Thu, 9 Dec 2004 13:25:26 +0200, Ilya Pashkovsky
> > >
> > >
> > > <ilya.pashkovsky@gmail.com> wrote:
> > > > This is the latest patch with removed bool > 1 check and ipv6 support.
> > > > http://puding.mine.nu/patches/
> > > > http://puding.mine.nu/patches/patch-reuse-bool-ipv6
> > > >
> > > > to check, you can use netcat (sets SO_REUSEADDR by default).
> > > > on one host (host A): nc -v -l -p 9999
> > > > on another/same host (host B): nc -v -l -p 9000
> > > > on host A: nc -v -p 9999 host.B.ip.addr 9000
> > > > on host B: nc -v host.A.ip.addr 9999
> > >
> > > What happens if on host B you do
> > >
> > > nc -v -p 9000 host.A.ip.addr 9999?
> > >
> > > Seems to me you will break the rule that a connection is uniquely
> > > identified by (srcpip, destip, srcport, destport).
> > >
> > >    Ross
> > >
> >
>
