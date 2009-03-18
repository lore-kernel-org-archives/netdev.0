From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next PATCH 1/2] igbvf: add new driver to support 82576 virtual
 functions
Date: Tue, 17 Mar 2009 17:12:48 -0700
Message-ID: <49C03C80.5020203@intel.com>
References: <20090311020928.23138.20790.stgit@lost.foo-projects.org> <20090310222154.4bc8c12c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"greg@kroah.com" <greg@kroah.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"Zhao, Yu" <yu.zhao@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090310222154.4bc8c12c.akpm@linux-foundation.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for all the comments.  I tried to incorporate most of them into 
the igbvf driver and also ended up porting some over to our other 
drivers, specifically igb since the igbvf driver copies much of the code.

I have added my comments inline below.

Thanks,

Alex

Andrew Morton wrote:
> On Tue, 10 Mar 2009 19:09:28 -0700 Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> 
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>
>> This adds an igbvf driver to handle virtual functions provided
>> by the igb driver.
> 
> The drive-by reader is now wondering what a "virtual function" is.
> 
>> ...
>>
>> +#define IGBVF_STAT(m, b) sizeof(((struct igbvf_adapter *)0)->m), \
>> +             offsetof(struct igbvf_adapter, m), \
>> +             offsetof(struct igbvf_adapter, b)
>>
>> +static const struct igbvf_stats igbvf_gstrings_stats[] = {
>> +     { "rx_packets", IGBVF_STAT(stats.gprc, stats.base_gprc) },
>> +     { "tx_packets", IGBVF_STAT(stats.gptc, stats.base_gptc) },
>> +     { "rx_bytes", IGBVF_STAT(stats.gorc, stats.base_gorc) },
>> +     { "tx_bytes", IGBVF_STAT(stats.gotc, stats.base_gotc) },
>> +     { "multicast", IGBVF_STAT(stats.mprc, stats.base_mprc) },
>> +     { "lbrx_bytes", IGBVF_STAT(stats.gorlbc, stats.base_gorlbc) },
>> +     { "lbrx_packets", IGBVF_STAT(stats.gprlbc, stats.base_gprlbc) },
>> +     { "tx_restart_queue", IGBVF_STAT(restart_queue, zero_base) },
>> +     { "rx_long_byte_count", IGBVF_STAT(stats.gorc, stats.base_gorc) },
>> +     { "rx_csum_offload_good", IGBVF_STAT(hw_csum_good, zero_base) },
>> +     { "rx_csum_offload_errors", IGBVF_STAT(hw_csum_err, zero_base) },
>> +     { "rx_header_split", IGBVF_STAT(rx_hdr_split, zero_base) },
>> +     { "alloc_rx_buff_failed", IGBVF_STAT(alloc_rx_buff_failed, zero_base) },
>> +};
> 
> <stares at it for a while>
> 
> It would be clearer if `m' and `b' were (much) more meaningful identifiers.

I agree, the values have been changed to current and base.

>> +#define IGBVF_GLOBAL_STATS_LEN       \
>> +     (sizeof(igbvf_gstrings_stats) / sizeof(struct igbvf_stats))
> 
> This is ARRAY_SIZE().
> 
>> +#define IGBVF_STATS_LEN (IGBVF_GLOBAL_STATS_LEN)
> 
> Why does this need to exist?

It doesn't, it has been dropped and references to it replaced with 
IGBVF_GLOBAL_STATS_LEN.

