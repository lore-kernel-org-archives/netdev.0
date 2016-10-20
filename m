From: Arun Easi <arun.easi@cavium.com>
Subject: Re: [RFC 2/6] qed: Add iSCSI out of order packet handling.
Date: Wed, 19 Oct 2016 17:43:43 -0700
Message-ID: <alpine.LRH.2.00.1610191721120.25712@mvluser05.qlc.com>
References: <1476853273-22960-1-git-send-email-manish.rangankar@cavium.com> <1476853273-22960-3-git-send-email-manish.rangankar@cavium.com> <20161019093923.y635a66joxvqgz5u@linux-x5ow.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <manish.rangankar@cavium.com>, <lduncan@suse.com>,
        <cleech@redhat.com>, <martin.petersen@oracle.com>,
        <jejb@linux.vnet.ibm.com>, <linux-scsi@vger.kernel.org>,
        <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>,
        <QLogic-Storage-Upstream@cavium.com>,
        Yuval Mintz <Yuval.Mintz@qlogic.com>
To: Johannes Thumshirn <jthumshirn@suse.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20161019093923.y635a66joxvqgz5u@linux-x5ow.site>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Oct 2016, 2:39am, Johannes Thumshirn wrote:

> On Wed, Oct 19, 2016 at 01:01:09AM -0400, manish.rangankar@cavium.com wrote:
> > From: Yuval Mintz <Yuval.Mintz@qlogic.com>
> > 
> > This patch adds out of order packet handling for hardware offloaded
> > iSCSI. Out of order packet handling requires driver buffer allocation
> > and assistance.
> > 
> > Signed-off-by: Arun Easi <arun.easi@cavium.com>
> > Signed-off-by: Yuval Mintz <yuval.mintz@cavium.com>
> > ---
> 
> [...]
> 
> > +		if (IS_ENABLED(CONFIG_QEDI) &&
> > +			p_ll2_conn->conn_type == QED_LL2_TYPE_ISCSI_OOO) {
> 
> If you're going to implement the qed_is_iscsi_personallity() helper, please
> consider a qed_ll2_is_iscsi_oooo() as well.

I see that I can avoid the IS_ENABLED() here as well. I will fix this
in the next revision.

> 
> > +			struct qed_ooo_buffer *p_buffer;
> 
> [...]
> 
> > +	while (cq_new_idx != cq_old_idx) {
> > +		struct core_rx_fast_path_cqe *p_cqe_fp;
> > +
> > +		cqe = qed_chain_consume(&p_rx->rcq_chain);
> > +		cq_old_idx = qed_chain_get_cons_idx(&p_rx->rcq_chain);
> > +		cqe_type = cqe->rx_cqe_sp.type;
> > +
> > +		if (cqe_type != CORE_RX_CQE_TYPE_REGULAR) {
> > +			DP_NOTICE(p_hwfn,
> > +				  "Got a non-regular LB LL2 completion [type 0x%02x]\n",
> > +				  cqe_type);
> > +			return -EINVAL;
> > +		}
> > +		p_cqe_fp = &cqe->rx_cqe_fp;
> > +
> > +		placement_offset = p_cqe_fp->placement_offset;
> > +		parse_flags = le16_to_cpu(p_cqe_fp->parse_flags.flags);
> > +		packet_length = le16_to_cpu(p_cqe_fp->packet_length);
> > +		vlan = le16_to_cpu(p_cqe_fp->vlan);
> > +		iscsi_ooo = (struct ooo_opaque *)&p_cqe_fp->opaque_data;
> > +		qed_ooo_save_history_entry(p_hwfn, p_hwfn->p_ooo_info,
> > +					   iscsi_ooo);
> > +		cid = le32_to_cpu(iscsi_ooo->cid);
> > +
> > +		/* Process delete isle first */
> > +		if (iscsi_ooo->drop_size)
> > +			qed_ooo_delete_isles(p_hwfn, p_hwfn->p_ooo_info, cid,
> > +					     iscsi_ooo->drop_isle,
> > +					     iscsi_ooo->drop_size);
> > +
> > +		if (iscsi_ooo->ooo_opcode == TCP_EVENT_NOP)
> > +			continue;
> > +
> > +		/* Now process create/add/join isles */
> > +		if (list_empty(&p_rx->active_descq)) {
> > +			DP_NOTICE(p_hwfn,
> > +				  "LL2 OOO RX chain has no submitted buffers\n");
> > +			return -EIO;
> > +		}
> > +
> > +		p_pkt = list_first_entry(&p_rx->active_descq,
> > +					 struct qed_ll2_rx_packet, list_entry);
> > +
> > +		if ((iscsi_ooo->ooo_opcode == TCP_EVENT_ADD_NEW_ISLE) ||
> > +		    (iscsi_ooo->ooo_opcode == TCP_EVENT_ADD_ISLE_RIGHT) ||
> > +		    (iscsi_ooo->ooo_opcode == TCP_EVENT_ADD_ISLE_LEFT) ||
> > +		    (iscsi_ooo->ooo_opcode == TCP_EVENT_ADD_PEN) ||
> > +		    (iscsi_ooo->ooo_opcode == TCP_EVENT_JOIN)) {
> > +			if (!p_pkt) {
> > +				DP_NOTICE(p_hwfn,
> > +					  "LL2 OOO RX packet is not valid\n");
> > +				return -EIO;
> > +			}
> > +			list_del(&p_pkt->list_entry);
> > +			p_buffer = (struct qed_ooo_buffer *)p_pkt->cookie;
> > +			p_buffer->packet_length = packet_length;
> > +			p_buffer->parse_flags = parse_flags;
> > +			p_buffer->vlan = vlan;
> > +			p_buffer->placement_offset = placement_offset;
> > +			qed_chain_consume(&p_rx->rxq_chain);
> > +			list_add_tail(&p_pkt->list_entry, &p_rx->free_descq);
> > +
> > +			switch (iscsi_ooo->ooo_opcode) {
> > +			case TCP_EVENT_ADD_NEW_ISLE:
> > +				qed_ooo_add_new_isle(p_hwfn,
> > +						     p_hwfn->p_ooo_info,
> > +						     cid,
> > +						     iscsi_ooo->ooo_isle,
> > +						     p_buffer);
> > +				break;
> > +			case TCP_EVENT_ADD_ISLE_RIGHT:
> > +				qed_ooo_add_new_buffer(p_hwfn,
> > +						       p_hwfn->p_ooo_info,
> > +						       cid,
> > +						       iscsi_ooo->ooo_isle,
> > +						       p_buffer,
> > +						       QED_OOO_RIGHT_BUF);
> > +				break;
> > +			case TCP_EVENT_ADD_ISLE_LEFT:
> > +				qed_ooo_add_new_buffer(p_hwfn,
> > +						       p_hwfn->p_ooo_info,
> > +						       cid,
> > +						       iscsi_ooo->ooo_isle,
> > +						       p_buffer,
> > +						       QED_OOO_LEFT_BUF);
> > +				break;
> > +			case TCP_EVENT_JOIN:
> > +				qed_ooo_add_new_buffer(p_hwfn,
> > +						       p_hwfn->p_ooo_info,
> > +						       cid,
> > +						       iscsi_ooo->ooo_isle +
> > +						       1,
> > +						       p_buffer,
> > +						       QED_OOO_LEFT_BUF);
> > +				qed_ooo_join_isles(p_hwfn,
> > +						   p_hwfn->p_ooo_info,
> > +						   cid, iscsi_ooo->ooo_isle);
> > +				break;
> > +			case TCP_EVENT_ADD_PEN:
> > +				num_ooo_add_to_peninsula++;
> > +				qed_ooo_put_ready_buffer(p_hwfn,
> > +							 p_hwfn->p_ooo_info,
> > +							 p_buffer, true);
> > +				break;
> > +			}
> > +		} else {
> > +			DP_NOTICE(p_hwfn,
> > +				  "Unexpected event (%d) TX OOO completion\n",
> > +				  iscsi_ooo->ooo_opcode);
> > +		}
> > +	}
> 
> Can you factoror the body of that "while(cq_new_idx != cq_old_idx)" loop into
> a own function?

Ok, will do.

> 
> >  
> > -		b_last = list_empty(&p_rx->active_descq);
> > +	/* Submit RX buffer here */
> > +	while ((p_buffer = qed_ooo_get_free_buffer(p_hwfn,
> > +						   p_hwfn->p_ooo_info))) {
> 
> This could be an opportunity for a qed_for_each_free_buffer() or maybe even a
> qed_ooo_submit_rx_buffers() and qed_ooo_submit_tx_buffers() as this is mostly
> duplicate code.

Sure, will do. Thank you.

Regards,
-Arun
> 
> > +		rc = qed_ll2_post_rx_buffer(p_hwfn, p_ll2_conn->my_id,
> > +					    p_buffer->rx_buffer_phys_addr,
> > +					    0, p_buffer, true);
> > +		if (rc) {
> > +			qed_ooo_put_free_buffer(p_hwfn, p_hwfn->p_ooo_info,
> > +						p_buffer);
> > +			break;
> > +		}
> >  	}
> > +
> > +	/* Submit Tx buffers here */
> > +	while ((p_buffer = qed_ooo_get_ready_buffer(p_hwfn,
> > +						    p_hwfn->p_ooo_info))) {
> 
> Ditto.
> 
> [...]
> > +
> > +	/* Submit Tx buffers here */
> > +	while ((p_buffer = qed_ooo_get_ready_buffer(p_hwfn,
> > +						    p_hwfn->p_ooo_info))) {
> 
> 
> And here
> 
> [...]
> 
> > +	while ((p_buffer = qed_ooo_get_free_buffer(p_hwfn,
> > +						   p_hwfn->p_ooo_info))) {
> 
> [..]
> 
> > +	while ((p_buffer = qed_ooo_get_free_buffer(p_hwfn,
> > +						   p_hwfn->p_ooo_info))) {
> 
> [...]
> 
> 
