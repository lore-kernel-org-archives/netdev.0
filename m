From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] netdev: pktgen xmit packet through vlan interface
Date: Fri, 02 May 2014 20:18:13 +0400
Message-ID: <5363C545.90600@cogentembedded.com>
References: <1399015092-28643-1-git-send-email-zhouzhouyi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: Zhouyi Zhou <zhouzhouyi@gmail.com>, davem@davemloft.net,
	steffen.klassert@secunet.com, fan.du@windriver.com,
	dborkman@redhat.com, minipli@googlemail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399015092-28643-1-git-send-email-zhouzhouyi@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/02/2014 11:18 AM, Zhouyi Zhou wrote:

> As http://www.spinics.net/lists/netdev/msg165015.html
> pktgen generates shared packet through vlan interface will cause
> oops because of duplicate entering tc queue.

> Try to solve this problem by means of packet clone instead of sharing.

> Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
> ---
>   net/core/pktgen.c |   20 +++++++++++++++++---
>   1 files changed, 17 insertions(+), 3 deletions(-)

> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index 0304f98..ced07fc 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
[...]
> @@ -3347,8 +3348,18 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
>   		pkt_dev->last_ok = 0;
>   		goto unlock;
>   	}
> -	atomic_inc(&(pkt_dev->skb->users));
> -	ret = (*xmit)(pkt_dev->skb, odev);
> +
> +	if (pkt_dev->clone_skb && is_vlan_dev(odev)) {
> +		nskb = skb_clone(pkt_dev->skb, GFP_ATOMIC);
> +		ret = -ENOMEM;
> +		if (nskb)
> +			ret = (*xmit)(nskb, odev);

    You can just do:

			ret = xmit(nskb, odev);

> +		else
> +			nskb = ERR_PTR(ret);
> +	} else {
> +		atomic_inc(&(pkt_dev->skb->users));
> +		ret = (*xmit)(pkt_dev->skb, odev);

    Same here.

WBR, Sergei
