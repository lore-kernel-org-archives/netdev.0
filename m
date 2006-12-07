From: "Amit S. Kale" <amitkale@linsyssoft.com>
Subject: Re: network devices don't handle pci_dma_mapping_error()'s
Date: Thu, 7 Dec 2006 11:55:22 +0530
Message-ID: <200612071155.23412.amitkale@linsyssoft.com>
References: <20061204103949.3d05b1ff@freekitty> <20061206.165418.54722201.davem@davemloft.net> <20061206165835.5391b75d@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, muli@il.ibm.com,
	jeff@garzik.org, amitkale@netxen.com, netdev@vger.kernel.org,
	brazilnut@us.ibm.com, netxenproj@linsyssoft.com, rob@netxen.com,
	romieu@fr.zoreil.com, sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:45126 "EHLO
	svr68.ehostpros.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031660AbWLGGZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 01:25:07 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061206165835.5391b75d@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We can let a driver handle dma mapping errors using these->

1.Reduce the size of a receive ring. This will free some possibly remapped 
memory, reducing pressure on iommu. We also need to printk a message so that 
a user knows the reason why receive ring was shrunk. Growing it when iommu 
pressure goes down will result in a ping-pong.
2. Force processing of receive and transmit ring. This will ensure that the 
buffers processed by hardware are freed, reducing iommu pressure.

3. If we need to do (1) and (2) a predefined number of times (say 20), stop 
the queue. Stopping the queue in general will cause a ping-pong, so it should 
be avoided as far as possible.

-Amit


On Thursday 07 December 2006 06:28, Stephen Hemminger wrote:
> The more robust way would be to stop the queue (like flow control)
> and return busy. You would need a timer though to handle the case
> where some disk i/o stole all the mappings and then network device flow
> blocked.
