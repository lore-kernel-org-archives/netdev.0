From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] kvm tools: Implement multiple VQ for virtio-net
Date: Tue, 15 Nov 2011 10:14:10 +0530
Message-ID: <OFDA747DDD.8D1C8FD8-ON65257949.001837DA-65257949.0019D25F@in.ibm.com>
References: <1321049521-26376-1-git-send-email-levinsasha928@gmail.com>	
	<20111113102428.GD15322@redhat.com> <1321196430.2425.2.camel@sasha>
	<4EC07729.3050303@gmail.com> <1321265740.2425.7.camel@sasha>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: penberg@kernel.org, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, Asias He <asias.hejun@gmail.com>,
	virtualization@lists.linux-foundation.org, gorcunov@gmail.com,
	netdev@vger.kernel.org, mingo@elte.hu
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1321265740.2425.7.camel@sasha>
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

Sasha Levin <levinsasha928@gmail.com> wrote on 11/14/2011 03:45:40 PM:

> > Why both the bandwidth and latency performance are dropping so
> > dramatically with multiple VQ?
>
> It looks like theres no hash sync between host and guest, which makes
> the RX VQ change for every packet. This is my guess.

Yes, I confirmed this happens for macvtap. I am
using ixgbe - it calls skb_record_rx_queue when
a skb is allocated, but sets rxhash when a packet
arrives. Macvtap is relying on record_rx_queue
first ahead of rxhash (as part of my patch making
macvtap multiqueue), hence different skbs result
in macvtap selecting different vq's.

Reordering macvtap to use rxhash first results in
all packets going to the same VQ. The code snippet
is:

{
	...
	if (!numvtaps)
                goto out;

	rxq = skb_get_rxhash(skb);
	if (rxq) {
		tap = rcu_dereference(vlan->taps[rxq % numvtaps]);
		if (tap)
			goto out;
	}

	if (likely(skb_rx_queue_recorded(skb))) {
		rxq = skb_get_rx_queue(skb);

		while (unlikely(rxq >= numvtaps))
			rxq -= numvtaps;
			tap = rcu_dereference(vlan->taps[rxq]);
			if (tap)
				goto out;
	}
}

I will submit a patch for macvtap separately. I am working
towards the other issue pointed out - different vhost
threads handling rx/tx of a single flow.

thanks,

- KK
