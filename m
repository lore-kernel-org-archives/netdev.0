From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next V2] tun: introduce tx skb ring
Date: Fri, 17 Jun 2016 15:22:27 +0800
Message-ID: <5763A533.8030206@redhat.com>
References: <1465979897-4445-1-git-send-email-jasowang@redhat.com>
 <20160617033218-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	davem@davemloft.net, eric.dumazet@gmail.com, brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160617033218-mutt-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016=E5=B9=B406=E6=9C=8817=E6=97=A5 08:41, Michael S. Tsirkin wrote:
> On Wed, Jun 15, 2016 at 04:38:17PM +0800, Jason Wang wrote:
>> >We used to queue tx packets in sk_receive_queue, this is less
>> >efficient since it requires spinlocks to synchronize between produc=
er
>> >and consumer.
>> >
>> >This patch tries to address this by:
>> >
>> >- introduce a new mode which will be only enabled with IFF_TX_ARRAY
>> >   set and switch from sk_receive_queue to a fixed size of skb
>> >   array with 256 entries in this mode.
>> >- introduce a new proto_ops peek_len which was used for peeking the
>> >   skb length.
>> >- implement a tun version of peek_len for vhost_net to use and conv=
ert
>> >   vhost_net to use peek_len if possible.
>> >
>> >Pktgen test shows about 18% improvement on guest receiving pps for =
small
>> >buffers:
>> >
>> >Before: ~1220000pps
>> >After : ~1440000pps
>> >
>> >The reason why I stick to new mode is because:
>> >
>> >- though resize is supported by skb array, in multiqueue mode, it's
>> >   not easy to recover from a partial success of queue resizing.
>> >- tx_queue_len is a user visible feature.
>> >
>> >Signed-off-by: Jason Wang<jasowang@redhat.com>
> I still think it's wrong to add a new feature for this.
> For example, why 256 entries?

It's the value of virtqueue size supported by qemu.

> Queue len is user visible but it's there precisely for this
> reason so people can tune queue for workload.

Right.

>
> Would it help to have ptr_ring_resize that gets an array of
> rings and resizes them both to same length?

Yes, that would be very helpful.
