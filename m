From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net v4 3/3] net: hns: fixed bug that skb used after kfree
Date: Thu, 27 Apr 2017 10:38:29 -0700
Message-ID: <eb7eaead-f32c-0ffb-3b24-0d6e11a60843@gmail.com>
References: <1493261053-68197-1-git-send-email-yankejian@huawei.com>
 <1493261053-68197-4-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxarm@huawei.com
To: Yankejian <yankejian@huawei.com>, davem@davemloft.net,
        salil.mehta@huawei.com, yisen.zhuang@huawei.com,
        matthias.bgg@gmail.com, lipeng321@huawei.com, zhouhuiru@huawei.com,
        huangdaode@hisilicon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34861 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751355AbdD0Rif (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 13:38:35 -0400
Received: by mail-wr0-f196.google.com with SMTP id g12so4555956wrg.2
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 10:38:35 -0700 (PDT)
In-Reply-To: <1493261053-68197-4-git-send-email-yankejian@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/26/2017 07:44 PM, Yankejian wrote:
>  	struct hns_nic_priv *priv = netdev_priv(ndev);
>  	struct hnae_ring *ring = ring_data->ring;
> @@ -361,6 +361,10 @@ int hns_nic_net_xmit_hw(struct net_device *ndev,
>  	dev_queue = netdev_get_tx_queue(ndev, skb->queue_mapping);
>  	netdev_tx_sent_queue(dev_queue, skb->len);
>  
> +	netif_trans_update(ndev);
> +	ndev->stats.tx_bytes += skb->len;
> +	ndev->stats.tx_packets++;

This is still wrong though, you should not update your TX statistics
until you get a TX completion interrupt that confirms these packets were
actually transmitted. This has the advantage of not causing use after
free in your ndo_start_xmit() function (current bug), and also allows
feeding information into BQL where it is appropriate, and in a central
location: the TX completion handler.
-- 
Florian