>> ...
>>
>> +static int igbvf_set_ringparam(struct net_device *netdev,
>> +                               struct ethtool_ringparam *ring)
>> +{
>> +     struct igbvf_adapter *adapter = netdev_priv(netdev);
>> +     struct igbvf_ring *tx_ring, *tx_old;
>> +     struct igbvf_ring *rx_ring, *rx_old;
>> +     int err;
>> +
>> +     if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
>> +             return -EINVAL;
>> +
>> +     while (test_and_set_bit(__IGBVF_RESETTING, &adapter->state))
>> +             msleep(1);
> 
> No timeout needed here?  Interrupts might not be working, for example..

This bit isn't set in interrupt context.  This is always used out of 
interrupt context and is just to prevent multiple setting changes at the 
same time.

>> +     if (netif_running(adapter->netdev))
>> +             igbvf_down(adapter);
>> +
>> +     tx_old = adapter->tx_ring;
>> +     rx_old = adapter->rx_ring;
>> +
>> +     err = -ENOMEM;
>> +     tx_ring = kzalloc(sizeof(struct igbvf_ring), GFP_KERNEL);
>> +     if (!tx_ring)
>> +             goto err_alloc_tx;
>> +     /*
>> +      * use a memcpy to save any previously configured
>> +      * items like napi structs from having to be
>> +      * reinitialized
>> +      */
>> +     memcpy(tx_ring, tx_old, sizeof(struct igbvf_ring));
>> +
>> +     rx_ring = kzalloc(sizeof(struct igbvf_ring), GFP_KERNEL);
>> +     if (!rx_ring)
>> +             goto err_alloc_rx;
>> +     memcpy(rx_ring, rx_old, sizeof(struct igbvf_ring));
>> +
>> +     adapter->tx_ring = tx_ring;
>> +     adapter->rx_ring = rx_ring;
>> +
>> +     rx_ring->count = max(ring->rx_pending, (u32)IGBVF_MIN_RXD);
>> +     rx_ring->count = min(rx_ring->count, (u32)(IGBVF_MAX_RXD));
>> +     rx_ring->count = ALIGN(rx_ring->count, REQ_RX_DESCRIPTOR_MULTIPLE);
>> +
>> +     tx_ring->count = max(ring->tx_pending, (u32)IGBVF_MIN_TXD);
>> +     tx_ring->count = min(tx_ring->count, (u32)(IGBVF_MAX_TXD));
>> +     tx_ring->count = ALIGN(tx_ring->count, REQ_TX_DESCRIPTOR_MULTIPLE);
>> +
>> +     if (netif_running(adapter->netdev)) {
>> +             /* Try to get new resources before deleting old */
>> +             err = igbvf_setup_rx_resources(adapter);
>> +             if (err)
>> +                     goto err_setup_rx;
>> +             err = igbvf_setup_tx_resources(adapter);
>> +             if (err)
>> +                     goto err_setup_tx;
>> +
>> +             /*
>> +              * restore the old in order to free it,
>> +              * then add in the new
>> +              */
>> +             adapter->rx_ring = rx_old;
>> +             adapter->tx_ring = tx_old;
>> +             igbvf_free_rx_resources(adapter);
>> +             igbvf_free_tx_resources(adapter);
>> +             kfree(tx_old);
>> +             kfree(rx_old);
> 
> That's odd-looking.  Why take a copy of rx_old and tx_old when we're
> about to free them?

This whole section has been redone.  The approach here didn't work well 
and so I redid it to match how we do this in igb.

>> +             adapter->rx_ring = rx_ring;
>> +             adapter->tx_ring = tx_ring;
>> +             err = igbvf_up(adapter);
>> +             if (err)
>> +                     goto err_setup;
>> +     }
>> +
>> +     clear_bit(__IGBVF_RESETTING, &adapter->state);
>> +     return 0;
>> +err_setup_tx:
>> +     igbvf_free_rx_resources(adapter);
>> +err_setup_rx:
>> +     adapter->rx_ring = rx_old;
>> +     adapter->tx_ring = tx_old;
>> +     kfree(rx_ring);
>> +err_alloc_rx:
>> +     kfree(tx_ring);
>> +err_alloc_tx:
>> +     igbvf_up(adapter);
>> +err_setup:
>> +     clear_bit(__IGBVF_RESETTING, &adapter->state);
>> +     return err;
>> +}
>> +
>>
>> ...
>>
>> +static void igbvf_diag_test(struct net_device *netdev,
>> +                            struct ethtool_test *eth_test, u64 *data)
>> +{
>> +     struct igbvf_adapter *adapter = netdev_priv(netdev);
>> +
>> +     set_bit(__IGBVF_TESTING, &adapter->state);
>> +
>> +     /*
>> +      * Link test performed before hardware reset so autoneg doesn't
>> +      * interfere with test result
>> +      */
>> +     if (igbvf_link_test(adapter, &data[0]))
>> +             eth_test->flags |= ETH_TEST_FL_FAILED;
>> +
>> +     clear_bit(__IGBVF_TESTING, &adapter->state);
>> +     msleep_interruptible(4 * 1000);
> 
> If this process has signal_pending(), msleep_interruptible() becomes a
> no-op.  I expect the driver breaks?

Actually it has no effect on the driver if the sleep fails.  For the 
most part the only reason for having this is to allow enough time to 
guarantee that the link has recovered after the link test.

>> +}
>> +
>>
>> ...
>>
>> +static void igbvf_get_ethtool_stats(struct net_device *netdev,
>> +                                    struct ethtool_stats *stats,
>> +                                    u64 *data)
>> +{
>> +     struct igbvf_adapter *adapter = netdev_priv(netdev);
>> +     int i;
>> +
>> +     igbvf_update_stats(adapter);
>> +     for (i = 0; i < IGBVF_GLOBAL_STATS_LEN; i++) {
>> +             char *p = (char *)adapter +
>> +                       igbvf_gstrings_stats[i].stat_offset;
>> +             char *b = (char *)adapter +
>> +                       igbvf_gstrings_stats[i].base_stat_offset;
>> +             data[i] = ((igbvf_gstrings_stats[i].sizeof_stat ==
>> +                         sizeof(u64)) ? *(u64 *)p : *(u32 *)p) -
>> +                       ((igbvf_gstrings_stats[i].sizeof_stat ==
>> +                         sizeof(u64)) ? *(u64 *)b : *(u32 *)b);
> 
> yitch.
> 
> Are we using the C type system as well as possible here?

Actually I think the ugliness is due to the fact that it is doing the 
check itself twice.  The code below is what it will look like after 
being redone.

                 data[i] = ((igbvf_gstrings_stats[i].sizeof_stat ==
                             sizeof(u64)) ? (*(u64 *)p - *(u64 *)b) :
                             (*(u32 *)p - *(u32 *)b));

>> +     }
>> +
>> +}
>> +
>>
>> ...
>>
>> +#define IGBVF_DESC_UNUSED(R) \
>> +     ((((R)->next_to_clean > (R)->next_to_use) ? 0 : (R)->count) + \
>> +     (R)->next_to_clean - (R)->next_to_use - 1)
> 
> my eyes.
> 
> This macro evaluates its argument multiple times and will misbehave (or
> be slow) if passed an expreesion with side-effects.
> 
> Why not just write a plain old C function for this?

