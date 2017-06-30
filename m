From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH net-next] cxgb4: Add PTP Hardware Clock (PHC) support
 (fwd)
Date: Thu, 29 Jun 2017 22:29:58 -0600 (MDT)
Message-ID: <alpine.DEB.2.20.1706292227380.2995@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net, venkatesh@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>, kbuild-all@01.org
To: Atul Gupta <atul.gupta@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:22498 "EHLO
        mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751333AbdF3EaD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 00:30:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The complete context isn't shown, but it seems likely that there is a goto
out_free under line 1207, with no unlock on &adap->ptp_lock.

julia

---------- Forwarded message ----------
Date: Fri, 30 Jun 2017 11:54:23 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: kbuild@01.org
Cc: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH net-next] cxgb4: Add PTP Hardware Clock (PHC) support

Hi Atul,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Atul-Gupta/cxgb4-Add-PTP-Hardware-Clock-PHC-support/20170629-200758
:::::: branch date: 16 hours ago
:::::: commit date: 16 hours ago

>> drivers/net/ethernet/chelsio/cxgb4/sge.c:1190:2-8: preceding lock on line 1204

git remote add linux-review https://github.com/0day-ci/linux
git remote update linux-review
git checkout 159226c60ceb77858018f6c31d17a575b3679b8a
vim +1190 drivers/net/ethernet/chelsio/cxgb4/sge.c

fd3a47900 drivers/net/cxgb4/sge.c                  Dimitris Michailidis 2010-04-01  1184  	/*
fd3a47900 drivers/net/cxgb4/sge.c                  Dimitris Michailidis 2010-04-01  1185  	 * The chip min packet length is 10 octets but play safe and reject
fd3a47900 drivers/net/cxgb4/sge.c                  Dimitris Michailidis 2010-04-01  1186  	 * anything shorter than an Ethernet header.
fd3a47900 drivers/net/cxgb4/sge.c                  Dimitris Michailidis 2010-04-01  1187  	 */
fd3a47900 drivers/net/cxgb4/sge.c                  Dimitris Michailidis 2010-04-01  1188  	if (unlikely(skb->len < ETH_HLEN)) {
a7525198a drivers/net/ethernet/chelsio/cxgb4/sge.c Eric W. Biederman    2014-03-15  1189  out_free:	dev_kfree_skb_any(skb);
fd3a47900 drivers/net/cxgb4/sge.c                  Dimitris Michailidis 2010-04-01 @1190  		return NETDEV_TX_OK;
fd3a47900 drivers/net/cxgb4/sge.c                  Dimitris Michailidis 2010-04-01  1191  	}
fd3a47900 drivers/net/cxgb4/sge.c                  Dimitris Michailidis 2010-04-01  1192
637d3e997 drivers/net/ethernet/chelsio/cxgb4/sge.c Hariprasad Shenai    2015-05-05  1193  	/* Discard the packet if the length is greater than mtu */
637d3e997 drivers/net/ethernet/chelsio/cxgb4/sge.c Hariprasad Shenai    2015-05-05  1194  	max_pkt_len = ETH_HLEN + dev->mtu;
8d09e6b8b drivers/net/ethernet/chelsio/cxgb4/sge.c Hariprasad Shenai    2016-07-28  1195  	if (skb_vlan_tagged(skb))
637d3e997 drivers/net/ethernet/chelsio/cxgb4/sge.c Hariprasad Shenai    2015-05-05  1196  		max_pkt_len += VLAN_HLEN;
637d3e997 drivers/net/ethernet/chelsio/cxgb4/sge.c Hariprasad Shenai    2015-05-05  1197  	if (!skb_shinfo(skb)->gso_size && (unlikely(skb->len > max_pkt_len)))
637d3e997 drivers/net/ethernet/chelsio/cxgb4/sge.c Hariprasad Shenai    2015-05-05  1198  		goto out_free;
637d3e997 drivers/net/ethernet/chelsio/cxgb4/sge.c Hariprasad Shenai    2015-05-05  1199
fd3a47900 drivers/net/cxgb4/sge.c                  Dimitris Michailidis 2010-04-01  1200  	pi = netdev_priv(dev);
fd3a47900 drivers/net/cxgb4/sge.c                  Dimitris Michailidis 2010-04-01  1201  	adap = pi->adapter;
fd3a47900 drivers/net/cxgb4/sge.c                  Dimitris Michailidis 2010-04-01  1202  	qidx = skb_get_queue_mapping(skb);
159226c60 drivers/net/ethernet/chelsio/cxgb4/sge.c Atul Gupta           2017-06-28  1203  	if (ptp_enabled) {
159226c60 drivers/net/ethernet/chelsio/cxgb4/sge.c Atul Gupta           2017-06-28 @1204  		spin_lock(&adap->ptp_lock);
159226c60 drivers/net/ethernet/chelsio/cxgb4/sge.c Atul Gupta           2017-06-28  1205  		if (!(adap->ptp_tx_skb)) {
159226c60 drivers/net/ethernet/chelsio/cxgb4/sge.c Atul Gupta           2017-06-28  1206  			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
159226c60 drivers/net/ethernet/chelsio/cxgb4/sge.c Atul Gupta           2017-06-28  1207  			adap->ptp_tx_skb = skb_get(skb);

:::::: The code at line 1190 was first introduced by commit
:::::: fd3a47900b6f9fa72a4074ecb630f9dae62f1a95 cxgb4: Add packet queues and packet DMA code

:::::: TO: Dimitris Michailidis <dm@chelsio.com>
:::::: CC: David S. Miller <davem@davemloft.net>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
