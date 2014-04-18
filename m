From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] net: Add rtnl_lock for netif_device_attach/detach
Date: Fri, 18 Apr 2014 23:01:18 +0400
Message-ID: <5351767E.6000404@cogentembedded.com>
References: <1397632082-18453-1-git-send-email-zhen-hual@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "Li, Zhen-Hua" <zhen-hual@hp.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Jiri Pirko <jiri@resnulli.us>,
	stephen hemminger <stephen@networkplumber.org>,
	Jerry Chu <hkchu@google.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397632082-18453-1-git-send-email-zhen-hual@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 04/16/2014 11:08 AM, Li, Zhen-Hua wrote:

> From: "Li, Zhen-Hua" <zhen-hual@hp.com>

> As netif_running is called in netif_device_attach/detach. There should be
> rtnl_lock/unlock called, to avoid dev stat change during netif_device_attach
> and detach being called.
> I checked NIC some drivers,  some of them have netif_device_attach/detach
> called between rtnl_lock/unlock, while some drivers do not.

> This patch is tring to find a generic way to fix this for all NIC drivers.

> Signed-off-by: Li, Zhen-Hua <zhen-hual@hp.com>
> ---
>   net/core/dev.c |   18 ++++++++++++++++++
>   1 file changed, 18 insertions(+)

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 5b3042e..795bbc5 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2190,10 +2190,19 @@ EXPORT_SYMBOL(__dev_kfree_skb_any);
>    */
>   void netif_device_detach(struct net_device *dev)
>   {
> +	/**

   Hm, why kernel-doc style comment here?

> +	 * As netif_running is called , rtnl_lock and unlock are needed to
> +	 * avoid __LINK_STATE_START bit changes during this function call.
> +	 */
> +	int need_unlock;
> +
> +	need_unlock = rtnl_trylock();
>   	if (test_and_clear_bit(__LINK_STATE_PRESENT, &dev->state) &&
>   	    netif_running(dev)) {
>   		netif_tx_stop_all_queues(dev);
>   	}
> +	if (need_unlock)
> +		rtnl_unlock();
>   }
>   EXPORT_SYMBOL(netif_device_detach);
>
> @@ -2205,11 +2214,20 @@ EXPORT_SYMBOL(netif_device_detach);
>    */
>   void netif_device_attach(struct net_device *dev)
>   {
> +	/**

   ... and here?

> +	 * As netif_running is called , rtnl_lock and unlock are needed to
> +	 * avoid __LINK_STATE_START bit changes during this function call.
> +	 */

WBR, Sergei
