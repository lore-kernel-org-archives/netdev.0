From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
	path if no tx napi
Date: Sun, 20 Aug 2017 16:49:15 -0400
Message-ID: <CAF=yD-LYLsQNt_5yYZ+PUwv04ZwaJUXn-YakH=tuh0TV+BG7iA@mail.gmail.com>
References: <20170819063854.27010-1-den@klaipeden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	virtualization@lists.linux-foundation.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Koichiro Den <den@klaipeden.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20170819063854.27010-1-den@klaipeden.com>
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

On Sat, Aug 19, 2017 at 2:38 AM, Koichiro Den <den@klaipeden.com> wrote:
> Facing the possible unbounded delay relying on freeing on xmit path,
> we also better to invoke and clear the upper layer zerocopy callback
> beforehand to keep them from waiting for unbounded duration in vain.

Good point.

> For instance, this removes the possible deadlock in the case that the
> upper layer is a zerocopy-enabled vhost-net.
> This does not apply if napi_tx is enabled since it will be called in
> reasonale time.

Indeed. Btw, I am gathering data to eventually make napi the default
mode. But that is taking some time.

>
> Signed-off-by: Koichiro Den <den@klaipeden.com>
> ---
>  drivers/net/virtio_net.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 4302f313d9a7..f7deaa5b7b50 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1290,6 +1290,14 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>
>         /* Don't wait up for transmitted skbs to be freed. */
>         if (!use_napi) {
> +               if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
> +                       struct ubuf_info *uarg;
> +                       uarg = skb_shinfo(skb)->destructor_arg;
> +                       if (uarg->callback)
> +                           uarg->callback(uarg, true);
> +                       skb_shinfo(skb)->destructor_arg = NULL;
> +                       skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
> +               }

Instead of open coding, this can use skb_zcopy_clear.

>                 skb_orphan(skb);
>                 nf_reset(skb);
>         }
> --
> 2.9.4
>
>
