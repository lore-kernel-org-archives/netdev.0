From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] hyperv: Fix the error processing in netvsc_send()
Date: Fri, 30 Jan 2015 10:33:19 +0008
Message-ID: <1422613519.8840.0@smtp.corp.redhat.com>
References: <1422563689-31036-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, haiyangz@microsoft.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
 davem@davemloft.net
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1422563689-31036-1-git-send-email-haiyangz@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



On Fri, Jan 30, 2015 at 4:34 AM, Haiyang Zhang <haiyangz@microsoft.com> 
wrote:
> The existing code frees the skb in EAGAIN case, in which the skb will 
> be
> retried from upper layer and used again.
> Also, the existing code doesn't free send buffer slot in error case, 
> because
> there is no completion message for unsent packets.
> This patch fixes these problems.
> 
> (Please also include this patch for stable trees. Thanks!)
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> ---
>  drivers/net/hyperv/netvsc.c |   11 ++++++++---
>  1 files changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
> index 9f49c01..7cd4eb3 100644
> --- a/drivers/net/hyperv/netvsc.c
> +++ b/drivers/net/hyperv/netvsc.c
> @@ -716,7 +716,7 @@ int netvsc_send(struct hv_device *device,
>  	u64 req_id;
>  	unsigned int section_index = NETVSC_INVALID_INDEX;
>  	u32 msg_size = 0;
> -	struct sk_buff *skb;
> +	struct sk_buff *skb = NULL;
>  	u16 q_idx = packet->q_idx;
>  
>  
> @@ -743,8 +743,6 @@ int netvsc_send(struct hv_device *device,
>  							   packet);
>  			skb = (struct sk_buff *)
>  			      (unsigned long)packet->send_completion_tid;
> -			if (skb)
> -				dev_kfree_skb_any(skb);
>  			packet->page_buf_cnt = 0;
>  		}
>  	}
> @@ -810,6 +808,13 @@ int netvsc_send(struct hv_device *device,
>  			   packet, ret);
>  	}
>  
> +	if (ret != 0) {
> +		if (section_index != NETVSC_INVALID_INDEX)
> +			netvsc_free_send_slot(net_device, section_index);

What if ret is -EINVAL or -ENOSPC? Looks like we need free the skb in 
this case also.
> 
> +	} else if (skb) {
> +		dev_kfree_skb_any(skb);

The caller - netvsc_start_xmit() do this also, may be handle this in 
caller is better since netvsc_start_xmit() is the only user that tries 
to send a skb?

btw, I find during netvsc_start_xmit(), ret was change to -ENOSPC when 
queue_sends[q_idx] < 1. But non of the caller check -ENOSPC in fact?

Thanks
> 
> +	}
> +
>  	return ret;
>  }
>  
> -- 
> 1.7.4.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
