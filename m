From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 10/10] net: hns3: Add mqprio support when
 interacting with network stack
Date: Fri, 22 Sep 2017 14:55:41 +0200
Message-ID: <20170922125541.GA2005@nanopsycho.orion>
References: <1505992913-107256-1-git-send-email-linyunsheng@huawei.com>
 <1505992913-107256-11-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, huangdaode@hisilicon.com,
        xuwei5@hisilicon.com, liguozhu@hisilicon.com,
        Yisen.Zhuang@huawei.com, gabriele.paoloni@huawei.com,
        john.garry@huawei.com, linuxarm@huawei.com, salil.mehta@huawei.com,
        lipeng321@huawei.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Yunsheng Lin <linyunsheng@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:38444 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752196AbdIVMzo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 08:55:44 -0400
Received: by mail-wr0-f195.google.com with SMTP id p37so605034wrb.5
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 05:55:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1505992913-107256-11-git-send-email-linyunsheng@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Sep 21, 2017 at 01:21:53PM CEST, linyunsheng@huawei.com wrote:
>When using tc qdisc to configure DCB parameter, dcb_ops->setup_tc
>is used to tell hclge_dcb module to do the setup.
>When using lldptool to configure DCB parameter, hclge_dcb module
>call the client_ops->setup_tc to tell network stack which queue
>and priority is using for specific tc.
>
>Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>

[...]
	
	
	
>-static int hns3_setup_tc(struct net_device *netdev, u8 tc)
>+static int hns3_setup_tc(struct net_device *netdev, u8 tc, u8 *prio_tc)
> {
> 	struct hns3_nic_priv *priv = netdev_priv(netdev);
> 	struct hnae3_handle *h = priv->ae_handle;
> 	struct hnae3_knic_private_info *kinfo = &h->kinfo;
>+	bool if_running = netif_running(netdev);
> 	unsigned int i;
> 	int ret;
> 
> 	if (tc > HNAE3_MAX_TC)
> 		return -EINVAL;
> 
>-	if (kinfo->num_tc == tc)
>-		return 0;
>-
> 	if (!netdev)
> 		return -EINVAL;
> 
>-	if (!tc) {
>+	if (if_running) {
>+		(void)hns3_nic_net_stop(netdev);
>+		msleep(100);
>+	}
>+
>+	ret = (kinfo->dcb_ops && kinfo->dcb_ops->setup_tc) ?
>+		kinfo->dcb_ops->setup_tc(h, tc, prio_tc) : -EOPNOTSUPP;

This is most odd. Why do you call dcb_ops from ndo_setup_tc callback?
Why are you mixing this together? prio->tc mapping can be done
directly in dcbnl
