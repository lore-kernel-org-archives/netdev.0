From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH net-next 0/6] Always use tx interrupt for virtio-net
Date: Wed, 15 Oct 2014 13:25:53 +0300
Message-ID: <20141015102553.GF25776@redhat.com>
References: <1413357930-45302-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1413357930-45302-1-git-send-email-jasowang@redhat.com>
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

On Wed, Oct 15, 2014 at 03:25:24PM +0800, Jason Wang wrote:
> According to David, proper accounting and queueing (at all levels, not
> just TCP sockets) is more important than trying to skim a bunch of
> cycles by avoiding TX interrupts.

He also mentioned we should find other ways to batch

> Having an event to free the SKB is
> absolutely essential for the stack to operate correctly.
> 
> This series tries to enable tx interrupt for virtio-net. The idea is
> simple: enable tx interrupt and schedule a tx napi to free old xmit
> skbs.
> 
> Several notes:
> - Tx interrupt storm avoidance when queue is about to be full is
>   kept.

But queue is typically *not* full. More important to avoid interrupt
storms in that case IMO.

> Since we may enable callbacks in both ndo_start_xmit() and tx
>   napi, patch 1 adds a check to make sure used event never go
>   back. This will let the napi not enable the callbacks wrongly after
>   delayed callbacks was used.

So why not just use delayed callbacks?


> - For bulk dequeuing, there's no need to enable tx interrupt for each
>   packet. The last patch only enable tx interrupt for the final skb in
>   the chain through xmit_more and a new helper to publish current avail
>   idx as used event.
> 
> This series fixes several issues of original rfc pointed out by Michael.

Could you list the issues, for ease of review?


> 
> Smoking test is done, and will do complete netperf test. Send the
> seires for early review.
> 
> Thanks
> 
> Jason Wang (6):
>   virtio: make sure used event never go backwards
>   virtio: introduce virtio_enable_cb_avail()
>   virtio-net: small optimization on free_old_xmit_skbs()
>   virtio-net: return the number of packets sent in free_old_xmit_skbs()
>   virtio-net: enable tx interrupt
>   virtio-net: enable tx interrupt only for the final skb in the chain
> 
>  drivers/net/virtio_net.c     |  125 ++++++++++++++++++++++++++++++------------
>  drivers/virtio/virtio_ring.c |   25 ++++++++-
>  include/linux/virtio.h       |    2 +
>  3 files changed, 115 insertions(+), 37 deletions(-)
