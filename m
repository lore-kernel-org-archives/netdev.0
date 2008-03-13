From: "Vernon Mauery" <vmauery@gmail.com>
Subject: Re: [PATCH 3/4] netxen: remove low level tx lock
Date: Thu, 13 Mar 2008 09:44:02 -0700
Message-ID: <200495120803130944n548f3a4dgc028741c9988fd68@mail.gmail.com>
References: <Pine.LNX.4.64.0803120059270.7717@unm84.unminc.com>
	 <Pine.LNX.4.64.0803120121580.7717@unm84.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jeff Garzik" <jeff@garzik.org>
To: "Dhananjay Phadke" <dhananjay@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:5143 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753218AbYCMQoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 12:44:06 -0400
Received: by wa-out-1112.google.com with SMTP id v27so4080842wah.23
        for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 09:44:03 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0803120121580.7717@unm84.unminc.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/12/08, Dhananjay Phadke <dhananjay@netxen.com> wrote:
>
>  o eliminate tx lock in netxen adapter struct, instead pound on netdev
>   tx lock appropriately.
>  o remove old "concurrent transmit" code that unnecessarily drops and
>   reacquires tx lock in hard_xmit_frame(), this is already serialized
>   the netdev xmit lock.
>  o reduce scope of tx lock in tx cleanup. tx cleanup operates on
>   different section of the ring than transmitting cpus and is
>   guarded by producer and consumer indices. This fixes a race
>   caused by rx softirq preemption on realtime kernels.
>
>  Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

I have tested this patch on my netxen hardware and found that it fixes
a TX timeout hang that I was seeing previously.

Tested-by: Vernon Mauery <vernux@us.ibm.com>

--Vernon

