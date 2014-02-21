From: Andrew Bennieston <andrew.bennieston@citrix.com>
Subject: Re: [PATCH V4 net-next 1/5] xen-netback: Factor queue-specific data
 into queue struct.
Date: Fri, 21 Feb 2014 12:22:48 +0000
Message-ID: <53074518.5010506@citrix.com>
References: <1392659880-2538-1-git-send-email-andrew.bennieston@citrix.com> <1392659880-2538-2-git-send-email-andrew.bennieston@citrix.com> <9AAE0902D5BC7E449B7C8E4E778ABCD02552E8@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <Paul.Durrant@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:13935 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754824AbaBUMWu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Feb 2014 07:22:50 -0500
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD02552E8@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/02/14 12:08, Paul Durrant wrote:
>> -----Original Message-----
>> From: Andrew J. Bennieston [mailto:andrew.bennieston@citrix.com]
>> Sent: 17 February 2014 17:58
>> To: xen-devel@lists.xenproject.org
>> Cc: Ian Campbell; Wei Liu; Paul Durrant; netdev@vger.kernel.org; David
>> Vrabel; Andrew Bennieston
>> Subject: [PATCH V4 net-next 1/5] xen-netback: Factor queue-specific data
>> into queue struct.
>>
>> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
>>
>> In preparation for multi-queue support in xen-netback, move the
>> queue-specific data from struct xenvif into struct xenvif_queue, and
>> update the rest of the code to use this.
>>
>> Also adds loops over queues where appropriate, even though only one is
>> configured at this point, and uses alloc_netdev_mq() and the
>> corresponding multi-queue netif wake/start/stop functions in preparation
>> for multiple active queues.
>>
>> Finally, implements a trivial queue selection function suitable for
>> ndo_select_queue, which simply returns 0 for a single queue and uses
>> skb_get_hash() to compute the queue index otherwise.
>>
>> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
>> ---
>>   drivers/net/xen-netback/common.h    |   81 ++++--
>>   drivers/net/xen-netback/interface.c |  314 ++++++++++++++-------
>>   drivers/net/xen-netback/netback.c   |  528 ++++++++++++++++++------------
>> -----
>>   drivers/net/xen-netback/xenbus.c    |   87 ++++--
>>   4 files changed, 593 insertions(+), 417 deletions(-)
>>
>> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-
>> netback/common.h
>> index ae413a2..2550867 100644
>> --- a/drivers/net/xen-netback/common.h
>> +++ b/drivers/net/xen-netback/common.h
>> @@ -108,17 +108,36 @@ struct xenvif_rx_meta {
>>    */
>>   #define MAX_GRANT_COPY_OPS (MAX_SKB_FRAGS *
>> XEN_NETIF_RX_RING_SIZE)
>>
>> -struct xenvif {
>> -	/* Unique identifier for this interface. */
>> -	domid_t          domid;
>> -	unsigned int     handle;
>> +/* Queue name is interface name with "-qNNN" appended */
>> +#define QUEUE_NAME_SIZE (IFNAMSIZ + 6)
>> +
>
> '-qNNN' is only 5 chars. Are you accounting for a NUL terminator too?

Almost certainly...

>
>> +/* IRQ name is queue name with "-tx" or "-rx" appended */
>> +#define IRQ_NAME_SIZE (QUEUE_NAME_SIZE + 4)
>> +
>
> If yes, then you appear to have doubly accounted for it here.

... yup, looks that way. I'll fix this.

>
>> +struct xenvif;
>> +
>> +struct xenvif_stats {
>> +	/* Stats fields to be updated per-queue.
>> +	 * A subset of struct net_device_stats that contains only the
>> +	 * fields that are updated in netback.c for each queue.
>> +	 */
>> +	unsigned int rx_bytes;
>> +	unsigned int rx_packets;
>> +	unsigned int tx_bytes;
>> +	unsigned int tx_packets;
>> +};
>> +
>> +struct xenvif_queue { /* Per-queue data for xenvif */
>> +	unsigned int id; /* Queue ID, 0-based */
>> +	char name[QUEUE_NAME_SIZE]; /* DEVNAME-qN */
>> +	struct xenvif *vif; /* Parent VIF */
>>
>>   	/* Use NAPI for guest TX */
>>   	struct napi_struct napi;
>>   	/* When feature-split-event-channels = 0, tx_irq = rx_irq. */
>>   	unsigned int tx_irq;
>>   	/* Only used when feature-split-event-channels = 1 */
>> -	char tx_irq_name[IFNAMSIZ+4]; /* DEVNAME-tx */
>> +	char tx_irq_name[IRQ_NAME_SIZE]; /* DEVNAME-qN-tx */
>>   	struct xen_netif_tx_back_ring tx;
>>   	struct sk_buff_head tx_queue;
>>   	struct page *mmap_pages[MAX_PENDING_REQS];
>> @@ -140,19 +159,34 @@ struct xenvif {
>>   	/* When feature-split-event-channels = 0, tx_irq = rx_irq. */
>>   	unsigned int rx_irq;
>>   	/* Only used when feature-split-event-channels = 1 */
>> -	char rx_irq_name[IFNAMSIZ+4]; /* DEVNAME-rx */
>> +	char rx_irq_name[IRQ_NAME_SIZE]; /* DEVNAME-qN-rx */
>>   	struct xen_netif_rx_back_ring rx;
>>   	struct sk_buff_head rx_queue;
>>   	RING_IDX rx_last_skb_slots;
>>
>> -	/* This array is allocated seperately as it is large */
>> -	struct gnttab_copy *grant_copy_op;
>> +	struct gnttab_copy grant_copy_op[MAX_GRANT_COPY_OPS];
>>
>>   	/* We create one meta structure per ring request we consume, so
>>   	 * the maximum number is the same as the ring size.
>>   	 */
>>   	struct xenvif_rx_meta meta[XEN_NETIF_RX_RING_SIZE];
>>
>> +	/* Transmit shaping: allow 'credit_bytes' every 'credit_usec'. */
>> +	unsigned long   credit_bytes;
>> +	unsigned long   credit_usec;
>> +	unsigned long   remaining_credit;
>> +	struct timer_list credit_timeout;
>> +	u64 credit_window_start;
>> +
>> +	/* Statistics */
>> +	struct xenvif_stats stats;
>> +};
>> +
>> +struct xenvif {
>> +	/* Unique identifier for this interface. */
>> +	domid_t          domid;
>> +	unsigned int     handle;
>> +
>>   	u8               fe_dev_addr[6];
>>
>>   	/* Frontend feature information. */
>> @@ -166,15 +200,12 @@ struct xenvif {
>>   	/* Internal feature information. */
>>   	u8 can_queue:1;	    /* can queue packets for receiver? */
>>
>> -	/* Transmit shaping: allow 'credit_bytes' every 'credit_usec'. */
>> -	unsigned long   credit_bytes;
>> -	unsigned long   credit_usec;
>> -	unsigned long   remaining_credit;
>> -	struct timer_list credit_timeout;
>> -	u64 credit_window_start;
>> +	/* Queues */
>> +	unsigned int num_queues;
>> +	struct xenvif_queue *queues;
>>
>>   	/* Statistics */
>> -	unsigned long rx_gso_checksum_fixup;
>> +	atomic_t rx_gso_checksum_fixup;
>
> Any reason why this is not in xenvif_stats? If  it were there then it would not need to be atomic.
The expectation was that it wouldn't be used very often, so an atomic 
op. here wouldn't hurt. I can move it to xenvif_stats if you'd prefer, 
though. I think the use of an atomic pre-dated the xenvif_stats struct, 
so maybe it makes sense to move it there now.

Andrew.

>
>    Paul
>
