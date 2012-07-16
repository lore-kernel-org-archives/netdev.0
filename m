From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [RFC 1/2] PCI-Express Non-Transparent Bridge Support
Date: Mon, 16 Jul 2012 15:27:48 -0400
Message-ID: <CAAsGZS43FkfTFkYnvFdaA+KSLD1ZVBfuFe7_2e7s29_X+rTmug@mail.gmail.com>
References: <1342215900-3358-1-git-send-email-jon.mason@intel.com>
	<CAAsGZS5uMArBVa+Rog1H60FVfKq84eqt5G2dvafDWXTP-RdiwQ@mail.gmail.com>
	<20120716183816.GH9598@jonmason-lab>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120716183816.GH9598@jonmason-lab>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 16, 2012 at 2:38 PM, Jon Mason <jon.mason@intel.com> wrote:
> On Mon, Jul 16, 2012 at 12:49:39PM -0400, chetan loke wrote:

....

>> Is it ok to rename the following vars for convenience sake?
>>
>> > +       struct list_head txq;
>> tx_pend_q - (pending_queue) or tx_out_q - (outstanding_queue) - or
>> pick any new string you like - other than a mono-syllable definition
>>
>> > +       struct list_head txc;
>> tx_compl_q - completion queue
>>
>> > +       struct list_head txe;
>> tx_avail_e - available entry queue
>>
>>
>> > +       spinlock_t txq_lock;
>> > +       spinlock_t txc_lock;
>> > +       spinlock_t txe_lock;
>>
>> then match the variants accordingly.
>>
>> > +       struct list_head rxq;
>> > +       struct list_head rxc;
>> > +       struct list_head rxe;
>> > +       spinlock_t rxq_lock;
>> > +       spinlock_t rxc_lock;
>> > +       spinlock_t rxe_lock;
>>
>> similarly the rx-counterpart
>
> Are they difficult to understand?  I can change them, but it seems rather moot since you seemed to immediately understand the logic behind the names.
>

Immediately understand? Not at first glance. I had to re-read the
functions. Its really is a minor change and variables will then become
self-explanatory. I can almost feel that a developer who works on this
code for the first time might end up choosing the wrong 'syllable' and
locking an entirely different lock.

Infact add a prefix 'ntb' to all the rx/tx locks. That way grep'ing
output of lockstat also becomes easier.

It now reads: ntb_tx_pend_lock