Actually that was already done and the macro was unused.  It has been 
dropped.

>> +#define IGBVF_RX_DESC_ADV(R, i)     \
>> +     (&(((union e1000_adv_rx_desc *)((R).desc))[i]))
>> +#define IGBVF_TX_DESC_ADV(R, i)     \
>> +     (&(((union e1000_adv_tx_desc *)((R).desc))[i]))
>> +#define IGBVF_TX_CTXTDESC_ADV(R, i) \
>> +     (&(((struct e1000_adv_tx_context_desc *)((R).desc))[i]))
> 
> Maybe igbvf_ring.desc should have had type
> 
>         union {
>                 union e1000_adv_rx_desc;
>                 union e1000_adv_tx_desc;
>                 union e1000_adv_tx_context_desc;
>         } *
> 
> Or something.

By switching these over to a typecast I can get away from some of the 
ugliness but it is still there.  Below are the changes I made to support 
what you suggested.

#define IGBVF_RX_DESC_ADV(R, i)     \
         (&((((R).desc))[i].rx_desc))
#define IGBVF_TX_DESC_ADV(R, i)     \
         (&((((R).desc))[i].tx_desc))
#define IGBVF_TX_CTXTDESC_ADV(R, i) \
         (&((((R).desc))[i].tx_context_desc))



union igbvf_desc {
         union e1000_adv_rx_desc rx_desc;
         union e1000_adv_tx_desc tx_desc;
         struct e1000_adv_tx_context_desc tx_context_desc;
};

