From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net 9/9] virtio-net: XDP support for small buffers
Date: Mon, 2 Jan 2017 14:43:39 -0800
Message-ID: <586AD79B.2070203@gmail.com>
References: <1482503852-12438-1-git-send-email-jasowang@redhat.com>
	<1482503852-12438-10-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1482503852-12438-10-git-send-email-jasowang@redhat.com>
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

On 16-12-23 06:37 AM, Jason Wang wrote:
> Commit f600b6905015 ("virtio_net: Add XDP support") leaves the case of
> small receive buffer untouched. This will confuse the user who want to
> set XDP but use small buffers. Other than forbid XDP in small buffer
> mode, let's make it work. XDP then can only work at skb->data since
> virtio-net create skbs during refill, this is sub optimal which could
> be optimized in the future.
> 
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/virtio_net.c | 112 ++++++++++++++++++++++++++++++++++++-----------
>  1 file changed, 87 insertions(+), 25 deletions(-)
> 

Hi Jason,

I was doing some more testing on this what do you think about doing this
so that free_unused_bufs() handles the buffer free with dev_kfree_skb()
instead of put_page in small receive mode. Seems more correct to me.


diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 783e842..27ff76c 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1898,6 +1898,10 @@ static void free_receive_page_frags(struct virtnet_info *vi)

 static bool is_xdp_queue(struct virtnet_info *vi, int q)
 {
+       /* For small receive mode always use kfree_skb variants */
+       if (!vi->mergeable_rx_bufs)
+               return false;
+
        if (q < (vi->curr_queue_pairs - vi->xdp_queue_pairs))
                return false;
        else if (q < vi->curr_queue_pairs)


patch is untested just spotted doing code review.

Thanks,
John
