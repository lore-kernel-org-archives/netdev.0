From: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: recvmmsg() timeout behavior strangeness
Date: Sun, 23 Dec 2012 21:50:11 +0100
Message-ID: <CAHO5Pa2goUtiBU8ye2beTBExL4it2-aDCPBhDOGyO3NX_PV_pQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Caitlin Bestler <caitlin.bestler-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Chris Van Hoof <vanhoof-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Clark Williams <williams-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andrew Grover <andy.grover-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Elie De Brauwer <eliedebrauwer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steven Whitehouse <steve-TMeXKDtMCpxBDgjK7y7TUQ@public.gmane.org>,
	=?ISO-8859-1?Q?R=E9mi_Denis=2DCourmont?=
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
To: Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Arnaldo,

As part of his attempt to better document the recvmmsg() syscall that
you added in commit a2e2725541fad72416326798c2d7fa4dafb7d337, Elie de
Brauwer alerted to me to some strangeness in the timeout behavior of
the syscall. I suspect there's a bug that needs fixing, as detailed
below.

AFAICT, the timeout argument was added to this syscall as a result of
the discussion here:
http://thread.gmane.org/gmane.linux.network/128582 .

If I understand correctly, the *intended* purpose of the timeout
argument is to set a limit on how long to wait for additional
datagrams after the arrival of an initial datagram. However, the
syscall behaves in quite a different way. Instead, it potentially
blocks forever, regardless of the timeout. The way the timeout seems
to work is as follows:

1. The timeout, T, is armed on receipt of first diagram, starting at time X.
2. After each further datagram is received, a check is made if we have
reached time X+T. If we have reached that time, then the syscall
returns.

Since the timeout is only checked after the arrival of each datagram,
we can have scenarios like the following:

0. Assume a timeout of 10 seconds, and that vlen is 5.
1. First datagram arrives at time X.
2. Second datagram arrives at time X+2 secs
3. No more datagrams arrive.

In this case, the call blocks forever. Is that intended behavior?
(Basically, if vlen-1 datagrams arrive before X+T, but then no more
datagrams arrive, the call will remain blocked forever.) If it's
intended behavior, could you elaborate the use case, since it would be
good to add that to the man page.

Thanks,

Michael
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
