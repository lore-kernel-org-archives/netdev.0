From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: fix multithreaded signal handling in unix recv routines/ background
Date: Mon, 28 Feb 2011 15:07:37 +0000
Message-ID: <8739n842py.fsf@sapphire.mobileactivedefense.com>
References: <877hck43hs.fsf@sapphire.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <877hck43hs.fsf@sapphire.mobileactivedefense.com> (Rainer Weikusat's message of "Mon\, 28 Feb 2011 14\:50\:55 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rainer Weikusat <rw@sapphire.mobileactivedefense.com> writes:
> The unix_dgram_recvmsg and unix_stream_recvmsg routines in
> net/af_unix.c utilize mutex_lock(&u->readlock) calls

This is IMHO a more sensible place for additional information.

I noticed this because the intended termination processing sequence of
some program which is used as part of a 'content-filtering solution'
for mobile devices (aka iPhones, iPads etc) stopped working the first
time I tested the program in its intended 'actual execution
context'. The program is supposed to listen for 'URL classifiction
requests' on a AF_UNIX SOCK_SEQPACKET socket, pass these to a
third-party library which does the actual classification job and then
send a reply containing a list of categories associated with the URL
in question. It uses multiple threads which basically work as follows:

	1. initialize the library
        2. unblock termination signals
        3. block in read awaiting requests
        4. block termination signals
        5. process request and send reply
        6. goto 2

Upon termination, each thread needs to execute the library
finalization routine before exiting. This is supposed to work with the
help of a signal handler for 'termination signals' calling siglongjmp
to get the particular thread executing it out of the processing
loop. Afterwards, this thread (with termination signals again blocked)
does the finalization call, executes a kill(getpid(), SIGTERM) and
exits via pthread_exit. The SIGTERM should then be picked up by
another thread of the process which will then perform the same
shutdown sequence and signal the next thread, until all threads of the
process have terminated properly. An example program whose structure
is basically identical to that of the actual application which
demonstrates the problem is available here:

	http://mss-uk.mssgmbh.com/~rw/signal/signal-problem-app.c

I've since spent some more thoughts on this and came to the conclusion
that this should also affect independent process blocking on the same
AF_UNIX socket and this even in absence of any user-defined signal
handling. Another example program demonstrating this phenomenon can be
downloaded from

	http://mss-uk.mssgmbh.com/~rw/signal/signal-problem-fork-simple.c

This basically creates an 'unkillable' process, meaning, one which is
even immune to a SIGKILL.

I've also tested that the issue still occurs with 2.6.38-rc5 and that
it is fixed by the proposed patch. The program itself has meanwhile
been moved to the computers which are actually used by the customers
of my employer. This move included patching all the kernels running on
these machines in the way I suggested.
