From: Patrick McHardy <kaber@trash.net>
Subject: Handling set_mac_address in set_rx_mode
Date: Sat, 30 Jun 2007 20:51:00 +0200
Message-ID: <4686A614.1000709@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40570 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138AbXF3SvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 14:51:08 -0400
Received: from [192.168.0.100] (unknown [195.158.167.166])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by stinky.trash.net (Postfix) with ESMTP id B68D9948D4
	for <netdev@vger.kernel.org>; Sat, 30 Jun 2007 20:51:06 +0200 (MEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While adding support for secondary unicast addresses to 8021q and
macvlan, I've tried keeping dev->dev_addr as global address on
dev->uc_list and have drivers skip them to avoid having all
dev_unicast_add users implement a state machine like this:


open(struct net_device *dev)
{
    struct net_device *lowerdev = ...;

    /* add our address in case it differs */
    if (memcmp(addr, lowerdev->dev_addr, dev->addr_len)
       dev_unicast_add(lowerdev, dev->dev_addr, dev->addr_len);
}

close(struct net_device *dev)
{
    struct net_device *lowerdev = ...;

    /* delete our address in case we've added it */
    if (memcmp(dev->dev_addr, lowerdev->dev_addr, dev->addr_len))
       dev_unicast_delete(lowerdev, dev->dev_addr, dev->addr_len);
}

set_mac_address(struct net_device *dev, void *addr)
{
    struct net_device *lowerdev = ...;

    if (!dev->flags & IFF_UP)
       return 0;

    /* delete our old address in case we've added it */
    if (memcmp(dev->dev_addr, lowerdev->dev_addr, dev->addr_len))
       dev_unicast_delete(lowerdev, dev->dev_addr, dev->addr_len);

    memcpy(dev->dev_addr, addr, dev->addr_len)

    /* add our new address in case it differs */
    if (memcmp(addr, lowerdev->dev_addr, dev->addr_len)
       dev_unicast_add(lowerdev, dev->dev_addr, dev->addr_len);

    store lowerdev->dev_addr somewhere
}

netdev_notifier(struct notifier_block, unsigned long event, void *ptr)
{
    struct net_device *lowerdev = ptr;
    struct net_device *dev = ...;

    switch (event) {
    case NETDEV_CHANGEADDR:
        /* was different before, is equal now: remove our address */
       if (memcmp(dev->dev_addr, last_lowerdev_addr, dev->addr_len) &&
           !memcmp(dev->dev_addr, lowerdev->dev_addr, dev->addr_len))
            dev_unicast_delete(lowerdev, dev->dev_addr, dev->addr_len);

       /* is different now, was equal before: add our address */
       if (memcmp(dev->dev_addr, lowerdev->dev_addr, dev->addr_len) &&
           !memcmp(dev->dev_addr, last_lowerdev_addr, dev->addr_len))
          dev_unicast_add(lowerdev, dev->dev_addr, dev->addr_len);
       break;
    }  
}

Not that its terribly complicated, but its not exactly pretty and
the existing examples of address and flag synchronization all get
*something* wrong, so its better to keep requirements simple.

Having the primary address on dev->uc_list would have the advantage
that the existing refcounting would take care of keeping addresses
around while they're still in use and drivers could just unconditionally
add and remove their own addresses without worrying about needlessly
putting the underlying device in promiscous mode.

Adding dev_addr to the uc_list in dev_set_mac_address turned out to
be more complicated than expected though because rolling back to the
previous state on error always includes an operation that might fail
again (dev->set_mac_address and dev->set_rx_mode).

The easiest way to handle this would be to program the MAC address
in set_rx_mode as well since then we'd only have a single operation
that could fail. For e1000 this would even simplify the code because
set_mac_address and set_rx_mode both program the same filters and handle
the same quirks. I would expect the same to be true for other drivers
as well.

If there are no objections to this I'll code something up tommorrow.

