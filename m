From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: [tproxy] udp + tproxy
Date: Thu, 13 Nov 2008 08:25:54 +0100
Message-ID: <1226561154.15193.10.camel@bzorp.balabit>
References: <1226490030.31896.12.camel@sysandrey.icomswg.local>
	 <20081112185910.GA1793@sch.bme.hu>
	 <1226518030.10667.68.camel@bzorp.balabit>
	 <alpine.LNX.1.10.0811130815300.8076@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: KOVACS Krisztian <hidden@sch.bme.hu>,
	Andrey Luzgin <andrey@icomsw.com>, tproxy@lists.balabit.hu,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.1.10.0811130815300.8076@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-11-13 at 08:17 +0100, Jan Engelhardt wrote:
> On Wednesday 2008-11-12 20:27, Balazs Scheidler wrote:
> >> 
> >> Since tproxy 4 (unlike tproxy 2) doesn't modify the incoming packets in
> >> any way you should be able to get the correct destination address by
> >> simply calling recvfrom() and using the source address returned by the
> >> kernel.
> >
> >This is not true, recvfrom() returns the client address and does not
> >return the original destination.
> 
> Mh, perhaps getsockname() could do something - well, at least
> if used with accept() and as such, mostly for TCP only.
> 

Well, here's my other mail on the subject on the tproxy list, it
basically details that we do have an implementation of accept() for UDP
which we use in production. But I'm not sure that could be integrated to
mainline.

-<- quote ->-

Well, for supporting UDP with tproxy4 we use a different approach:
udp_accept(), you can find it in the BalaBit kernel patch tree at
http://www.balabit.com/downloads/files/kernel-patches/

The way udp_accept() works is as follows:
  * the userspace proxy opens a "listening" udp socket, binds it to the
listening address, performs no connect() calls
  * tproxy redirects packets to this socket just like in the case for
TCP
  * whenever the socket becomes readable from the userspace proxy,
accept() is invoked on the UDP socket, this accept() is implemented by
the patch mentioned above
  * in kernel space: the first packet is consulted from the socket
buffer of the listening socket
  * the kernel opens a new UDP socket, just like the accept() call for
TCP does
  * this new UDP socket is bound this way: 
    * local address is the same as the destination address of the
incoming packet
    * destination address is the same as the source address of the
incoming packet
  * the socket buffer of the listening socket is traversed, and each
packet having the same IP addresses as the first packet is moved to the
newly opened socket; this traversal is happening in an atomic context,
thus no new packets can arrive
  * a reference to the newly opened socket is returned to userspace
  * when a new packet comes in, the socket lookup will prefer the
completely bound socket over the listening socket

Since at the end of the accept() call you get a completely bound socket,
you can simply call getsockname() to query the target address, just like
with TCP.

Hope this helps.

PS: I was talking to Patrick McHardy whether to send the udp_accept()
patch for kernel inclusion, he said it might be worth trying, however he
was not completely sure it'd be integrated. So I didn't push it so far.


-- 
Bazsi


