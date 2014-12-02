From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC v4 net-next 0/5] virtio_net: enabling tx interrupts
Date: Tue, 2 Dec 2014 11:43:18 +0200
Message-ID: <20141202094318.GB7732@redhat.com>
References: <1417429028-11971-1-git-send-email-jasowang@redhat.com>
	<20141201104223.GB16108@redhat.com>
	<1417490120.4405.2@smtp.corp.redhat.com>
	<1417507622.12638.0@smtp.corp.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pagupta@redhat.com, netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1417507622.12638.0@smtp.corp.redhat.com>
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

On Tue, Dec 02, 2014 at 08:15:02AM +0008, Jason Wang wrote:
> 
> 
> On Tue, Dec 2, 2014 at 11:15 AM, Jason Wang <jasowang@redhat.com> wrote:
> >
> >
> >On Mon, Dec 1, 2014 at 6:42 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> >>On Mon, Dec 01, 2014 at 06:17:03PM +0800, Jason Wang wrote:
> >>> Hello:
> >>>  We used to orphan packets before transmission for virtio-net. This
> >>>breaks
> >>> socket accounting and can lead serveral functions won't work, e.g:
> >>>  - Byte Queue Limit depends on tx completion nofication to work.
> >>> - Packet Generator depends on tx completion nofication for the last
> >>>   transmitted packet to complete.
> >>> - TCP Small Queue depends on proper accounting of sk_wmem_alloc to
> >>>work.
> >>>  This series tries to solve the issue by enabling tx interrupts. To
> >>>minize
> >>> the performance impacts of this, several optimizations were used:
> >>>  - In guest side, virtqueue_enable_cb_delayed() was used to delay the
> >>>tx
> >>>   interrupt untile 3/4 pending packets were sent.
> >>> - In host side, interrupt coalescing were used to reduce tx
> >>>interrupts.
> >>>  Performance test results[1] (tx-frames 16 tx-usecs 16) shows:
> >>>  - For guest receiving. No obvious regression on throughput were
> >>>   noticed. More cpu utilization were noticed in few cases.
> >>> - For guest transmission. Very huge improvement on througput for
> >>>small
> >>>   packet transmission were noticed. This is expected since TSQ and
> >>>other
> >>>   optimization for small packet transmission work after tx interrupt.
> >>>But
> >>>   will use more cpu for large packets.
> >>> - For TCP_RR, regression (10% on transaction rate and cpu
> >>>utilization) were
> >>>   found. Tx interrupt won't help but cause overhead in this case.
> >>>Using
> >>>   more aggressive coalescing parameters may help to reduce the
> >>>regression.
> >>
> >>OK, you do have posted coalescing patches - does it help any?
> >
> >Helps a lot.
> >
> >For RX, it saves about 5% - 10% cpu. (reduce 60%-90% tx intrs)
> >For small packet TX, it increases 33% - 245% throughput. (reduce about 60%
> >inters)
> >For TCP_RR, it increase the 3%-10% trans.rate. (reduce 40%-80% tx intrs)
> >
> >>
> >>I'm not sure the regression is due to interrupts.
> >>It would make sense for CPU but why would it
> >>hurt transaction rate?
> >
> >Anyway guest need to take some cycles to handle tx interrupts.
> >And transaction rate does increase if we coalesces more tx interurpts.
> >>
> >>
> >>It's possible that we are deferring kicks too much due to BQL.
> >>
> >>As an experiment: do we get any of it back if we do
> >>-        if (kick || netif_xmit_stopped(txq))
> >>-                virtqueue_kick(sq->vq);
> >>+        virtqueue_kick(sq->vq);
> >>?
> >
> >
> >I will try, but during TCP_RR, at most 1 packets were pending,
> >I suspect if BQL can help in this case.
> 
> Looks like this helps a lot in multiple sessions of TCP_RR.

so what's faster
	BQL + kick each packet
	no BQL
?

> How about move the BQL patch out of this series?
> 
> Let's first converge tx interrupt and then introduce it?
> (e.g with kicking after queuing X bytes?)

Sounds good.