>> ...
>>
>> +/**
>> + * igbvf_alloc_rx_buffers - Replace used receive buffers; packet split
>> + * @rx_ring: address of ring structure to repopulate
>> + * @cleaned_count: number of buffers to repopulate
>> + **/
>> +static void igbvf_alloc_rx_buffers(struct igbvf_ring *rx_ring,
>> +                                   int cleaned_count)
>> +{
>> +     struct igbvf_adapter *adapter = rx_ring->adapter;
>> +     struct net_device *netdev = adapter->netdev;
>> +     struct pci_dev *pdev = adapter->pdev;
>> +     union e1000_adv_rx_desc *rx_desc;
>> +     struct igbvf_buffer *buffer_info;
>> +     struct sk_buff *skb;
>> +     unsigned int i;
>> +     int bufsz;
>> +
>> +     i = rx_ring->next_to_use;
>> +     buffer_info = &rx_ring->buffer_info[i];
>> +
>> +     if (adapter->rx_ps_hdr_size)
>> +             bufsz = adapter->rx_ps_hdr_size;
>> +     else
>> +             bufsz = adapter->rx_buffer_len;
>> +     bufsz += NET_IP_ALIGN;
>> +
>> +     while (cleaned_count--) {
>> +             rx_desc = IGBVF_RX_DESC_ADV(*rx_ring, i);
>> +
>> +             if (adapter->rx_ps_hdr_size && !buffer_info->page_dma) {
>> +                     if (!buffer_info->page) {
>> +                             buffer_info->page = alloc_page(GFP_ATOMIC);
>> +                             if (!buffer_info->page) {
>> +                                     adapter->alloc_rx_buff_failed++;
>> +                                     goto no_buffers;
>> +                             }
>> +                             buffer_info->page_offset = 0;
>> +                     } else {
>> +                             buffer_info->page_offset ^= PAGE_SIZE / 2;
>> +                     }
>> +                     buffer_info->page_dma =
>> +                             pci_map_page(pdev, buffer_info->page,
>> +                                          buffer_info->page_offset,
>> +                                          PAGE_SIZE / 2,
>> +                                          PCI_DMA_FROMDEVICE);
>> +             }
>> +
>> +             if (!buffer_info->skb) {
>> +                     skb = netdev_alloc_skb(netdev, bufsz);
>> +                     if (!skb) {
>> +                             adapter->alloc_rx_buff_failed++;
>> +                             goto no_buffers;
>> +                     }
>> +
>> +                     /* Make buffer alignment 2 beyond a 16 byte boundary
>> +                      * this will result in a 16 byte aligned IP header after
>> +                      * the 14 byte MAC header is removed
>> +                      */
>> +                     skb_reserve(skb, NET_IP_ALIGN);
>> +
>> +                     buffer_info->skb = skb;
>> +                     buffer_info->dma = pci_map_single(pdev, skb->data,
>> +                                                       bufsz,
>> +                                                       PCI_DMA_FROMDEVICE);
>> +             }
>> +             /* Refresh the desc even if buffer_addrs didn't change because
>> +              * each write-back erases this info. */
>> +             if (adapter->rx_ps_hdr_size) {
>> +                     rx_desc->read.pkt_addr =
>> +                          cpu_to_le64(buffer_info->page_dma);
>> +                     rx_desc->read.hdr_addr = cpu_to_le64(buffer_info->dma);
>> +             } else {
>> +                     rx_desc->read.pkt_addr =
>> +                          cpu_to_le64(buffer_info->dma);
>> +                     rx_desc->read.hdr_addr = 0;
>> +             }
>> +
>> +             i++;
>> +             if (i == rx_ring->count)
>> +                     i = 0;
>> +             buffer_info = &rx_ring->buffer_info[i];
>> +     }
>> +
>> +no_buffers:
>> +     if (rx_ring->next_to_use != i) {
>> +             rx_ring->next_to_use = i;
>> +             if (i == 0)
>> +                     i = (rx_ring->count - 1);
>> +             else
>> +                     i--;
>> +
>> +             /* Force memory writes to complete before letting h/w
>> +              * know there are new descriptors to fetch.  (Only
>> +              * applicable for weak-ordered memory model archs,
>> +              * such as IA-64). */
>> +             wmb();
>> +             writel(i, adapter->hw.hw_addr + rx_ring->tail);
> 
> Does wmb() work reliably for masters other than CPUs?  I lose track...

For SR-IOV it is always possible that someone might decide to run some 
of the VFs in their DOM0 kernel so it is best to leave it in there to 
support it just in case.

>> +     }
>> +}
>> +
>>
>> ...
>>
>> +/**
>> + * igbvf_setup_tx_resources - allocate Tx resources (Descriptors)
>> + * @adapter: board private structure
>> + *
>> + * Return 0 on success, negative on failure
>> + **/
>> +int igbvf_setup_tx_resources(struct igbvf_adapter *adapter)
>> +{
>> +     struct igbvf_ring *tx_ring = adapter->tx_ring;
>> +     int err = -ENOMEM, size;
>> +
>> +     size = sizeof(struct igbvf_buffer) * tx_ring->count;
>> +     tx_ring->buffer_info = vmalloc(size);
> 
> How large is this likely to be?

This can get to be up to 4K * size of igbvf_buffer which int total comes 
to something like 32K or more.

>> +     if (!tx_ring->buffer_info)
>> +             goto err;
>> +     memset(tx_ring->buffer_info, 0, size);
>> +
>> +     /* round up to nearest 4K */
>> +     tx_ring->size = tx_ring->count * sizeof(union e1000_adv_tx_desc);
>> +     tx_ring->size = ALIGN(tx_ring->size, 4096);
>> +
>> +     err = igbvf_alloc_ring_dma(adapter, tx_ring);
>> +     if (err)
>> +             goto err;
>> +
>> +     tx_ring->next_to_use = 0;
>> +     tx_ring->next_to_clean = 0;
>> +     spin_lock_init(&adapter->tx_queue_lock);
>> +
>> +     return 0;
>> +err:
>> +     vfree(tx_ring->buffer_info);
>> +     dev_err(&adapter->pdev->dev,
>> +             "Unable to allocate memory for the transmit descriptor ring\n");
>> +     return err;
>> +}
>> +
>>
>> ...
>>
>> +void igbvf_set_interrupt_capability(struct igbvf_adapter *adapter)
>> +{
>> +     int err = -ENOMEM;
>> +     int i;
>> +
>> +     /* we allocate 3 vectors, 1 for tx, 1 for rx, one for pf messages */
>> +     adapter->msix_entries = kcalloc(3, sizeof(struct msix_entry),
>> +                                     GFP_KERNEL);
>> +     if (adapter->msix_entries) {
>> +             for (i = 0; i < 3; i++)
>> +                     adapter->msix_entries[i].entry = i;
>> +
>> +             err = pci_enable_msix(adapter->pdev,
>> +                                   adapter->msix_entries, 3);
>> +     }
>> +
>> +     if (err) {
>> +             /* MSI-X failed */
>> +             dev_err(&adapter->pdev->dev,
>> +                     "Failed to initialize MSI-X interrupts.\n");
>> +             igbvf_reset_interrupt_capability(adapter);
> 
> This can run pci_disable_msix() even if pci_enable_msix() falied.  Seems odd.

Calling pci_disable_msix is safe since the first thing it checks for is 
to verify if msix is enabled.  If it isn't the function does nothing.

>> +     }
>> +}
>> +
>>
>> ...
>>
>> +static int __devinit igbvf_alloc_queues(struct igbvf_adapter *adapter)
>> +{
>> +     struct net_device *netdev = adapter->netdev;
>> +
>> +     adapter->tx_ring = kzalloc(sizeof(struct igbvf_ring), GFP_KERNEL);
>> +     if (!adapter->tx_ring)
>> +             goto tx_err;
>> +     adapter->tx_ring->adapter = adapter;
>> +
>> +     adapter->rx_ring = kzalloc(sizeof(struct igbvf_ring), GFP_KERNEL);
>> +     if (!adapter->rx_ring)
>> +             goto err;
>> +     adapter->rx_ring->adapter = adapter;
>> +
>> +     netif_napi_add(netdev, &adapter->rx_ring->napi, igbvf_poll, 64);
>> +
>> +     return 0;
>> +err:
>> +     dev_err(&adapter->pdev->dev, "Unable to allocate memory for queues\n");
>> +     kfree(adapter->rx_ring);
>> +tx_err:
>> +     kfree(adapter->tx_ring);
>> +     return -ENOMEM;
>> +}
> 
> The error handling here is all mucked up.

