From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next 5/6] net: use core MTU range checking in virt
 drivers
Date: Wed, 19 Oct 2016 10:23:26 -0400
Message-ID: <20161019142326.GD18569@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
 <20161019023333.15760-6-jarod@redhat.com>
 <BLUPR03MB141289B9E24503DF35D5AAC3CAD20@BLUPR03MB1412.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "virtualization@lists.linux-foundation.org"
        <virtualization@lists.linux-foundation.org>,
        KY Srinivasan <kys@microsoft.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Shrikrishna Khare <skhare@vmware.com>,
        "VMware, Inc." <pv-drivers@vmware.com>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BLUPR03MB141289B9E24503DF35D5AAC3CAD20@BLUPR03MB1412.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 19, 2016 at 02:07:47PM +0000, Haiyang Zhang wrote:
> 
> 
> > -----Original Message-----
> > From: Jarod Wilson [mailto:jarod@redhat.com]
> > Sent: Tuesday, October 18, 2016 10:34 PM
> > To: linux-kernel@vger.kernel.org
> > Cc: Jarod Wilson <jarod@redhat.com>; netdev@vger.kernel.org;
> > virtualization@lists.linux-foundation.org; KY Srinivasan
> > <kys@microsoft.com>; Haiyang Zhang <haiyangz@microsoft.com>; Michael S.
> > Tsirkin <mst@redhat.com>; Shrikrishna Khare <skhare@vmware.com>; VMware,
> > Inc. <pv-drivers@vmware.com>
> > Subject: [PATCH net-next 5/6] net: use core MTU range checking in virt
> > drivers
> > 
> > hyperv_net:
> > - set min/max_mtu
> > 
> > virtio_net:
> > - set min/max_mtu
> > - remove virtnet_change_mtu
> > 
> > vmxnet3:
> > - set min/max_mtu
> > 
> > CC: netdev@vger.kernel.org
> > CC: virtualization@lists.linux-foundation.org
> > CC: "K. Y. Srinivasan" <kys@microsoft.com>
> > CC: Haiyang Zhang <haiyangz@microsoft.com>
> > CC: "Michael S. Tsirkin" <mst@redhat.com>
> > CC: Shrikrishna Khare <skhare@vmware.com>
> > CC: "VMware, Inc." <pv-drivers@vmware.com>
> > Signed-off-by: Jarod Wilson <jarod@redhat.com>
> > ---
> >  drivers/net/hyperv/hyperv_net.h   |  4 ++--
> >  drivers/net/hyperv/netvsc_drv.c   | 14 +++++++-------
> >  drivers/net/virtio_net.c          | 23 ++++++++++-------------
> >  drivers/net/vmxnet3/vmxnet3_drv.c |  7 ++++---
> >  4 files changed, 23 insertions(+), 25 deletions(-)
> > 
> > diff --git a/drivers/net/hyperv/hyperv_net.h
> > b/drivers/net/hyperv/hyperv_net.h
> > index f4fbcb5..3958ada 100644
> > --- a/drivers/net/hyperv/hyperv_net.h
> > +++ b/drivers/net/hyperv/hyperv_net.h
> > @@ -606,8 +606,8 @@ struct nvsp_message {
> >  } __packed;
> > 
> > 
> > -#define NETVSC_MTU 65536
> > -#define NETVSC_MTU_MIN 68
> > +#define NETVSC_MTU 65535
> 
> Why change it to 65535? For Hyperv host, this should be 65536.

Forgot to call this change out, sorry. That was changed, because of
IP_MAX_MTU being 0xFFFFU -> 65535.

> > @@ -1343,6 +1336,13 @@ static int netvsc_probe(struct hv_device *dev,
> > 
> >  	netif_carrier_off(net);
> > 
> > +	/* MTU range: 68 - 1500 or 65521 */
> > +	net->min_mtu = NETVSC_MTU_MIN;
> > +	if (nvdev->nvsp_version >= NVSP_PROTOCOL_VERSION_2)
> > +		net->max_mtu = NETVSC_MTU - ETH_HLEN;
> > +	else
> > +		net->max_mtu = ETH_DATA_LEN;
> > +
> >  	netvsc_init_settings(net);
> > 
> >  	net_device_ctx = netdev_priv(net);
> 
> nvdev->nvsp_version is not set until after rndis_filter_device_add()
> is successfully completed.
> You need to move this part to the place just before this line:
>  ret = register_netdev(net);

Okay, will fix that up.

-- 
Jarod Wilson
jarod@redhat.com