>>
>>
>> ..................
>>
>> > +static void ntb_tx_copy_task(struct ntb_transport_qp *qp,
>> > +                            struct ntb_queue_entry *entry,
>> > +                            void *offset)
>> > +{
>> > +       struct ntb_payload_header *hdr = offset;
>> > +       int rc;
>> > +
>> > +       offset += sizeof(struct ntb_payload_header);
>> > +       memcpy_toio(offset, entry->buf, entry->len);
>> > +
>> > +       hdr->len = entry->len;
>> > +       hdr->ver = qp->tx_pkts;
>> > +
>> > +       /* Ensure that the data is fully copied out before setting the flag */
>> > +       wmb();
>> > +       hdr->flags = entry->flags | DESC_DONE_FLAG;
>> > +
>> > +       rc = ntb_ring_sdb(qp->ndev, qp->qp_num);
>> > +       if (rc)
>> > +               pr_err("%s: error ringing db %d\n", __func__, qp->qp_num);
>> > +
>> > +       if (entry->len > 0) {
>>
>> how do you interpret this len variable and decide if it's a good/bad completion?
>
> The length of 0 is for messages from the remote system, which currently only consists of a "link down" message notifying the local system to no longer send any messages to the remote side.
>

May be I didn't read the code properly. Is there a length-comment that
explains the above? If not then just by pure code inspection it would
seem that a skb was leaked. So add the above comment that way we can
save time for other netdev folks too.


>>
>> > +               qp->tx_bytes += entry->len;
>> > +
>> > +               /* Add fully transmitted data to completion queue */
>> > +               ntb_list_add_tail(&qp->txc_lock, &entry->entry, &qp->txc);
>> > +
>> > +               if (qp->tx_handler)
>> > +                       qp->tx_handler(qp);
>> > +       } else
>> > +               ntb_list_add_tail(&qp->txe_lock, &entry->entry, &qp->txe);
>>
>> I could be wrong but how is the original skb handled if the code path
>> goes in the else clause?
>
> There is no skb is the length is zero.  Since the only client is virtual ethernet, it will always be > 60.  However, I should add a sanity check for 0 length in tx_enqueue.
>
>> Also, in the else clause, how about a ntb_list_add_head rather than a _tail.
>
> Why add to the head, it was just used?

Yes, just re-use what's hot(best guess).

>
>> > +
>> > +static int ntb_process_tx(struct ntb_transport_qp *qp,
>> > +                         struct ntb_queue_entry *entry)
>> > +{
>> > +       struct ntb_payload_header *hdr;
>> > +       void *offset;
>> > +
>> > +       offset = qp->tx_offset;
>> > +       hdr = offset;
>> > +
>> > +       pr_debug("%lld - offset %p, tx %p, entry len %d flags %x buff %p\n",
>> > +                qp->tx_pkts, offset, qp->tx_offset, entry->len, entry->flags,
>> > +                entry->buf);
>> > +       if (hdr->flags) {
>> > +               ntb_list_add_head(&qp->txq_lock, &entry->entry, &qp->txq);
>> > +               qp->tx_ring_full++;
>> > +               return -EAGAIN;
>> > +       }
>> > +
>> > +       if (entry->len > transport_mtu) {
>> > +               pr_err("Trying to send pkt size of %d\n", entry->len);
>> > +               entry->flags = HW_ERROR_FLAG;
>> > +
>> > +               ntb_list_add_tail(&qp->txc_lock, &entry->entry, &qp->txc);
>> > +
>> > +               if (qp->tx_handler)
>> > +                       qp->tx_handler(qp);
>> > +
>> > +               return 0;
>> > +       }
>> > +
>> > +       ntb_tx_copy_task(qp, entry, offset);
>>
>> what happens when ntb_sdb_ring returns an error? would you still want
>> to increment tx_pkts below?
>
> It's not fatal if the remote side isn't notified.  It will hurt latency, since the next packet would be the one that triggers the next interrupt.  Also, the only way it could ever fail would be if it was an invalid interrupt bit being set, which should never happen.
>

What happens when the 'db >= ndev->max_cbs' check fails? Under what
circumstances will that happen? When it does happen how does the
remote side then gets notified or should it even get notified?

'which should never happen'? FYI - I have seen and debugged(not this
one but doorbells and what not) weirdness while working on CLARiiON +
PCie-interconnects. Board bring-up is a PITA. So you get the idea ...

>>
>> > +void *ntb_transport_tx_dequeue(struct ntb_transport_qp *qp, unsigned int *len)
>> > +{
>> > +       struct ntb_queue_entry *entry;
>> > +       void *buf;
>> > +
>> > +       if (!qp)
>> > +               return NULL;
>> > +
>> > +       entry = ntb_list_rm_head(&qp->txc_lock, &qp->txc);
>> > +       if (!entry)
>> > +               return NULL;
>> > +
>> > +       buf = entry->callback_data;
>> > +       if (entry->flags != HW_ERROR_FLAG)
>> > +               *len = entry->len;
>> > +       else
>> > +               *len = -EIO;
>> > +
>> > +       ntb_list_add_tail(&qp->txe_lock, &entry->entry, &qp->txe);
>>
>> how about a ntb_list_add_head?
>
> Is there a benefit to adding to the head versus tail?  It makes more sense to me to pull from the head and add to the tail.
>

Yes, explained above. Today there are 100(..DEF_NUM...) entries.
Tomorrow there could be more. So why not re-use what's hot? You could
also think of this as yet another way of forcing detection of
double-use corruption/bug. I'm not saying that there's a bug here but
you get the idea.

Chetan Loke
