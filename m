From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2] bonding: Fix corrupted queue_mapping
Date: Tue, 12 Jun 2012 13:16:08 -0400
Message-ID: <20120612171608.GC15984@hmsreliant.think-freely.org>
References: <1339517031.22704.202.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Roland Dreier <roland@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48025 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640Ab2FLRQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 13:16:22 -0400
Content-Disposition: inline
In-Reply-To: <1339517031.22704.202.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 12, 2012 at 06:03:51PM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> In the transmit path of the bonding driver, skb->cb is used to
> stash the skb->queue_mapping so that the bonding device can set its
> own queue mapping.  This value becomes corrupted since the skb->cb is
> also used in __dev_xmit_skb.
> 
> When transmitting through bonding driver, bond_select_queue is
> called from dev_queue_xmit.  In bond_select_queue the original
> skb->queue_mapping is copied into skb->cb (via bond_queue_mapping)
> and skb->queue_mapping is overwritten with the bond driver queue.
> 
> Subsequently in dev_queue_xmit, __dev_xmit_skb is called which writes
> the packet length into skb->cb, thereby overwriting the stashed
> queue mappping.  In bond_dev_queue_xmit (called from hard_start_xmit),
> the queue mapping for the skb is set to the stashed value which is now
> the skb length and hence is an invalid queue for the slave device.
> 
> If we want to save skb->queue_mapping into skb->cb[], best place is to
> add a field in struct qdisc_skb_cb, to make sure it wont conflict with
> other layers (eg : Qdiscc, Infiniband...)
> 
> This patchs also makes sure (struct qdisc_skb_cb)->data is aligned on 8
> bytes :
> 
> netem qdisc for example assumes it can store an u64 in it, without
> misalignment penalty.
> 
> Note : we only have 20 bytes left in (struct qdisc_skb_cb)->data[].
> The largest user is CHOKe and it fills it.
> 
> Based on a previous patch from Tom Herbert.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Tom Herbert <therbert@google.com>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Cc: Roland Dreier <roland@kernel.org>
Acked-by: Neil Horman <nhorman@tuxdriver.com>

Looking at this, it would be really nice if we could have some sort of layer
independent space in an skb.  It seems we're often looking to shoehorn more
stuff into the control bock.
Neil
