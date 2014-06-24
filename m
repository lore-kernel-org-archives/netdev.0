From: Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH/RFC] Re: recvmmsg() timeout behavior strangeness [RESEND]
Date: Tue, 24 Jun 2014 17:25:41 -0300
Message-ID: <20140624202541.GD3456@kernel.org>
References: <20140527203010.GA2764@kernel.org>
 <5385D47A.3070401@gmail.com>
 <20140528150720.GB2764@kernel.org>
 <063D6719AE5E284EB5DD2968C1650D6D1724F2A0@AcuExch.aculab.com>
 <20140528195004.GD2764@kernel.org>
 <063D6719AE5E284EB5DD2968C1650D6D1724FB67@AcuExch.aculab.com>
 <20140529135547.GG2764@kernel.org>
 <063D6719AE5E284EB5DD2968C1650D6D1724FC78@AcuExch.aculab.com>
 <20140529141705.GI2764@kernel.org>
 <CAKgNAkj-MVfeqEeffWKMNok0yO-Rm1kyY+zhXEy-U9NkB+aLow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Ondrej =?iso-8859-1?Q?B=EDlka?= <neleai-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org>,
	Caitlin Bestler <caitlin.bestler-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Elie De Brauwer <eliedebrauwer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Steven Whitehouse <steve-TMeXKDtMCpxBDgjK7y7TUQ@public.gmane.org>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
	Chris Friesen <chris.friesen-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAKgNAkj-MVfeqEeffWKMNok0yO-Rm1kyY+zhXEy-U9NkB+aLow-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Em Mon, Jun 16, 2014 at 11:58:51AM +0200, Michael Kerrisk (man-pages) escreveu:
> Hi Arnaldo,
> 
> Things have gone quiet ;-). What's the current state of this patch?

Yeah, I kept meaning to prod the other people on this thread about what
they thought about my last messages, patches, etc. :-)

Can I have acked-by or even tested-by on those? Is it ok?

- Arnaldo

> Thanks,
> 
> Michael
> 
> 
> On Thu, May 29, 2014 at 4:17 PM, Arnaldo Carvalho de Melo
> <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org> wrote:
> > Em Thu, May 29, 2014 at 02:06:04PM +0000, David Laight escreveu:
> >> From: 'Arnaldo Carvalho de Melo'
> >> ...
> >> > > I remember some discussions from an XNET standards meeting (I've forgotten
> >> > > exactly which errors on which calls were being discussed).
> >> > > My recollection is that you return success with a partial transfer
> >> > > count for ANY error that happens after some data has been transferred.
> >> > > The actual error will be returned when it happens again on the next
> >> > > system call - Note the AGAIN, not a saved error.
> >
> >> > A saved error, for the right entity, in the recvmmsg case, that
> >> > basically is batching multiple recvmsg syscalls, doesn't sound like a
> >> > problem, i.e. the idea is to, as much as possible, mimic what multiple
> >> > recvmsg calls would do, but reduce its in/out kernel (and inside kernel
> >> > subsystems) overhead.
> >
> >> > Perhaps we can have something in between, i.e. for things like EFAULT,
> >> > we should report straight away, effectively dropping whatever datagrams
> >> > successfully received in the current batch, do you agree?
> >
> >> Not unreasonable - EFAULT shouldn't happen unless the application
> >> is buggy.
> >
> > Ok.
> >
> >> > For transient errors the existing mechanism, fixed so that only per
> >> > socket errors are saved for later, as today, could be kept?
> >
> >> I don't think it is ever necessary to save an errno value for the
> >> next system call at all.
> >> Just process the next system call and see what happens.
> >
> >> If the call returns with less than the maximum number of datagrams
> >> and with a non-zero timeout left - then the application can infer
> >> that it was terminated by an abnormal event of some kind.
> >> This might be a signal.
> >
> > Then it could use getsockopt(SO_ERROR) perhaps? I.e. we don't return the
> > error on the next call, but we provide a way for the app to retrieve the
> > reason for the smaller than expected batch?
> >
> >> I'm not sure if an icmp error on a connected datagram socket could
> >> generate a 'disconnect'. It might happen if the interface is being
> >> used for something like SCTP.
> >> In either case the next call will detect the error.
> >
> > - Arnaldo
> 
> 
> 
> -- 
> Michael Kerrisk
> Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> Linux/UNIX System Programming Training: http://man7.org/training/
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
