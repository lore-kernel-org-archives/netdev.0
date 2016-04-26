From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] tuntap: calculate rps hash only when needed
Date: Tue, 26 Apr 2016 11:12:52 +0800
Message-ID: <571EDCB4.4080508@redhat.com>
References: <1461635741-18857-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461635741-18857-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 04/26/2016 09:55 AM, Jason Wang wrote:
> There's no need to calculate rps hash if it was not enabled. So this
> patch export rps_needed and check it before trying to get rps
> hash. Tests (using pktgen to inject packets to guest) shows this can
> improve pps about 13% (when rps is disabled).
>
> Before:
> ~1150000 pps
> After:
> ~1300000 pps
>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/tun.c | 2 +-
>  net/core/dev.c    | 1 +
>  2 files changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index afdf950..746877f 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -819,7 +819,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
>  	if (txq >= numqueues)
>  		goto drop;
>  
> -	if (numqueues == 1) {
> +	if (numqueues == 1 && static_key_false(&rps_needed)) {
>  		/* Select queue was not called for the skbuff, so we extract the
>  		 * RPS hash and save it into the flow_table here.
>  		 */
> diff --git a/net/core/dev.c b/net/core/dev.c
> index b9bcbe7..d4ba936 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3428,6 +3428,7 @@ u32 rps_cpu_mask __read_mostly;
>  EXPORT_SYMBOL(rps_cpu_mask);
>  
>  struct static_key rps_needed __read_mostly;
> +EXPORT_SYMBOL(rps_needed);
>  
>  static struct rps_dev_flow *
>  set_rps_cpu(struct net_device *dev, struct sk_buff *skb,

Kbuild bot reports an error when !CONFIG_RPS. Will send V2 to fix this.
