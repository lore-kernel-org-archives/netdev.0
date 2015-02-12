From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH net-next] ipv6: fix ipv6_cow_metrics for non
 DST_HOST case
Date: Thu, 12 Feb 2015 16:32:39 -0500
Message-ID: <1423776759.3051.5.camel@stressinduktion.org>
References: <1423771650-870555-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:50570 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750878AbbBLViZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 16:38:25 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 7FA9B20C47
	for <netdev@vger.kernel.org>; Thu, 12 Feb 2015 16:32:40 -0500 (EST)
In-Reply-To: <1423771650-870555-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Do, 2015-02-12 at 12:07 -0800, Martin KaFai Lau wrote:
> ipv6_cow_metrics() currently assumes only DST_HOST routes require
> dynamic metrics allocation from inetpeer.  The assumption breaks
> when ndisc discovered router with RTAX_MTU and RTAX_HOPLIMIT metric.
> Refer to ndisc_router_discovery() in ndisc.c and note that dst_metric_set()
> is called after the route is created.
> 
> This patch creates the metrics array (by calling dst_cow_metrics_generic) in
> ipv6_cow_metrics().
> 
> Test:
> radvd.conf:
> interface qemubr0
> {
> 	AdvLinkMTU 1300;
> 	AdvCurHopLimit 30;
> 
> 	prefix fd00:face:face:face::/64
> 	{
> 		AdvOnLink on;
> 		AdvAutonomous on;
> 		AdvRouterAddr off;
> 	};
> };
> 
> Before:
> [root@qemu1 ~]# ip -6 r show | egrep -v unreachable
> fd00:face:face:face::/64 dev eth0  proto kernel  metric 256  expires 27sec
> fe80::/64 dev eth0  proto kernel  metric 256
> default via fe80::74df:d0ff:fe23:8ef2 dev eth0  proto ra  metric 1024  expires 27sec
> 
> After:
> [root@qemu1 ~]# ip -6 r show | egrep -v unreachable
> fd00:face:face:face::/64 dev eth0  proto kernel  metric 256  expires 27sec mtu 1300
> fe80::/64 dev eth0  proto kernel  metric 256  mtu 1300
> default via fe80::74df:d0ff:fe23:8ef2 dev eth0  proto ra  metric 1024  expires 27sec mtu 1300 hoplimit 30
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Looks good to me.

This fixes 8e2ec639173f325 ("ipv6: don't use inetpeer to store metrics
for routes.")?

Thanks,
Hannes
