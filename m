From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Bug with IPv6-UDP address binding
Date: Thu, 09 Aug 2012 11:40:05 +0200
Message-ID: <1344505205.3069.55.camel@localhost>
References: <1344458238.3069.13.camel@localhost>
	 <1344459591.28967.271.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38627 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751723Ab2HIJkO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 05:40:14 -0400
In-Reply-To: <1344459591.28967.271.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-08 at 22:59 +0200, Eric Dumazet wrote:
> On Wed, 2012-08-08 at 22:37 +0200, Jesper Dangaard Brouer wrote:
> > Hi NetDev
> > 
> > I think I have found a problem/bug with IPv6-UDP address binding.
> > 
> > I found this problem while playing with IPVS and IPv6-UDP, but its also
> > present in more basic/normal situations.
> > 
> > If you have two IPv6 addresses, within the same IPv6 subnet, then one
> > of the IPv6 addrs takes precedence over the other (for UDP only).
> > 
> > Meaning that, if connecting to the "secondary" IPv6 via UDP, will
> > result in userspace see/bind the connection as being created to the
> > "primary" IP, even-though tcpdump shows that the IPv6-UDP packets are
> > dest the "secondary".
> > 
> > The result is; that only the first IPv6-UDP packet is delivered to
> > userspace, and the next packets are denied by the kernel as the UDP
> > socket is "established" with the "primary" IPv6 addr.
> > 
> > I would appreciate some hints to where in the IPv6 code I should look
> > for this bug.  If any one else wants to fix it, I'm also fine with
> > that ;-)
> > 
> > 
> > Its quite easy to reproduce, using netcat (nc).
> > 
> > Add two addresses to the "server" e.g.:
> >  ip addr add fee0:cafe::102/64 dev eth0
> >  ip addr add fee0:cafe::bad/64 dev eth0
> > 
> > Run a netcat listener on "server":
> >  nc -6 -u -l 2000
> > (Notice restart the listener between runs, due to limitation in nc)
> > 
> > On the client add an IPv6 addr e.g.:
> >  ip addr add fee0:cafe::101/64 dev eth0
> > 
> > Run a netcat UDP-IPv6 producer on "client":
> >   nc -6 -u fee0:cafe::bad 2000
> > 
> > Notice that first packet, will get through, but second packets will
> > not (nc: Write error: Connection refused).  Running a tcpdump shows
> > that the kernel is sending back ICMP6, destination unreachable,
> > unreachable port.
> > 
> > Its also possible to see the problem, simply running "netstat -uan" on
> > "server", which will show that the "established" UDP connection, is
> > bound to the wrong "Local Address".
> > 
> > (Tested on both latest net-next kernel at commit 79cda75a1, and also
> > on RHEL6 approx 2.6.32)
> > 
> 
> Hi Jesper
> 
> Thats because the "nc -6 -u -l 2000" on server does :
> 
> bind(3, {sa_family=AF_INET6, sin6_port=htons(2000), inet_pton(AF_INET6,
> "::", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = 0
> 
> recvfrom(3, "\n", 1024, MSG_PEEK, {sa_family=AF_INET6,
> sin6_port=htons(53696), inet_pton(AF_INET6, "fee0:cafe::101",
> &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, [28]) = 1
> 
> connect(3, {sa_family=AF_INET6, sin6_port=htons(53696),
> inet_pton(AF_INET6, "fee0:cafe::101", &sin6_addr), sin6_flowinfo=0,
> sin6_scope_id=0}, 28) = 0
> 
> And the kernel automatically chooses a SOURCE address (fee0:cafe::102)
> that is not what you expected (fee0:cafe::bad)

Okay I see.  And this is also the case for IPv4.

Guess I should have read Stephens[1] first, as this problem with
multihomed hosts is described  (on page 219).  He also states, that this
is a problem/feature related to Berkely-derived implementations.  E.g.
Solaris handle this, the way I expected. That is, the source IP address
for the server's reply is the dest IP of the client's request.


> So its a bug in the application.

Yes, I guess its an application bug, because Berkely-derived
implementations don't handle multihomeing well for UDP.

Why are we keeping this, counter-intuitive behavior? 

What about changing the implementation to act like Solaris, which IMHO
makes much more sense?

(BTW, iperf also have this "bug")


> UDP connect() is tricky : In this case, nc should learn on what IP
> address the client sent the frame. (using recvmsg() and appropriate
> ancillary message)

Reading through howto use recvmsg() and parsing of the ancillary
messages.  See [1] "Advanced UDP sockets" page 531-538.  Its quite an
extensive task to extract destination IP address.  No wonder, netcat
missed this part.

> Then nc should bind a new socket on this address, then do the connect()

Yes, after the difficult extraction of the dest IP of the UDP packet.


Now I better understand, why the DNS server named/bind is so annoying,
that is requires a restart after adding IPs.  I guess they didn't
implement this recvmsg(), and instead chooses to bind to all avail IPs
on init/start.

Hints for readers:
For IPv4 is easy to see which is the "secondary" IP via the command "ip
addr" (look for the word "secondary")
For IPv6 I cannot tell which one is the secondary/primary from the "ip
addr" output.  But you can instead do a route lookup via the command
e.g: "ip route get fee0:cafe::102" and look for the "src" field.


[1] UNIX network programming Vol.1 (Networking APIs) by W. Richard
Stevens
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
