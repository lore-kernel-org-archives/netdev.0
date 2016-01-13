From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 06/12] net: sched: support qdisc_reset on NOLOCK
 qdisc
Date: Wed, 13 Jan 2016 11:20:16 -0500 (EST)
Message-ID: <20160113.112016.995229320622519258.davem@davemloft.net>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
	<20151230175313.26257.46445.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, brouer@redhat.com, john.r.fastabend@intel.com,
	netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34921 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046AbcAMQUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 11:20:20 -0500
In-Reply-To: <20151230175313.26257.46445.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Wed, 30 Dec 2015 09:53:13 -0800

>  case 2: dev_deactivate sequence. This can come from a user bringing
> 	 the interface down which causes the gso_skb list to be flushed
> 	 and the qlen zero'd. At the moment this is protected by the
> 	 qdisc lock so while we clear the qlen/gso_skb fields we are
> 	 guaranteed no new skbs are added. For the lockless case
> 	 though this is not true. To resolve this move the qdisc_reset
> 	 call after the new qdisc is assigned and a grace period is
> 	 exercised to ensure no new skbs can be enqueued. Further
> 	 the RTNL lock is held so we can not get another call to
> 	 activate the qdisc while the skb lists are being free'd.
> 
> 	 Finally, fix qdisc_reset to handle the per cpu stats and
> 	 skb lists.

Just wanted to note that some setups are sensitive to device
register/deregister costs.  This is why we batch register and
unregister operations in the core, so that the RCU grace period
is consolidated into one when we register/unregister a lot of
net devices.

If we now will incur a new per-device unregister RCU grace period
when the qdisc is destroyed, it could cause a regression.
