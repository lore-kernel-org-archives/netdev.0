From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Mon, 24 Jan 2011 21:42:24 +0200
Message-ID: <20110124194224.GD29941@redhat.com>
References: <4D35ECE2.4040901@hp.com>
 <20110120083727.GA1807@verge.net.au>
 <20110121095929.GE26070@redhat.com>
 <20110121231149.GI2195@verge.net.au>
 <20110122215742.GC5617@redhat.com>
 <20110123063849.GB2673@verge.net.au>
 <20110123103902.GA28585@redhat.com>
 <4D3DC4AB.1000207@hp.com>
 <20110124183626.GB29941@redhat.com>
 <4D3DCC99.5050101@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>, Jesse Gross <jesse@nicira.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D3DCC99.5050101@hp.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 24, 2011 at 11:01:45AM -0800, Rick Jones wrote:
> Michael S. Tsirkin wrote:
> >On Mon, Jan 24, 2011 at 10:27:55AM -0800, Rick Jones wrote:
> >
> >>>Just to block netperf you can send it SIGSTOP :)
> >>>
> >>
> >>Clever :)  One could I suppose achieve the same result by making the
> >>remote receive socket buffer size smaller than the UDP message size
> >>and then not worry about having to learn the netserver's PID to send
> >>it the SIGSTOP.  I *think* the semantics will be substantially the
> >>same?
> >
> >
> >If you could set, it, yes. But at least linux ignores
> >any value substantially smaller than 1K, and then
> >multiplies that by 2:
> >
> >        case SO_RCVBUF:
> >                /* Don't error on this BSD doesn't and if you think
> >                   about it this is right. Otherwise apps have to
> >                   play 'guess the biggest size' games. RCVBUF/SNDBUF
> >                   are treated in BSD as hints */
> >
> >                if (val > sysctl_rmem_max)
> >                        val = sysctl_rmem_max;
> >set_rcvbuf:                     sk->sk_userlocks |=
> >SOCK_RCVBUF_LOCK;
> >
> >                /*
> >                 * We double it on the way in to account for
> >                 * "struct sk_buff" etc. overhead.   Applications
> >                 * assume that the SO_RCVBUF setting they make will
> >                 * allow that much actual data to be received on that
> >                 * socket.
> >                 *
> >                 * Applications are unaware that "struct sk_buff" and
> >                 * other overheads allocate from the receive buffer
> >                 * during socket buffer allocation.
> >*
> >                 * And after considering the possible alternatives,
> >                 * returning the value we actually used in getsockopt
> >                 * is the most desirable behavior.
> >                 */                 if ((val * 2) <
> >SOCK_MIN_RCVBUF)
> >                        sk->sk_rcvbuf = SOCK_MIN_RCVBUF;
> >                else
> >                        sk->sk_rcvbuf = val * 2;
> >
> >and
> >
> >/*                       * Since sk_rmem_alloc sums skb->truesize,
> >even a small frame might need
> > * sizeof(sk_buff) + MTU + padding, unless net driver perform copybreak
> > */             #define SOCK_MIN_RCVBUF (2048 + sizeof(struct
> >sk_buff))
> 
> Pity - seems to work back on 2.6.26:

Hmm, that code is there at least as far back as 2.6.12.

> raj@tardy:~/netperf2_trunk$ src/netperf -t UDP_STREAM -- -S 1 -m 1024
> MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> localhost (127.0.0.1) port 0 AF_INET : histogram
> Socket  Message  Elapsed      Messages
> Size    Size     Time         Okay Errors   Throughput
> bytes   bytes    secs            #      #   10^6bits/sec
> 
> 124928    1024   10.00     2882334      0    2361.17
>    256           10.00           0              0.00
> 
> raj@tardy:~/netperf2_trunk$ uname -a
> Linux tardy 2.6.26-2-amd64 #1 SMP Sun Jun 20 20:16:30 UTC 2010 x86_64 GNU/Linux
> 
> Still, even with that (or SIGSTOP) we don't really know where the
> packets were dropped right?  There is no guarantee they weren't
> dropped before they got to the socket buffer
> 
> happy benchmarking,
> rick jones

Right. Better send to a port with no socket listening there,
that would drop the packet at an early (if not at the earliest
possible)  opportunity.

> PS - here is with a -S 1024 option:
> 
> raj@tardy:~/netperf2_trunk$ src/netperf -t UDP_STREAM -- -S 1024 -m 1024
> MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> localhost (127.0.0.1) port 0 AF_INET : histogram
> Socket  Message  Elapsed      Messages
> Size    Size     Time         Okay Errors   Throughput
> bytes   bytes    secs            #      #   10^6bits/sec
> 
> 124928    1024   10.00     1679269      0    1375.64
>   2048           10.00     1490662           1221.13
> 
> showing that there is a decent chance that many of the frames were
> dropped at the socket buffer, but not all - I suppose I could/should
> be checking netstat stats... :)
> 
> And just a little more, only because I was curious :)
> 
> raj@tardy:~/netperf2_trunk$ src/netperf -t UDP_STREAM -- -S 1M -m 257
> MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> localhost (127.0.0.1) port 0 AF_INET : histogram
> Socket  Message  Elapsed      Messages
> Size    Size     Time         Okay Errors   Throughput
> bytes   bytes    secs            #      #   10^6bits/sec
> 
> 124928     257   10.00     1869134      0     384.29
> 262142           10.00     1869134            384.29
> 
> raj@tardy:~/netperf2_trunk$ src/netperf -t UDP_STREAM -- -S 1 -m 257
> MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> localhost (127.0.0.1) port 0 AF_INET : histogram
> Socket  Message  Elapsed      Messages
> Size    Size     Time         Okay Errors   Throughput
> bytes   bytes    secs            #      #   10^6bits/sec
> 
> 124928     257   10.00     3076363      0     632.49
>    256           10.00           0              0.00
