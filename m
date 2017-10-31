From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 2/4] hv_netvsc: protect nvdev->extension with
 RCU
Date: Tue, 31 Oct 2017 17:44:51 +0100
Message-ID: <20171031174451.096978cd@shemminger-XPS-13-9360>
References: <20171031134204.15287-1-vkuznets@redhat.com>
        <20171031134204.15287-3-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@linuxdriverproject.org,
        Haiyang Zhang <haiyangz@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        linux-kernel@vger.kernel.org
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171031134204.15287-3-vkuznets@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 31 Oct 2017 14:42:02 +0100
Vitaly Kuznetsov <vkuznets@redhat.com> wrote:

> @@ -2002,7 +2002,9 @@ static int netvsc_probe(struct hv_device *dev,
>  	device_info.recv_sections = NETVSC_DEFAULT_RX;
>  	device_info.recv_section_size = NETVSC_RECV_SECTION_SIZE;
>  
> +	rtnl_lock();
>  	nvdev = rndis_filter_device_add(dev, &device_info);
> +	rtnl_unlock();

rtnl is not necessary here. probe can not be bothered by other changes.

> --- a/drivers/net/hyperv/rndis_filter.c
> +++ b/drivers/net/hyperv/rndis_filter.c
> @@ -402,20 +402,27 @@ int rndis_filter_receive(struct net_device *ndev,
>  			 void *data, u32 buflen)
>  {
>  	struct net_device_context *net_device_ctx = netdev_priv(ndev);
> -	struct rndis_device *rndis_dev = net_dev->extension;
> +	struct rndis_device *rndis_dev;
>  	struct rndis_message *rndis_msg = data;
> +	int ret = 0;
> +
> +	rcu_read_lock_bh();
> +
> +	rndis_dev = rcu_dereference_bh(net_dev->extension);

filter_receive is already called only from NAPI only and has RCU lock and soft
irq disabled. This is not necessary.

> -	net_dev->extension = NULL;
> +	rcu_assign_pointer(net_dev->extension, NULL);
> +
> +	synchronize_rcu();

rcu_assign_pointer with NULL is never a good idea.
And synchronize_rcu is slow. Since net_device is already protected
by RCU (for deletion) it should not be necessary.


Thank you for trying to address these races. But it should be
done carefully not by just slapping RCU everywhere.
