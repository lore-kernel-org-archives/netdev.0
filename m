From: Stephane Doyon <sdoyon@max-t.com>
Subject: E1000: bug on error path in e1000_probe()
Date: Tue, 1 Aug 2006 11:16:24 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607311522200.3139@madrid.max-t.internal>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from h216-18-124-229.gtcust.grouptelecom.net ([216.18.124.229]:23459
	"EHLO mail.max-t.com") by vger.kernel.org with ESMTP
	id S1751455AbWHAPRt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 11:17:49 -0400
To: linux.nics@intel.com, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The e1000_probe() function passes references to the netdev structure 
before it's actually registered. In the (admittedly obscure) case where 
the netdev registration fails, we are left with a dangling reference.

Specifically, e1000_probe() calls
         netif_carrier_off(netdev);
before register_netdev(netdev).

(It also calls pci_set_drvdata(pdev, netdev) rather early, not sure how 
important that is.)

netif_carrier_off() does linkwatch_fire_event(dev);, which in turn does 
dev_hold(dev); and queues up an event with a reference to the netdev.

But the net_device reference counting mechanism only works on registered 
netdevs.

Should the register_netdev() call fail, the error path does 
free_netdev(netdev);, and when the event goes off, it accesses random 
memory through the dangling reference.

I would recommend moving the register_netdev() call earlier.

Thanks