I agree, it has been fixed.

>> ...
>>
>> +/**
>> + * igbvf_set_multi - Multicast and Promiscuous mode set
>> + * @netdev: network interface device structure
>> + *
>> + * The set_multi entry point is called whenever the multicast address
>> + * list or the network interface flags are updated.  This routine is
>> + * responsible for configuring the hardware for proper multicast,
>> + * promiscuous mode, and all-multi behavior.
>> + **/
> 
> It is conventional to terminate a kerneldoc comemnt with
> 
>     */

This is the coding convention we have been using this format for all of 
our functions for a long time.  If you check e1000 or igb you will see 
they all use this format for function comments.

>> +static void igbvf_set_multi(struct net_device *netdev)
>> +{
>> +     struct igbvf_adapter *adapter = netdev_priv(netdev);
>> +     struct e1000_hw *hw = &adapter->hw;
>> +     struct dev_mc_list *mc_ptr;
>> +     u8  *mta_list;
>> +     int i;
>> +
>> +     if (netdev->mc_count) {
>> +             mta_list = kmalloc(netdev->mc_count * 6, GFP_ATOMIC);
>> +             if (!mta_list)
>> +                     return;
> 
> Shouldn't this be reported to someone?

I've added dev_err message if this fails, but other than that it is just 
a failure to set a receive filter so it isn't a showstopper.  Also the 
call itself is a void so I have no way of notifying the stack of the error.

>> +             /* prepare a packed array of only addresses. */
>> +             mc_ptr = netdev->mc_list;
>> +
>> +             for (i = 0; i < netdev->mc_count; i++) {
>> +                     if (!mc_ptr)
>> +                             break;
>> +                     memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr,
>> +                            ETH_ALEN);
>> +                     mc_ptr = mc_ptr->next;
>> +             }
>> +
>> +             hw->mac.ops.update_mc_addr_list(hw, mta_list, i, 0, 0);
>> +             kfree(mta_list);
>> +     } else {
>> +             /*
>> +              * if we're called from probe, we might not have
>> +              * anything to do here, so clear out the list
>> +              */
>> +             hw->mac.ops.update_mc_addr_list(hw, NULL, 0, 0, 0);
>> +     }
>> +}
>> +
>>
>> ...
>>
>> +void igbvf_down(struct igbvf_adapter *adapter)
>> +{
>> +     struct net_device *netdev = adapter->netdev;
>> +
>> +     /*
>> +      * signal that we're down so the interrupt handler does not
>> +      * reschedule our watchdog timer
>> +      */
>> +     set_bit(__IGBVF_DOWN, &adapter->state);
>> +
>> +     netif_stop_queue(netdev);
>> +
>> +     /* FIX ME!!!! */
>> +     /* need to disable local queue transmit and receive */
>> +
>> +     msleep(10);
> 
> Random mysterious msleep() deserves a code commeent.

I redid the entire section above.  This is one spot I missed when I was 
cleaning up all this code.

>> +     napi_disable(&adapter->rx_ring->napi);
>> +
>> +     igbvf_irq_disable(adapter);
>> +
>> +     del_timer_sync(&adapter->watchdog_timer);
>> +
>> +     netdev->tx_queue_len = adapter->tx_queue_len;
>> +     netif_carrier_off(netdev);
>> +     adapter->link_speed = 0;
>> +     adapter->link_duplex = 0;
>> +
>> +     igbvf_reset(adapter);
>> +     igbvf_clean_tx_ring(adapter);
>> +     igbvf_clean_rx_ring(adapter);
>> +}
>> +
>> +void igbvf_reinit_locked(struct igbvf_adapter *adapter)
>> +{
>> +     might_sleep();
>> +     while (test_and_set_bit(__IGBVF_RESETTING, &adapter->state))
>> +             msleep(1);
> 
> timeout?

Once again this isn't called normally in interrupt context so it is safe 
here since if we set the bit we should clear it when we are done.

>> +     igbvf_down(adapter);
>> +     igbvf_up(adapter);
>> +     clear_bit(__IGBVF_RESETTING, &adapter->state);
>> +}
>> +
>>
>> ...
>>
>> +static int __devinit igbvf_probe(struct pci_dev *pdev,
>> +                                 const struct pci_device_id *ent)
>> +{
>> +     struct net_device *netdev;
>> +     struct igbvf_adapter *adapter;
>> +     struct e1000_hw *hw;
>> +     const struct igbvf_info *ei = igbvf_info_tbl[ent->driver_data];
>> +
>> +     static int cards_found;
>> +     int err, pci_using_dac;
>> +
>> +     err = pci_enable_device_mem(pdev);
>> +     if (err)
>> +             return err;
>> +
>> +     pci_using_dac = 0;
>> +     err = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
>> +     if (!err) {
>> +             err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
>> +             if (!err)
>> +                     pci_using_dac = 1;
>> +     } else {
>> +             err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
>> +             if (err) {
>> +                     err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
>> +                     if (err) {
>> +                             dev_err(&pdev->dev, "No usable DMA "
>> +                                     "configuration, aborting\n");
>> +                             goto err_dma;
>> +                     }
>> +             }
>> +     }
>> +
>> +     err = pci_request_regions(pdev, igbvf_driver_name);
>> +     if (err)
>> +             goto err_pci_reg;
>> +
>> +     pci_set_master(pdev);
>> +
>> +     err = -ENOMEM;
>> +     netdev = alloc_etherdev(sizeof(struct igbvf_adapter));
>> +     if (!netdev)
>> +             goto err_alloc_etherdev;
>> +
>> +     SET_NETDEV_DEV(netdev, &pdev->dev);
>> +
>> +     pci_set_drvdata(pdev, netdev);
>> +     adapter = netdev_priv(netdev);
>> +     hw = &adapter->hw;
>> +     adapter->netdev = netdev;
>> +     adapter->pdev = pdev;
>> +     adapter->ei = ei;
>> +     adapter->pba = ei->pba;
>> +     adapter->flags = ei->flags;
>> +     adapter->hw.back = adapter;
>> +     adapter->hw.mac.type = ei->mac;
>> +     adapter->msg_enable = (1 << NETIF_MSG_DRV | NETIF_MSG_PROBE) - 1;
>> +
>> +     /* PCI config space info */
>> +
>> +     hw->vendor_id = pdev->vendor;
>> +     hw->device_id = pdev->device;
>> +     hw->subsystem_vendor_id = pdev->subsystem_vendor;
>> +     hw->subsystem_device_id = pdev->subsystem_device;
>> +
>> +     pci_read_config_byte(pdev, PCI_REVISION_ID, &hw->revision_id);
>> +
>> +     err = -EIO;
>> +     adapter->hw.hw_addr = ioremap(pci_resource_start(pdev, 0),
>> +                                   pci_resource_len(pdev, 0));
>> +
>> +     if (!adapter->hw.hw_addr)
>> +             goto err_ioremap;
>> +
>> +     if (ei->get_variants) {
>> +             err = ei->get_variants(adapter);
>> +             if (err)
>> +                     goto err_hw_init;
>> +     }
>> +
>> +     /* setup adapter struct */
>> +     err = igbvf_sw_init(adapter);
>> +     if (err)
>> +             goto err_sw_init;
>> +
>> +     /* construct the net_device struct */
>> +     netdev->netdev_ops = &igbvf_netdev_ops;
>> +
>> +     igbvf_set_ethtool_ops(netdev);
>> +     netdev->watchdog_timeo = 5 * HZ;
>> +     strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
>> +
>> +     adapter->bd_number = cards_found++;
>> +
>> +     netdev->features = NETIF_F_SG |
>> +                        NETIF_F_IP_CSUM |
>> +                        NETIF_F_HW_VLAN_TX |
>> +                        NETIF_F_HW_VLAN_RX |
>> +                        NETIF_F_HW_VLAN_FILTER;
>> +
>> +     netdev->features |= NETIF_F_IPV6_CSUM;
>> +     netdev->features |= NETIF_F_TSO;
>> +     netdev->features |= NETIF_F_TSO6;
>> +
>> +     if (pci_using_dac)
>> +             netdev->features |= NETIF_F_HIGHDMA;
>> +
>> +     netdev->vlan_features |= NETIF_F_TSO;
>> +     netdev->vlan_features |= NETIF_F_TSO6;
>> +     netdev->vlan_features |= NETIF_F_IP_CSUM;
>> +     netdev->vlan_features |= NETIF_F_IPV6_CSUM;
>> +     netdev->vlan_features |= NETIF_F_SG;
>> +
>> +     /*reset the controller to put the device in a known good state */
>> +     err = hw->mac.ops.reset_hw(hw);
>> +     if (err) {
>> +             dev_info(&pdev->dev,
>> +                      "PF still in reset state, assigning new address\n");
>> +             random_ether_addr(hw->mac.addr);
>> +     } else {
>> +             err = hw->mac.ops.read_mac_addr(hw);
>> +             if (err) {
>> +                     dev_err(&pdev->dev, "Error reading MAC address\n");
>> +                     goto err_hw_init;
>> +             }
>> +     }
>> +
>> +     memcpy(netdev->dev_addr, adapter->hw.mac.addr, netdev->addr_len);
>> +     memcpy(netdev->perm_addr, adapter->hw.mac.addr, netdev->addr_len);
>> +
>> +     if (!is_valid_ether_addr(netdev->perm_addr)) {
>> +             dev_err(&pdev->dev, "Invalid MAC Address: "
>> +                     "%02x:%02x:%02x:%02x:%02x:%02x\n",
>> +                     netdev->dev_addr[0], netdev->dev_addr[1],
>> +                     netdev->dev_addr[2], netdev->dev_addr[3],
>> +                     netdev->dev_addr[4], netdev->dev_addr[5]);
>> +             err = -EIO;
>> +             goto err_hw_init;
>> +     }
>> +
>> +     init_timer(&adapter->watchdog_timer);
>> +     adapter->watchdog_timer.function = &igbvf_watchdog;
>> +     adapter->watchdog_timer.data = (unsigned long) adapter;
> 
> Could use setup_timer() here.

done.

>> +     INIT_WORK(&adapter->reset_task, igbvf_reset_task);
>> +     INIT_WORK(&adapter->watchdog_task, igbvf_watchdog_task);
>> +
>> +     /* ring size defaults */
>> +     adapter->rx_ring->count = 1024;
>> +     adapter->tx_ring->count = 1024;
>> +
>> +     /* reset the hardware with the new settings */
>> +     igbvf_reset(adapter);
>> +
>> +     /* tell the stack to leave us alone until igbvf_open() is called */
>> +     netif_carrier_off(netdev);
>> +     netif_stop_queue(netdev);
>> +
>> +     strcpy(netdev->name, "eth%d");
>> +     err = register_netdev(netdev);
>> +     if (err)
>> +             goto err_hw_init;
>> +
>> +     igbvf_print_device_info(adapter);
>> +
>> +     igbvf_initialize_last_counter_stats(adapter);
>> +
>> +     return 0;
>> +
>> +err_hw_init:
>> +     kfree(adapter->tx_ring);
>> +     kfree(adapter->rx_ring);
>> +     igbvf_reset_interrupt_capability(adapter);
>> +err_sw_init:
>> +     iounmap(adapter->hw.hw_addr);
>> +err_ioremap:
>> +     free_netdev(netdev);
>> +err_alloc_etherdev:
>> +     pci_release_regions(pdev);
>> +err_pci_reg:
>> +err_dma:
>> +     pci_disable_device(pdev);
>> +     return err;
>> +}
>> +
>> +/**
>> + * igbvf_remove - Device Removal Routine
>> + * @pdev: PCI device information struct
>> + *
>> + * igbvf_remove is called by the PCI subsystem to alert the driver
>> + * that it should release a PCI device.  The could be caused by a
>> + * Hot-Plug event, or because the driver is going to be removed from
>> + * memory.
>> + **/
>> +static void __devexit igbvf_remove(struct pci_dev *pdev)
>> +{
>> +     struct net_device *netdev = pci_get_drvdata(pdev);
>> +     struct igbvf_adapter *adapter = netdev_priv(netdev);
>> +     struct e1000_hw *hw = &adapter->hw;
>> +
>> +     /*
>> +      * flush_scheduled work may reschedule our watchdog task, so
>> +      * explicitly disable watchdog tasks from being rescheduled
>> +      */
>> +     set_bit(__IGBVF_DOWN, &adapter->state);
>> +     del_timer_sync(&adapter->watchdog_timer);
>> +
>> +     flush_scheduled_work();
> 
> flush_work() is a bit more modern - it will flush a specific work item
> rather than waiting for the kernel-wide queue to drain.

I think we want to use flush_scheduled_work here since there is also the 
dev watchdog timer which could be in the middle of running while we are 
shutting down if we don't flush all work queues.

>> +     unregister_netdev(netdev);
>> +
>> +     igbvf_reset_interrupt_capability(adapter);
>> +     kfree(adapter->tx_ring);
>> +     kfree(adapter->rx_ring);
>> +
>> +     iounmap(hw->hw_addr);
>> +     if (hw->flash_address)
>> +             iounmap(hw->flash_address);
>> +     pci_release_regions(pdev);
>> +
>> +     free_netdev(netdev);
>> +
>> +     pci_disable_device(pdev);
>> +}
>> +
>>
>> ...
>>
> 
> What a lot of code.

I know it is a lot of code, but it is a new driver so it can't really be 
helped.

