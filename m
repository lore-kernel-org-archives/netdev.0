From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [RFC v2 1/2] PCI-Express Non-Transparent Bridge Support
Date: Tue, 31 Jul 2012 12:14:36 -0400
Message-ID: <CAAsGZS4NBM0_o1-RHEZGbYDmJkwTx_RrkYFm7a7-AZRpx0dYAQ@mail.gmail.com>
References: <1343607994-32415-1-git-send-email-jon.mason@intel.com>
	<1343607994-32415-2-git-send-email-jon.mason@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1343607994-32415-2-git-send-email-jon.mason@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 29, 2012 at 8:26 PM, Jon Mason <jon.mason@intel.com> wrote:

<snip>

> +static void ntb_tx_copy_task(struct ntb_transport_qp *qp,
> +                            struct ntb_queue_entry *entry,
> +                            void *offset)
> +{
> +       struct ntb_payload_header *hdr = offset;
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
> +       ntb_ring_sdb(qp->ndev, qp->qp_num);
> +
> +       /* The entry length can only be zero if the packet is intended to be a
> +        * "link down" or similar.  Since no payload is being sent in these
> +        * cases, there is nothing to add to the completion queue.
> +        */
> +       if (entry->len > 0) {
> +               qp->tx_bytes += entry->len;
> +
> +               /* Add fully transmitted data to completion queue */
> +               ntb_list_add_tail(&qp->ntb_tx_comp_q_lock, &entry->entry,
> +                                 &qp->tx_comp_q);
> +
> +               if (qp->tx_handler)
> +                       qp->tx_handler(qp->cb_data, qp);
> +       } else
> +               ntb_list_add_tail(&qp->ntb_tx_free_q_lock, &entry->entry,
> +                                 &qp->tx_free_q);
> +}

I know you talked about a fixed array. But it's not here yet. So at
all the call-sites, for [r/t]x_free_q , add the 'entry' to the head -
change to ntb_list_add_head here and else where.

Chetan Loke
