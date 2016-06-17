From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 12/18] IB/mlx5: Add kernel offload flow-tag
Date: Fri, 17 Jun 2016 09:50:38 -0700
Message-ID: <57642A5E.5000308@gmail.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
 <1466174639-14576-13-git-send-email-saeedm@mellanox.com>
 <20160617160007.GA52082@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36423 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752450AbcFQQuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 12:50:55 -0400
Received: by mail-pa0-f67.google.com with SMTP id fg1so6134658pad.3
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 09:50:55 -0700 (PDT)
In-Reply-To: <20160617160007.GA52082@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-17 09:00 AM, Alexei Starovoitov wrote:
> On Fri, Jun 17, 2016 at 05:43:53PM +0300, Saeed Mahameed wrote:
>> From: Maor Gottlieb <maorg@mellanox.com>
>>
>> Add kernel offload flow tag for packets that will bypass the kernel
>> stack, e.g (RoCE/RDMA/RAW ETH (DPDK), etc ..).
> 
> so the whole series is an elaborate way to enable dpdk? how nice.
> NACK.
> 

Well there is certainly room for augmenting the af_packet interfac with
hardware support.

Some things on my list (its a bit behind a few other things though) is
to align queues to af_packet sockets, put those queues in busy poll and
if possible look at zero copy RX. The problem with zero copy rx is it
bypasses the stack but we should be able to detect hooks being added on
ingress and disable it dynamically. Maybe I could look at this in a few
months but think about it for me I'm a bit busy lately. Also it requires
the driver to translate descriptor formats but I'm not convinced it is
that costly to do.

For DPDK why not just use SR-IOV like everyone else and bind a VF to
your favorite user space implementation (DPDK, NETMAP, PFRING, foobar0)
even Windows if you like. DPDK even supports this as far as I know.
Then you don't need to bother kernel folks at all. And you don't have
any overhead except from whatever your usermode code does.

Here's a really old patch I wrote that I would like to revisit at some
point,

---

