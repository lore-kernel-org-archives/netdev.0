From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Initial benchmarks of some VJ ideas [mmap memcpy vs
 copy_to_user].
Date: Thu, 11 May 2006 11:54:09 -0700 (PDT)
Message-ID: <20060511.115409.89709859.davem@davemloft.net>
References: <20060511.000721.60889163.davem@davemloft.net>
	<20060511083031.GA12712@2ka.mipt.ru>
	<20060511161815.GA623@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, caitlinb@broadcom.com, kelly@au1.ibm.com,
	rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:29915
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750702AbWEKSyM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 May 2006 14:54:12 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060511161815.GA623@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 11 May 2006 20:18:15 +0400

> Here is profile result:
> 1463625  78.0003  poll_idle
> 19171     1.0217  _spin_lock_irqsave
> 15887     0.8467  _read_lock
> 14712     0.7840  kfree
> 13370     0.7125  ip_frag_queue
> 11896     0.6340  delay_pmtmr
> 11811     0.6294  _spin_lock
> 11723     0.6247  csum_partial
> 11399     0.6075  ip_frag_destroy
> 11063     0.5896  serial_in
> 10533     0.5613  skb_release_data
> 10524     0.5609  ip_route_input
> 10319     0.5499  __alloc_skb

Too bad spinlocks are not inlined any longer, this makes oprofile
output so much less useful.

Also, since you test UDP with >MTU sized sends, you add fragmentation
into the mix, yet another variable that you won't see with TCP :-)

BTW you make another massively critical error in your analysis of TCP
profiles.

You mention that "tcp_v4_rcv()" shows up in your profiles and not
__inet_lookup().  This __inet_lookup() is inlined, and thus it's cost
shows up as "tcp_v4_rcv()".  I find such oversight amazing for someone
as careful about details as you are :-)

I would suggest to look at instruction level profile hits, it makes
such mistakes in analysis almost impossible :-)
