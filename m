From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Advertise PPPoE MTU / avoid memory leak.
Date: Sat, 23 Sep 2006 14:56:00 -0700 (PDT)
Message-ID: <20060923.145600.51855973.davem@davemloft.net>
References: <115903262344-git-send-email-mostrows@earthlink.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ppp-bugs@dp.samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57800
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750738AbWIWV4B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 17:56:01 -0400
To: mostrows@earthlink.net
In-Reply-To: <115903262344-git-send-email-mostrows@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: mostrows@earthlink.net
Date: Sat, 23 Sep 2006 12:30:23 -0500

> __pppoe_xmit must free any skb it allocates if there is an error
> submitting the skb downstream.

This isn't right, dev_queue_xmit() can return -ENETDOWN and still
free the SKB, so your change will cause the SKB to be freed up
twice in that case, from dev_queue_xmit():

	rc = -ENETDOWN;
	rcu_read_unlock_bh();

out_kfree_skb:
	kfree_skb(skb);
	return rc;

dev_queue_xmit() is basically expected to consume the packet,
error or not.

What case of calling dev_queue_xmit() did you discover that did not
kfree the SKB on error?  We should fix that.  On a quick scan on the
entire dev_queue_xmit() implmentation, I cannot find such a case.
