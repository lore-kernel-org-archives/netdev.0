From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [RFC 1/2] PCI-Express Non-Transparent Bridge Support
Date: Mon, 16 Jul 2012 14:26:48 -0400
Message-ID: <CAAsGZS7B5Ch40UQVjgjoRB=RVhkNS-nhi5gh04RSBwsUpZ-9kA@mail.gmail.com>
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

Jon,

On Fri, Jul 13, 2012 at 5:44 PM, Jon Mason <jon.mason@intel.com> wrote:

..............

> +/**
> + * ntb_ring_sdb() - Set the doorbell on the secondary/external side
> + * @ndev: pointer to ntb_device instance
> + * @db: doorbell to ring
> + *
> + * This function allows triggering of a doorbell on the secondary/external
> + * side that will initiate an interrupt on the remote host
> + *
> + * RETURNS: An appropriate -ERRNO error value on error, or zero for success.
> + */
> +int ntb_ring_sdb(struct ntb_device *ndev, unsigned int db)
> +{
> +       dev_dbg(&ndev->pdev->dev, "%s: ringing doorbell %d\n", __func__, db);
> +

> +       if (db >= ndev->max_cbs)
> +               return -EINVAL;

How about moving this max_cbs error check in the upper level
callers(example in ntb_process_tx)?
That way you won't have to defer handling some negative cases all the
way till the end.

So ntb_process_tx could now look like:

.....
error=0;
if (entry->len > transport_mtu) {
...
error=1;
}
else if (qp->qp_num >= qp->ndev->max_cbs) {
...
error=1;
}

if (unlikely(error)) {
      ntb_list_add_tail(&qp->txc_lock, &entry->entry, &qp->txc);
      if (qp->tx_handler)
           qp->tx_handler(qp);

      return 0;
}
.................

No further comments below

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


Chetan Loke
