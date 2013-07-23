From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] tuntap: hardware vlan tx support
Date: Tue, 23 Jul 2013 16:12:49 +0400
Message-ID: <51EE7341.4060404@cogentembedded.com>
References: <1374563748-38821-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Basil Gor <basil.gor@gmail.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374563748-38821-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 23-07-2013 11:15, Jason Wang wrote:

> Inspired by commit f09e2249c4f5c7c13261ec73f5a7807076af0c8e (macvtap: restore
> vlan header on user read). This patch adds hardware vlan tx support for
> tuntap. This is done by copying vlan header directly into userspace in
> tun_put_user() instead of doing it through __vlan_put_tag() in
> dev_hard_start_xmit(). This eliminates one unnecessary memove in

    s/memove/memmove/?

> vlan_insert_tag() for 802.1ad and 802.1q traffic.

> pktgen test shows about 20% improvement for 802.1q traffic:

> Before:
>    662149pps 317Mb/sec (317831520bps) errors: 0
> After:
>    801033pps 384Mb/sec (384495840bps) errors: 0

> Cc: Basil Gor <basil.gor@gmail.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>   drivers/net/tun.c |   39 +++++++++++++++++++++++++++++++++++----
>   1 files changed, 35 insertions(+), 4 deletions(-)

> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index a72d141..66e265d 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
[...]
> @@ -1328,11 +1330,39 @@ static ssize_t tun_put_user(struct tun_struct *tun,
>   		total += tun->vnet_hdr_sz;
>   	}
>
> -	len = min_t(int, skb->len, len);
> +	if (!vlan_tx_tag_present(skb))
> +		len = min_t(int, skb->len, len);
> +	else {

    According to Documentation/CodingStyle chapter 3, both arms of an *if* 
statement should have {} if one arm has it.

> +		int copy, ret;
> +		struct {
> +			__be16 h_vlan_proto;
> +			__be16 h_vlan_TCI;
> +		} veth;

    Empty line wouldn't hurt here, after declarations...

> +		veth.h_vlan_proto = skb->vlan_proto;
> +		veth.h_vlan_TCI = htons(vlan_tx_tag_get(skb));
[...]

WBR, Sergei
