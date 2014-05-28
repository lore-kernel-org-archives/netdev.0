From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH/RFC] Re: recvmmsg() timeout behavior strangeness [RESEND]
Date: Wed, 28 May 2014 15:17:40 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1724F2A0@AcuExch.aculab.com>
References: <20140512143451.GB13801@kernel.org>
 <20140521210535.GA5414@kernel.org> <537E0961.8040005@gmail.com>
 <20140526134647.GB8176@kernel.org> <20140526211706.GA25474@kernel.org>
 <5384BEC5.2080607@gmail.com> <20140527192115.GD25474@kernel.org>
 <CAKgNAkht1vubHueYPpkRu_W5B8OYW3rPUkHeLEq5WMVbCvO47w@mail.gmail.com>
 <20140527203010.GA2764@kernel.org> <5385D47A.3070401@gmail.com>
 <20140528150720.GB2764@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	=?iso-8859-2?Q?Ondrej_B=EDlka?= <neleai-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org>,
	Caitlin Bestler <caitlin.bestler-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Elie De Brauwer" <eliedebrauwer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Steven Whitehouse" <steve-TMeXKDtMCpxBDgjK7y7TUQ@public.gmane.org>,
	=?iso-8859-2?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
	"Chris Friesen" <chris.friesen-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
To: 'Arnaldo Carvalho de Melo' <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140528150720.GB2764-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Content-Language: en-US
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Arnaldo Carvalho de Melo
...
> > But, another question...
> >
> > In the case that the call is interrupted by a signal handler and some
> > datagrams have already been received, then the call succeeds, and
> > returns the number of datagrams received, and 'timeout' is updated with
> > the remaining time. Maybe that's the right behavior, but I just want to
> 
> Note that what the comment in the existing code says should apply here,
> namely that the next recv (m or mmsg) syscall on this socket will return
> what is in sock->sk->sk_err, that is the signal:
> 
...
> 
> So, yes, the user _can_ process the packets already copied to userspace,
> i.e. no packet loss, and then, on the next call, will receive the signal
> notification.

The application shouldn't need to see an EINTR response, any signal handler
should be run when the system call returns to user (regardless of the
system call result code).
If that doesn't happen Linux is badly broken!
>From an application point of view this is exactly the same as the signal
occurring just before/after the kernel entry/exit for the system call.

The call should just return early with success status.
No need to preserve the EINTR response for later.

The same might be appropriate for other errors - maybe including EFAULT
copying non-initial messages to userspace.
Put the message being processed back on the socket queue and return
success with the (non-zero) partial message count.

	David



--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
