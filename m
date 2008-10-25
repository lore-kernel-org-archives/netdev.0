From: Robert Fitzsimons <robfitz@273k.net>
Subject: Re: [Bugme-new] [Bug 11754] New: tlan network driver does not work
Date: Sat, 25 Oct 2008 01:00:33 +0100
Message-ID: <20081025000033.GA2967@localhost>
References: <bug-11754-10286@http.bugzilla.kernel.org/> <200810211634.02138.manfred.scherer.mhm@t-online.de> <e6d1cecd0810211540l7182c270l88de14cf18cfcd50@mail.gmail.com> <200810240612.13247.manfred.scherer.mhm@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Ostrowski <mostrows@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Robert Fitzsimons <robfitz@273k.net>
To: Manfred Scherer <manfred.scherer.mhm@t-online.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.153.208.64] ([78.153.208.64]:35091 "EHLO
	vps-1000455-184.cp.blacknight.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751295AbYJYABY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 20:01:24 -0400
Content-Disposition: inline
In-Reply-To: <200810240612.13247.manfred.scherer.mhm@t-online.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've double checked my patch and still think it's correct.  Lets quickly
review it:

@@ -360,8 +360,8 @@ TLan_GetSKB( const struct tlan_list_tag *tag)
 {
 	unsigned long addr;
 
-	addr = tag->buffer[8].address;
-	addr |= (tag->buffer[9].address << 16) << 16;
+	addr = tag->buffer[9].address;
+	addr |= (tag->buffer[8].address << 16) << 16;
 	return (struct sk_buff *) addr;
 }

The hardware structure tlan_list_tag is used (abused?) to store
non-hardware related data.  So buffer[8].address is used to store the
upper 32 bits and buffer[9].address is the lower 32 bits of the
sk_buffer address.


@@ -1984,7 +1984,6 @@ static void TLan_ResetLists( struct net_device *dev )
 	TLanList	*list;
 	dma_addr_t	list_phys;
 	struct sk_buff	*skb;
-	void		*t = NULL;
 
 	priv->txHead = 0;
 	priv->txTail = 0;
@@ -2022,7 +2021,8 @@ static void TLan_ResetLists( struct net_device *dev )
 			}
 
 			skb_reserve( skb, NET_IP_ALIGN );
-			list->buffer[0].address = pci_map_single(priv->pciDev, t,
+			list->buffer[0].address = pci_map_single(priv->pciDev,
+								 skb->data,
 								 TLAN_MAX_FRAME_SIZE,
 								 PCI_DMA_FROMDEVICE);
 			TLan_StoreSKB(list, skb);


buffer[0].address is the hardware address which the card can DMA the
received frame to.  The previous version of the code mapped a null
pointer.  So my change uses the sk_buffer data pointer which is what the
TLan_HandleRxEOF does and expected objective.


Manfred, where are you getting the source from, how much ram does the
computer have, and can you send your .config file.

Robert


On Fri, Oct 24, 2008 at 06:12:12AM +0200, Manfred Scherer wrote:
> I had a look on the ethernet pci-card LAN-LED and the DSL-Modem LAN-LED. 
> It seems to be that the packets were sent out are going over the
> wire, the ethernet pci-card LAN-LED and the DSL-Modem LAN-LED blinks
> three times. It seems so that the replayed packets are dropped.
> 
> Manfred Scherer
