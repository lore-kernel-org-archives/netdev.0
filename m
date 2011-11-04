From: Rick Jones <rick.jones2@hp.com>
Subject: what's in a bus_info
Date: Fri, 04 Nov 2011 15:27:23 -0700
Message-ID: <4EB466CB.2040506@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:8650 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754761Ab1KDW1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 18:27:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

...or would an interface name smell as sweet? (as PCI bus addressing)

Is there a "standard" for what is returned in bus_info of 
ethtool_drvinfo?  I have been very used to seeing PCI bus addressing 
information in that field (at least as displayed by ethtool -i) and when 
I went to "leverage how to" from other drivers, to add "native" ethtool 
-i support to virtio_net, I ended-up with "eth0" rather than the PCI 
information I see in lspci output and in ethtool -i against other 
devices.  Including an emulated e1000 interface in the same kernel.

What I'm doing is calling pci_name(), feeding it with to_pci_dev() from 
the address of the struct device in the struct net_device.  The perhaps 
overly paranoid work-in-progress:

static void virtnet_get_drvinfo(struct net_device *dev,
                                 struct ethtool_drvinfo *info)
{

         struct device *dev_dev;
         struct pci_dev *pci_dev = NULL;


         dev_dev = &(dev->dev);
         if (dev_dev != NULL)
                 pci_dev = to_pci_dev(dev_dev);
         strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
         strlcpy(info->version,"I am versionless", sizeof(info->version));
         strlcpy(info->fw_version,"I have no firmware", 
sizeof(info->fw_version));
         strlcpy(info->bus_info,
                 (pci_dev != NULL) ? pci_name(pci_dev) : "",
                 sizeof(info->bus_info));

}

So, with the emulated e1000 I get:

raj@raj-ubuntu-guest:~$ ethtool -i eth0
driver: e1000
version: 7.3.21-k8-NAPI
firmware-version: N/A
bus-info: 0000:00:11.0
raj@raj-ubuntu-guest:~$

and I see that the e1000 driver calls pci_name().  However, the code 
above, when I boot the guest with the virtio device gives me:

raj@raj-ubuntu-guest:~$ ethtool -i eth0
driver: virtio_net
version: I am versionless
firmware-version: I have no firmware
bus-info: eth0

00:03.0 Ethernet controller: Red Hat, Inc Virtio network device

Am I chasing the wrong pointers?  Is it  a function of virtio?

rick jones

BTW, I notice some drivers call strlcpy and some strncpy, and some even 
call strcpy.  Is there one that is meant to be preferred over the others?
