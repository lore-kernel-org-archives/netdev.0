From: 'Arnaldo Carvalho de Melo' <acme@kernel.org>
Subject: Re: [PATCH/RFC] Re: recvmmsg() timeout behavior strangeness [RESEND]
Date: Thu, 29 May 2014 10:55:47 -0300
Message-ID: <20140529135547.GG2764@kernel.org>
References: <20140526211706.GA25474@kernel.org>
 <5384BEC5.2080607@gmail.com>
 <20140527192115.GD25474@kernel.org>
 <CAKgNAkht1vubHueYPpkRu_W5B8OYW3rPUkHeLEq5WMVbCvO47w@mail.gmail.com>
 <20140527203010.GA2764@kernel.org>
 <5385D47A.3070401@gmail.com>
 <20140528150720.GB2764@kernel.org>
 <063D6719AE5E284EB5DD2968C1650D6D1724F2A0@AcuExch.aculab.com>
 <20140528195004.GD2764@kernel.org>
 <063D6719AE5E284EB5DD2968C1650D6D1724FB67@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>,
	lkml <linux-kernel@vger.kernel.org>,
	"linux-man@vger.kernel.org" <linux-man@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Ondrej =?iso-8859-1?Q?B=EDlka?= <neleai@seznam.cz>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Elie De Brauwer <eliedebrauwer@gmail.com>,
	David Miller <davem@davemloft.net>,
	Steven Whitehouse <steve@chygwyn.com>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>, Paul Moore <paul@paul-moore.com>,
	Chris Friesen <chris.friesen@windriver.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1724FB67@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Thu, May 29, 2014 at 10:53:22AM +0000, David Laight escreveu:
> From: 'Arnaldo Carvalho de 
> ...
> > > > So, yes, the user _can_ process the packets already copied to userspace,
> > > > i.e. no packet loss, and then, on the next call, will receive the signal
> > > > notification.
> > 
> > > The application shouldn't need to see an EINTR response, any signal handler
> > > should be run when the system call returns to user (regardless of the
> > > system call result code).
> > > If that doesn't happen Linux is badly broken!
> > > >From an application point of view this is exactly the same as the signal
> > > occurring just before/after the kernel entry/exit for the system call.

> > > The call should just return early with success status.
> > > No need to preserve the EINTR response for later.

> > > The same might be appropriate for other errors - maybe including EFAULT
> > > copying non-initial messages to userspace.
> > > Put the message being processed back on the socket queue and return
> > > success with the (non-zero) partial message count.
 
> > We don't need to put anything back, if we get an EFAULT for a datagram,
> > then we stop processing that packet, _dropping_ it (and that is just
> > like recvmsg works, look at __skb_recv_datagram, the skb_unlink there,
> > and udp_recvmsg, what happens if skb_copy_and_csum_datagram_iovec fails)
> > and stop the batch, and if no datagrams were received, return the error
> > straight away.
 
> > But if some datagrams were successfully received, and at that point
> > _already_ removed from queues and sent successfully to userspace,
> > recvmmsg will return the number of successfully copied datagrams and
> > store the error so that it can return on the next syscall,
 
> That just doesn't make any sense.

Yeah for things like EFAULT, storing it in a per socket area for later
reporting is a bug, a separate bug.

> Saving an errno code would only make any sense if the error were a
> property of the socket - but EFAULT is a property of the system call,

Agreed, so for the errors that are socket related, the mechanism should
work, not for things that are thread specific, then we should either
straight away signal it despite of any successfully received packets in
the batch so far in the current recvmmsg syscall or mimic what would
happen if the user issued multiple recvmsg syscalls instead, i.e. in the
next call _for this thread_, the EFAULT will take place.

> and EINTR a property of the process (it exists so that the process
> can return to userspace to execute a signal handler - relying on
> SIGALRM to timeout blocking system calls is a recipe for disaster).
> 
> The next system call could be from an entirely different process,
> neither EFAULT nor EINTR would mean anything to it at all.

Right, storing thread specific errors on the socket is a bug and has to
be fixed. I.e. _if_ we keep the saving error for next syscall strategy,
then that error has, for the per thread cases, be stored in a per thread
area error field for socket operations.
 
> ISTR that returning EFAULT generates a signal that will typically
> terminate the process.
> You definitely don't want to send one to a different process.

Right.
 
> > Please refer to the original discussion on how to report how many
> > successfully copied datagrams and also report that it stopped before the
> > timeout and the number of requested datagrams in a batch:
 
> > http://lkml.kernel.org/r/200905221022.48790.remi.denis-courmont@nokia.com
 
> I do remember the original problem.
> I don't recall error reporting being referenced.
 
> > What is being discussed here is how to return the EFAULT that may happen
> > _after_ datagram processing, be it interrupted by an EFAULT, signal, or
> > plain returning all that was requested, with no errors.

> I remember some discussions from an XNET standards meeting (I've forgotten
> exactly which errors on which calls were being discussed).
> My recollection is that you return success with a partial transfer
> count for ANY error that happens after some data has been transferred.
> The actual error will be returned when it happens again on the next
> system call - Note the AGAIN, not a saved error.

A saved error, for the right entity, in the recvmmsg case, that
basically is batching multiple recvmsg syscalls, doesn't sound like a
problem, i.e. the idea is to, as much as possible, mimic what multiple
recvmsg calls would do, but reduce its in/out kernel (and inside kernel
subsystems) overhead.

Perhaps we can have something in between, i.e. for things like EFAULT,
we should report straight away, effectively dropping whatever datagrams
successfully received in the current batch, do you agree?

For transient errors the existing mechanism, fixed so that only per
socket errors are saved for later, as today, could be kept?
 
> Things like blocking send/write being interrupted spring to mind.
> Possibly even copyin/out failures part way through a read/write call.
> 
> > This EFAULT _after_ datagram processing may happen when updating the
> > remaining timeout, because then how can userspace both receive the
> > number of successfully copied datagrams (in any of the cases mentioned
> > in the previous paragraph) and know that that timeout can't be used
> > because there was a problem while trying to copy it to userspace
> > (EFAULT)?
> 
> Failure to write the control structure back to userspace probably
> deserves an EFAULT return - the application is buggy.
> IIRC normal recvmsg() copies out the control structure at the end
> of processing - that can fail.
> I wouldn't worry about datagram discards on any of those late
> EFAULT conditions.

This part we all seem to be in agreement, so I'll just leave it as is,
i.e. it doesn't matter that the actual packet receiving part was
(partially) successful, if the copy_to_user(remaining timeout) fails,
EFAULT should be returned.

- Arnaldo
