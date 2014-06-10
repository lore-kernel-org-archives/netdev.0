From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: SCTP's processing of unexpected COOKIE_ECHO doesn't seem useful.
Date: Tue, 10 Jun 2014 09:44:19 -0400
Message-ID: <53970BB3.5010909@gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D17259B99@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:63290 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbaFJNoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 09:44:22 -0400
Received: by mail-qa0-f46.google.com with SMTP id i13so2669351qae.5
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 06:44:22 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17259B99@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/2014 05:52 AM, David Laight wrote:
> I'm seeing some unexpected (to me) behaviour of the SCTP stack
> when the remote system restarts.
> 
> I've a socket that has a single association, and I'm rather
> expecting TCP-like behaviour.
> So I'd expect some kind of failure condition on my existing
> connection, and then a new connection be established on a
> different socket - eg though a listening socket.
> This would then go through all my code for correctly
> initialising a new connection.
> 
> What happens is rather different.
> 
> The remote sends an INIT with the same port numbers as the
> previous connection, AFAICT the code sends an INIT_ACK with
> some numbers taken from the existing TCB.
> 
> When the COOKIE_ECHO is received sctp_sf_do_5_2_4_dupcook()
> is called, condition 'A' is detected and sctp_sf_do_dupcook_a()
> called.
> 
> RFC 2960 says that this should be treated as a received ABORT
> followed by a COOKIE echo - this sounds fine, I want the ABORT
> processing to kill the existing connection.
> However it then says that 'RESTART' should be indicated to the ULP
> rather than 'COMMUNICATION LOST'.
> 
> AFAICT this is just silently ignored by the socket layer.
> I've a process sleeping in recv() (actually a kernel thread in
> sock_recvmsg()) and it is not woken up at all.

You haven't subscribed to receive notifications and as a result
you haven't been woken up.

The ABORT treatment above simply resets the state of the original
connection, thus simulating the ABORT and a new connection all
in one.

This is where an application really needs to utilize and process
SCTP notifications.  You can also collect data like which messages
have not been send to the remote, so that you can re-queue them.

> 
> This leaves the 'application' code in completely the wrong state for
> the SCTP connection.
>

I can understand where you are coming from.  There are some useful
cases for association restart, but it could also be turned off
without much adverse effect to the applications.

May be a sysctl or a socket option that allows you control whether you
want association restart or not might be nice to have.

-vlad

> ISTM that the mapping of SCTP to connection-mode sockets should be
> treating this as a disconnect.
> 
> This scenario can be reproduced by disconnecting with ABORT and
> getting iptables to discard the ABORT.
> It can happen with some connection retry algorithms if there is
> message loss.
> 
> 	David
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
