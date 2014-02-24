From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] openvswitch: orphan frags on local receive
Date: Mon, 24 Feb 2014 15:30:15 +0200
Message-ID: <20140224133015.GG8981@redhat.com>
References: <530B45E0.20009@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, KVM list <kvm@vger.kernel.org>,
	netdev@vger.kernel.org
To: Qin Chuanyu <qinchuanyu@huawei.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <530B45E0.20009@huawei.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 24, 2014 at 09:15:12PM +0800, Qin Chuanyu wrote:
> with vhost tx zero_copy, guest nic might get hang when host reserving
> skb in socket queue delivered by guest, the case has been solved in
> tun, it also been needed by openvswitch. This could easily happened
> when a LAST_ACK state tcp occuring between guest and host.
> 
> Signed-off-by: Chuanyu Qin <qinchuanyu@huawei.com>

Same question as with bridge.

> ---
>  net/openvswitch/vport-internal_dev.c |    3 +++
>  net/openvswitch/vport.c              |    1 +
>  2 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/net/openvswitch/vport-internal_dev.c
> b/net/openvswitch/vport-internal_dev.c
> index 729c687..adb25e2 100644
> --- a/net/openvswitch/vport-internal_dev.c
> +++ b/net/openvswitch/vport-internal_dev.c
> @@ -212,6 +212,9 @@ static int internal_dev_recv(struct vport
> *vport, struct sk_buff *skb)
>  	struct net_device *netdev = netdev_vport_priv(vport)->dev;
>  	int len;
> 
> +	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
> +		return -NET_RX_DROP;
> +
>  	len = skb->len;
> 
>  	skb_dst_drop(skb);
> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
> index 208dd9a..04172d6 100644
> --- a/net/openvswitch/vport.c
> +++ b/net/openvswitch/vport.c
> @@ -383,6 +383,7 @@ int ovs_vport_send(struct vport *vport, struct
> sk_buff *skb)
>  		u64_stats_update_end(&stats->syncp);
>  	} else if (sent < 0) {
>  		ovs_vport_record_error(vport, VPORT_E_TX_ERROR);
> +		skb_tx_error(skb);
>  		kfree_skb(skb);
>  	} else
>  		ovs_vport_record_error(vport, VPORT_E_TX_DROPPED);
> -- 
> 1.7.3.1.msysgit.0
