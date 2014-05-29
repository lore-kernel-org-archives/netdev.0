From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH/RFC] Re: recvmmsg() timeout behavior strangeness [RESEND]
Date: Thu, 29 May 2014 14:40:08 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1724FCAB@AcuExch.aculab.com>
References: <20140527192115.GD25474@kernel.org>
 <CAKgNAkht1vubHueYPpkRu_W5B8OYW3rPUkHeLEq5WMVbCvO47w@mail.gmail.com>
 <20140527203010.GA2764@kernel.org> <5385D47A.3070401@gmail.com>
 <20140528150720.GB2764@kernel.org>
 <063D6719AE5E284EB5DD2968C1650D6D1724F2A0@AcuExch.aculab.com>
 <20140528195004.GD2764@kernel.org>
 <063D6719AE5E284EB5DD2968C1650D6D1724FB67@AcuExch.aculab.com>
 <20140529135547.GG2764@kernel.org>
 <063D6719AE5E284EB5DD2968C1650D6D1724FC78@AcuExch.aculab.com>
 <20140529141705.GI2764@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	=?Windows-1252?Q?Ondrej_B=EDlka?= <neleai-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org>,
	Caitlin Bestler <caitlin.bestler-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Elie De Brauwer" <eliedebrauwer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Steven Whitehouse" <steve-TMeXKDtMCpxBDgjK7y7TUQ@public.gmane.org>,
	=?Windows-1252?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
	"Chris Friesen" <chris.friesen-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
To: 'Arnaldo Carvalho de Melo' <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140529141705.GI2764-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Content-Language: en-US
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: 'Arnaldo Carvalho de Melo'
> Em Thu, May 29, 2014 at 02:06:04PM +0000, David Laight escreveu:
> > From: 'Arnaldo Carvalho de Melo'
> > ...
> > > > I remember some discussions from an XNET standards meeting (I've forgotten
> > > > exactly which errors on which calls were being discussed).
> > > > My recollection is that you return success with a partial transfer
> > > > count for ANY error that happens after some data has been transferred.
> > > > The actual error will be returned when it happens again on the next
> > > > system call - Note the AGAIN, not a saved error.
> 
> > > A saved error, for the right entity, in the recvmmsg case, that
> > > basically is batching multiple recvmsg syscalls, doesn't sound like a
> > > problem, i.e. the idea is to, as much as possible, mimic what multiple
> > > recvmsg calls would do, but reduce its in/out kernel (and inside kernel
> > > subsystems) overhead.
> 
> > > Perhaps we can have something in between, i.e. for things like EFAULT,
> > > we should report straight away, effectively dropping whatever datagrams
> > > successfully received in the current batch, do you agree?
> 
> > Not unreasonable - EFAULT shouldn't happen unless the application
> > is buggy.
> 
> Ok.
> 
> > > For transient errors the existing mechanism, fixed so that only per
> > > socket errors are saved for later, as today, could be kept?
> 
> > I don't think it is ever necessary to save an errno value for the
> > next system call at all.
> > Just process the next system call and see what happens.
> 
> > If the call returns with less than the maximum number of datagrams
> > and with a non-zero timeout left - then the application can infer
> > that it was terminated by an abnormal event of some kind.
> > This might be a signal.
> 
> Then it could use getsockopt(SO_ERROR) perhaps? I.e. we don't return the
> error on the next call, but we provide a way for the app to retrieve the
> reason for the smaller than expected batch?

If you really think it is necessary, then you want a field in the
control structure.
But IMHO returning the 'time left' is more than enough.

IIRC the original problem was that the user-specified timeout
was used as an inter-datagram timer instead of an overall timeout.

I suspect that most application won't actually care about the
'time left', nor the actual number of returned datagrams.
They will just process what they are given and then wait for
the next batch.

	David



--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
