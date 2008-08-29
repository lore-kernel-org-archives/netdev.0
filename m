From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Fri, 29 Aug 2008 14:41:50 -0300
Message-ID: <20080829144150.171ba495@tux>
References: <20080819213417.45133573@tux>
	<Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
	<20080822183224.2d52f16c@tux>
	<20080822.143709.65615512.davem@davemloft.net>
	<20080823111446.06a350a2@tux>
	<Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
	<20080824163843.33b4f890@tux>
	<Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
	<20080826141812.589848a0@tux>
	<Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
	<20080828184919.611dd578@tux>
	<Pine.LNX.4.64.0808291045430.7971@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:62657 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526AbYH2RmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 13:42:00 -0400
Received: by an-out-0708.google.com with SMTP id d40so163836and.103
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2008 10:41:59 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0808291045430.7971@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Aug 2008 16:07:04 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Can you check during a "normal" time if the ListenOverflows grows wit=
h as=20
> considerable rate as during the stall (no need to send that log to me=
,
> just confirm that it doesn't do that is enough). A little cheat to do=
 that=20
> for a logfile (the command I used):
>=20
> grep -A1 "ListenOverflows" <log> | cut -d ' ' -f 21-22 | grep [0-9]

	It does not grow:

10953 10953
10953 10953
10953 10953
10953 10953
10953 10953
10953 10953
10953 10953
10953 10953
10953 10953
10953 10953
10953 10953
10953 10953
10953 10953
10953 10953
10953 10953
10953 10953
10953 10953
10953 10953
10953 10953
10953 10953
10953 10953
10953 10953

	It stays in this value for a long time.

> ...When you use nmap to resolve, is the time always constant or do yo=
u run=20
> it until the situation resolves?

	The time is constant. It takes just 3 seconds to nmap to
"solve" the problem. I always have to use Ctrl+C to stop nmap before it
completes the scanning because in the first 3 seconds the problem is
"solved".

> There are constantly 9 items in sk_ack_backlog (ie., connections whic=
h are=20
> not yet accept), those connections are in TCP_CLOSE_WAIT, then there =
are=20
> ~7 connections hanging in SYN_RECV which cannot make progress (all of=
 them=20
> from a single address besides two flows of yours in SYN_RECV).
>=20
> So I guess that the configured 128 is not related to the number that=20
> is given to listen syscall, as it seems to be 9.
>=20
> ...Next we need to find out why dovecot is not accept()ing or is doin=
g=20
> that dead slow (the client's state is hardly significant, so I guess=20
> it's no longer mandatory to collect it every time)...

	Would it be useful if I do the same for port 119? Because inn
(nntp) stalls too. And proftp too. So I'm sure it isn't related to
dovecot, otherwise the other services wouldn't stall too.

> Can you provide these to familiarize myself a bit to the server's=20
> environment (no need to wait for the stall):
>=20
> ps ax | grep dovecot  (or whatever the process is named)

fraga@teleporto ~$ ps ax|grep dovecot
 2361 ?        Ss     0:13 /usr/local/sbin/dovecot
 2363 ?        S      0:07 dovecot-auth
 4751 ?        S      0:00 dovecot-auth -w
 6133 ?        S      0:00 dovecot-auth -w
 6134 ?        S      0:00 dovecot-auth -w
15963 ?        S      0:00 dovecot-auth -w

	The dovecot-auth I use for postfix too.

> netstat -p -n -l | grep "995"

fraga@teleporto ~$ sudo netstat -p -n -l | grep "995"
Password:
tcp        0      0 0.0.0.0:995             0.0.0.0:*       LISTEN     =
 2361/dovecot       =20

> But you'll mostly have to resort to strace during the stall, I recomm=
end=20
> trying to trace just part of the syscalls, eg at least these:
>=20
> strace -e trace=3Daccept,listen,close,shutdown,select
>=20
> ...as it would probably not be wise to make a full dump available (th=
at it=20
> would contain every syscall). Alternatively, you can create one full =
dump=20
> for yourself and just grep the relevant parts. There may be need to s=
trace
> more than one process (all dovecot related).
=09
	Ok, at next stall I'll do that.

	Maybe it's good to strace inn and proftp too, right?

	Don't you think it's interesting that http (apache) and ssh never stal=
ls?

--=20