>> This adds ndo ops for upper layer objects to request direct DMA from
>> the network interface into memory "slots". The slots must be DMA'able
>> memory given by a page/offset/size vector in a packet_ring_buffer
>> structure.
>>
>> The PF_PACKET socket interface can use these ndo_ops to do zerocopy
>> RX from the network device into memory mapped userspace memory. For
>> this to work ixgbe encodes the correct descriptor blocks and headers
>> so that existing PF_PACKET applications work without any modification.
>> This only supports the V2 header formats. And works by mapping a ring
>> of the network device to these slots.
>>
>> V3 header formats added bulk polling via socket calls and timers
>> used in the polling interface to return every n milliseconds. Currently,
>> I don't see any way to support this in hardware because we can't
>> know if the hardware is in the middle of a DMA operation or not
>> on a slot. So when a timer fires I don't know how to advance the
>> descriptor ring leaving empty descriptors similar to how the software
>> ring works. The easiest (best?) route is to simply not support this.
>>
>> The ndo operations and new socket option PACKET_RX_DIRECT work by
>> selecting a queue_index to run the direct dma operations over. Once
>> setsockopt returns sucessfully the indicated queue is mapped
>> directly to the requesting application and can not be used for
>> other purposes. Also any kernel layers such as BPF will be bypassed
>> and need to be implemented in the hardware via some other mechanism
>> such as flow classifier or future offload interfaces.
>>
>> Users steer traffic to the selected queue using flow director or
>> VMDQ. This needs to implemented through the ioctl flow classifier
>> interface (ethtool) or macvlan+hardware offload via netlink the
>> command line tool ip also supports macvlan+hardware_offload.
>>
>> The new socket option added to PF_PACKET is called PACKET_RX_DIRECT.
>> It takes a single unsigned int value specifying the queue index,
>>
>>      setsockopt(sock, SOL_PACKET, PACKET_RX_DIRECT,
>>             &queue_index, sizeof(queue_index));
>>
>> To test this I modified the tool psock_tpacket in the selftests
>> kernel directory here:
>>
>>      ./tools/testing/selftests/net/psock_tpacket.c
>>
>> Running this tool opens a socket and listend for packets over
>> the PACKET_RX_DIRECT enabled socket.
>>
>> One more caveat is the ring size of ixgbe and the size used by
>> the software socket need to be the same. There is currently an
>> ethtool to configure this and a warnding is pushed to dmesg when
>> it is not the case. To set use an ioctl directly or call
>>
>>      ethtool -G ethx rx <size>
>>
>> where <size> is the number of configured slots. The demo program
>> psock_tpacket needs size=2400.
>>
>> Known Limitations (TBD):
>>
>>      (1) Users are required to match the number of rx ring
>>              slots with ethtool to the number requested by the
>>              setsockopt PF_PACKET layout. In the future we could
>>              possibly do this automatically. More importantly this
>>          setting is currently global for all rings and needs
>>          to be per queue.
>>
>>      (2) Users need to configure Flow director or VMDQ (macvlan)
>>              to steer traffic to the correct queues. I don't believe
>>          this needs to be changed it seems to be a good mechanism
>>          for driving ddma.
>>
>>      (3) Not supporting timestamps or priv space yet
>>
>>      (4) Not supporting BPF yet...
>>
>>      (5) Only RX supported so far. TX already supports direct DMA
>>          interface but uses skbs which is really not needed. In
>>          the TX_RING case.
>>
>> To be done:
>>
>>      (1) More testing and performance analysis
>>      (2) Busy polling sockets
>>      (3) Write generic code so driver implementation is small
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>   drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    5
>>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  383 +++++++++++++++++++++++++
>>   include/linux/netdevice.h                     |    8 +
>>   include/net/af_packet.h                       |   62 ++++
>>   include/uapi/linux/if_packet.h                |    1
>>   net/packet/af_packet.c                        |   41 +++
>>   net/packet/internal.h                         |   59 ----
>>   tools/testing/selftests/net/psock_tpacket.c   |   49 +++
>>   8 files changed, 537 insertions(+), 71 deletions(-)
>>   create mode 100644 include/net/af_packet.h
>>
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>> index ac9f214..5000731 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>> @@ -186,6 +186,8 @@ struct ixgbe_rx_buffer {
>>       dma_addr_t dma;
>>       struct page *page;
>>       unsigned int page_offset;
>> +    unsigned int hdr;
>> +    bool last_frame;
>>   };
>>
>>   struct ixgbe_queue_stats {
>> @@ -279,6 +281,9 @@ struct ixgbe_ring {
>>           };
>>       };
>>
>> +    bool ddma;            /* direct DMA for mapping user pages */
>> +    size_t ddma_size;
>> +    struct sock *sk;
>>       u8 dcb_tc;
>>       struct ixgbe_queue_stats stats;
>>       struct u64_stats_sync syncp;
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> index e22278a..b4997b4 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> @@ -1478,6 +1478,79 @@ static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
>>   }
>>
>>   /**
>> + * ixgbe_ddma_claim_buffers - Manage user visible buffer pages
>> + * @rx_ring: ring to place buffers on
>> + * @cleaned_count: number of buffers to replace
>> + *
>> + * First check that userspace is done with the page then reclaim it with a
>> + * dma_map_page() and give it to the hardware. In comparison to the normal
>> + * alloc_rx_buffers path there is never any need to allocate pages because
>> + * this is done at setup time by the mmapped rx_ring calculations.
>> + *
>> + * Because we are effectively giving the hardware ring to user space a
>> + * misbehaving or simply slow program may stall the receiving of packets
>> + * by causing descriptor exhaustion. But the ring is "owned" by the application
>> + * so the side effects should be limited. Administrators do need to be
>> + * concerned about giving applications flow control enabled queues though.
>> + **/
>> +static u16 ixgbe_ddma_claim_buffers(struct ixgbe_ring *rx_ring,
>> +                    u16 cleaned_count)
>> +{
>> +    union ixgbe_adv_rx_desc *rx_desc;
>> +    struct ixgbe_rx_buffer *bi;
>> +    u16 i = rx_ring->next_to_use;
>> +
>> +    /* nothing to do */
>> +    if (!cleaned_count)
>> +        return cleaned_count;
>> +
>> +    rx_desc = IXGBE_RX_DESC(rx_ring, i);
>> +    bi = &rx_ring->rx_buffer_info[i];
>> +    i -= rx_ring->count;
>> +
>> +    do {
>> +        struct tpacket2_hdr *hdr = page_address(bi->page) + bi->hdr;
>> +
>> +        /* If user space has not released packet yet stop */
>> +        if (unlikely(TP_STATUS_USER & hdr->tp_status))
>> +            break;
>> +
>> +        /* Reclaim shared memory for next DMA */
>> +        dma_sync_single_range_for_device(rx_ring->dev, bi->dma,
>> +                         bi->page_offset,
>> +                         rx_ring->ddma_size,
>> +                         DMA_FROM_DEVICE);
>> +
>> +        /*
>> +         * Refresh the desc even if buffer_addrs didn't change
>> +         * because each write-back erases this info.
>> +         */
>> +        rx_desc->read.pkt_addr = cpu_to_le64(bi->dma + bi->page_offset);
>> +
>> +        rx_desc++;
>> +        bi++;
>> +        i++;
>> +        if (unlikely(!i)) {
>> +            rx_desc = IXGBE_RX_DESC(rx_ring, 0);
>> +            bi = rx_ring->rx_buffer_info;
>> +            i -= rx_ring->count;
>> +        }
>> +
>> +        /* clear the hdr_addr for the next_to_use descriptor */
>> +        rx_desc->read.hdr_addr = 0;
>> +
>> +        cleaned_count--;
>> +    } while (cleaned_count);
>> +
>> +    i += rx_ring->count;
>> +
>> +    if (rx_ring->next_to_use != i)
>> +        ixgbe_release_rx_desc(rx_ring, i);
>> +
>> +    return cleaned_count;
>> +}
>> +
>> +/**
>>    * ixgbe_alloc_rx_buffers - Replace used receive buffers
>>    * @rx_ring: ring to place buffers on
>>    * @cleaned_count: number of buffers to replace
>> @@ -1492,6 +1565,12 @@ void ixgbe_alloc_rx_buffers(struct ixgbe_ring *rx_ring, u16 cleaned_count)
>>       if (!cleaned_count)
>>           return;
>>
>> +    /* Debug helper remember to remove before official patch */
>> +    if (rx_ring->ddma) {
>> +        WARN_ON(rx_ring->ddma);
>> +        return;
>> +    }
>> +
>>       rx_desc = IXGBE_RX_DESC(rx_ring, i);
>>       bi = &rx_ring->rx_buffer_info[i];
>>       i -= rx_ring->count;
>> @@ -1908,6 +1987,12 @@ static void ixgbe_reuse_rx_page(struct ixgbe_ring *rx_ring,
>>       struct ixgbe_rx_buffer *new_buff;
>>       u16 nta = rx_ring->next_to_alloc;
>>
>> +    /* Debug statement to catch logic errors remove later */
>> +    if (rx_ring->ddma) {
>> +        WARN_ON(1);
>> +        return;
>> +    }
>> +
>>       new_buff = &rx_ring->rx_buffer_info[nta];
>>
>>       /* update, and store next to alloc */
>> @@ -2005,6 +2090,128 @@ static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
>>       return true;
>>   }
>>
>> +/* ixgbe_do_ddma - direct dma routine to populate PACKET_RX_RING mmap region
>> + *
>> + * The packet socket interface builds a shared memory region using mmap after
>> + * it is specified by the PACKET_RX_RING socket option. This will create a
>> + * circular ring of memory slots. Typical software usage case copies the skb
>> + * into these pages via tpacket_rcv() routine.
>> + *
>> + * Here we do direct DMA from the hardware (82599 in this case) into the
>> + * mmap regions and populate the uhdr (think user space descriptor). This
>> + * requires the hardware to support Scatter Gather and HighDMA which should
>> + * be standard on most 10/40 Gbps devices.
>> + *
>> + * The buffer mapping should have already been done so that rx_buffer pages
>> + * are handed to the driver from the mmap setup done at the socket layer.
>> + *
>> + * This routine may be moved into a generic method later.
>> + *
>> + * See ./include/uapi/linux/if_packet.h for details on packet layout here
>> + * we can only use tpacket2_hdr type. v3 of the header type introduced bulk
>> + * polling modes which do not work correctly with hardware DMA engine. The
>> + * primary issue is we can not stop a DMA transaction from occuring after it
>> + * has been configured. What results is the software timer advances the
>> + * ring ahead of the hardware and the ring state is lost. Maybe there is
>> + * a clever way to resolve this by I haven't thought it up yet.
>> + *
>> + * TBD: integrate timesync with tp_sec, tp_nsec
>> + */
>> +static int ixgbe_do_ddma(struct ixgbe_ring *rx_ring,
>> +             union ixgbe_adv_rx_desc *rx_desc)
>> +{
>> +    struct ixgbe_adapter *adapter = netdev_priv(rx_ring->netdev);
>> +    struct ixgbe_rx_buffer *rx_buffer;
>> +    struct tpacket2_hdr *h2;        /* userspace descriptor */
>> +    struct sockaddr_ll *sll;
>> +    struct ethhdr *eth;
>> +#if 0 /* PTP implementation */
>> +    struct ixgbe_hw *hw = &adapter->hw;
>> +    unsigned long flags;
>> +    u64 regval = 0;
>> +    u32 tsyncrxctl;
>> +#endif
>> +    u64 ns = 0;
>> +    struct page *page;
>> +    int len = 0;
>> +    s32 rem;
>> +
>> +    rx_buffer = &rx_ring->rx_buffer_info[rx_ring->next_to_clean];
>> +
>> +    if (!rx_buffer->dma)
>> +        return -EBUSY;
>> +
>> +    page = rx_buffer->page;
>> +    prefetchw(page);
>> +
>> +    /* This indicates some obscure err case that needs to be handled
>> +     * gracefully
>> +     */
>> +    WARN_ON(ixgbe_test_staterr(rx_desc,
>> +                   IXGBE_RXDADV_ERR_FRAME_ERR_MASK) &&
>> +                   !(rx_ring->netdev->features & NETIF_F_RXALL));
>> +
>> +    dma_sync_single_range_for_cpu(rx_ring->dev,
>> +                      rx_buffer->dma,
>> +                      rx_buffer->page_offset,
>> +                      rx_ring->ddma_size,
>> +                      DMA_FROM_DEVICE);
>> +
>> +#if 0
>> +    /* use PTP for timestamps */
>> +    tsyncrxctl = IXGBE_READ_REG(hw, IXGBE_TSYNCRXCTL);
>> +    if (!(tsyncrxctl & IXGBE_TSYNCRXCTL_VALID)) {
>> +        e_warn(drv, "Direct DMA timestamp error aborting.");
>> +        return 0;
>> +    }
>> +
>> +    regval |= (u64)IXGBE_READ_REG(hw, IXGBE_RXSTMPL);
>> +    regval |= (u64)IXGBE_READ_REG(hw, IXGBE_RXSTMPH) << 32;
>> +
>> +    spin_lock_irqsave(&adapter->tmreg_lock, flags);
>> +    ns = 0; //timecounter_cyc2ns(&adapter->tc, regval); /* TBD */
>> +    spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
>> +#endif
>> +
>> +    /* Update the last_rx_timestamp timer in order to enable watchdog check
>> +     * for error case of latched timestamp on a dropped packet.
>> +     */
>> +    adapter->last_rx_timestamp = jiffies;
>> +
>> +    h2 = page_address(rx_buffer->page) + rx_buffer->hdr;
>> +     eth = page_address(rx_buffer->page) + rx_buffer->page_offset,
>> +
>> +    /* This indicates a bug in ixgbe leaving for testing purposes */
>> +    WARN_ON(TP_STATUS_USER & h2->tp_status);
>> +
>> +    h2->tp_len = len = le16_to_cpu(rx_desc->wb.upper.length);
>> +    h2->tp_snaplen = len;
>> +    h2->tp_mac = ALIGN(TPACKET_ALIGN(TPACKET2_HDRLEN), L1_CACHE_BYTES);
>> +    h2->tp_net = ALIGN(TPACKET_ALIGN(TPACKET2_HDRLEN), L1_CACHE_BYTES) + ETH_HLEN;
>> +    h2->tp_sec = div_s64_rem(ns, NSEC_PER_SEC, &rem);
>> +    h2->tp_nsec = rem;
>> +
>> +    sll = (void *)h2 + TPACKET_ALIGN(sizeof(struct tpacket2_hdr));
>> +    sll->sll_halen = ETH_HLEN;
>> +    memcpy(sll->sll_addr, eth->h_source, ETH_ALEN);
>> +    sll->sll_family = AF_PACKET;
>> +    sll->sll_hatype = rx_ring->netdev->type;
>> +    sll->sll_protocol = eth->h_proto;
>> +    sll->sll_pkttype = PACKET_HOST;
>> +    sll->sll_ifindex = rx_ring->netdev->ifindex;
>> +
>> +    smp_mb();
>> +    h2->tp_status = TP_STATUS_USER;
>> +    rx_ring->sk->sk_data_ready(rx_ring->sk);
>> +
>> +    /* TBD handle non-EOP frames? - I think this is an invalid case
>> +     * assuming ring slots are setup correctly.
>> +     */
>> +    if (ixgbe_is_non_eop(rx_ring, rx_desc, NULL))
>> +        e_warn(drv, "Direct DMA received non-eop descriptor!");
>> +
>> +    return len;
>> +}
>>   static struct sk_buff *ixgbe_fetch_rx_buffer(struct ixgbe_ring *rx_ring,
>>                            union ixgbe_adv_rx_desc *rx_desc)
>>   {
>> @@ -2012,6 +2219,12 @@ static struct sk_buff *ixgbe_fetch_rx_buffer(struct ixgbe_ring *rx_ring,
>>       struct sk_buff *skb;
>>       struct page *page;
>>
>> +    /* Debug stmt to catch logic errors */
>> +    if (rx_ring->ddma) {
>> +        WARN_ON(1);
>> +        return NULL;
>> +    }
>> +
>>       rx_buffer = &rx_ring->rx_buffer_info[rx_ring->next_to_clean];
>>       page = rx_buffer->page;
>>       prefetchw(page);
>> @@ -2119,8 +2332,12 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
>>
>>           /* return some buffers to hardware, one at a time is too slow */
>>           if (cleaned_count >= IXGBE_RX_BUFFER_WRITE) {
>> -            ixgbe_alloc_rx_buffers(rx_ring, cleaned_count);
>> -            cleaned_count = 0;
>> +            if (rx_ring->ddma) {
>> +                cleaned_count = ixgbe_ddma_claim_buffers(rx_ring, cleaned_count);
>> +            } else {
>> +                ixgbe_alloc_rx_buffers(rx_ring, cleaned_count);
>> +                cleaned_count = 0;
>> +            }
>>           }
>>
>>           rx_desc = IXGBE_RX_DESC(rx_ring, rx_ring->next_to_clean);
>> @@ -2135,6 +2352,21 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
>>            */
>>           rmb();
>>
>> +        /* If we use direct DMA to shmem then we do not need SKBs
>> +          * because user space descriptors are populated directly.
>> +          */
>> +        if (rx_ring->ddma) {
>> +            int len = ixgbe_do_ddma(rx_ring, rx_desc);
>> +
>> +            if (len) {
>> +                total_rx_packets++;
>> +                total_rx_bytes += len;
>> +                cleaned_count++;
>> +                continue;
>> +            }
>> +            break;
>> +        }
>> +
>>           /* retrieve a buffer from the ring */
>>           skb = ixgbe_fetch_rx_buffer(rx_ring, rx_desc);
>>
>> @@ -2197,8 +2429,12 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
>>       q_vector->rx.total_packets += total_rx_packets;
>>       q_vector->rx.total_bytes += total_rx_bytes;
>>
>> -    if (cleaned_count)
>> -        ixgbe_alloc_rx_buffers(rx_ring, cleaned_count);
>> +    if (cleaned_count) {
>> +        if (rx_ring->ddma) /* TBD resolve stalls */
>> +            ixgbe_ddma_claim_buffers(rx_ring, cleaned_count);
>> +        else
>> +            ixgbe_alloc_rx_buffers(rx_ring, cleaned_count);
>> +    }
>>
>>       return total_rx_packets;
>>   }
>> @@ -3522,7 +3758,10 @@ void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
>>       IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(reg_idx), rxdctl);
>>
>>       ixgbe_rx_desc_queue_enable(adapter, ring);
>> -    ixgbe_alloc_rx_buffers(ring, ixgbe_desc_unused(ring));
>> +    if (!ring->ddma)
>> +        ixgbe_alloc_rx_buffers(ring, ixgbe_desc_unused(ring));
>> +    else
>> +        ixgbe_ddma_claim_buffers(ring, ixgbe_desc_unused(ring));
>>   }
>>
>>   static void ixgbe_setup_psrtype(struct ixgbe_adapter *adapter)
>> @@ -4435,6 +4674,9 @@ static void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring)
>>       if (!rx_ring->rx_buffer_info)
>>           return;
>>
>> +    if (rx_ring->ddma)
>> +        return;
>> +
>>       /* Free all the Rx ring sk_buffs */
>>       for (i = 0; i < rx_ring->count; i++) {
>>           struct ixgbe_rx_buffer *rx_buffer;
>> @@ -5398,6 +5640,12 @@ int ixgbe_setup_rx_resources(struct ixgbe_ring *rx_ring)
>>       if (rx_ring->q_vector)
>>           numa_node = rx_ring->q_vector->numa_node;
>>
>> +    /* Debug stmt to catch logic errors */
>> +    if (rx_ring->ddma) {
>> +        WARN_ON(1);
>> +        return 0;
>> +    }
>> +
>>       rx_ring->rx_buffer_info = vzalloc_node(size, numa_node);
>>       if (!rx_ring->rx_buffer_info)
>>           rx_ring->rx_buffer_info = vzalloc(size);
>> @@ -5514,6 +5762,12 @@ static void ixgbe_free_all_tx_resources(struct ixgbe_adapter *adapter)
>>    **/
>>   void ixgbe_free_rx_resources(struct ixgbe_ring *rx_ring)
>>   {
>> +    /* Debug stmt to catch logic errors */
>> +    if (rx_ring->ddma) {
>> +        WARN_ON(1);
>> +        return;
>> +    }
>> +
>>       ixgbe_clean_rx_ring(rx_ring);
>>
>>       vfree(rx_ring->rx_buffer_info);
>> @@ -7916,6 +8170,123 @@ static void ixgbe_fwd_del(struct net_device *pdev, void *priv)
>>       kfree(fwd_adapter);
>>   }
>>
>> +static int ixgbe_ddma_map(struct net_device *dev, unsigned int ring,
>> +              struct sock *sk, struct packet_ring_buffer *prb)
>> +{
>> +    struct ixgbe_adapter *adapter = netdev_priv(dev);
>> +    struct ixgbe_ring *rx_ring = adapter->rx_ring[ring];
>> +    unsigned int frames_per_blk = prb->frames_per_block;
>> +    unsigned int blk_nr = prb->pg_vec_len;
>> +    struct ixgbe_rx_buffer *bi;
>> +    int i, j, err = 0;
>> +
>> +    /* Verify we are given a valid ring */
>> +    if (ring >= adapter->num_rx_queues)
>> +        return -EINVAL;
>> +
>> +    /* Verify we have enough descriptors to support user space ring */
>> +    if (!frames_per_blk || ((blk_nr * frames_per_blk) != rx_ring->count)) {
>> +        e_warn(drv, "ddma map requires %i ring slots\n",
>> +               blk_nr * frames_per_blk);
>> +        return -EBUSY;
>> +    }
>> +
>> +    /* Bring the queue down */
>> +    ixgbe_disable_rx_queue(adapter, rx_ring);
>> +    usleep_range(10000, 20000);
>> +    ixgbe_irq_disable_queues(adapter, ((u64)1 << ring));
>> +    ixgbe_clean_rx_ring(rx_ring);
>> +
>> +    rx_ring->ddma_size = prb->frame_size;
>> +
>> +    /* In Direct DMA mode the descriptor block and tpacket headers are
>> +      * held in fixed locations  so we can pre-populate most of the fields.
>> +      * Similarly the pages, offsets, and sizes for DMA are pre-calculated
>> +      * to align with the user space ring and do not need to change.
>> +      *
>> +      * The layout is fixed to match the PF_PACKET layer in /net/packet/
>> +      * which also invokes this routine via ndo_ddma_map().
>> +      */
>> +    for (i = 0; i < blk_nr; i++) {
>> +        char *kaddr = prb->pg_vec[i].buffer;
>> +        //struct tpacket_block_desc *desc;
>> +        unsigned int blk_size;
>> +        struct page *page;
>> +        size_t offset = 0;
>> +        dma_addr_t dma;
>> +
>> +        /* For DMA usage we can't use vmalloc */
>> +        if (is_vmalloc_addr(kaddr)) {
>> +            e_warn(drv, "vmalloc pages not supported in ddma\n");
>> +            err = -EINVAL;
>> +            goto unwind_map;
>> +        }
>> +
>> +        /* map page for use */
>> +        page = virt_to_page(kaddr);
>> +        blk_size = PAGE_SIZE << prb->pg_vec_order;
>> +        dma = dma_map_page(rx_ring->dev,
>> +                   page, 0, blk_size, DMA_FROM_DEVICE);
>> +        if (dma_mapping_error(rx_ring->dev, dma)) {
>> +            e_warn(drv, "ddma dma mapping error DMA_FROM_DEVICE\n");
>> +            rx_ring->rx_stats.alloc_rx_page_failed++;
>> +            err = -EBUSY;
>> +            goto unwind_map;
>> +        }
>> +
>> +        /* We may be able to push multiple frames per block in this case
>> +          * set offset correctly to set pkt_addr correctly in descriptor.
>> +          */
>> +        for (j = 0; j < frames_per_blk; j++) {
>> +            int hdrlen = ALIGN(TPACKET_ALIGN(TPACKET2_HDRLEN), L1_CACHE_BYTES);
>> +            int b = ((i * frames_per_blk) + j);
>> +
>> +            bi = &rx_ring->rx_buffer_info[b];
>> +            bi->hdr = offset;
>> +            bi->page = page;
>> +            bi->dma = dma;
>> +
>> +            /* ignore priv for now */
>> +            bi->page_offset = offset + hdrlen;
>> +
>> +             offset += rx_ring->ddma_size;
>> +        }
>> +    }
>> +
>> +    rx_ring->ddma = true;
>> +    rx_ring->sk = sk;
>> +unwind_map:
>> +    ixgbe_configure_rx_ring(adapter, rx_ring);
>> +    return err;
>> +}
>> +
>> +static void ixgbe_ddma_unmap(struct net_device *dev, unsigned int index)
>> +{
>> +    struct ixgbe_adapter *adapter = netdev_priv(dev);
>> +    struct ixgbe_ring *rx_ring = adapter->rx_ring[index];
>> +    int i;
>> +
>> +    rx_ring->ddma = false;
>> +
>> +    /* Free all the Rx ring sk_buffs */
>> +    for (i = 0; i < rx_ring->count; i++) {
>> +        struct ixgbe_rx_buffer *rx_buffer;
>> +
>> +        rx_buffer = &rx_ring->rx_buffer_info[i];
>> +        if (rx_buffer->dma)
>> +            dma_unmap_page(rx_ring->dev, rx_buffer->dma,
>> +                       rx_buffer->page_offset,
>> +                       DMA_FROM_DEVICE);
>> +        rx_buffer->dma = 0;
>> +        rx_buffer->page_offset = 0;
>> +        rx_buffer->page = NULL;
>> +    }
>> +
>> +    rtnl_lock();
>> +    ixgbe_setup_tc(dev, netdev_get_num_tc(dev));
>> +    rtnl_unlock();
>> +}
>> +
>>   static const struct net_device_ops ixgbe_netdev_ops = {
>>       .ndo_open        = ixgbe_open,
>>       .ndo_stop        = ixgbe_close,
>> @@ -7960,6 +8331,8 @@ static const struct net_device_ops ixgbe_netdev_ops = {
>>       .ndo_bridge_getlink    = ixgbe_ndo_bridge_getlink,
>>       .ndo_dfwd_add_station    = ixgbe_fwd_add,
>>       .ndo_dfwd_del_station    = ixgbe_fwd_del,
>> +    .ndo_ddma_map        = ixgbe_ddma_map,
>> +    .ndo_ddma_unmap        = ixgbe_ddma_unmap,
>>   };
>>
>>   /**
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 774e539..fde9815 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -51,6 +51,8 @@
>>   #include <linux/neighbour.h>
>>   #include <uapi/linux/netdevice.h>
>>
>> +#include <net/af_packet.h>
>> +
>>   struct netpoll_info;
>>   struct device;
>>   struct phy_device;
>> @@ -1144,6 +1146,12 @@ struct net_device_ops {
>>                               struct net_device *dev,
>>                               void *priv);
>>       int            (*ndo_get_lock_subclass)(struct net_device *dev);
>> +    int            (*ndo_ddma_map) (struct net_device *dev,
>> +                         unsigned int rindex,
>> +                         struct sock *sk,
>> +                         struct packet_ring_buffer *rb);
>> +    void            (*ndo_ddma_unmap) (struct net_device *dev,
>> +                           unsigned int rindex);
>>   };
>>
>>   /**
>> diff --git a/include/net/af_packet.h b/include/net/af_packet.h
>> new file mode 100644
>> index 0000000..f1622da
>> --- /dev/null
>> +++ b/include/net/af_packet.h
>> @@ -0,0 +1,62 @@
>> +#include <linux/timer.h>
>> +
>> +struct pgv {
>> +    char *buffer;
>> +};
>> +
>> +/* kbdq - kernel block descriptor queue */
>> +struct tpacket_kbdq_core {
>> +    struct pgv    *pkbdq;
>> +    unsigned int    feature_req_word;
>> +    unsigned int    hdrlen;
>> +    unsigned char    reset_pending_on_curr_blk;
>> +    unsigned char   delete_blk_timer;
>> +    unsigned short    kactive_blk_num;
>> +    unsigned short    blk_sizeof_priv;
>> +
>> +    /* last_kactive_blk_num:
>> +     * trick to see if user-space has caught up
>> +     * in order to avoid refreshing timer when every single pkt arrives.
>> +     */
>> +    unsigned short    last_kactive_blk_num;
>> +
>> +    char        *pkblk_start;
>> +    char        *pkblk_end;
>> +    int        kblk_size;
>> +    unsigned int    knum_blocks;
>> +    uint64_t    knxt_seq_num;
>> +    char        *prev;
>> +    char        *nxt_offset;
>> +    struct sk_buff    *skb;
>> +
>> +    atomic_t    blk_fill_in_prog;
>> +
>> +    /* Default is set to 8ms */
>> +#define DEFAULT_PRB_RETIRE_TOV    (8)
>> +
>> +    unsigned short  retire_blk_tov;
>> +    unsigned short  version;
>> +    unsigned long    tov_in_jiffies;
>> +
>> +    /* timer to retire an outstanding block */
>> +    struct timer_list retire_blk_timer;
>> +};
>> +
>> +struct packet_ring_buffer {
>> +    struct pgv        *pg_vec;
>> +
>> +    unsigned int        head;
>> +    unsigned int        frames_per_block;
>> +    unsigned int        frame_size;
>> +    unsigned int        frame_max;
>> +
>> +    unsigned int        pg_vec_order;
>> +    unsigned int        pg_vec_pages;
>> +    unsigned int        pg_vec_len;
>> +
>> +    unsigned int __percpu    *pending_refcnt;
>> +
>> +    bool            ddma;
>> +
>> +    struct tpacket_kbdq_core    prb_bdqc;
>> +};
>> diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
>> index bac27fa..7db6aba 100644
>> --- a/include/uapi/linux/if_packet.h
>> +++ b/include/uapi/linux/if_packet.h
>> @@ -54,6 +54,7 @@ struct sockaddr_ll {
>>   #define PACKET_FANOUT            18
>>   #define PACKET_TX_HAS_OFF        19
>>   #define PACKET_QDISC_BYPASS        20
>> +#define PACKET_RX_DIRECT        21
>>
>>   #define PACKET_FANOUT_HASH        0
>>   #define PACKET_FANOUT_LB        1
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index b85c67c..6fe0a3b 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -1970,6 +1970,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
>>       }
>>       spin_unlock(&sk->sk_receive_queue.lock);
>>
>> +    /* skb_copy_bits(skb, offset, to, len) */
>>       skb_copy_bits(skb, 0, h.raw + macoff, snaplen);
>>
>>       if (!(ts_status = tpacket_get_timestamp(skb, &ts, po->tp_tstamp)))
>> @@ -3256,6 +3257,37 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
>>           return packet_set_ring(sk, &req_u, 0,
>>               optname == PACKET_TX_RING);
>>       }
>> +    case PACKET_RX_DIRECT:
>> +    {
>> +        struct packet_ring_buffer *rb = &po->rx_ring;
>> +        struct net_device *dev;
>> +        unsigned int index;
>> +        int err;
>> +
>> +        if (optlen != sizeof(index))
>> +            return -EINVAL;
>> +        if (copy_from_user(&index, optval, sizeof(index)))
>> +            return -EFAULT;
>> +
>> +        /* This call only works after a bind call which calls a dev_hold
>> +          * operation so we do not need to increment dev ref counter
>> +          */
>> +        dev = __dev_get_by_index(sock_net(sk), po->ifindex);
>> +        if (!dev)
>> +            return -EINVAL;
>> +
>> +        if (!dev->netdev_ops->ndo_ddma_map)
>> +            return -EOPNOTSUPP;
>> +
>> +        if (!atomic_read(&po->mapped))
>> +            return -EINVAL;
>> +
>> +        err =  dev->netdev_ops->ndo_ddma_map(dev, index, sk, rb);
>> +        if (!err)
>> +            rb->ddma = true;
>> +
>> +        return err;
>> +    }
>>       case PACKET_COPY_THRESH:
>>       {
>>           int val;
>> @@ -3861,6 +3893,15 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
>>           if (atomic_read(&po->mapped))
>>               pr_err("packet_mmap: vma is busy: %d\n",
>>                      atomic_read(&po->mapped));
>> +
>> +        if (rb->ddma) {
>> +            struct net_device *dev =
>> +                __dev_get_by_index(sock_net(sk), po->ifindex);
>> +
>> +            if (dev && dev->netdev_ops->ndo_ddma_map)
>> +                dev->netdev_ops->ndo_ddma_unmap(dev, 0);
>> +            rb->ddma = false;
>> +        }
>>       }
>>       mutex_unlock(&po->pg_vec_lock);
>>
>> diff --git a/net/packet/internal.h b/net/packet/internal.h
>> index eb9580a..6257dab 100644
>> --- a/net/packet/internal.h
>> +++ b/net/packet/internal.h
>> @@ -10,65 +10,6 @@ struct packet_mclist {
>>       unsigned char        addr[MAX_ADDR_LEN];
>>   };
>>
>> -/* kbdq - kernel block descriptor queue */
>> -struct tpacket_kbdq_core {
>> -    struct pgv    *pkbdq;
>> -    unsigned int    feature_req_word;
>> -    unsigned int    hdrlen;
>> -    unsigned char    reset_pending_on_curr_blk;
>> -    unsigned char   delete_blk_timer;
>> -    unsigned short    kactive_blk_num;
>> -    unsigned short    blk_sizeof_priv;
>> -
>> -    /* last_kactive_blk_num:
>> -     * trick to see if user-space has caught up
>> -     * in order to avoid refreshing timer when every single pkt arrives.
>> -     */
>> -    unsigned short    last_kactive_blk_num;
>> -
>> -    char        *pkblk_start;
>> -    char        *pkblk_end;
>> -    int        kblk_size;
>> -    unsigned int    knum_blocks;
>> -    uint64_t    knxt_seq_num;
>> -    char        *prev;
>> -    char        *nxt_offset;
>> -    struct sk_buff    *skb;
>> -
>> -    atomic_t    blk_fill_in_prog;
>> -
>> -    /* Default is set to 8ms */
>> -#define DEFAULT_PRB_RETIRE_TOV    (8)
>> -
>> -    unsigned short  retire_blk_tov;
>> -    unsigned short  version;
>> -    unsigned long    tov_in_jiffies;
>> -
>> -    /* timer to retire an outstanding block */
>> -    struct timer_list retire_blk_timer;
>> -};
>> -
>> -struct pgv {
>> -    char *buffer;
>> -};
>> -
>> -struct packet_ring_buffer {
>> -    struct pgv        *pg_vec;
>> -
>> -    unsigned int        head;
>> -    unsigned int        frames_per_block;
>> -    unsigned int        frame_size;
>> -    unsigned int        frame_max;
>> -
>> -    unsigned int        pg_vec_order;
>> -    unsigned int        pg_vec_pages;
>> -    unsigned int        pg_vec_len;
>> -
>> -    unsigned int __percpu    *pending_refcnt;
>> -
>> -    struct tpacket_kbdq_core    prb_bdqc;
>> -};
>> -
>>   extern struct mutex fanout_mutex;
>>   #define PACKET_FANOUT_MAX    256
>>
>> diff --git a/tools/testing/selftests/net/psock_tpacket.c b/tools/testing/selftests/net/psock_tpacket.c
>> index 24adf70..279d56a 100644
>> --- a/tools/testing/selftests/net/psock_tpacket.c
>> +++ b/tools/testing/selftests/net/psock_tpacket.c
>> @@ -133,6 +133,19 @@ static void status_bar_update(void)
>>       }
>>   }
>>
>> +static void print_payload(void *pay, size_t len)
>> +{
>> +    char *payload = pay;
>> +    int i;
>> +
>> +    printf("payload (bytes %lu): ", len);
>> +    for (i = 0; i < len; i++) {
>> +        printf("0x%02x ", payload[i]);
>> +        if ((i % 32) == 0)
>> +            printf("\n");
>> +    }
>> +}
>> +
>>   static void test_payload(void *pay, size_t len)
>>   {
>>       struct ethhdr *eth = pay;
>> @@ -238,15 +251,15 @@ static void walk_v1_v2_rx(int sock, struct ring *ring)
>>
>>       bug_on(ring->type != PACKET_RX_RING);
>>
>> -    pair_udp_open(udp_sock, PORT_BASE);
>> -    pair_udp_setfilter(sock);
>> +    //pair_udp_open(udp_sock, PORT_BASE);
>> +    //pair_udp_setfilter(sock);
>>
>>       memset(&pfd, 0, sizeof(pfd));
>>       pfd.fd = sock;
>>       pfd.events = POLLIN | POLLERR;
>>       pfd.revents = 0;
>>
>> -    pair_udp_send(udp_sock, NUM_PACKETS);
>> +    //pair_udp_send(udp_sock, NUM_PACKETS);
>>
>>       while (total_packets < NUM_PACKETS * 2) {
>>           while (__v1_v2_rx_kernel_ready(ring->rd[frame_num].iov_base,
>> @@ -263,6 +276,8 @@ static void walk_v1_v2_rx(int sock, struct ring *ring)
>>               case TPACKET_V2:
>>                   test_payload((uint8_t *) ppd.raw + ppd.v2->tp_h.tp_mac,
>>                            ppd.v2->tp_h.tp_snaplen);
>> +                print_payload((uint8_t *) ppd.raw + ppd.v2->tp_h.tp_mac,
>> +                         ppd.v2->tp_h.tp_snaplen);
>>                   total_bytes += ppd.v2->tp_h.tp_snaplen;
>>                   break;
>>               }
>> @@ -273,12 +288,14 @@ static void walk_v1_v2_rx(int sock, struct ring *ring)
>>               __v1_v2_rx_user_ready(ppd.raw, ring->version);
>>
>>               frame_num = (frame_num + 1) % ring->rd_num;
>> +            printf("%i ", frame_num);
>>           }
>>
>> -        poll(&pfd, 1, 1);
>> +        printf("\npolling %i: ", frame_num);
>> +        poll(&pfd, 1, 1000);
>>       }
>>
>> -    pair_udp_close(udp_sock);
>> +    //pair_udp_close(udp_sock);
>>
>>       if (total_packets != 2 * NUM_PACKETS) {
>>           fprintf(stderr, "walk_v%d_rx: received %u out of %u pkts\n",
>> @@ -372,7 +389,7 @@ static void walk_v1_v2_tx(int sock, struct ring *ring)
>>
>>       pair_udp_setfilter(rcv_sock);
>>
>> -    ll.sll_ifindex = if_nametoindex("lo");
>> +    ll.sll_ifindex = if_nametoindex("p3p2");
>>       ret = bind(rcv_sock, (struct sockaddr *) &ll, sizeof(ll));
>>       if (ret == -1) {
>>           perror("bind");
>> @@ -687,7 +704,7 @@ static void bind_ring(int sock, struct ring *ring)
>>
>>       ring->ll.sll_family = PF_PACKET;
>>       ring->ll.sll_protocol = htons(ETH_P_ALL);
>> -    ring->ll.sll_ifindex = if_nametoindex("lo");
>> +    ring->ll.sll_ifindex = if_nametoindex("p3p2");
>>       ring->ll.sll_hatype = 0;
>>       ring->ll.sll_pkttype = 0;
>>       ring->ll.sll_halen = 0;
>> @@ -755,6 +772,19 @@ static const char *type_str[] = {
>>       [PACKET_TX_RING] = "PACKET_TX_RING",
>>   };
>>
>> +void direct_dma_ring(int sock)
>> +{
>> +    int ret;
>> +    int index = 0;
>> +
>> +    ret = setsockopt(sock, SOL_PACKET, PACKET_RX_DIRECT, &index, sizeof(index));
>> +    if (ret < 0)
>> +        printf("Failed direct dma socket with %i\n", ret);
>> +    else
>> +        printf("Configured a direct dma socket!\n");
>> +
>> +}
>> +
>>   static int test_tpacket(int version, int type)
>>   {
>>       int sock;
>> @@ -777,6 +807,7 @@ static int test_tpacket(int version, int type)
>>       setup_ring(sock, &ring, version, type);
>>       mmap_ring(sock, &ring);
>>       bind_ring(sock, &ring);
>> +    direct_dma_ring(sock);
>>       walk_ring(sock, &ring);
>>       unmap_ring(sock, &ring);
>>       close(sock);
>> @@ -789,13 +820,17 @@ int main(void)
>>   {
>>       int ret = 0;
>>
>> +#if 0
>>       ret |= test_tpacket(TPACKET_V1, PACKET_RX_RING);
>>       ret |= test_tpacket(TPACKET_V1, PACKET_TX_RING);
>> +#endif
>>
>>       ret |= test_tpacket(TPACKET_V2, PACKET_RX_RING);
>> +#if 0
>>       ret |= test_tpacket(TPACKET_V2, PACKET_TX_RING);
>>
>>       ret |= test_tpacket(TPACKET_V3, PACKET_RX_RING);
>> +#endif
>>
>>       if (ret)
>>           return 1;
>>
>>
>>
>>
> 
