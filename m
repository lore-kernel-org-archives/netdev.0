From: Jeff Haran <jharan@bytemobile.com>
Subject: locking in net_device_ops callbacks
Date: Wed, 21 Mar 2012 18:59:30 +0000
Message-ID: <471DE477E2B1F549A58F3A14A27180BE014357@HQ-EX01.bytemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport.bytemobile.com ([12.153.136.13]:39779 "EHLO
	ironport.bytemobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869Ab2CUTJ2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 15:09:28 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I had posted the below to the kernelnewbies email list and never got a response. I am hoping somebody on this list could provide some feedback.

Just to be clear, it's not the issue of copying the MAC address that I am asking about. That's just an example.

What I am trying to understand is, what mechanisms generally are at play to serialize access to struct net_device private data that is accessed in both process and softirq contexts? Explicit locking "seems" to be mostly absent from the driver sources I've inspected so I can't help but believe I am missing something fundamental here.

Thanks in advance,

Jeff Haran

I was hoping somebody could enlighten me on how serialization of access
to data in struct net_device and associated netdev_priv() data works in
the callback functions registered in net_device_ops. For example, I am
looking at drivers/net/e1000/e1000_main.c in my 2.6.32 based kernel
tree. My understanding is this is a reference driver of sorts, so it
should be doing the "right thing".

This driver registers a callback for the ndo_set_mac_address callback
like this (much of what I think is not significant to the question code
replaced with "..." below for brevity):

static const struct net_device_ops e1000_netdev_ops = {
        ...
        .ndo_set_mac_address    = e1000_set_mac,
        ...
};

static int __devinit e1000_probe(struct pci_dev *pdev,
                                 const struct pci_device_id *ent)
{
        struct net_device *netdev;
       ....

        netdev = alloc_etherdev(sizeof(struct e1000_adapter));
        ....
        netdev->netdev_ops = &e1000_netdev_ops;
        ...
        err = register_netdev(netdev);
        ...
}

Most network drivers seem to follow more or less the same initialization
sequence.

When I look at the implementation of e1000_set_mac(), I see this:

static int e1000_set_mac(struct net_device *netdev, void *p)
{
        struct e1000_adapter *adapter = netdev_priv(netdev);
        struct e1000_hw *hw = &adapter->hw;
        struct sockaddr *addr = p;

        ...
        memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
        memcpy(hw->mac_addr, addr->sa_data, netdev->addr_len);
        ...

        return 0;
}

I can't help but notice there is no locking going on around the
memcpy()s of the passed in MAC address to the net_device dev_addr and
private data mac_addr fields.

I assume that e1000_set_mac() is typically called in process context in
response to some user space application like ifconfig or ip changing the
interface MAC address. I am also assuming that these dev_addr and
mac_addr fields are also referenced in other contexts. An Ethernet MAC
address is 6 bytes, so the memcpy()'s can't be atomic operations at
least on a 32 bit machine.

Shouldn't there have been some sort of lock taken before the memcpy()s
are executed so that other execution contexts won't see a partially
copied MAC address?

Is there some sort of lock taken higher up the call stack by the code
that calls these callback functions so that the callbacks themselves
don't have to do it explicitly?

I am writing a network device driver (modifying an existing one
actually) and am therefore trying to understand what kinds of explicit
locking my net_device_ops callbacks need to take in order to ensure
proper operation on an SMP system.

Thanks,

Jeff Haran
