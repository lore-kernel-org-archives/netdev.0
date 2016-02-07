From: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC RESEND] iwlwifi: pcie: transmit queue auto-sizing
Date: Sun, 7 Feb 2016 12:39:18 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32EA05D67@hasmsx107.ger.corp.intel.com>
References: <1454616764-19841-1-git-send-email-emmanuel.grumbach@intel.com>
 <1454616972-21709-1-git-send-email-emmanuel.grumbach@intel.com>
 <CAA93jw7POqxj6AGVkSc_LCjaeSKbTVBZF+NPqrWgRpT05=JDmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 02/05/2016 12:06 AM, Dave Taht wrote:
> I am not on linux-wireless nor netdev presently, but...
>
> On Thu, Feb 4, 2016 at 12:16 PM, Emmanuel Grumbach
> <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:
>> As many (all?) WiFi devices, Intel WiFi devices have
>> transmit queues which have 256 transmit descriptors
>> each and each descriptor corresponds to an MPDU.
>> This means that when it is full, the queue contains
>> 256 * ~1500 bytes to be transmitted (if we don't have
>> A-MSDUs). The purpose of those queues is to have enough
>> packets to be ready for transmission so that when the device
>> gets an opportunity to transmit (TxOP), it can take as many
>> packets as the spec allows and aggregate them into one
>> A-MPDU or even several A-MPDUs if we are using bursts.
>>
>> The problem is that the packets that are in these queues are
>> already out of control of the Qdisc and can stay in those
>> queues for a fairly long time when the link condition is
>> not good. This leads to the well known bufferbloat problem.
>>
>> This patch adds a way to tune the size of the transmit queue
>> so that it won't cause excessive latency. When the link
>> condition is good, the packets will flow smoothly and the
>> transmit queue will grow quickly allowing A-MPDUs and
>> maximal throughput. When the link is not optimal, we will
>> have retransmissions, lower transmit rates or signal
>> detection (CCA) which will cause a delay in the packet
>> transmission. The driver will sense this higher latency
>> and will reduce the size of the transmit queue.
>> This means that the packets that continue to arrive
>> will pile up in the Qdisc rather than in the device
>> queues. The major advantage of this approach is that
>> codel can now do its work.
>>
>> The algorithm is really (too?) simple:
>> every 5 seconds, starts from a short queue again.
>> If a packet has been in the queue for less than 10ms,
>> allow 10 more MPDUs in.
>> If a packet has been in the queue for more than 20ms,
>> reduce by 10 the size of the transmit queue.
>>
>> The implementation is really naive and way too simple:
>>  * reading jiffies for every Tx / Tx status is not a
>>    good idead.
>>  * jiffies are not fine-grained enough on all platforms
>>  * the constants chosen are really arbitrary and can't be
>>    tuned.
>>  * This may be implemented in mac80211 probably and help
>>    other drivers.
>>  * etc...
>>
>> But already this gives nice results. I ran a very simple
>> experiment: I put the device in a controlled environment
>> and ran traffic while running default sized ping in the
>> background. In this configuration, our device quickly
>> raises its transmission rate to the best rate.
>> Then, I force the device to use the lowest rate (6Mbps).
>> Of course, the throughput collapses, but the ping RTT
>> shoots up.
>> Using codel helps, but the latency is still high. Codel
>> with this patch gives much better results:
>>
>> pfifo_fast:
>> rtt min/avg/max/mdev =3D 1932.616/2393.284/2833.407/315.941 ms, pipe=
 3, ipg/ewma 2215.707/2446.884 ms
>>
>> fq_codel + Tx queue auto-sizing:
>> rtt min/avg/max/mdev =3D 13.541/32.396/54.791/9.610 ms, ipg/ewma 200=
=2E685/32.202 ms
>>
>> fq_codel without Tx queue auto-sizing:
>> rtt min/avg/max/mdev =3D 140.821/257.303/331.889/31.074 ms, pipe 2, =
ipg/ewma 258.147/252.847 ms
> This is a dramatic improvement. But I'm not sure what you are
> measuring. Is this the 6mbit test? What happens when you send traffic
> the other way (more pure acks, rather than big packets?)

Not tested. I only tested the part that I thought was most interesting:
lots of TCP traffic (charriot) with a very low rate and ping in the
background.

>
> I try to encourage folk to use flent whenever possible, for pretty
> graphs and long term measurements, so you can simultaneously measure
> both throughput and latency.
>
> flent.org's .14 release just shipped.


