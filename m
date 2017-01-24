From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: Re: [PATCH] ibmveth: Add a proper check for the availability of the
 checksum features
Date: Tue, 24 Jan 2017 15:28:18 -0600
Message-ID: <d2d6c228-18bc-8e14-1314-fd2c8c486640@linux.vnet.ibm.com>
References: <1485239321-14947-1-git-send-email-thuth@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org
To: Thomas Huth <thuth@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:55536 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750828AbdAXV21 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:28:27 -0500
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0OLNXVI121803
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 16:28:27 -0500
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
        by mx0b-001b2d01.pphosted.com with ESMTP id 286et4r4f7-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 16:28:26 -0500
Received: from localhost
        by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Tue, 24 Jan 2017 14:28:26 -0700
In-Reply-To: <1485239321-14947-1-git-send-email-thuth@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/24/2017 12:28 AM, Thomas Huth wrote:
> When using the ibmveth driver in a KVM/QEMU based VM, it currently
> always prints out a scary error message like this when it is started:
>
>  ibmveth 71000003 (unregistered net_device): unable to change
>  checksum offload settings. 1 rc=-2 ret_attr=71000003
>
> This happens because the driver always tries to enable the checksum
> offloading without checking for the availability of this feature first.
> QEMU does not support checksum offloading for the spapr-vlan device,
> thus we always get the error message here.
> According to the LoPAPR specification, the "ibm,illan-options" property
> of the corresponding device tree node should be checked first to see
> whether the H_ILLAN_ATTRIUBTES hypercall and thus the checksum offloading
> feature is available. Thus let's do this in the ibmveth driver, too, so
> that the error message is really only limited to cases where something
> goes wrong, and does not occur if the feature is just missing.

Thanks a lot for this patch, Thomas.  Was going to give an Ack, but its already been applied :)

>
> Signed-off-by: Thomas Huth <thuth@redhat.com>
> ---
>  drivers/net/ethernet/ibm/ibmveth.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
> index a831f94..309f5c6 100644
> --- a/drivers/net/ethernet/ibm/ibmveth.c
> +++ b/drivers/net/ethernet/ibm/ibmveth.c
> @@ -1601,8 +1601,11 @@ static int ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
>  	netdev->netdev_ops = &ibmveth_netdev_ops;
>  	netdev->ethtool_ops = &netdev_ethtool_ops;
>  	SET_NETDEV_DEV(netdev, &dev->dev);
> -	netdev->hw_features = NETIF_F_SG | NETIF_F_RXCSUM |
> -		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
> +	netdev->hw_features = NETIF_F_SG;
> +	if (vio_get_attribute(dev, "ibm,illan-options", NULL) != NULL) {
> +		netdev->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> +				       NETIF_F_RXCSUM;
> +	}
>
>  	netdev->features |= netdev->hw_features;
>
