From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [RFC 1/2] PCI-Express Non-Transparent Bridge Support
Date: Mon, 16 Jul 2012 12:49:39 -0400
Message-ID: <CAAsGZS5uMArBVa+Rog1H60FVfKq84eqt5G2dvafDWXTP-RdiwQ@mail.gmail.com>
References: <1342215900-3358-1-git-send-email-jon.mason@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1342215900-3358-1-git-send-email-jon.mason@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jon,

On Fri, Jul 13, 2012 at 5:44 PM, Jon Mason <jon.mason@intel.com> wrote:

Just a few minor comments/questions:

....

> +struct ntb_transport_qp {
> +       struct ntb_device *ndev;
> +
> +       bool client_ready;
> +       bool qp_link;
> +       u8 qp_num;      /* Only 64 QP's are allowed.  0-63 */
> +
> +       void (*tx_handler) (struct ntb_transport_qp *qp);
> +       struct tasklet_struct tx_work;

Is it ok to rename the following vars for convenience sake?

> +       struct list_head txq;
tx_pend_q - (pending_queue) or tx_out_q - (outstanding_queue) - or
pick any new string you like - other than a mono-syllable definition

> +       struct list_head txc;
tx_compl_q - completion queue

> +       struct list_head txe;
tx_avail_e - available entry queue


> +       spinlock_t txq_lock;
> +       spinlock_t txc_lock;
> +       spinlock_t txe_lock;

then match the variants accordingly.

> +       struct list_head rxq;
> +       struct list_head rxc;
> +       struct list_head rxe;
> +       spinlock_t rxq_lock;
> +       spinlock_t rxc_lock;
> +       spinlock_t rxe_lock;

similarly the rx-counterpart


..................

> +static void ntb_tx_copy_task(struct ntb_transport_qp *qp,
> +                            struct ntb_queue_entry *entry,
> +                            void *offset)
> +{
> +       struct ntb_payload_header *hdr = offset;
> +       int rc;
> +
> +       offset += sizeof(struct ntb_payload_header);
> +       memcpy_toio(offset, entry->buf, entry->len);
> +
> +       hdr->len = entry->len;
> +       hdr->ver = qp->tx_pkts;
> +
> +       /* Ensure that the data is fully copied out before setting the flag */
> +       wmb();
> +       hdr->flags = entry->flags | DESC_DONE_FLAG;
> +
> +       rc = ntb_ring_sdb(qp->ndev, qp->qp_num);
> +       if (rc)
> +               pr_err("%s: error ringing db %d\n", __func__, qp->qp_num);
> +
> +       if (entry->len > 0) {

how do you interpret this len variable and decide if it's a good/bad completion?

> +               qp->tx_bytes += entry->len;
> +
> +               /* Add fully transmitted data to completion queue */
> +               ntb_list_add_tail(&qp->txc_lock, &entry->entry, &qp->txc);
> +
> +               if (qp->tx_handler)
> +                       qp->tx_handler(qp);
> +       } else
> +               ntb_list_add_tail(&qp->txe_lock, &entry->entry, &qp->txe);

I could be wrong but how is the original skb handled if the code path
goes in the else clause?
Also, in the else clause, how about a ntb_list_add_head rather than a _tail.

> +
> +static int ntb_process_tx(struct ntb_transport_qp *qp,
> +                         struct ntb_queue_entry *entry)
> +{
> +       struct ntb_payload_header *hdr;
> +       void *offset;
> +
> +       offset = qp->tx_offset;
> +       hdr = offset;
> +
> +       pr_debug("%lld - offset %p, tx %p, entry len %d flags %x buff %p\n",
> +                qp->tx_pkts, offset, qp->tx_offset, entry->len, entry->flags,
> +                entry->buf);
> +       if (hdr->flags) {
> +               ntb_list_add_head(&qp->txq_lock, &entry->entry, &qp->txq);
> +               qp->tx_ring_full++;
> +               return -EAGAIN;
> +       }
> +
> +       if (entry->len > transport_mtu) {
> +               pr_err("Trying to send pkt size of %d\n", entry->len);
> +               entry->flags = HW_ERROR_FLAG;
> +
> +               ntb_list_add_tail(&qp->txc_lock, &entry->entry, &qp->txc);
> +
> +               if (qp->tx_handler)
> +                       qp->tx_handler(qp);
> +
> +               return 0;
> +       }
> +
> +       ntb_tx_copy_task(qp, entry, offset);

what happens when ntb_sdb_ring returns an error? would you still want
to increment tx_pkts below?

> +
> +       qp->tx_offset =
> +           (qp->tx_offset +
> +            ((transport_mtu + sizeof(struct ntb_payload_header)) * 2) >=
> +            qp->tx_mw_end) ? qp->tx_mw_begin : qp->tx_offset + transport_mtu +
> +           sizeof(struct ntb_payload_header);
> +
> +       qp->tx_pkts++;
> +
> +       return 0;
> +}
> +

........................


> +void *ntb_transport_tx_dequeue(struct ntb_transport_qp *qp, unsigned int *len)
> +{
> +       struct ntb_queue_entry *entry;
> +       void *buf;
> +
> +       if (!qp)
> +               return NULL;
> +
> +       entry = ntb_list_rm_head(&qp->txc_lock, &qp->txc);
> +       if (!entry)
> +               return NULL;
> +
> +       buf = entry->callback_data;
> +       if (entry->flags != HW_ERROR_FLAG)
> +               *len = entry->len;
> +       else
> +               *len = -EIO;
> +
> +       ntb_list_add_tail(&qp->txe_lock, &entry->entry, &qp->txe);

how about a ntb_list_add_head?


Chetan Loke
