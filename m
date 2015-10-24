From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RTF] sh_eth: fix kernel oops in skb_put()
Date: Sat, 24 Oct 2015 15:05:35 +0300
Message-ID: <562B740F.6010900@cogentembedded.com>
References: <4859772.ltR2e4ZqZH@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org, yashi@atmark-techno.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4859772.ltR2e4ZqZH@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 10/24/2015 2:09 AM, Sergei Shtylyov wrote:

> In a low memory situation the following kernel oops occurs:
>
> Unable to handle kernel NULL pointer dereference at virtual address 00000050
> pgd = 8490c000
> [00000050] *pgd=4651e831, *pte=00000000, *ppte=00000000
> Internal error: Oops: 17 [#1] PREEMPT ARM
> Modules linked in:
> CPU: 0    Not tainted  (3.4-at16 #9)
> PC is at skb_put+0x10/0x98
> LR is at sh_eth_poll+0x2c8/0xa10
> pc : [<8035f780>]    lr : [<8028bf50>]    psr: 60000113
> sp : 84eb1a90  ip : 84eb1ac8  fp : 84eb1ac4
> r10: 0000003f  r9 : 000005ea  r8 : 00000000
> r7 : 00000000  r6 : 940453b0  r5 : 00030000  r4 : 9381b180
> r3 : 00000000  r2 : 00000000  r1 : 000005ea  r0 : 00000000
> Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
> Control: 10c53c7d  Table: 4248c059  DAC: 00000015
> Process klogd (pid: 2046, stack limit = 0x84eb02e8)
> [...]
>
> This is because netdev_alloc_skb() fails and 'mdp->rx_skbuff[entry]' is left
> NULL but sh_eth_rx() later uses it without checking. Add such check...
>
> Reported-by: Yasushi SHOJI <yashi@atmark-techno.com>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>
> ---
> This patch is against DaveM's 'net.git' repo.
>
> drivers/net/ethernet/renesas/sh_eth.c |    3 +++
>   1 file changed, 3 insertions(+)
>
> Index: net/drivers/net/ethernet/renesas/sh_eth.c
> ===================================================================
> --- net.orig/drivers/net/ethernet/renesas/sh_eth.c
> +++ net/drivers/net/ethernet/renesas/sh_eth.c
> @@ -1502,6 +1502,8 @@ static int sh_eth_rx(struct net_device *
>   					phys_to_virt(ALIGN(rxdesc->addr, 4)),
>   					pkt_len + 2);
>   			skb = mdp->rx_skbuff[entry];
> +			if (!skb)
> +				goto skip;
>   			mdp->rx_skbuff[entry] = NULL;
>   			if (mdp->cd->rpadir)
>   				skb_reserve(skb, NET_IP_ALIGN);
> @@ -1516,6 +1518,7 @@ static int sh_eth_rx(struct net_device *
>   			if (desc_status & RD_RFS8)
>   				ndev->stats.multicast++;
>   		}
> +skip:
>   		entry = (++mdp->cur_rx) % mdp->num_rx_ring;
>   		rxdesc = &mdp->rx_ring[entry];
>   	}

    In fact, it could be done without goto/label. I'll recast.

MBR, Sergei