Ok - I hope I'll get some time to give it a try.

>> Clearly, there is more work to do to be able to merge this,
>> but it seems that the wireless problems mentioned in
>> https://lwn.net/Articles/616241/ may have a solution.
> I gave talks on the problems that wifi had with bufferbloat at the
> ieee 802.11 wg meeting a while back, and more recently it was filmed
> at battlemesh.
>
> https://www.youtube.com/watch?v=3DRb-UnHDw02o
>
> I have spent my time since trying to raise sufficient resources
> (testbeds and test tools), orgs, people and money to tackle these
> problems at more depth. We made a bit of progress recently which I ca=
n
> talk about offline...
>
> In that talk I suggested that overall we move towards timestamping
> everything, that (at least in the case of the ath9k and mt72) we tie
> together aggregation with a byte based estimator similar to how BQL
> works, and I hoped that eventually - we'd be able to basically - at
> low rates, keep no more than one aggregate in the hardware, one in th=
e
> driver queue, and one being assembled. The pending aggregate would be
> sent to the hardware on the completion interrupt for the previous
> aggregate, which would fire off the size estimator and start
> aggrefying the one being assembled.
>
> A hook to do that is in use on the mt72 chipset that felix is working
> on... but nowhere else so far as I know (as yet).
>
> the iwl does it's own aggregation (I think(?))... but estimates can
> still be made...
>
> There are WAY more details of course - per station queuing, a separat=
e
> multicast queue, only some in that talk!, but my hope was that under
> good conditions we'd get wireless-n down below 12ms driver overhead,
> even at 6mbit, before something like fq_codel could kick in (under
> good conditions! Plenty of other potential latency sources beside
> excessive queuing in wifi!). My ideal world would be to hold it at
> under 1250us at higher rates....
>
> Periodically sampling seems like a reasonable approach under lab
> conditions but it would be nicer to have feedback from the firmware -
> "I transmitted the last tx as an X byte aggregate, at MCS1, I had to
> retransmit a few packets once, it took me 6ms to acquire the media, I
> heard 3 other stations transmitting, etc.".
>
> The above info we know we can get from a few chipsets, but not enough
> was known about the iwl last I looked. And one reason why fq_codel -
> unassisted - is not quite the right thing on top of this is that
> multicast can take a really long time...
>
> Regardless, I'd highly love to see/use this patch myself in a variety
> of real world conditions and see what happens. And incremental
> progress is the only way forward. Thx for cheering me up.
>
>> Cc: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
>> Cc: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Cc: Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>
>> Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> ---
>> Fix Dave's email address
>> ---
>>  drivers/net/wireless/intel/iwlwifi/pcie/internal.h |  6 ++++
>>  drivers/net/wireless/intel/iwlwifi/pcie/tx.c       | 32 +++++++++++=
+++++++++--
>>  2 files changed, 35 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/wireless/intel/iwlwifi/pcie/internal.h b/dr=
ivers/net/wireless/intel/iwlwifi/pcie/internal.h
>> index 2f95916..d83eb56 100644
>> --- a/drivers/net/wireless/intel/iwlwifi/pcie/internal.h
>> +++ b/drivers/net/wireless/intel/iwlwifi/pcie/internal.h
>> @@ -192,6 +192,11 @@ struct iwl_cmd_meta {
>>         u32 flags;
>>  };
>>
>> +struct iwl_txq_auto_size {
>> +       int min_space;
>> +       unsigned long reset_ts;
>> +};
>> +
>>  /*
>>   * Generic queue structure
>>   *
>> @@ -293,6 +298,7 @@ struct iwl_txq {
>>         bool block;
>>         unsigned long wd_timeout;
>>         struct sk_buff_head overflow_q;
>> +       struct iwl_txq_auto_size auto_sz;
>>  };
>>
>>  static inline dma_addr_t
>> diff --git a/drivers/net/wireless/intel/iwlwifi/pcie/tx.c b/drivers/=
net/wireless/intel/iwlwifi/pcie/tx.c
>> index 837a7d5..4d1dee6 100644
>> --- a/drivers/net/wireless/intel/iwlwifi/pcie/tx.c
>> +++ b/drivers/net/wireless/intel/iwlwifi/pcie/tx.c
>> @@ -572,6 +572,8 @@ static int iwl_pcie_txq_init(struct iwl_trans *t=
rans, struct iwl_txq *txq,
>>
>>         spin_lock_init(&txq->lock);
>>         __skb_queue_head_init(&txq->overflow_q);
>> +       txq->auto_sz.min_space =3D 240;
>> +       txq->auto_sz.reset_ts =3D jiffies;
>>
>>         /*
>>          * Tell nic where to find circular buffer of Tx Frame Descri=
ptors for
>> @@ -1043,10 +1045,14 @@ void iwl_trans_pcie_reclaim(struct iwl_trans=
 *trans, int txq_id, int ssn,
>>              q->read_ptr !=3D tfd_num;
>>              q->read_ptr =3D iwl_queue_inc_wrap(q->read_ptr)) {
>>                 struct sk_buff *skb =3D txq->entries[txq->q.read_ptr=
].skb;
>> +               struct ieee80211_tx_info *info;
>> +               unsigned long tx_time;
>>
>>                 if (WARN_ON_ONCE(!skb))
>>                         continue;
>>
>> +               info =3D IEEE80211_SKB_CB(skb);
>> +
>>                 iwl_pcie_free_tso_page(skb);
>>
>>                 __skb_queue_tail(skbs, skb);
>> @@ -1056,6 +1062,18 @@ void iwl_trans_pcie_reclaim(struct iwl_trans =
*trans, int txq_id, int ssn,
>>                 iwl_pcie_txq_inval_byte_cnt_tbl(trans, txq);
>>
>>                 iwl_pcie_txq_free_tfd(trans, txq);
>> +
>> +               tx_time =3D (uintptr_t)info->driver_data[IWL_TRANS_F=
IRST_DRIVER_DATA + 2];
>> +               if (time_before(jiffies, tx_time + msecs_to_jiffies(=
10))) {
>> +                       txq->auto_sz.min_space -=3D 10;
>> +                       txq->auto_sz.min_space =3D
>> +                               max(txq->auto_sz.min_space, txq->q.h=
igh_mark);
>> +               } else if (time_after(jiffies,
>> +                                     tx_time + msecs_to_jiffies(20)=
)) {
>> +                       txq->auto_sz.min_space +=3D 10;
>> +                       txq->auto_sz.min_space =3D
>> +                               min(txq->auto_sz.min_space, 252);
>> +               }
>>         }
>>
>>         iwl_pcie_txq_progress(txq);
>> @@ -2185,6 +2203,7 @@ int iwl_trans_pcie_tx(struct iwl_trans *trans,=
 struct sk_buff *skb,
>>                       struct iwl_device_cmd *dev_cmd, int txq_id)
>>  {
>>         struct iwl_trans_pcie *trans_pcie =3D IWL_TRANS_GET_PCIE_TRA=
NS(trans);
>> +       struct ieee80211_tx_info *info =3D IEEE80211_SKB_CB(skb);
>>         struct ieee80211_hdr *hdr;
>>         struct iwl_tx_cmd *tx_cmd =3D (struct iwl_tx_cmd *)dev_cmd->=
payload;
>>         struct iwl_cmd_meta *out_meta;
>> @@ -2234,13 +2253,20 @@ int iwl_trans_pcie_tx(struct iwl_trans *tran=
s, struct sk_buff *skb,
>>
>>         spin_lock(&txq->lock);
>>
>> -       if (iwl_queue_space(q) < q->high_mark) {
>> +       info->driver_data[IWL_TRANS_FIRST_DRIVER_DATA + 2] =3D
>> +               (void *)(uintptr_t)jiffies;
>> +
>> +       if (time_after(jiffies,
>> +                      txq->auto_sz.reset_ts + msecs_to_jiffies(5000=
))) {
>> +               txq->auto_sz.min_space =3D 240;
>> +               txq->auto_sz.reset_ts =3D jiffies;
>> +       }
>> +
>> +       if (iwl_queue_space(q) < txq->auto_sz.min_space) {
>>                 iwl_stop_queue(trans, txq);
>>
>>                 /* don't put the packet on the ring, if there is no =
room */
>>                 if (unlikely(iwl_queue_space(q) < 3)) {
>> -                       struct ieee80211_tx_info *info =3D IEEE80211=
_SKB_CB(skb);
>> -
>>                         info->driver_data[IWL_TRANS_FIRST_DRIVER_DAT=
A + 1] =3D
>>                                 dev_cmd;
>>                         __skb_queue_tail(&txq->overflow_q, skb);
>> --
>> 2.5.0
> =3D
> Dave T=E4ht
> Let's go make home routers and wifi faster! With better software!
> https://www.gofundme.com/savewifi
>

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
