From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net-qdisc-hhf: Heavy-Hitter Filter (HHF) qdisc
Date: Wed, 11 Dec 2013 15:50:43 -0800
Message-ID: <CA+mtBx_-Wh1EwCw6Sa6eO8J9q2+fm640d0J74JP0-fzWteTWHA@mail.gmail.com>
References: <1386746796-490-1-git-send-email-vtlam@google.com>
	<20131211123710.62b9c7ce@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Terry Lam <vtlam@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:64457 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380Ab3LKXun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 18:50:43 -0500
Received: by mail-ie0-f179.google.com with SMTP id x13so12310126ief.38
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 15:50:43 -0800 (PST)
In-Reply-To: <20131211123710.62b9c7ce@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 11, 2013 at 12:37 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Tue, 10 Dec 2013 23:26:36 -0800
> Terry Lam <vtlam@google.com> wrote:
>
>> This patch implements the first size-based qdisc that attempts to
>> differentiate between small flows and heavy-hitters.  The goal is to
>> catch the heavy-hitters and move them to a separate queue with less
>> priority so that bulk traffic does not affect the latency of critical
>> traffic.  Currently "less priority" means less weight (2:1 in
>> particular) in a Weighted Deficit Round Robin (WDRR) scheduler.
>>
>> In essence, this patch addresses the "delay-bloat" problem due to
>> bloated buffers. In some systems, large queues may be necessary for
>> obtaining CPU efficiency, or due to the presence of unresponsive
>> traffic like UDP, or just a large number of connections with each
>> having a small amount of outstanding traffic. In these circumstances,
>> HHF aims to reduce the HoL blocking for latency sensitive traffic,
>> while not impacting the queues built up by bulk traffic.  HHF can also
>> be used in conjunction with other AQM mechanisms such as CoDel.
>>
>> To capture heavy-hitters, we implement the "multi-stage filter" design
>> in the following paper:
>> C. Estan and G. Varghese, "New Directions in Traffic Measurement and
>> Accounting", in ACM SIGCOMM, 2002.
>>
>> Some configurable qdisc settings through 'tc':
>> - hhf_reset_timeout: period to reset counter values in the multi-stage
>>                      filter (default 40ms)
>> - hhf_admit_bytes:   threshold to classify heavy-hitters
>>                      (default 128KB)
>> - hhf_evict_timeout: threshold to evict idle heavy-hitters
>>                      (default 1s)
>> - hhf_non_hh_weight: Weighted Deficit Round Robin (WDRR) weight for
>>                      non-heavy-hitters (default 2)
>> - hh_flows_limit:    max number of heavy-hitter flow entries
>>                      (default 2048)
>>
>> Note that the ratio between hhf_admit_bytes and hhf_reset_timeout
>> reflects the bandwidth of heavy-hitters that we attempt to capture
>> (25Mbps with the above default settings).
>>
>> The false negative rate (heavy-hitter flows getting away unclassified)
>> is zero by the design of the multi-stage filter algorithm.
>> With 100 heavy-hitter flows, using four hashes and 4000 counters yields
>> a false positive rate (non-heavy-hitters mistakenly classified as
>> heavy-hitters) of less than 1e-4.
>>
>> Signed-off-by: Terry Lam <vtlam@google.com>
>> ---
>>  include/uapi/linux/pkt_sched.h |  25 ++
>>  net/sched/Kconfig              |   9 +
>>  net/sched/Makefile             |   1 +
>>  net/sched/sch_hhf.c            | 746 +++++++++++++++++++++++++++++++++++++++++
>>  4 files changed, 781 insertions(+)
>>  create mode 100644 net/sched/sch_hhf.c
>>
>> diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
>> index a806687..4566993 100644
>> --- a/include/uapi/linux/pkt_sched.h
>> +++ b/include/uapi/linux/pkt_sched.h
>> @@ -790,4 +790,29 @@ struct tc_fq_qd_stats {
>>       __u32   throttled_flows;
>>       __u32   pad;
>>  };
>> +
>> +/* Heavy-Hitter Filter */
>> +
>> +enum {
>> +     TCA_HHF_UNSPEC,
>> +     TCA_HHF_BACKLOG_LIMIT,
>> +     TCA_HHF_QUANTUM,
>> +     TCA_HHF_HH_FLOWS_LIMIT,
>> +     TCA_HHF_RESET_TIMEOUT,
>> +     TCA_HHF_ADMIT_BYTES,
>> +     TCA_HHF_EVICT_TIMEOUT,
>> +     TCA_HHF_NON_HH_WEIGHT,
>> +     __TCA_HHF_MAX
>> +};
>> +
>> +#define TCA_HHF_MAX  (__TCA_HHF_MAX - 1)
>> +
>> +struct tc_hhf_xstats {
>> +     __u32   drop_overlimit; /* number of times max qdisc packet limit
>> +                              * was hit
>> +                              */
>
> 64 bit?
>
>> +     __u32   hh_overlimit;   /* number of times max heavy-hitters was hit */
>> +     __u32   hh_tot_count;   /* number of captured heavy-hitters so far */
>> +     __u32   hh_cur_count;   /* number of current heavy-hitters */
>> +};
>>  #endif
>
>
>
>> diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
>> new file mode 100644
>> index 0000000..91c723e
>> --- /dev/null
>> +++ b/net/sched/sch_hhf.c
>> @@ -0,0 +1,746 @@
>
>> +#define hhf_time_before(a, b)        \
>> +     (typecheck(u32, a) && typecheck(u32, b) && ((s32)((a) - (b)) < 0))
>
> Why reinvent time_before?
>
>> +
>> +/* Heavy-hitter per-flow state */
>> +struct hh_flow_state {
>> +     u32              hash_id;       /* hash of flow-id (e.g. TCP 5-tuple) */
>> +     u32              hit_timestamp; /* last time heavy-hitter was seen */
>> +     struct list_head flowchain;     /* chaining under hash collision */
>> +};
>> +
>> +/* Weighted Deficit Round Robin (WDRR) scheduler */
>> +struct wdrr_bucket {
>> +     struct sk_buff    *head;
>> +     struct sk_buff    *tail;
>> +     struct list_head  bucketchain;
>> +     int               deficit;
>> +};
>> +
>> +struct hhf_sched_data {
>> +     struct wdrr_bucket buckets[WDRR_BUCKET_CNT];
>> +     u32                perturbation;   /* hash perturbation */
>> +     u32                quantum;        /* psched_mtu(qdisc_dev(sch)); */
>> +     u32                drop_overlimit; /* number of times max qdisc packet
>> +                                         * limit was hit
>> +                                         */
>> +     struct list_head   *hh_flows;       /* table T (currently active HHs) */
>> +     u32                hh_flows_limit;            /* max active HH allocs */
>> +     u32                hh_flows_overlimit; /* num of disallowed HH allocs */
>> +     u32                hh_flows_total_cnt;          /* total admitted HHs */
>> +     u32                hh_flows_current_cnt;        /* total current HHs  */
>> +     u32                *hhf_arrays[HHF_ARRAYS_CNT]; /* HH filter F */
>> +     u32                hhf_arrays_reset_timestamp;  /* last time hhf_arrays
>> +                                                      * was reset
>> +                                                      */
>> +     unsigned long      *hhf_valid_bits[HHF_ARRAYS_CNT]; /* shadow valid bits
>> +                                                          * of hhf_arrays
>> +                                                          */
>> +     /* Similar to the "new_flows" vs. "old_flows" concept in fq_codel DRR */
>> +     struct list_head   new_buckets; /* list of new buckets */
>> +     struct list_head   old_buckets; /* list of old buckets */
>> +
>> +     /* Configurable HHF parameters */
>> +     u32                hhf_reset_timeout; /* interval to reset counter
>> +                                            * arrays in filter F
>> +                                            * (default 40ms)
>> +                                            */
>> +     u32                hhf_admit_bytes;   /* counter thresh to classify as
>> +                                            * HH (default 128KB).
>> +                                            * With these default values,
>> +                                            * 128KB / 40ms = 25 Mbps
>> +                                            * i.e., we expect to capture HHs
>> +                                            * sending > 25 Mbps.
>> +                                            */
>> +     u32                hhf_evict_timeout; /* aging threshold to evict idle
>> +                                            * HHs out of table T. This should
>> +                                            * be large enough to avoid
>> +                                            * reordering during HH eviction.
>> +                                            * (default 1s)
>> +                                            */
>> +     u32                hhf_non_hh_weight; /* WDRR weight for non-HHs
>> +                                            * (default 2,
>> +                                            *  i.e., non-HH : HH = 2 : 1)
>> +                                            */
>> +};
>> +
>> +static inline u32 hhf_time_stamp(void)
>> +{
>> +     return jiffies;
>> +}
>
> Why wrap jiffies needlessly
>
>
>> +static unsigned int skb_hash(const struct hhf_sched_data *q,
>> +                          const struct sk_buff *skb)
>> +{
>> +     struct flow_keys keys;
>> +     unsigned int hash;
>> +
>> +     if (skb->sk && skb->sk->sk_hash)
>> +             return skb->sk->sk_hash;
>> +
>> +     skb_flow_dissect(skb, &keys);
>> +     hash = jhash_3words((__force u32)keys.dst,
>> +                         (__force u32)keys.src ^ keys.ip_proto,
>> +                         (__force u32)keys.ports, q->perturbation);
>> +     return hash;
>> +}
>
> Why not reuse flow dissect logic that exists in SFQ?
>
This could be a library function to to get the "txhash" for an skb,
most of it should also be in a common function with __skb_get_rxhash.
Does not applying the perturbation in the case of a hash in the socket
cause a loss of functionality?

