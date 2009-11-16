From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] dev->refcnt long term holder
Date: Mon, 16 Nov 2009 19:01:37 +0100
Message-ID: <4B019381.2010509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44099 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825AbZKPSBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 13:01:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

time ip link del eth3.103 ; time ip link del eth3.104 ; time ip link del eth3.105

real	0m0.266s
user	0m0.000s
sys	0m0.001s

real	0m0.770s
user	0m0.000s
sys	0m0.000s

real	0m1.022s
user	0m0.000s
sys	0m0.000s


One problem of current schem in vlan dismantle phase is the
holding of device done by following chain :

vlan_dev_stop() ->
	netif_carrier_off(dev) ->
		linkwatch_fire_event(dev) ->
			dev_hold() ...

And __linkwatch_run_queue() run up to one second later...

Is following patch one way to avoid the problem, or should
we add a new linkwatch_forgetpro_device(dev) method to immediately
release the device reference (and unlink device from the list) ?
(This would probably need a doubly linked list instead of single link list)

Thanks

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 4198ec5..17216f9 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -512,7 +512,6 @@ static int vlan_dev_stop(struct net_device *dev)
 	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
 		dev_unicast_delete(real_dev, dev->dev_addr);
 
-	netif_carrier_off(dev);
 	return 0;
 }
 