>  ---
>   drivers/net/netxen/netxen_nic.h         |   14 +----
>   drivers/net/netxen/netxen_nic_ethtool.c |    2 -
>   drivers/net/netxen/netxen_nic_init.c    |   89 ++++++-----------------------
>   drivers/net/netxen/netxen_nic_main.c    |   95 +++++++-----------------------
>   4 files changed, 43 insertions(+), 157 deletions(-)
>
>  diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
>  index 8b6546c..070421b 100644
>  --- a/drivers/net/netxen/netxen_nic.h
>  +++ b/drivers/net/netxen/netxen_nic.h
>  @@ -85,7 +85,7 @@
>         (sizeof(struct netxen_cmd_buffer) * adapter->max_tx_desc_count)
>   #define RCV_BUFFSIZE   \
>         (sizeof(struct netxen_rx_buffer) * rcv_desc->max_rx_desc_count)
>  -#define find_diff_among(a,b,range) ((a)<=(b)?((b)-(a)):((b)+(range)-(a)))
>  +#define find_diff_among(a,b,range) ((a)<(b)?((b)-(a)):((b)+(range)-(a)))
>
>   #define NETXEN_NETDEV_STATUS           0x1
>   #define NETXEN_RCV_PRODUCER_OFFSET     0
>  @@ -204,7 +204,7 @@ enum {
>                         ? RCV_DESC_LRO :        \
>                         (RCV_DESC_NORMAL)))
>
>  -#define MAX_CMD_DESCRIPTORS            1024
>  +#define MAX_CMD_DESCRIPTORS            4096
>   #define MAX_RCV_DESCRIPTORS            16384
>   #define MAX_CMD_DESCRIPTORS_HOST       (MAX_CMD_DESCRIPTORS / 4)
>   #define MAX_RCV_DESCRIPTORS_1G         (MAX_RCV_DESCRIPTORS / 4)
>  @@ -824,9 +824,7 @@ struct netxen_adapter_stats {
>         u64  uphcong;
>         u64  upmcong;
>         u64  updunno;
>  -       u64  skbfreed;
>         u64  txdropped;
>  -       u64  txnullskb;
>         u64  csummed;
>         u64  no_rcv;
>         u64  rxbytes;
>  @@ -888,8 +886,6 @@ struct netxen_adapter {
>         int mtu;
>         int portnum;
>
>  -       spinlock_t tx_lock;
>  -       spinlock_t lock;
>         struct work_struct watchdog_task;
>         struct timer_list watchdog_timer;
>         struct work_struct  tx_timeout_task;
>  @@ -898,16 +894,12 @@ struct netxen_adapter {
>
>         u32 cmd_producer;
>         __le32 *cmd_consumer;
>  -
>         u32 last_cmd_consumer;
>  +
>         u32 max_tx_desc_count;
>         u32 max_rx_desc_count;
>         u32 max_jumbo_rx_desc_count;
>         u32 max_lro_rx_desc_count;
>  -       /* Num of instances active on cmd buffer ring */
>  -       u32 proc_cmd_buf_counter;
>  -
>  -       u32 num_threads, total_threads; /*Use to keep track of xmit threads */
>
>         u32 flags;
>         u32 irq;
>  diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
>  index 7a876f4..d324ea3 100644
>  --- a/drivers/net/netxen/netxen_nic_ethtool.c
>  +++ b/drivers/net/netxen/netxen_nic_ethtool.c
>  @@ -70,9 +70,7 @@ static const struct netxen_nic_stats netxen_nic_gstrings_stats[] = {
>         {"uphcong", NETXEN_NIC_STAT(stats.uphcong)},
>         {"upmcong", NETXEN_NIC_STAT(stats.upmcong)},
>         {"updunno", NETXEN_NIC_STAT(stats.updunno)},
>  -       {"skb_freed", NETXEN_NIC_STAT(stats.skbfreed)},
>         {"tx_dropped", NETXEN_NIC_STAT(stats.txdropped)},
>  -       {"tx_null_skb", NETXEN_NIC_STAT(stats.txnullskb)},
>         {"csummed", NETXEN_NIC_STAT(stats.csummed)},
>         {"no_rcv", NETXEN_NIC_STAT(stats.no_rcv)},
>         {"rx_bytes", NETXEN_NIC_STAT(stats.rxbytes)},
>  diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
>  index 64fc18d..fe64618 100644
>  --- a/drivers/net/netxen/netxen_nic_init.c
>  +++ b/drivers/net/netxen/netxen_nic_init.c
>  @@ -1197,96 +1197,50 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
>   /* Process Command status ring */
>   int netxen_process_cmd_ring(struct netxen_adapter *adapter)
>   {
>  -       u32 last_consumer;
>  -       u32 consumer;
>  -       int count1 = 0;
>  -       int count2 = 0;
>  +       u32 last_consumer, consumer;
>  +       int count = 0, i;
>         struct netxen_cmd_buffer *buffer;
>  -       struct pci_dev *pdev;
>  +       struct pci_dev *pdev = adapter->pdev;
>  +       struct net_device *netdev = adapter->netdev;
>         struct netxen_skb_frag *frag;
>  -       u32 i;
>  -       int done;
>  +       int done = 0;
>
>  -       spin_lock(&adapter->tx_lock);
>         last_consumer = adapter->last_cmd_consumer;
>  -       DPRINTK(INFO, "procesing xmit complete\n");
>  -       /* we assume in this case that there is only one port and that is
>  -        * port #1...changes need to be done in firmware to indicate port
>  -        * number as part of the descriptor. This way we will be able to get
>  -        * the netdev which is associated with that device.
>  -        */
>  -
>         consumer = le32_to_cpu(*(adapter->cmd_consumer));
>  -       if (last_consumer == consumer) {        /* Ring is empty    */
>  -               DPRINTK(INFO, "last_consumer %d == consumer %d\n",
>  -                       last_consumer, consumer);
>  -               spin_unlock(&adapter->tx_lock);
>  -               return 1;
>  -       }
>  -
>  -       adapter->proc_cmd_buf_counter++;
>  -       /*
>  -        * Not needed - does not seem to be used anywhere.
>  -        * adapter->cmd_consumer = consumer;
>  -        */
>  -       spin_unlock(&adapter->tx_lock);
>
>  -       while ((last_consumer != consumer) && (count1 < MAX_STATUS_HANDLE)) {
>  +       while (last_consumer != consumer) {
>                 buffer = &adapter->cmd_buf_arr[last_consumer];
>  -               pdev = adapter->pdev;
>                 if (buffer->skb) {
>                         frag = &buffer->frag_array[0];
>                         pci_unmap_single(pdev, frag->dma, frag->length,
>                                          PCI_DMA_TODEVICE);
>                         frag->dma = 0ULL;
>                         for (i = 1; i < buffer->frag_count; i++) {
>  -                               DPRINTK(INFO, "getting fragment no %d\n", i);
>                                 frag++; /* Get the next frag */
>                                 pci_unmap_page(pdev, frag->dma, frag->length,
>                                                PCI_DMA_TODEVICE);
>                                 frag->dma = 0ULL;
>                         }
>
>  -                       adapter->stats.skbfreed++;
>  +                       adapter->stats.xmitfinished++;
>                         dev_kfree_skb_any(buffer->skb);
>                         buffer->skb = NULL;
>  -               } else if (adapter->proc_cmd_buf_counter == 1) {
>  -                       adapter->stats.txnullskb++;
>  -               }
>  -               if (unlikely(netif_queue_stopped(adapter->netdev)
>  -                            && netif_carrier_ok(adapter->netdev))
>  -                   && ((jiffies - adapter->netdev->trans_start) >
>  -                       adapter->netdev->watchdog_timeo)) {
>  -                       SCHEDULE_WORK(&adapter->tx_timeout_task);
>                 }
>
>                 last_consumer = get_next_index(last_consumer,
>                                                adapter->max_tx_desc_count);
>  -               count1++;
>  +               if (++count >= MAX_STATUS_HANDLE)
>  +                       break;
>         }
>
>  -       count2 = 0;
>  -       spin_lock(&adapter->tx_lock);
>  -       if ((--adapter->proc_cmd_buf_counter) == 0) {
>  +       if (count) {
>                 adapter->last_cmd_consumer = last_consumer;
>  -               while ((adapter->last_cmd_consumer != consumer)
>  -                      && (count2 < MAX_STATUS_HANDLE)) {
>  -                       buffer =
>  -                           &adapter->cmd_buf_arr[adapter->last_cmd_consumer];
>  -                       count2++;
>  -                       if (buffer->skb)
>  -                               break;
>  -                       else
>  -                               adapter->last_cmd_consumer =
>  -                                   get_next_index(adapter->last_cmd_consumer,
>  -                                                  adapter->max_tx_desc_count);
>  -               }
>  -       }
>  -       if (count1 || count2) {
>  -               if (netif_queue_stopped(adapter->netdev)
>  -                   && (adapter->flags & NETXEN_NETDEV_STATUS)) {
>  -                       netif_wake_queue(adapter->netdev);
>  -                       adapter->flags &= ~NETXEN_NETDEV_STATUS;
>  +               smp_mb();
>  +               if (netif_queue_stopped(netdev) && netif_running(netdev)) {
>  +                       netif_tx_lock(netdev);
>  +                       netif_wake_queue(netdev);
>  +                       smp_mb();
>  +                       netif_tx_unlock(netdev);
>                 }
>         }
>         /*
>  @@ -1302,16 +1256,9 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
>          * There is still a possible race condition and the host could miss an
>          * interrupt. The card has to take care of this.
>          */
>  -       if (adapter->last_cmd_consumer == consumer &&
>  -           (((adapter->cmd_producer + 1) %
>  -             adapter->max_tx_desc_count) == adapter->last_cmd_consumer)) {
>  -               consumer = le32_to_cpu(*(adapter->cmd_consumer));
>  -       }
>  -       done = (adapter->last_cmd_consumer == consumer);
>  +       consumer = le32_to_cpu(*(adapter->cmd_consumer));
>  +       done = (last_consumer == consumer);
>
>  -       spin_unlock(&adapter->tx_lock);
>  -       DPRINTK(INFO, "last consumer is %d in %s\n", last_consumer,
>  -               __FUNCTION__);
>         return (done);
>   }
>
>  diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
>  index 9595520..dc4d593 100644
>  --- a/drivers/net/netxen/netxen_nic_main.c
>  +++ b/drivers/net/netxen/netxen_nic_main.c
>  @@ -317,7 +317,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>
>         adapter->ahw.pdev = pdev;
>         adapter->ahw.pci_func  = pci_func_id;
>  -       spin_lock_init(&adapter->tx_lock);
>
>         /* remap phys address */
>         mem_base = pci_resource_start(pdev, 0); /* 0 is for BAR 0 */
>  @@ -533,7 +532,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>         adapter->watchdog_timer.data = (unsigned long)adapter;
>         INIT_WORK(&adapter->watchdog_task, netxen_watchdog_task);
>         adapter->ahw.pdev = pdev;
>  -       adapter->proc_cmd_buf_counter = 0;
>         adapter->ahw.revision_id = pdev->revision;
>
>         /* make sure Window == 1 */
>  @@ -952,41 +950,17 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>         struct netxen_skb_frag *buffrag;
>         unsigned int i;
>
>  -       u32 producer = 0;
>  +       u32 producer, consumer;
>         u32 saved_producer = 0;
>         struct cmd_desc_type0 *hwdesc;
>         int k;
>         struct netxen_cmd_buffer *pbuf = NULL;
>  -       static int dropped_packet = 0;
>         int frag_count;
>  -       u32 local_producer = 0;
>  -       u32 max_tx_desc_count = 0;
>  -       u32 last_cmd_consumer = 0;
>         int no_of_desc;
>  +       u32 num_txd = adapter->max_tx_desc_count;
>
>  -       adapter->stats.xmitcalled++;
>         frag_count = skb_shinfo(skb)->nr_frags + 1;
>
>  -       if (unlikely(skb->len <= 0)) {
>  -               dev_kfree_skb_any(skb);
>  -               adapter->stats.badskblen++;
>  -               return NETDEV_TX_OK;
>  -       }
>  -
>  -       if (frag_count > MAX_BUFFERS_PER_CMD) {
>  -               printk("%s: %s netxen_nic_xmit_frame: frag_count (%d) "
>  -                      "too large, can handle only %d frags\n",
>  -                      netxen_nic_driver_name, netdev->name,
>  -                      frag_count, MAX_BUFFERS_PER_CMD);
>  -               adapter->stats.txdropped++;
>  -               if ((++dropped_packet & 0xff) == 0xff)
>  -                       printk("%s: %s droppped packets = %d\n",
>  -                              netxen_nic_driver_name, netdev->name,
>  -                              dropped_packet);
>  -
>  -               return NETDEV_TX_OK;
>  -       }
>  -
>         /* There 4 fragments per descriptor */
>         no_of_desc = (frag_count + 3) >> 2;
>         if (netdev->features & NETIF_F_TSO) {
>  @@ -1001,27 +975,16 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>                 }
>         }
>
>  -       spin_lock_bh(&adapter->tx_lock);
>  -       if (adapter->total_threads >= MAX_XMIT_PRODUCERS) {
>  -               goto out_requeue;
>  +       producer = adapter->cmd_producer;
>  +       smp_mb();
>  +       consumer = adapter->last_cmd_consumer;
>  +       if ((no_of_desc+2) > find_diff_among(producer, consumer, num_txd)) {
>  +               netif_stop_queue(netdev);
>  +               smp_mb();
>  +               return NETDEV_TX_BUSY;
>         }
>  -       local_producer = adapter->cmd_producer;
>  -       k = adapter->cmd_producer;
>  -       max_tx_desc_count = adapter->max_tx_desc_count;
>  -       last_cmd_consumer = adapter->last_cmd_consumer;
>  -       if ((k + no_of_desc) >=
>  -           ((last_cmd_consumer <= k) ? last_cmd_consumer + max_tx_desc_count :
>  -            last_cmd_consumer)) {
>  -               goto out_requeue;
>  -       }
>  -       k = get_index_range(k, max_tx_desc_count, no_of_desc);
>  -       adapter->cmd_producer = k;
>  -       adapter->total_threads++;
>  -       adapter->num_threads++;
>
>  -       spin_unlock_bh(&adapter->tx_lock);
>         /* Copy the descriptors into the hardware    */
>  -       producer = local_producer;
>         saved_producer = producer;
>         hwdesc = &hw->cmd_desc_head[producer];
>         memset(hwdesc, 0, sizeof(struct cmd_desc_type0));
>  @@ -1061,8 +1024,7 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>                 /* move to next desc. if there is a need */
>                 if ((i & 0x3) == 0) {
>                         k = 0;
>  -                       producer = get_next_index(producer,
>  -                                                 adapter->max_tx_desc_count);
>  +                       producer = get_next_index(producer, num_txd);
>                         hwdesc = &hw->cmd_desc_head[producer];
>                         memset(hwdesc, 0, sizeof(struct cmd_desc_type0));
>                         pbuf = &adapter->cmd_buf_arr[producer];
>  @@ -1080,7 +1042,6 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>                 buffrag->dma = temp_dma;
>                 buffrag->length = temp_len;
>
>  -               DPRINTK(INFO, "for loop. i=%d k=%d\n", i, k);
>                 switch (k) {
>                 case 0:
>                         hwdesc->buffer1_length = cpu_to_le16(temp_len);
>  @@ -1101,7 +1062,7 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>                 }
>                 frag++;
>         }
>  -       producer = get_next_index(producer, adapter->max_tx_desc_count);
>  +       producer = get_next_index(producer, num_txd);
>
>         /* might change opcode to TX_TCP_LSO */
>         netxen_tso_check(adapter, &hw->cmd_desc_head[saved_producer], skb);
>  @@ -1128,7 +1089,7 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>                 /* copy the first 64 bytes */
>                 memcpy(((void *)hwdesc) + 2,
>                        (void *)(skb->data), first_hdr_len);
>  -               producer = get_next_index(producer, max_tx_desc_count);
>  +               producer = get_next_index(producer, num_txd);
>
>                 if (more_hdr) {
>                         hwdesc = &hw->cmd_desc_head[producer];
>  @@ -1141,35 +1102,19 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>                                                          hwdesc,
>                                                          (hdr_len -
>                                                           first_hdr_len));
>  -                       producer = get_next_index(producer, max_tx_desc_count);
>  +                       producer = get_next_index(producer, num_txd);
>                 }
>         }
>
>  -       spin_lock_bh(&adapter->tx_lock);
>  +       adapter->cmd_producer = producer;
>         adapter->stats.txbytes += skb->len;
>
>  -       /* Code to update the adapter considering how many producer threads
>  -          are currently working */
>  -       if ((--adapter->num_threads) == 0) {
>  -               /* This is the last thread */
>  -               u32 crb_producer = adapter->cmd_producer;
>  -               netxen_nic_update_cmd_producer(adapter, crb_producer);
>  -               wmb();
>  -               adapter->total_threads = 0;
>  -       }
>  +       netxen_nic_update_cmd_producer(adapter, adapter->cmd_producer);
>
>  -       adapter->stats.xmitfinished++;
>  +       adapter->stats.xmitcalled++;
>         netdev->trans_start = jiffies;
>
>  -       spin_unlock_bh(&adapter->tx_lock);
>         return NETDEV_TX_OK;
>  -
>  -out_requeue:
>  -       netif_stop_queue(netdev);
>  -       adapter->flags |= NETXEN_NETDEV_STATUS;
>  -
>  -       spin_unlock_bh(&adapter->tx_lock);
>  -       return NETDEV_TX_BUSY;
>   }
>
>   static void netxen_watchdog(unsigned long v)
>  @@ -1194,9 +1139,13 @@ static void netxen_tx_timeout_task(struct work_struct *work)
>         printk(KERN_ERR "%s %s: transmit timeout, resetting.\n",
>                netxen_nic_driver_name, adapter->netdev->name);
>
>  -       netxen_nic_close(adapter->netdev);
>  -       netxen_nic_open(adapter->netdev);
>  +       netxen_nic_disable_int(adapter);
>  +       napi_disable(&adapter->napi);
>  +
>         adapter->netdev->trans_start = jiffies;
>  +
>  +       napi_enable(&adapter->napi);
>  +       netxen_nic_enable_int(adapter);
>         netif_wake_queue(adapter->netdev);
>   }
>
>
>  --
>  To unsubscribe from this list: send the line "unsubscribe netdev" in
>  the body of a message to majordomo@vger.kernel.org
>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
