From: 'Arnaldo Carvalho de Melo' <acme@kernel.org>
Subject: [PATCH/RFC] Handle EFAULT in partial recvmmsg was Re: [PATCH/RFC]
 Re: recvmmsg() timeout behavior strangeness [RESEND]
Date: Thu, 29 May 2014 12:33:42 -0300
Message-ID: <20140529153342.GJ2764@kernel.org>
References: <CAKgNAkht1vubHueYPpkRu_W5B8OYW3rPUkHeLEq5WMVbCvO47w@mail.gmail.com>
 <20140527203010.GA2764@kernel.org>
 <5385D47A.3070401@gmail.com>
 <20140528150720.GB2764@kernel.org>
 <063D6719AE5E284EB5DD2968C1650D6D1724F2A0@AcuExch.aculab.com>
 <20140528195004.GD2764@kernel.org>
 <063D6719AE5E284EB5DD2968C1650D6D1724FB67@AcuExch.aculab.com>
 <20140529135547.GG2764@kernel.org>
 <063D6719AE5E284EB5DD2968C1650D6D1724FC78@AcuExch.aculab.com>
 <20140529141705.GI2764@kernel.org>
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
In-Reply-To: <20140529141705.GI2764@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Thu, May 29, 2014 at 11:17:05AM -0300, 'Arnaldo Carvalho de Melo' escreveu:
> Em Thu, May 29, 2014 at 02:06:04PM +0000, David Laight escreveu:
> > From: 'Arnaldo Carvalho de Melo'
> > ...
> > > > I remember some discussions from an XNET standards meeting (I've forgotten
> > > > exactly which errors on which calls were being discussed).
> > > > My recollection is that you return success with a partial transfer
> > > > count for ANY error that happens after some data has been transferred.
> > > > The actual error will be returned when it happens again on the next
> > > > system call - Note the AGAIN, not a saved error.
 
> > > A saved error, for the right entity, in the recvmmsg case, that
> > > basically is batching multiple recvmsg syscalls, doesn't sound like a
> > > problem, i.e. the idea is to, as much as possible, mimic what multiple
> > > recvmsg calls would do, but reduce its in/out kernel (and inside kernel
> > > subsystems) overhead.
 
> > > Perhaps we can have something in between, i.e. for things like EFAULT,
> > > we should report straight away, effectively dropping whatever datagrams
> > > successfully received in the current batch, do you agree?
  
> > Not unreasonable - EFAULT shouldn't happen unless the application
> > is buggy.
 
> Ok.

So the patch below should handle it, and record that the packets were
dropped, not at the transport level, like UDP_MIB_INERRORS, for
instance, would indicate, but at the batching, recvmmsg level, so
perhaps we'll need a MIB variable for that.

Also a counterpart to the trace_kfree_skb(skb, udp_recvmsg) tracepoint
for dropwatch and similar tools to use, Neil?

I'm keeping this separate from the timeout update patch.

- Arnaldo

diff --git a/net/socket.c b/net/socket.c
index abf56b2a14f9..63491f015912 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2415,13 +2415,17 @@ out_put:
 		return datagrams;
 
 	if (datagrams != 0) {
+		if (err == -EFAULT) {
+			atomic_add(datagrams, &sock->sk->sk_drops);
+			return -EFAULT;
+		}
 		/*
 		 * We may return less entries than requested (vlen) if the
 		 * sock is non block and there aren't enough datagrams...
 		 */
 		if (err != -EAGAIN) {
 			/*
-			 * ... or  if recvmsg returns an error after we
+			 * ... or if recvmsg returns a socket error after we
 			 * received some datagrams, where we record the
 			 * error to return on the next call or if the
 			 * app asks about it using getsockopt(SO_ERROR).
