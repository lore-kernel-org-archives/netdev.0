From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next 4/6] net: hip04: Don't free the tx skb when the buffer is not ready for xmit
Date: Thu, 16 Apr 2015 10:41:09 +0200
Message-ID: <4971105.FJGVdDRE9f@wuerfel>
References: <1429101008-9464-1-git-send-email-dingtianhong@huawei.com> <2218546.M1hzu1bzfh@wuerfel> <552F560D.4070309@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, grant.likely@linaro.org,
	sergei.shtylyov@cogentembedded.com,
	linux-arm-kernel@lists.infradead.org, eric.dumazet@gmail.com,
	zhangfei.gao@linaro.org, joe@perches.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux@arm.linux.org.uk
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:60769 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755AbbDPIlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 04:41:20 -0400
In-Reply-To: <552F560D.4070309@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 16 April 2015 14:26:21 Ding Tianhong wrote:
> On 2015/4/15 22:19, Arnd Bergmann wrote:
> > On Wednesday 15 April 2015 20:30:06 Ding Tianhong wrote:
> >> @@ -489,6 +487,8 @@ static int hip04_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> >>  
> >>         /* Ensure tx_head update visible to tx reclaim */
> >>         smp_wmb();
> >> +       count++;
> >> +       priv->tx_head = TX_NEXT(tx_head);
> >>  
> >>
> > 
> > Something is wrong here, the comment does not match the code any more, because
> > the smp_wmb() won't actually make the tx_head update visible.
> > 
> >       Arnd
> > 
> Yes, the smp_wmb() could only make sure the tx buffer was ready to xmit.

The problem you need to avoid is that the tx reclaim function thinks it's
done with all outstanding packets and does not retrigger, while the
start_xmit thinks it will still get to that. This means you
need a barrier between the priv->tx_head update and the
napi_schedule_prep() call.

	Arnd
