From: f6bvp <f6bvp@free.fr>
Subject: Re: [Patch] rose_route_frame() NULL pointer dereference kernel panic
Date: Tue, 1 Mar 2016 21:37:14 +0100
Message-ID: <56D5FD7A.5080104@free.fr>
References: <56CDDFF7.2040609@free.fr>
 <20160225.170957.836114237953219422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva144.upmc.fr ([134.157.0.144]:65071 "EHLO shiva.upmc.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751337AbcCAUhZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2016 15:37:25 -0500
In-Reply-To: <20160225.170957.836114237953219422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Ralf,

David is absolutely right about my unappropriate patch.
Although I had searched functions calling rose_route_frame(), I did not
notice rose_xmit() was involved. Shame on me !

Then, David precisely located the source of the issue we are facing.

When rose_xmit() calls rose_route_frame() with NULL as second argument,
there is always a null pointer dereference when rose_route_frame() calls 
ax25cmp().

Here is the explanation :

When rose_route_frame() is called by rose_xmit() with NULL *ax25 argument
the following comparison (rose_route.c , line 883)

if (ax25cmp(&ax25->dest_addr, &rose_neigh->callsign) == 0 &&

always has a pointer dereference leading to a kernel panic.

I noticed, using a few printk, that during rose normal operations 
rose_xmit() was never called
when ax25ipd sends an UDP frame. Otherwise, this bug would have been 
found earlier.
It is only because FPAC application asked for a connection to an address 
without defined route and
gateway that rose_xmit() was activated.

I am not sure I understood well the purpose of the NULL second argument.
I only guess it was intended to have ax25->dest_addr empty in order to 
make the comparison
with all possible rose_neigh->callsign always false.

I built the following patch in order to obtain the same result without 
NULL pointer.

--- a/net/rose/rose_dev.c       2016-02-25 21:01:36.000000000 +0100
+++ b/net/rose/rose_dev.c  2016-03-01 14:08:29.911389078 +0100
@@ -101,13 +101,16 @@ static netdev_tx_t rose_xmit(struct sk_b
  {
         struct net_device_stats *stats = &dev->stats;
         unsigned int len = skb->len;
+       struct ax25_cb ax25;

+       memset(&ax25, 0, sizeof(struct ax25_cb));
+
         if (!netif_running(dev)) {
                 printk(KERN_ERR "ROSE: rose_xmit - called when iface is 
down\n");
                 return NETDEV_TX_BUSY;
         }

-       if (!rose_route_frame(skb, NULL)) {
+       if (!rose_route_frame(skb, &ax25)) {
                 dev_kfree_skb(skb);
                 stats->tx_errors++;
                 return NETDEV_TX_OK;

Could Ralf or David please check if above code syntax is correct.
I tested the patch and found rose was working correctly with no more 
panic nor
unwanted effects on rose_route_frame() normal operations.

Bernard Pidoux
