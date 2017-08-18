From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH net-next] net: hns3: Add support to change MTU in
 hardware & netdev
Date: Fri, 18 Aug 2017 14:55:13 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B86F75F@FRAEML521-MBX.china.huawei.com>
References: <20170818113558.71928-1-salil.mehta@huawei.com>
 <20170818133128.GA523@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170818133128.GA523@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Friday, August 18, 2017 2:31 PM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); lipeng (Y);
> dan.carpenter@oracle.com; mehta.salil.lnk@gmail.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; linux-
> rdma@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH net-next] net: hns3: Add support to change MTU in
> hardware & netdev
> 
> On Fri, Aug 18, 2017 at 12:35:58PM +0100, Salil Mehta wrote:
> > This patch adds the following support to the HNS3 driver:
> > 1. Support to change the Maximum Transmission Unit of a
> >    netdevice and of a port in hardware .
> > 2. Initializes the supported MTU range for the netdevice.
> >
> > Signed-off-by: lipeng <lipeng321@huawei.com>
> > Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
> > ---
> >  .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 46
> ++++++++++++++++++++++
> >  .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h |  1 +
> >  2 files changed, 47 insertions(+)
> >
> > diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
> b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
> > index e731f87..8e3711e 100644
> > --- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
> > +++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
> > @@ -1278,11 +1278,53 @@ static int hns3_ndo_set_vf_vlan(struct
> net_device *netdev, int vf, u16 vlan,
> >  	return ret;
> >  }
> >
> > +static int hns3_nic_change_mtu(struct net_device *netdev, int
> new_mtu)
> > +{
> > +	struct hns3_nic_priv *priv = netdev_priv(netdev);
> > +	struct hnae3_handle *h = priv->ae_handle;
> > +	bool if_running = netif_running(netdev);
> > +	int ret;
> > +
> > +	/* no change in MTU */
> > +	if (new_mtu == netdev->mtu)
> > +		return 0;
> 
> Hi Salil
> 
> It is worth reading the core code:
> 
> http://elixir.free-
> electrons.com/linux/latest/source/net/core/dev.c#L6713
Right. Looks like it is already being done since 4.10-rc1 because of
the patches Floated by Jarod Wilson <jarod@redhat.com>.
Link: https://lkml.org/lkml/2016/10/13/270

Will remove this duplicate check!

Thanks
Salil 
>  +
> > +	if (!h->ae_algo->ops->set_mtu)
> > +		return -ENOTSUPP;
> > +
> > +	/* if this was called with netdev up then bring netdevice down */
> > +	if (if_running) {
> > +		(void)hns3_nic_net_stop(netdev);
> > +		msleep(100);
> > +	}
> > +
> > +	ret = h->ae_algo->ops->set_mtu(h, new_mtu);
> > +	if (ret) {
> > +		netdev_err(netdev, "failed to change MTU in hardware %d\n",
> > +			   ret);
> > +		return ret;
> > +	}
> > +
> > +	/* assign newly changed mtu to netdevice as well */
> > +	netdev->mtu = new_mtu;
> 
> http://elixir.free-
> electrons.com/linux/latest/source/net/core/dev.c#L6698
Again, it is being done by core now since 4.10-rc1.
Link: https://lkml.org/lkml/2016/10/13/270

Will remove this duplicate code!

Thanks
Salil
> 
> > +
> > +	/* if the netdev was running earlier, bring it up again */
> > +	if (if_running) {
> > +		if (hns3_nic_net_open(netdev)) {
> > +			netdev_err(netdev, "MTU, couldnt up netdev again\n");
> > +			ret = -EINVAL;
> > +		}
> > +	}
> > +
> > +	return ret;
> > +}
> > +
> >  static const struct net_device_ops hns3_nic_netdev_ops = {
> >  	.ndo_open		= hns3_nic_net_open,
> >  	.ndo_stop		= hns3_nic_net_stop,
> >  	.ndo_start_xmit		= hns3_nic_net_xmit,
> >  	.ndo_set_mac_address	= hns3_nic_net_set_mac_address,
> > +	.ndo_change_mtu		= hns3_nic_change_mtu,
> >  	.ndo_set_features	= hns3_nic_set_features,
> >  	.ndo_get_stats64	= hns3_nic_get_stats64,
> >  	.ndo_setup_tc		= hns3_nic_setup_tc,
> > @@ -2752,6 +2794,10 @@ static int hns3_client_init(struct
> hnae3_handle *handle)
> >  		goto out_reg_netdev_fail;
> >  	}
> >
> > +	/* MTU range: 68 - 9706 */
> > +	netdev->min_mtu = ETH_MIN_MTU;
> 
> http://elixir.free-
> electrons.com/linux/latest/source/net/ethernet/eth.c#L361
Supported range of Min and Max MTU should be at the discretion
of the driver. Therefore, initialization looks fine to me.

I could not clearly understand the problem being highlighted
over here. Could you further clarify?

Thanks
Salil
> 
> > +	netdev->max_mtu = HNS3_MAX_MTU - (ETH_HLEN + ETH_FCS_LEN +
> VLAN_HLEN);
> > +
> >  	return ret;
> >
> >  out_reg_netdev_fail:
> > diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
> b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
> > index a6e8f15..7e87461 100644
> > --- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
> > +++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
> > @@ -76,6 +76,7 @@ enum hns3_nic_state {
> >  #define HNS3_RING_NAME_LEN			16
> >  #define HNS3_BUFFER_SIZE_2048			2048
> >  #define HNS3_RING_MAX_PENDING			32768
> > +#define HNS3_MAX_MTU				9728
> 
> It seems odd that it does not already exists somewhere. The core does
> not enforce the MTU.  You could be passed a frame which is bigger. So
> you should check before trying to pass something to the hardware which
> the hardware cannot handle.
There is a check already in place for this as well since 4.10-rc1.
But perhaps this time there is no change required as it is being taken
care by the core. Thanks to sharp eyes of Jarod.
Link: https://lkml.org/lkml/2016/10/13/270

[...]
if (dev->max_mtu > 0 && new_mtu > dev->max_mtu) {
	net_err_ratelimited("%s: Invalid MTU %d requested, hw max %d\n",
			    dev->name, new_mtu, dev->max_mtu);
[...]

I think I missed this patch entirely so those rest above checks &
assignments were repeated. 

Thanks
Salil
> 
>     Andrew
