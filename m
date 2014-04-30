From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: recvmmsg() timeout behavior strangeness [RESEND]
Date: Wed, 30 Apr 2014 15:59:37 +0200
Message-ID: <536101C9.9090601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	"linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	=?UTF-8?B?T25kxZllaiBCw61sa2E=?= <neleai-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org>,
	Caitlin Bestler <caitlin.bestler-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Elie De Brauwer <eliedebrauwer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Steven Whitehouse <steve-TMeXKDtMCpxBDgjK7y7TUQ@public.gmane.org>,
	=?UTF-8?B?UsOpbWkgRGVuaXMtQ291cm1v?= =?UTF-8?B?bnQ=?=
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
	Chris Friesen <chris.friesen-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
To: Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Arnaldo,

I raised this issue somewhat more than a year ago, here:
http://thread.gmane.org/gmane.linux.man/3477
but got no reply from you. (Chris Friesen in that thread agreed 
that there is a problem though.)

Here, a slightly revised version of that mail, since I've just bumper 
into a related problem in a different context...

As part of his attempt to better document the recvmmsg() syscall that
you added in commit a2e2725541fad72416326798c2d7fa4dafb7d337, Elie de
Brauwer alerted to me to some strangeness in the timeout behavior of
the syscall. I suspect there's a bug that needs fixing, as detailed
below.

AFAICT, the timeout argument was added to this syscall as a result of
the discussion here:
http://markmail.org/message/m5l2ap4hiiimut6k#query:+page:1+mid:m5l2ap4hiiimut6k+state:results
(20-21 May 2009, "[RFC 1/2] net: Introduce recvmmsg...")

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
(Basically, if up to vlen-1 datagrams arrive before X+T, but then no 
more datagrams arrive, the call will remain blocked forever.) If it's
intended behavior, could you elaborate the use case, since it would be
good to add that to the man page. If not, a fix seems to be needed,
since otherwise, it's hard to see how the recvmmsg() timeout argument
can sanely be used.

Thanks,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
