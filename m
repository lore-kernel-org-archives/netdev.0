From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] virtio-net: fix page refcnt leaking when fail to
	allocate frag skb
Date: Wed, 20 Nov 2013 07:16:33 -0800
Message-ID: <1384960593.8604.147.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384848307-7217-1-git-send-email-jasowang@redhat.com>
	<1384869828.8604.97.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119204909.GA15004@redhat.com>
	<1384896996.8604.120.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119215312.GE15004@redhat.com>
	<1384898411.8604.127.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131120085835.GB19341@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20131120085835.GB19341@redhat.com>
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

On Wed, 2013-11-20 at 10:58 +0200, Michael S. Tsirkin wrote:
> On Tue, Nov 19, 2013 at 02:00:11PM -0800, Eric Dumazet wrote:
> > On Tue, 2013-11-19 at 23:53 +0200, Michael S. Tsirkin wrote:
> > 
> > > Which NIC? Virtio? Prior to 2613af0ed18a11d5c566a81f9a6510b73180660a
> > > it didn't drop packets received from host as far as I can tell.
> > > virtio is more like a pipe than a real NIC in this respect.
> > 
> > Prior/after to this patch, you were not posting buffers, so if packets
> > were received on a physical NIC, you were dropping the packets anyway.
> >
> > It makes no difference at all, adding a cushion might make you feel
> > better, but its really not worth it.
> > 
> > Under memory stress, it makes better sense to drop a super big GRO
> > packet (The one needing frag_list extension ...)
> > 
> > It gives a better signal to the sender to reduce its pressure, and gives
> > opportunity to free more of your memory.
> > 
> 
> OK, but in that case one wonders whether we should do more to free memory?
> 
> E.g. imagine that we dropped a packet of a specific TCP flow
> because we couldn't allocate a new packet.
> 
> What happens now is that the old packet is freed as well.
> 
> So quite likely the next packet in queue will get processed
> since it will reuse the memory we have just freed.
> 
> The next packet and the next after it etc all will have to go through
> the net stack until they get at the socket and are dropped then
> because we missed a segment.  Even worse, GRO gets disabled so the load
> on receiver goes up instead of down.
> 
> Sounds like a problem doesn't it?

I see no problem at all. GRO is a hint for high rates (and obviously
when there is enough memory)

> 
> GRO actually detects it's the same flow and can see packet is
> out of sequence. Why doesn't it drop the packet then?
> Alternatively, we could (for example using the pre-allocated skb
> like I suggested) notify GRO that it should start dropping packets
> of this flow.
> 
> What do you think?
> 

I think we disagree a lot on memory management on networking stacks.

We did a lot of work in TCP stack and Qdisc layers to lower memory
pressure (and bufferbloat), an you seem to try hard to introduce yet
another layer of buffer bloat in virtio_net.

So add whatever you want to proudly state to your management :

"Look how smart we are : we drop no packets in our layer"
