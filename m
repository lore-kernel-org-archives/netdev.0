From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] mlx4: optimize xmit path
Date: Mon, 29 Sep 2014 11:08:06 -0700
Message-ID: <1412014086.30721.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMEtUuw0UjJuDqSDrK9L-CUWaVdKni1p9cib+VGCOYtBbrCY4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:53050 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755179AbaI2SII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 14:08:08 -0400
Received: by mail-pd0-f169.google.com with SMTP id p10so5720592pdj.0
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 11:08:07 -0700 (PDT)
In-Reply-To: <CAMEtUuw0UjJuDqSDrK9L-CUWaVdKni1p9cib+VGCOYtBbrCY4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-29 at 10:46 -0700, Alexei Starovoitov wrote:
> On Sun, Sep 28, 2014 at 9:19 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >         send_doorbell = !skb->xmit_more || netif_xmit_stopped(ring->tx_queue);
> >
> >         if (ring->bf_enabled && desc_size <= MAX_BF && !bounce &&
> >             !vlan_tx_tag_present(skb) && send_doorbell) {
> 
> This patch is good,
> 
> but I've been thinking more about bf+xmit_more and want
> to double check my understanding in that scenario:
> xmit_more=true will queue descriptors normally and
> the last xmit_more=false packet will write into BF.
> I guess BF suppose to pick up the earlier ones from
> the queue, otherwise the whole thing is broken.
> So if indeed BF can pick up the whole chain, then
> it should be the faster way than doing iowrite32(), right?
> --


Right, this is what my patch is doing.

Say we send a burst of 8 packets.

7 first packets are queued, but no iowrite32() is performed.

final packet is queued, and bf is used to send the doorbell.

With our current stack (net-next), its very easy to check :

Disable tso (ethtool -K eth0 tso off)

Then run netperf -t TCP_RR -H ... -- -r 6000,6000

GSO makes great use of skb->xmit_more right now ;)

(Assuming we do not have GSO preparing hundred of segments out of a
single TSO packet)
