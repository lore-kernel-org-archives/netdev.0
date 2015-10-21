From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is
 incorrect for sockets in accept(3)
Date: Wed, 21 Oct 2015 04:28:52 -0700
Message-ID: <1445426932.22974.43.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151019095938.72ea48e6@xeon-e3>
	 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <562594E1.8040403@oracle.com>
	 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56261092.7080003@oracle.com>
	 <1445347173.22974.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56264596.90104@oracle.com>
	 <1445355027.22974.22.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5626887D.5050308@oracle.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CBBD206@AcuExch.aculab.com>
	 <56276DA2.8010905@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34625 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbbJUL2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 07:28:54 -0400
Received: by padhk11 with SMTP id hk11so52800205pad.1
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 04:28:54 -0700 (PDT)
In-Reply-To: <56276DA2.8010905@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-10-21 at 11:49 +0100, Alan Burlison wrote:
> On 21/10/2015 11:25, David Laight wrote:
> 
> >> The problem with poll() is that it returns immediately when passed a FD
> >> that is in the listening state. rather than waiting until there's an
> >> incoming connection to handle. As I said, that means you can't use
> >> poll() to multiplex between read/write/accept sockets.
> >
> > That seems to work for me...
> 
> In my test case I was setting all the available event bits in 
> pollfd.events to see what came back. With poll() on a listen() socket 
> you get an immediate return with bits set in revents indicating the 
> socket is available for output, which of course it isn't. Indeed an 
> attempt to write to it fails. If you remove the output event bits in 
> pollfd.events then the poll() waits as expected until there's an 
> incoming connection on the socket.
> 
> I suppose one answer is "Well, don't do that then" but returning an 
> output indication on a socket that's in listen() seems rather odd.
> 
> With POLLOUT|POLLWRNORM|POLLWRBAND:
> 
> main: polling #1
> [returns immediately]
> main: poll #1: Success
> poll fd: 0 revents: POLLOUT POLLWRBAND
> main: write #1: Transport endpoint is not connected
> 
> Without POLLOUT|POLLWRNORM|POLLWRBAND:
> 
> main: polling #1
> [waits for connection]
> main: poll #1: Success
> poll fd: 0 revents: POLLIN POLLRDNORM
> 

This works for me. Please double check your programs

242046 poll([{fd=3, events=POLLIN|POLLOUT|POLLWRNORM|POLLWRBAND}], 1, 4294967295 <unfinished ...>
242046 <... poll resumed> )             = 1 ([{fd=3, revents=POLLIN}])
242046 accept(3, {sa_family=AF_INET6, sin6_port=htons(35888), inet_pton(AF_INET6, "::ffff:10.246.7.151", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, [28]) = 4
242046 close(4)                         = 0
242046 poll([{fd=3, events=POLLIN|POLLOUT|POLLWRNORM|POLLWRBAND}], 1, 4294967295) = 1 ([{fd=3, revents=POLLIN}])
242046 accept(3, {sa_family=AF_INET6, sin6_port=htons(35890), inet_pton(AF_INET6, "::ffff:10.246.7.151", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, [28]) = 4
242046 close(4)                         = 0
242046 poll([{fd=3, events=POLLIN|POLLOUT|POLLWRNORM|POLLWRBAND}], 1, 4294967295) = 1 ([{fd=3, revents=POLLIN}])
242046 accept(3, {sa_family=AF_INET6, sin6_port=htons(35892), inet_pton(AF_INET6, "::ffff:10.246.7.151", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, [28]) = 4
242046 close(4)                         = 0
242046 poll([{fd=3, events=POLLIN|POLLOUT|POLLWRNORM|POLLWRBAND}], 1, 4294967295) = 1 ([{fd=3, revents=POLLIN}])
242046 accept(3, {sa_family=AF_INET6, sin6_port=htons(35894), inet_pton(AF_INET6, "::ffff:10.246.7.151", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, [28]) = 4
242046 close(4)                         = 0

poll() only cares about POLLIN | POLLRDNORM for a listener.


static inline unsigned int inet_csk_listen_poll(const struct sock *sk)
{
        return !reqsk_queue_empty(&inet_csk(sk)->icsk_accept_queue) ?
                        (POLLIN | POLLRDNORM) : 0;
}

if (sk->sk_state == TCP_LISTEN)
    return inet_csk_listen_poll(sk);
