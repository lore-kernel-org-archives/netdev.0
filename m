From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Fri, 8 Jun 2007 12:55:50 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902FFCE03@orsmsx414.amr.corp.intel.com>
References: <OFCFDBAE89.6D3D1B4D-ON652572F4.001DC5F4-652572F4.001E7A65@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"David Miller" <davem@davemloft.net>, <hadi@cyberus.ca>,
	<jeff@garzik.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	<kaber@trash.net>, <netdev@vger.kernel.org>
To: "Krishna Kumar2" <krkumar2@in.ibm.com>,
	"Sridhar Samudrala" <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32593 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752093AbXFHTzw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 15:55:52 -0400
Content-class: urn:content-classes:message
In-Reply-To: <OFCFDBAE89.6D3D1B4D-ON652572F4.001DC5F4-652572F4.001E7A65@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I thought the correct use is to get this lock on clean_tx 
> side which can get called on a different cpu on rx (which 
> also cleans up slots for skbs that have finished xmit). Both 
> TX and clean_tx uses the same tx_ring's head/tail ptrs and 
> should be exclusive. But I don't find clean tx using this 
> lock in the code, so I am confused :-)

>From e1000_main.c, e1000_clean():

        /* e1000_clean is called per-cpu.  This lock protects
         * tx_ring[0] from being cleaned by multiple cpus
         * simultaneously.  A failure obtaining the lock means
         * tx_ring[0] is currently being cleaned anyway. */
        if (spin_trylock(&adapter->tx_queue_lock)) {
                tx_cleaned = e1000_clean_tx_irq(adapter,
                                                &adapter->tx_ring[0]);
                spin_unlock(&adapter->tx_queue_lock);
        }

In a multi-ring implementation of the driver, this is wrapped with for
(i = 0; i < adapter->num_tx_queues; i++) and &adapter->tx_ring[i].  This
lock also prevents the clean routine from stomping on xmit_frame() when
transmitting.  Also in the multi-ring implementation, the tx_lock is
pushed down into the individual tx_ring struct, not at the adapter
level.

Cheers,

-PJ Waskiewicz
peter.p.waskiewicz.jr@intel.com
