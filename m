From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] tun: bail out from tun_get_user() if the skb is empty
Date: Wed, 27 Sep 2017 05:42:48 -0700
Message-ID: <1506516168.6617.38.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170927121649.90557-1-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, dvyukov@google.com,
        syzkaller@googlegroups.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Alexander Potapenko <glider@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170927121649.90557-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-09-27 at 14:16 +0200, Alexander Potapenko wrote:
> KMSAN (https://github.com/google/kmsan) reported accessing uninitialized
> skb->data[0] in the case the skb is empty (i.e. skb->len is 0):

> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
> v2: free the skb
> ---
>  drivers/net/tun.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 3c9985f29950..0d60fd4ada9e 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1496,6 +1496,11 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  	switch (tun->flags & TUN_TYPE_MASK) {
>  	case IFF_TUN:
>  		if (tun->flags & IFF_NO_PI) {
> +			if (!skb->len) {
> +				this_cpu_inc(tun->pcpu_stats->rx_dropped);
> +				kfree_skb(skb);
> +				return -EINVAL;
> +			}
>  			switch (skb->data[0] & 0xf0) {
>  			case 0x40:
>  				pi.proto = htons(ETH_P_IP);


Acked-by: Eric Dumazet <edumazet@google.com>

Or something cleaner to avoid copy/paste and focus on proper
skb->data[0] access and meaning.

Thanks.

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 3c9985f299503ea65dad7eb3b47e2ab3bef87800..8ddb840687c1bdb24e4182612abc9e362624c3e9 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1496,11 +1496,13 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	switch (tun->flags & TUN_TYPE_MASK) {
 	case IFF_TUN:
 		if (tun->flags & IFF_NO_PI) {
-			switch (skb->data[0] & 0xf0) {
-			case 0x40:
+			u8 ip_proto = skb->len ? (skb->data[0] >> 4) : 0;
+
+			switch (ip_proto) {
+			case 4:
 				pi.proto = htons(ETH_P_IP);
 				break;
-			case 0x60:
+			case 6:
 				pi.proto = htons(ETH_P_IPV6);
 				break;
 			default:
