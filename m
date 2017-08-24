From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
	path if no tx napi
Date: Thu, 24 Aug 2017 16:50:31 +0300
Message-ID: <20170824160748-mutt-send-email-mst@kernel.org>
References: <20170819063854.27010-1-den@klaipeden.com>
	<5352c98a-fa48-fcf9-c062-9986a317a1b0@redhat.com>
	<CAF=yD-LZ4=WAYfUtY7xRWi50FRSkrcOa+b7uc46xRnC4sbDCzQ@mail.gmail.com>
	<64d451ae-9944-e978-5a05-54bb1a62aaad@redhat.com>
	<20170822204015-mutt-send-email-mst@kernel.org>
	<1503498504.8694.26.camel@klaipeden.com>
	<CAF=yD-+U_aWxSmPPY8v8t=JO0MRZ+N+DzVJTAMKYQ5F=pE1PfA@mail.gmail.com>
	<20170824014553-mutt-send-email-mst@kernel.org>
	<CAF=yD-KSek+LmZu0X0TXetmFEQ59iF3NpjZ4KugbwLo1BGfhaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	Koichiro Den <den@klaipeden.com>, virtualization@lists.linux-foundation.org
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <CAF=yD-KSek+LmZu0X0TXetmFEQ59iF3NpjZ4KugbwLo1BGfhaA@mail.gmail.com>
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

On Wed, Aug 23, 2017 at 11:28:24PM -0400, Willem de Bruijn wrote:
> >> > * as a generic solution, if we were to somehow overcome the safety issue, track
> >> > the delay and do copy if some threshold is reached could be an answer, but it's
> >> > hard for now.> * so things like the current vhost-net implementation of deciding whether or not
> >> > to do zerocopy beforehand referring the zerocopy tx error ratio is a point of
> >> > practical compromise.
> >>
> >> The fragility of this mechanism is another argument for switching to tx napi
> >> as default.
> >>
> >> Is there any more data about the windows guest issues when completions
> >> are not queued within a reasonable timeframe? What is this timescale and
> >> do we really need to work around this.
> >
> > I think it's pretty large, many milliseconds.
> >
> > But I wonder what do you mean by "work around". Using buffers within
> > limited time frame sounds like a reasonable requirement to me.
> 
> Vhost-net zerocopy delays completions until the skb is really
> sent.

This is fundamental in any solution. Guest/application can not
write over a memory buffer as long as hardware might be reading it.

> Traffic shaping can introduce msec timescale latencies.
> 
> The delay may actually be a useful signal. If the guest does not
> orphan skbs early, TSQ will throttle the socket causing host
> queue build up.
> 
> But, if completions are queued in-order, unrelated flows may be
> throttled as well. Allowing out of order completions would resolve
> this HoL blocking.

We can allow out of order, no guests that follow virtio spec
will break. But this won't help in all cases
- a single slow flow can occupy the whole ring, you will not
  be able to make any new buffers available for the fast flow
- what host considers a single flow can be multiple flows for guest

There are many other examples.

> > Neither
> > do I see why would using tx interrupts within guest be a work around -
> > AFAIK windows driver uses tx interrupts.
> 
> It does not address completion latency itself. What I meant was
> that in an interrupt-driver model, additional starvation issues,
> such as the potential deadlock raised at the start of this thread,
> or the timer delay observed before packets were orphaned in
> virtio-net in commit b0c39dbdc204, are mitigated.
> 
> Specifically, it breaks the potential deadlock where sockets are
> blocked waiting for completions (to free up budget in sndbuf, tsq, ..),
> yet completion handling is blocked waiting for a new packet to
> trigger free_old_xmit_skbs from start_xmit.

This talk of potential deadlock confuses me - I think you mean we would
deadlock if we did not orphan skbs in !use_napi - is that right?  If you
mean that you can drop skb orphan and this won't lead to a deadlock if
free skbs upon a tx interrupt, I agree, for sure.

> >> That is the only thing keeping us from removing the HoL blocking in vhost-net zerocopy.
> >
> > We don't enable network watchdog on virtio but we could and maybe
> > should.
> 
> Can you elaborate?

The issue is that holding onto buffers for very long times makes guests
think they are stuck. This is funamentally because from guest point of
view this is a NIC, so it is supposed to transmit things out in
a timely manner. If host backs the virtual NIC by something that is not
a NIC, with traffic shaping etc introducing unbounded latencies,
guest will be confused.

For example, we could set ndo_tx_timeout within guest. Then
if tx queue is stopped for too long, a watchdog would fire.

We worked around most of the issues by introducing guest/host
copy. This copy, done by vhost-net, allows us to pretend that
a not-nic backend (e.g. a qdisc) is a nic (virtio-net).
This way you can both do traffic shaping in host with
unbounded latencies and limit latency from guest point of view.

Cost is both data copies and loss of end to end credit accounting.

Changing Linux as a host to limit latencies while not doing copies will
not be an easy task but that's the only fix that comes to mind.

-- 
MST
