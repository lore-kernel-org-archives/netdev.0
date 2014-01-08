From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 2/3] virtio-net: use per-receive queue page frag
	alloc for mergeable bufs
Date: Wed, 8 Jan 2014 20:57:25 +0200
Message-ID: <20140108185725.GA18276@redhat.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>
	<1387239389-13216-2-git-send-email-mwdalton@google.com>
	<52B7F065.3010707@redhat.com>
	<1387819627.12212.4.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131223193704.GC1582@redhat.com>
	<CANJ5vPLEV_Z-D-0tThwhWXbHVaRWOLv566Xk1eD4TNYqNvknHw@mail.gmail.com>
	<20131226213727.GA10259@redhat.com>
	<1388095258.12212.37.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140108172104.GD17404@redhat.com>
	<1389204587.26646.111.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, netdev@vger.kernel.org,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1389204587.26646.111.camel@edumazet-glaptop2.roam.corp.google.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 08, 2014 at 10:09:47AM -0800, Eric Dumazet wrote:
> On Wed, 2014-01-08 at 19:21 +0200, Michael S. Tsirkin wrote:
> 
> > Basically yes, we could start dropping packets immediately
> > once GFP_ATOMIC allocations fail and repost the buffer to host,
> > and hope memory is available by the time we get the next interrupt.
> 
> > But we wanted host to have visibility into the fact that
> > we are out of memory and packets are dropped, so we did not want to
> > repost.
> 
> bufferbloat alert :)
>

I guess you are saying we never need to signal host/device
that we are out of memory, it's enough that packets are dropped?
It seemed like a useful thing for hypervisor to know about on general
principles, even though I don't think kvm uses this info at this point.

> > If we don't repost how do we know memory is finally available?
> > We went for a timer based workqueue thing.
> > What do you suggest?
> 
> 
> In normal networking land, when a host A sends frames to host B,
> nothing prevents A to pause the traffic to B if B is dropping packets
> under stress.
> 
> A physical NIC do not use a workqueue to refill its RX queue but uses
> the following strategy :
> 
> 0) Pre filling of RX ring buffer with N frames. This can use GFP_KERNEL
>    allocations with all needed (sleep/retry/shout) logic...
> 1) IRQ is handled.
> 2) Can we allocate a new buffer (GFP_ATOMIC) ?
>    If yes, we accept the frame,
>       and post the new buffer for the 'next frame'
>    If no, we drop the frame and recycle the memory for next round.
> 

Exactly, this is what I tried to describe in the part that
you have snipped out - but this means queue is always full.

Also, I wonder whether allocating before passing
frame to the stack might slow us down a tiny bit e.g. if an application
is polling this socket on another CPU.

Maybe a slightly better strategy is to do the above when queue depth
is running low. E.g. when queue is 3/4 empty, try
allocating before giving frames to net core,
and recycle buffers on error.

Not sure how much of a win this is.

-- 
MST