>
>> +/* Looks up a heavy-hitter flow in a chaining list of table T. */
>> +static inline struct hh_flow_state *seek_list(const u32 hash,
>> +                                           struct list_head *head,
>> +                                           struct hhf_sched_data *q)
>
> Don't use inline. Let compiler decide.
>
>> +{
>> +     struct hh_flow_state *flow, *next;
>> +     u32 now = hhf_time_stamp();
>> +
>> +     if (list_empty(head))
>> +             return NULL;
>> +
>> +     list_for_each_entry_safe(flow, next, head, flowchain) {
>> +             u32 prev = flow->hit_timestamp + q->hhf_evict_timeout;
>> +
>> +             if (hhf_time_before(prev, now)) {
>> +                     /* Delete expired heavy-hitters, but preserve one entry
>> +                      * to avoid kzalloc() when next time this slot is hit.
>> +                      */
>> +                     if (list_is_last(&flow->flowchain, head))
>> +                             return NULL;
>> +                     list_del(&flow->flowchain);
>> +                     kfree(flow);
>> +                     q->hh_flows_current_cnt--;
>> +             } else if (flow->hash_id == hash) {
>> +                     return flow;
>> +             }
>> +     }
>> +     return NULL;
>> +}
>> +
>> +/* Returns a flow state entry for a new heavy-hitter.  Either reuses an expired
>> + * entry or dynamically alloc a new entry.
>> + */
>> +static inline struct hh_flow_state *alloc_new_hh(struct list_head *head,
>> +                                              struct hhf_sched_data *q)
>> +{
>> +     struct hh_flow_state *flow;
>> +     u32 now = hhf_time_stamp();
>> +
>> +     if (!list_empty(head)) {
>> +             /* Find an expired heavy-hitter flow entry. */
>> +             list_for_each_entry(flow, head, flowchain) {
>> +                     u32 prev = flow->hit_timestamp + q->hhf_evict_timeout;
>> +
>> +                     if (hhf_time_before(prev, now))
>> +                             return flow;
>> +             }
>> +     }
>> +
>> +     if (q->hh_flows_current_cnt >= q->hh_flows_limit) {
>> +             q->hh_flows_overlimit++;
>> +             return NULL;
>> +     }
>> +     /* Create new entry. */
>> +     flow = kzalloc(sizeof(struct hh_flow_state), GFP_ATOMIC);
>> +     if (!flow)
>> +             return NULL;
>> +
>> +     q->hh_flows_current_cnt++;
>> +     INIT_LIST_HEAD(&flow->flowchain);
>> +     list_add_tail(&flow->flowchain, head);
>> +
>> +     return flow;
>> +}
>> +
>> +/* Assigns packets to WDRR buckets.  Implements a multi-stage filter to
>> + * classify heavy-hitters.
>> + */
>> +static enum wdrr_bucket_idx hhf_classify(struct sk_buff *skb, struct Qdisc *sch)
>> +{
>> +     struct hhf_sched_data *q = qdisc_priv(sch);
>> +     u32 tmp_hash, hash;
>> +     u32 xorsum, filter_pos[HHF_ARRAYS_CNT], flow_pos;
>> +     struct hh_flow_state *flow;
>> +     u32 pkt_len, min_hhf_val;
>> +     int i;
>> +     u32 prev;
>> +     u32 now = hhf_time_stamp();
>> +
>> +     /* Reset the HHF counter arrays if this is the right time. */
>> +     prev = q->hhf_arrays_reset_timestamp + q->hhf_reset_timeout;
>> +     if (hhf_time_before(prev, now)) {
>> +             for (i = 0; i < HHF_ARRAYS_CNT; i++)
>> +                     bitmap_zero(q->hhf_valid_bits[i], HHF_ARRAYS_LEN);
>> +             q->hhf_arrays_reset_timestamp = now;
>> +     }
>> +
>> +     /* Get hashed flow-id of the skb. */
>> +     hash = skb_hash(q, skb);
>> +
>> +     /* Check if this packet belongs to an already established HH flow. */
>> +     flow_pos = hash & HHF_BIT_MASK;
>> +     flow = seek_list(hash, &q->hh_flows[flow_pos], q);
>> +     if (flow) { /* found its HH flow */
>> +             flow->hit_timestamp = now;
>> +             return WDRR_BUCKET_FOR_HH;
>> +     }
>> +
>> +     /* Now pass the packet through the multi-stage filter. */
>> +     tmp_hash = hash;
>> +     xorsum = 0;
>> +     for (i = 0; i < HHF_ARRAYS_CNT - 1; i++) {
>> +             /* Split the skb_hash into three 10-bit chunks. */
>> +             filter_pos[i] = tmp_hash & HHF_BIT_MASK;
>> +             xorsum ^= filter_pos[i];
>> +             tmp_hash >>= HHF_BIT_MASK_LEN;
>> +     }
>> +     /* The last chunk is computed as XOR sum of other chunks. */
>> +     filter_pos[HHF_ARRAYS_CNT - 1] = xorsum ^ tmp_hash;
>> +
>> +     pkt_len = qdisc_pkt_len(skb);
>> +     min_hhf_val = ~0U;
>> +     for (i = 0; i < HHF_ARRAYS_CNT; i++) {
>> +             u32 val;
>> +
>> +             if (!test_bit(filter_pos[i], q->hhf_valid_bits[i])) {
>> +                     q->hhf_arrays[i][filter_pos[i]] = 0;
>> +                     __set_bit(filter_pos[i], q->hhf_valid_bits[i]);
>> +             }
>> +
>> +             val = q->hhf_arrays[i][filter_pos[i]] + pkt_len;
>> +             if (min_hhf_val > val)
>> +                     min_hhf_val = val;
>> +     }
>> +
>> +     /* Found a new HH iff all counter values > HH admit threshold. */
>> +     if (min_hhf_val > q->hhf_admit_bytes) {
>> +             /* Just captured a new heavy-hitter. */
>> +             flow = alloc_new_hh(&q->hh_flows[flow_pos], q);
>> +             if (!flow) /* memory alloc problem */
>> +                     return WDRR_BUCKET_FOR_NON_HH;
>> +             flow->hash_id = hash;
>> +             flow->hit_timestamp = now;
>> +             q->hh_flows_total_cnt++;
>> +
>> +             /* By returning without updating counters in q->hhf_arrays,
>> +              * we implicitly implement "shielding" (see Optimization O1).
>> +              */
>> +             return WDRR_BUCKET_FOR_HH;
>> +     }
>> +
>> +     /* Conservative update of HHF arrays (see Optimization O2). */
>> +     for (i = 0; i < HHF_ARRAYS_CNT; i++) {
>> +             if (q->hhf_arrays[i][filter_pos[i]] < min_hhf_val)
>> +                     q->hhf_arrays[i][filter_pos[i]] = min_hhf_val;
>> +     }
>> +     return WDRR_BUCKET_FOR_NON_HH;
>> +}
>> +
>> +/* Removes one skb from head of bucket. */
>> +static inline struct sk_buff *dequeue_head(struct wdrr_bucket *bucket)
>> +{
>> +     struct sk_buff *skb = bucket->head;
>> +
>> +     bucket->head = skb->next;
>> +     skb->next = NULL;
>> +     return skb;
>> +}
>
> Seems like reinvention of sk_list??
>
>> +
>> +/* Tail-adds skb to bucket. */
>> +static inline void bucket_add(struct wdrr_bucket *bucket, struct sk_buff *skb)
>> +{
>> +     if (bucket->head == NULL)
>> +             bucket->head = skb;
>> +     else
>> +             bucket->tail->next = skb;
>> +     bucket->tail = skb;
>> +     skb->next = NULL;
>> +}
>> +
>> +static unsigned int hhf_drop(struct Qdisc *sch)
>> +{
>> +     struct hhf_sched_data *q = qdisc_priv(sch);
>> +     struct wdrr_bucket *bucket;
>> +
>> +     /* Always try to drop from heavy-hitters first. */
>> +     bucket = &q->buckets[WDRR_BUCKET_FOR_HH];
>> +     if (!bucket->head)
>> +             bucket = &q->buckets[WDRR_BUCKET_FOR_NON_HH];
>> +
>> +     if (bucket->head) {
>> +             struct sk_buff *skb = dequeue_head(bucket);
>> +
>> +             sch->q.qlen--;
>> +             sch->qstats.drops++;
>> +             sch->qstats.backlog -= qdisc_pkt_len(skb);
>> +             kfree_skb(skb);
>> +     }
>> +
>> +     /* Return id of the bucket from which the packet was dropped. */
>> +     return bucket - q->buckets;
>> +}
>> +
>> +static int hhf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>> +{
>> +     struct hhf_sched_data *q = qdisc_priv(sch);
>> +     enum wdrr_bucket_idx idx;
>> +     struct wdrr_bucket *bucket;
>> +
>> +     idx = hhf_classify(skb, sch);
>> +
>> +     bucket = &q->buckets[idx];
>> +     bucket_add(bucket, skb);
>> +     sch->qstats.backlog += qdisc_pkt_len(skb);
>> +
>> +     if (list_empty(&bucket->bucketchain)) {
>> +             unsigned int weight;
>> +
>> +             /* The logic of new_buckets vs. old_buckets is the same as
>> +              * new_flows vs. old_flows in the implementation of fq_codel,
>> +              * i.e., short bursts of non-HHs should have strict priority.
>> +              */
>> +             if (idx == WDRR_BUCKET_FOR_HH) {
>> +                     /* Always move heavy-hitters to old bucket. */
>> +                     weight = 1;
>> +                     list_add_tail(&bucket->bucketchain, &q->old_buckets);
>> +             } else {
>> +                     weight = q->hhf_non_hh_weight;
>> +                     list_add_tail(&bucket->bucketchain, &q->new_buckets);
>> +             }
>> +             bucket->deficit = weight * q->quantum;
>> +     }
>> +     if (++sch->q.qlen < sch->limit)
>> +             return NET_XMIT_SUCCESS;
>> +
>> +     q->drop_overlimit++;
>> +     /* Return Congestion Notification only if we dropped a packet from this
>> +      * bucket.
>> +      */
>> +     if (hhf_drop(sch) == idx)
>> +             return NET_XMIT_CN;
>> +
>> +     /* As we dropped a packet, better let upper stack know this. */
>> +     qdisc_tree_decrease_qlen(sch, 1);
>> +     return NET_XMIT_SUCCESS;
>> +}
>> +
>> +static struct sk_buff *hhf_dequeue(struct Qdisc *sch)
>> +{
>> +     struct hhf_sched_data *q = qdisc_priv(sch);
>> +     struct sk_buff *skb = NULL;
>> +     struct wdrr_bucket *bucket;
>> +     struct list_head *head;
>> +
>> +begin:
>> +     head = &q->new_buckets;
>> +     if (list_empty(head)) {
>> +             head = &q->old_buckets;
>> +             if (list_empty(head))
>> +                     return NULL;
>> +     }
>> +     bucket = list_first_entry(head, struct wdrr_bucket, bucketchain);
>> +
>> +     if (bucket->deficit <= 0) {
>> +             int weight = (bucket - q->buckets == WDRR_BUCKET_FOR_HH) ?
>> +                           1 : q->hhf_non_hh_weight;
>> +
>> +             bucket->deficit += weight * q->quantum;
>> +             list_move_tail(&bucket->bucketchain, &q->old_buckets);
>> +             goto begin;
>> +     }
>> +
>> +     if (bucket->head) {
>> +             skb = dequeue_head(bucket);
>> +             sch->q.qlen--;
>> +             sch->qstats.backlog -= qdisc_pkt_len(skb);
>> +     }
>> +
>> +     if (!skb) {
>> +             /* Force a pass through old_buckets to prevent starvation. */
>> +             if ((head == &q->new_buckets) && !list_empty(&q->old_buckets))
>> +                     list_move_tail(&bucket->bucketchain, &q->old_buckets);
>> +             else
>> +                     list_del_init(&bucket->bucketchain);
>> +             goto begin;
>> +     }
>> +     qdisc_bstats_update(sch, skb);
>> +     bucket->deficit -= qdisc_pkt_len(skb);
>> +
>> +     return skb;
>> +}
>> +
>> +static void hhf_reset(struct Qdisc *sch)
>> +{
>> +     struct sk_buff *skb;
>> +
>> +     while ((skb = hhf_dequeue(sch)) != NULL)
>> +             kfree_skb(skb);
>> +}
>> +
>> +static void *hhf_zalloc(size_t sz)
>> +{
>> +     void *ptr = kzalloc(sz, GFP_KERNEL | __GFP_NOWARN);
>> +
>> +     if (!ptr)
>> +             ptr = vzalloc(sz);
>> +
>> +     return ptr;
>> +}
>
> Are you really allocating thing so big that kmalloc fails?
> If so, please base it on size > PAGE_SIZE
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
