From: Michal Ostrowski <mostrows@earthlink.net>
Subject: Re: [PATCH] Advertise PPPoE MTU / avoid memory leak.
Date: Sun, 24 Sep 2006 07:29:25 -0500
Message-ID: <1159100966.23197.293.camel@brick.austin.ibm.com>
References: <115903262344-git-send-email-mostrows@earthlink.net>
	 <20060923.145600.51855973.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ppp-bugs@dp.samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.watson.ibm.com ([129.34.20.6]:16559 "EHLO
	igw2.watson.ibm.com") by vger.kernel.org with ESMTP
	id S1750865AbWIXMah (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 08:30:37 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060923.145600.51855973.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-09-23 at 14:56 -0700, David Miller wrote:
> From: mostrows@earthlink.net
> Date: Sat, 23 Sep 2006 12:30:23 -0500
> 
> > __pppoe_xmit must free any skb it allocates if there is an error
> > submitting the skb downstream.
> 
> This isn't right, dev_queue_xmit() can return -ENETDOWN and still
> free the SKB, so your change will cause the SKB to be freed up
> twice in that case, from dev_queue_xmit():
> 
> 	rc = -ENETDOWN;
> 	rcu_read_unlock_bh();
> 
> out_kfree_skb:
> 	kfree_skb(skb);
> 	return rc;
> 
> dev_queue_xmit() is basically expected to consume the packet,
> error or not.
> 
> What case of calling dev_queue_xmit() did you discover that did not
> kfree the SKB on error?  We should fix that.  On a quick scan on the
> entire dev_queue_xmit() implmentation, I cannot find such a case.
> 

I think the call path via dev->hard_start_xmit, if it fails, may result
in an skb not being freed.  This appears to be the case with the e100.c
driver.  The qdisc_restart path to dev->hard_start_xmit also appears
susceptible to this.  It appears that not all devices agree as to who
should clean-up an skb on error.

-- 
Michal Ostrowski <mostrows@earthlink.net>

