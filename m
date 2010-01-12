From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] sky2: safer transmit ring cleaning
Date: Tue, 12 Jan 2010 15:31:36 -0500
Message-ID: <4B4CDC28.2050508@majjas.com>
References: <20100112.000804.186755338.davem@davemloft.net>
 <20100112085633.GB6628@ff.dom.local>
 <20100112.014218.112731835.davem@davemloft.net>
 <20100112.025620.210305029.davem@davemloft.net>
 <20100112081513.0175d579@nehalam> <4B4CC0E3.5050106@majjas.com>
 <4B4CC29E.4020703@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	mikem@ring3k.org, flyboy@gmail.com, rjw@sisk.pl,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta3.srv.hcvlny.cv.net ([167.206.4.198]:64676 "EHLO
	mta3.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753839Ab0ALUc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 15:32:26 -0500
Received: from mail.majjas.com (ool-44c00dc8.dyn.optonline.net [68.192.13.200])
 by mta3.srv.hcvlny.cv.net
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 with ESMTP id <0KW500MGMIDSRE50@mta3.srv.hcvlny.cv.net> for
 netdev@vger.kernel.org; Tue, 12 Jan 2010 15:32:17 -0500 (EST)
In-reply-to: <4B4CC29E.4020703@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/12/2010 1:42 PM, Michael Breuer wrote:
> On 1/12/2010 1:35 PM, Michael Breuer wrote:
>> On 1/12/2010 11:15 AM, Stephen Hemminger wrote:
>>> This code makes transmit path and transmit reset safer by:
>>>    * adding memory barrier before checking available ring slots
>>>    * reseting state of tx ring elements after free
>>>    * seperate cleanup function from ring done function
>>>    * removing mostly unused tx_next element
>>>
>>> Signed-off-by: Stephen Hemminger<shemminger@vyatta.com>
>>>
>>> ---
>>> Please apply this instead of the various bits and pieces flying
>>> around labeled as sky2 panic under load
>>>
>>>
>>> --- a/drivers/net/sky2.c    2010-01-11 10:49:50.907113126 -0800
>>> +++ b/drivers/net/sky2.c    2010-01-11 17:36:22.027429875 -0800
>>> @@ -1596,6 +1596,9 @@ static inline int tx_inuse(const struct
>>>   /* Number of list elements available for next tx */
>>>   static inline int tx_avail(const struct sky2_port *sky2)
>>>   {
>>> +    /* Makes sure update of tx_prod from start_xmit and
>>> +       tx_cons from tx_done are seen. */
>>> +    smp_mb();
>>>       return sky2->tx_pending - tx_inuse(sky2);
>>>   }
>>>
>>> @@ -1618,8 +1621,7 @@ static unsigned tx_le_req(const struct s
>>>       return count;
>>>   }
>>>
>>> -static void sky2_tx_unmap(struct pci_dev *pdev,
>>> -              const struct tx_ring_info *re)
>>> +static void sky2_tx_unmap(struct pci_dev *pdev, struct tx_ring_info 
>>> *re)
>>>   {
>>>       if (re->flags&  TX_MAP_SINGLE)
>>>           pci_unmap_single(pdev, pci_unmap_addr(re, mapaddr),
>>> @@ -1629,6 +1631,7 @@ static void sky2_tx_unmap(struct pci_dev
>>>           pci_unmap_page(pdev, pci_unmap_addr(re, mapaddr),
>>>                      pci_unmap_len(re, maplen),
>>>                      PCI_DMA_TODEVICE);
>>> +    re->flags = 0;
>>>   }
>>>
>>>   /*
>>> @@ -1804,7 +1807,8 @@ mapping_error:
>>>   }
>>>
>>>   /*
>>> - * Free ring elements from starting at tx_cons until "done"
>>> + * Transmit complete processing
>>> + * Free ring elements from starting at tx_cons until done index
>>>    *
>>>    * NB:
>>>    *  1. The hardware will tell us about partial completion of 
>>> multi-part
>>> @@ -1813,9 +1817,9 @@ mapping_error:
>>>    *     looks at the tail of the queue of FIFO (tx_cons), not
>>>    *     the head (tx_prod)
>>>    */
>>> -static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
>>> +static void sky2_tx_done(struct net_device *dev, u16 done)
>>>   {
>>> -    struct net_device *dev = sky2->netdev;
>>> +    struct sky2_port *sky2 = netdev_priv(dev);
>>>       unsigned idx;
>>>
>>>       BUG_ON(done>= sky2->tx_ring_size);
>>> @@ -1828,6 +1832,8 @@ static void sky2_tx_complete(struct sky2
>>>           sky2_tx_unmap(sky2->hw->pdev, re);
>>>
>>>           if (skb) {
>>> +            re->skb = NULL;
>>> +
>>>               if (unlikely(netif_msg_tx_done(sky2)))
>>>                   printk(KERN_DEBUG "%s: tx done %u\n",
>>>                          dev->name, idx);
>>> @@ -1836,13 +1842,10 @@ static void sky2_tx_complete(struct sky2
>>>               dev->stats.tx_bytes += skb->len;
>>>
>>>               dev_kfree_skb_any(skb);
>>> -
>>> -            sky2->tx_next = RING_NEXT(idx, sky2->tx_ring_size);
>>>           }
>>>       }
>>>
>>>       sky2->tx_cons = idx;
>>> -    smp_mb();
>>>
>>>       if (tx_avail(sky2)>  MAX_SKB_TX_LE + 4)
>>>           netif_wake_queue(dev);
>>> @@ -1870,6 +1873,21 @@ static void sky2_tx_reset(struct sky2_hw
>>>       sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_SET);
>>>   }
>>>
>>> +static void sky2_tx_clean(struct sky2_port *sky2)
>>> +{
>>> +    u16 idx;
>>> +
>>> +    for (idx = 0; idx<  sky2->tx_ring_size; idx++) {
>>> +        struct tx_ring_info *re = sky2->tx_ring + idx;
>>> +
>>> +        sky2_tx_unmap(sky2->hw->pdev, re);
>>> +        if (re->skb) {
>>> +            dev_kfree_skb_any(re->skb);
>>> +            re->skb = NULL;
>>> +        }
>>> +    }
>>> +}
>>> +
>>>   /* Network shutdown */
>>>   static int sky2_down(struct net_device *dev)
>>>   {
>>> @@ -1933,8 +1951,7 @@ static int sky2_down(struct net_device *
>>>       sky2_tx_reset(hw, port);
>>>
>>>       /* Free any pending frames stuck in HW queue */
>>> -    sky2_tx_complete(sky2, sky2->tx_prod);
>>> -
>>> +    sky2_tx_clean(sky2);
>>>       sky2_rx_clean(sky2);
>>>
>>>       sky2_free_buffers(sky2);
>>> @@ -2411,15 +2428,6 @@ error:
>>>       goto resubmit;
>>>   }
>>>
>>> -/* Transmit complete */
>>> -static inline void sky2_tx_done(struct net_device *dev, u16 last)
>>> -{
>>> -    struct sky2_port *sky2 = netdev_priv(dev);
>>> -
>>> -    if (netif_running(dev))
>>> -        sky2_tx_complete(sky2, last);
>>> -}
>>> -
>>>   static inline void sky2_skb_rx(const struct sky2_port *sky2,
>>>                      u32 status, struct sk_buff *skb)
>>>   {
>>> @@ -4201,7 +4209,7 @@ static int sky2_debug_show(struct seq_fi
>>>
>>>       /* Dump contents of tx ring */
>>>       sop = 1;
>>> -    for (idx = sky2->tx_next; idx != sky2->tx_prod&&  idx<  
>>> sky2->tx_ring_size;
>>> +    for (idx = sky2->tx_cons; idx != sky2->tx_prod&&  idx<  
>>> sky2->tx_ring_size;
>>>            idx = RING_NEXT(idx, sky2->tx_ring_size)) {
>>>           const struct sky2_tx_le *le = sky2->tx_le + idx;
>>>           u32 a = le32_to_cpu(le->addr);
>>> --- a/drivers/net/sky2.h    2010-01-11 17:29:22.817088617 -0800
>>> +++ b/drivers/net/sky2.h    2010-01-11 17:29:28.197120484 -0800
>>> @@ -2187,7 +2187,6 @@ struct sky2_port {
>>>       u16             tx_ring_size;
>>>       u16             tx_cons;        /* next le to check */
>>>       u16             tx_prod;        /* next le to use */
>>> -    u16             tx_next;        /* debug only */
>>>
>>>       u16             tx_pending;
>>>       u16             tx_last_mss;
>> Test observations:
>>
>> 1. DHCP request/response sequence having some issues... can't confirm 
>> that it's a result of this patch, but I don't see this with the prior 
>> patch. Prior to this patch, if I connect a new device (Blackberry in 
>> this case) I see DHCPDISCOVER;DHCPOFFER;DHCPREQUEST;DHCPACK (just the 
>> four messages). With this patch I'm seeing repeated attempts - i.e., 
>> DISCOVER/OFFER 6 times before the REQUEST/ACK. This is repeatable 
>> and  happening whether or not under load. As my original problem 
>> started with DHCP packets, this seems interesting. I don't see any 
>> errors logged (dmesg, messages, etc.).
>> 2. Probably not related to this patch, but perhaps to the driver - 
>> I've finally tracked the source of my dropped RX packets. It's 
>> happening when a sending data to a CIFS client on a MacOS system. The 
>> RX drop rate seems proportional to the TX rate for SMB to that client 
>> - at a tx rate of about 200Kb/s I see about 20 dropped RX packets/sec 
>> - at 400 I see about 40.  I'm thinking therefore it's ACKs being 
>> dropped on RX. Why? no idea (yet). Nothing reported by ethtool or 
>> netstat -s remotely correlates to the number of dropped RX packets.
>>
>>
> Let me add: the CIFS client from which the packets are dropped is 
> connected via a dd-wrt router (on wifi) connected to the sky2 1G port. 
> A Windows client connected directly to the 1G port does not exhibit 
> the same symptoms (. I'll try later the Mac directly connected & a 
> Wintel box over wifi if possible. The DD-WRT router (linksys 
> wrt54g-tm) is bridged (wifi clients on same subnet as wired & serviced 
> by DHCPD running on the linux box). This is also the source of the 
> aforementioned perhaps-flaky DHCP connections.
Ok - a little more on the dropped packets - only happens when connected 
through the wifi router - but happens using a wired connection as well 
(via the router's ethernet port).

 From sniffer traces: I see large frames outbound (even though 
MTU=1500). I see the fragmented result arriving on the remote side. I 
see ACK's for each of the fragmented frames outbound from the Mac, but 
not received on the Linux side.

I also don't see any retransmissions or duplicate ACKS on either sniffer 
trace. I'm wondering whether there is fragmentation offload to the 
Yukon2, and whether the individual fragment acks are what's showing up 
dropped. If so, I don't understand why it would only happen with the 
wifi router vs. switch in the middle. Maybe the router is doing 
something to the packets which is causing the Yukon to forward the acks 
up differently? The router MTU is also 1500 on all ports, and does not 
show dropped packets or errors corresponding to what I'm seeing on the 
sky2 adapter.
