From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 14:33:01 -0800
Message-ID: <1447972381.22599.278.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
	 <20151119.005318.838757439536205791.davem@davemloft.net>
	 <CANP3RGcPRzSL06qZB9oewrvN_AUUodnYzXQO=itoK40z64x8Yw@mail.gmail.com>
	 <20151119.104811.1447518072450380661.davem@davemloft.net>
	 <1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S363gYA37GnEuArp+PKVjFdLchB_66zuLF5kJnSFKF4t6Q@mail.gmail.com>
	 <1447969264.22599.253.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S374xUUzWXUgA27PubceyDckrrfTiq7wvkLxXa0NacqqZA@mail.gmail.com>
	 <1447970875.22599.265.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S35CxmsN6Cx0BXCyqzWE67HF9SwTPAyzRnbVFKun8AOTYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	zenczykowski <zenczykowski@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35155 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbbKSWdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 17:33:05 -0500
Received: by pacej9 with SMTP id ej9so94300443pac.2
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 14:33:03 -0800 (PST)
In-Reply-To: <CALx6S35CxmsN6Cx0BXCyqzWE67HF9SwTPAyzRnbVFKun8AOTYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-11-19 at 14:14 -0800, Tom Herbert wrote:
> On Thu, Nov 19, 2015 at 2:07 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Thu, 2015-11-19 at 13:53 -0800, Tom Herbert wrote:
> >
> >> That covers the case where the local address is removed, but the not
> >> the case where the network manager is informed of an error in the path
> >> and wants to signal the application. My understanding was that
> >> SIOCKILLADDR would work for the first case, but this patch was need to
> >> cover the second case.
> >>
> >> btw, instead of closing the TCP socket can we just report an error and
> >> wake up the application without affecting the connection? That is this
> >> just becomes an error on the socket. The response by the application
> >> will be the same in any case, porbablly just close the socket and try
> >> to reestablish the connection.
> >
> > I thought this was the patch intent ?
> >
> > Application gets a EPOLLIN|EPOLLOUT|POLLERR notification (if it is
> > willing to receive it, or blocked in a socket syscall) and closes the
> > socket.
> >
> >          sk->sk_err = ETIMEDOUT;
> >          sk->sk_error_report(sk);
> >          tcp_done(sk);
> >
> The tcp_done is not needed here. This is the difference between the
> application having the connection closed underneath them, versus the
> application performing a close to terminate the connection. The latter
> behavior preserves the semantics that only the stack or the
> application owning the socket can initiate a state change on the
> connection.


The code behaves like we received a formal RST : 

Please do not even bother trying to send additional data, it is not
worth wasting precious resource.

There is currently no system call telling the stack : 

Please remove all outstanding data for this socket.

And even if it was present, how many applications need to be changed,
because all they do is probably a close(), after a shutdown() if they
really were cautious...
