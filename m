From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] xen/netback: calculate correctly the SKB slots.
Date: Mon, 21 May 2012 20:14:00 +0100
Message-ID: <1337627640.2979.33.camel@bwh-desktop.uk.solarflarecom.com>
References: <1337621793-12486-1-git-send-email-konrad.wilk@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xensource.com>, <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>,
	Adnan Misherfi <adnan.misherfi@oracle.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337621793-12486-1-git-send-email-konrad.wilk@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-05-21 at 13:36 -0400, Konrad Rzeszutek Wilk wrote:
> From: Adnan Misherfi <adnan.misherfi@oracle.com>
> 
> A programming error cause the calculation of receive SKB slots to be
> wrong, which caused the RX ring to be erroneously declared full,
> and the receive queue to be stopped. The problem shows up when two
> guest running on the same server tries to communicates using large
> MTUs. Each guest is connected to a bridge with VLAN over bond
> interface, so traffic from one guest leaves the server on one bridge
> and comes back to the second guest on the second bridge. This can be
> reproduces using ping, and one guest as follow:
> 
> - Create active-back bond (bond0)
> - Set up VLAN 5 on bond0 (bond0.5)
> - Create a bridge (br1)
> - Add bond0.5 to a bridge (br1)
> - Start a guest and connect it to br1
> - Set MTU of 9000 across the link
> 
> Ping the guest from an external host using packet sizes of 3991, and
> 4054; ping -s 3991 -c 128 "Guest-IP-Address"
> 
> At the beginning ping works fine, but after a while ping packets do
> not reach the guest because the RX ring becomes full, and the queue
> get stopped. Once the problem accrued, the only way to get out of it
> is to reboot the guest, or use xm network-detach/network-attach.
> 
> ping works for packets sizes 3990,3992, and many other sizes including
> 4000,5000,9000, and 1500 ..etc. MTU size of 3991,4054 are the sizes
> that quickly reproduce this problem.
> 
> Signed-off-by: Adnan Misherfi <adnan.misherfi@oracle.com>
> Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> ---
>  drivers/net/xen-netback/netback.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 957cf9d..e382e5b 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -212,7 +212,7 @@ unsigned int xenvif_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)

The function name is xen_netbk_count_skb_slots() in net-next.  This
appears to depend on the series in
<http://lists.xen.org/archives/html/xen-devel/2012-01/msg00982.html>.

>  	int i, copy_off;
>  
>  	count = DIV_ROUND_UP(
> -			offset_in_page(skb->data)+skb_headlen(skb), PAGE_SIZE);
> +			offset_in_page(skb->data + skb_headlen(skb)), PAGE_SIZE);

The new version would be equivalent to:
	count = offset_in_page(skb->data + skb_headlen(skb)) != 0;
which is not right, as netbk_gop_skb() will use one slot per page.

The real problem is likely that you're not using the same condition to
stop and wake the queue.  Though it appears you're also missing an
smp_mb() at the top of xenvif_notify_tx_completion().

Ben.

>  	copy_off = skb_headlen(skb) % PAGE_SIZE;
>  

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
