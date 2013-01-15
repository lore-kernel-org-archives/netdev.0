From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 0/5]: soreuseport: Bind multiple sockets to the same port
Date: Tue, 15 Jan 2013 09:34:30 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B710E@saturn3.aculab.com>
References: <alpine.DEB.2.00.1301141138440.959@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@markandruth.co.uk>, <eric.dumazet@gmail.com>
To: "Tom Herbert" <therbert@google.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33190 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751998Ab3AOJgb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 04:36:31 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 06412-07 for <netdev@vger.kernel.org>;
 Tue, 15 Jan 2013 09:36:28 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <alpine.DEB.2.00.1301141138440.959@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.o=
rg] On Behalf Of Tom Herbert
> Sent: 14 January 2013 20:00
> To: netdev@vger.kernel.org; davem@davemloft.net
> Cc: netdev@markandruth.co.uk; eric.dumazet@gmail.com
> Subject: [PATCH 0/5]: soreuseport: Bind multiple sockets to the same =
port
>=20
> Rebasing the soreuseport patches to 3.8.  No material changes since
> first posted.
> ---
> These patches implements so_reuseport (SO_REUSEPORT socket option) fo=
r
> TCP and UDP. =A0For TCP, so_reuseport allows multiple listener socket=
s
> to be bound to the same port.
>....
>=20
> The motivating case for so_resuseport in TCP would be something like
> a web server binding to port 80 running with multiple threads, ...
> 2) accept on a single
> listener socket from multiple threads
> In case #2, the proportion of connections accepted per thread tends
> to be uneven under high connection load (assuming simple event loop:
> while (1) { accept(); process() }, wakeup does not promote fairness
> among the sockets. =A0We have seen the =A0disproportion to be as high
> as 3:1 ratio between thread accepting most connections and the one
> accepting the fewest. =A0With so_reusport the distribution is
> uniform.

Hmmm.... do you need that sort of fairness between the threads?

If one request takes longer than average to process, then you
don't want other requests to be delayed when there are other
idle worker processes.

Also having the same thread normally collect a request would
make it more likely that the required code/data be in the
cache of the cpu (assuming that the main reason for multiple
threads is to load balance over multiple cpus, and with the
threads tied to a single cpu).

If there are a lot of processes sleeping in accept() (on the same
socket) it might be worth looking at which is actually woken
when a new connection arrives. If they are sleeping in poll/select
it is probably more difficult (but not impossible) to avoid waking
all the processes for every incoming connection.

	David
