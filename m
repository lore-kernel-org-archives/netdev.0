From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [RFC][NET-NEXT PATCH 2/2] net: Add GSO to vlan_features initialization
Date: Sat, 02 Jul 2011 15:07:43 +0800
Message-ID: <4E0EC3BF.1060107@cn.fujitsu.com>
References: <4E0406BE.50900@cn.fujitsu.com> <1308934302.3034.4.camel@bwh-desktop> <4E094EE7.1000203@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	"therbert@google.com" <therbert@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56589 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753525Ab1GBHGs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Jul 2011 03:06:48 -0400
In-Reply-To: <4E094EE7.1000203@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben:

Shan Wei wrote, at 06/28/2011 11:47 AM:
> Hi Ben:
> 
> Ben Hutchings wrote, at 06/25/2011 12:51 AM:
>> Have you verified that GSO works correctly for VLAN devices if the
>> underlying device does not support VLAN tag insertion?
> 
> OK. I will do some test in future days.
> Then report test results.

Results is coming....
GSO works correctly for VLAN devices when
underlying device is Realtek NIC with 8139too driver.

Network tracepoint shows as following:
<Begin:
       tcpclient-5915  [000]  2114.246780: net_dev_queue: dev=eth1.44 skbaddr=f3051bc0 len=74
       tcpclient-5915  [000]  2114.246790: net_dev_queue: dev=eth1 skbaddr=f3051bc0 len=74
       tcpclient-5915  [000]  2114.246798: net_dev_xmit: dev=eth1 skbaddr=f3051bc0 len=78 rc=0
       tcpclient-5915  [000]  2114.246799: net_dev_xmit: dev=eth1.44 skbaddr=f3051bc0 len=74 rc=0
          <idle>-0     [000]  2114.246905: net_dev_queue: dev=eth1.44 skbaddr=f73cc480 len=66
          <idle>-0     [000]  2114.246908: net_dev_queue: dev=eth1 skbaddr=f73cc480 len=66
          <idle>-0     [000]  2114.246911: net_dev_xmit: dev=eth1 skbaddr=f73cc480 len=70 rc=0
          <idle>-0     [000]  2114.246912: net_dev_xmit: dev=eth1.44 skbaddr=f73cc480 len=66 rc=0
       tcpclient-5915  [000]  2114.247109: net_dev_queue: dev=eth1.44 skbaddr=f3051bc0 len=2962
       tcpclient-5915  [000]  2114.247121: net_dev_queue: dev=eth1 skbaddr=f73cc380 len=1514
       tcpclient-5915  [000]  2114.247130: net_dev_xmit: dev=eth1 skbaddr=f73cc380 len=1518 rc=0
       tcpclient-5915  [000]  2114.247131: net_dev_xmit: dev=eth1.44 skbaddr=f73cc380 len=1514 rc=0
       tcpclient-5915  [000]  2114.247132: net_dev_queue: dev=eth1 skbaddr=f73cc480 len=1514
       tcpclient-5915  [000]  2114.247138: net_dev_xmit: dev=eth1 skbaddr=f73cc480 len=1518 rc=0
       tcpclient-5915  [000]  2114.247139: net_dev_xmit: dev=eth1.44 skbaddr=f73cc480 len=1514 rc=0
end:>

But, test case requires following two patches:
1. Fix broken vlan GSO setting

[PATCH 1/2] net: vlan: enable GSO by default
http://patchwork.ozlabs.org/patch/101714/

2. Fix my 8139too NIC driver that does not initial vlan_features.
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -993,6 +993,7 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
         * features
         */
        dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA;
+       dev->vlan_features = dev->features;

-- 
Best Regards
-----
Shan Wei
