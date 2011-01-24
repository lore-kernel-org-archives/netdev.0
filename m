From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Mon, 24 Jan 2011 20:36:26 +0200
Message-ID: <20110124183626.GB29941@redhat.com>
References: <20110116223728.GA6279@verge.net.au>
 <20110117102655.GH23479@redhat.com>
 <4D35ECE2.4040901@hp.com>
 <20110120083727.GA1807@verge.net.au>
 <20110121095929.GE26070@redhat.com>
 <20110121231149.GI2195@verge.net.au>
 <20110122215742.GC5617@redhat.com>
 <20110123063849.GB2673@verge.net.au>
 <20110123103902.GA28585@redhat.com>
 <4D3DC4AB.1000207@hp.com>
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
In-Reply-To: <4D3DC4AB.1000207@hp.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 24, 2011 at 10:27:55AM -0800, Rick Jones wrote:
> >
> >Just to block netperf you can send it SIGSTOP :)
> >
> 
> Clever :)  One could I suppose achieve the same result by making the
> remote receive socket buffer size smaller than the UDP message size
> and then not worry about having to learn the netserver's PID to send
> it the SIGSTOP.  I *think* the semantics will be substantially the
> same?

If you could set, it, yes. But at least linux ignores
any value substantially smaller than 1K, and then
multiplies that by 2:

        case SO_RCVBUF:
                /* Don't error on this BSD doesn't and if you think
                   about it this is right. Otherwise apps have to
                   play 'guess the biggest size' games. RCVBUF/SNDBUF
                   are treated in BSD as hints */

                if (val > sysctl_rmem_max)
                        val = sysctl_rmem_max;
set_rcvbuf:     
                sk->sk_userlocks |= SOCK_RCVBUF_LOCK;

                /*
                 * We double it on the way in to account for
                 * "struct sk_buff" etc. overhead.   Applications
                 * assume that the SO_RCVBUF setting they make will
                 * allow that much actual data to be received on that
                 * socket.
                 *
                 * Applications are unaware that "struct sk_buff" and
                 * other overheads allocate from the receive buffer
                 * during socket buffer allocation. 
                 *
                 * And after considering the possible alternatives,
                 * returning the value we actually used in getsockopt
                 * is the most desirable behavior.
                 */ 
                if ((val * 2) < SOCK_MIN_RCVBUF)
                        sk->sk_rcvbuf = SOCK_MIN_RCVBUF;
                else
                        sk->sk_rcvbuf = val * 2;

and

/*                      
 * Since sk_rmem_alloc sums skb->truesize, even a small frame might need
 * sizeof(sk_buff) + MTU + padding, unless net driver perform copybreak
 */             
#define SOCK_MIN_RCVBUF (2048 + sizeof(struct sk_buff))


>  Both will be drops at the socket buffer, albeit for for
> different reasons.  The "too small socket buffer" version though
> doesn't require one remember to "wake" the netserver in time to have
> it send results back to netperf without netperf tossing-up an error
> and not reporting any statistics.
> 
> Also, netperf has a "no control connection" mode where you can, in
> effect cause it to send UDP datagrams out into the void - I put it
> there to allow folks to test against the likes of echo discard and
> chargen services but it may have a use here.  Requires that one
> specify the destination IP and port for the "data connection"
> explicitly via the test-specific options.  In that mode the only
> stats reported are those local to netperf rather than netserver.

Ah, sounds perfect.

> happy benchmarking,
> 
> rick jones

