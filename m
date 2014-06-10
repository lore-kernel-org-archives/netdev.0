From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: SCTP's processing of unexpected COOKIE_ECHO doesn't seem useful.
Date: Tue, 10 Jun 2014 14:09:39 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725A469@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D17259B99@AcuExch.aculab.com>
 <53970BB3.5010909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Vlad Yasevich' <vyasevich@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:36433 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751058AbaFJOK1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 10:10:27 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 03184-02 for <netdev@vger.kernel.org>;
 Tue, 10 Jun 2014 15:10:18 +0100 (BST)
In-Reply-To: <53970BB3.5010909@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich [ 
> On 06/10/2014 05:52 AM, David Laight wrote:
> > I'm seeing some unexpected (to me) behaviour of the SCTP stack
> > when the remote system restarts.
> >
> > I've a socket that has a single association, and I'm rather
> > expecting TCP-like behaviour.
> > So I'd expect some kind of failure condition on my existing
> > connection, and then a new connection be established on a
> > different socket - eg though a listening socket.
> > This would then go through all my code for correctly
> > initialising a new connection.
> >
> > What happens is rather different.
> >
> > The remote sends an INIT with the same port numbers as the
> > previous connection, AFAICT the code sends an INIT_ACK with
> > some numbers taken from the existing TCB.
> >
> > When the COOKIE_ECHO is received sctp_sf_do_5_2_4_dupcook()
> > is called, condition 'A' is detected and sctp_sf_do_dupcook_a()
> > called.
> >
> > RFC 2960 says that this should be treated as a received ABORT
> > followed by a COOKIE echo - this sounds fine, I want the ABORT
> > processing to kill the existing connection.
> > However it then says that 'RESTART' should be indicated to the ULP
> > rather than 'COMMUNICATION LOST'.
> >
> > AFAICT this is just silently ignored by the socket layer.
> > I've a process sleeping in recv() (actually a kernel thread in
> > sock_recvmsg()) and it is not woken up at all.
> 
> You haven't subscribed to receive notifications and as a result
> you haven't been woken up.

I've spent some time reading the morass^Wcode and discovered where
the notification gets dropped.

> The ABORT treatment above simply resets the state of the original
> connection, thus simulating the ABORT and a new connection all
> in one.

This might be nice for the remote side, but isn't really useful
for many applications - imagine what ftp would have to do...

> This is where an application really needs to utilize and process
> SCTP notifications.  You can also collect data like which messages
> have not been send to the remote, so that you can re-queue them.

Yes, I guess the last bit comes from trying to emulate the MTP2 'retrieval',
however it is probably a waste of time unless all the timers have been
reduced to a few 10s of milliseconds.

> > This leaves the 'application' code in completely the wrong state for
> > the SCTP connection.
> >
> 
> I can understand where you are coming from.  There are some useful
> cases for association restart, but it could also be turned off
> without much adverse effect to the applications.

I can image the notifications being useful for UDP style sockets, or
where the messages themselves are idempotent (maybe something like
DNS lookups), but if there is any application level state processing
the RESTART event is probably quite difficult.

> May be a sysctl or a socket option that allows you control whether you
> want association restart or not might be nice to have.

A 1-1 TCP-style socket that doesn't have the notifications enabled would
be a good start.

	David
