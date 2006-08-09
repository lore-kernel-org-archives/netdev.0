From: Christian Borntraeger <borntrae@de.ibm.com>
Subject: Re: [PATCH 1/6] ehea: interface to network stack
Date: Wed, 9 Aug 2006 11:08:51 +0200
Message-ID: <200608091108.51774.borntrae@de.ibm.com>
References: <44D99EFC.3000105@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Marcus Eder <meder@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:56537 "EHLO
	mtagate3.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1030596AbWHIJIy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 05:08:54 -0400
To: Jan-Bernd Themann <ossthema@de.ibm.com>
In-Reply-To: <44D99EFC.3000105@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jan-Bernd,

I had some minutes, here are some finding after a quick look.

On Wednesday 09 August 2006 10:38, you wrote:
> +static struct net_device_stats *ehea_get_stats(struct net_device *de=
v)
> +{
> +	int i;
> +	u64 hret =3D H_HARDWARE;
> +	u64 rx_packets =3D 0;
> +	struct ehea_port *port =3D (struct ehea_port*)dev->priv;

dev->priv is a void pointer, this cast is unnecessary. When we are at i=
t, have=20
you considered the netdev_priv macro? This will require some prep in=20
alloc_netdev and might not always pe possible.=20

> +	struct ehea_adapter *adapter =3D port->adapter;
> +	struct hcp_query_ehea_port_cb_2 *cb2 =3D NULL;
> +	struct net_device_stats *stats =3D &port->stats;
> +
> +	EDEB_EN(7, "net_device=3D%p", dev);
> +
> +	cb2 =3D kzalloc(H_CB_ALIGNMENT, GFP_KERNEL);
> +	if (!cb2) {
> +		EDEB_ERR(4, "No memory for cb2");
> +		goto get_stat_exit;
> +	}
> +
> +	hret =3D ehea_h_query_ehea_port(adapter->handle,
> +				      port->logical_port_id,
> +				      H_PORT_CB2,
> +				      H_PORT_CB2_ALL,
> +				      cb2);
> +
> +	if (hret !=3D H_SUCCESS) {
> +		EDEB_ERR(4, "query_ehea_port failed for cb2");
> +		goto get_stat_exit;
> +	}

You leak memory here, dont you? (cb2 points to allocated memory and you=
 are in=20
an error path.)

> +
> +	EDEB_DMP(7, (u8*)cb2,
> +		 sizeof(struct hcp_query_ehea_port_cb_2), "After HCALL");
> +
> +	for (i =3D 0; i < port->num_def_qps; i++) {
> +		rx_packets +=3D port->port_res[i].rx_packets;
> +	}
> +
> +	stats->tx_packets =3D cb2->txucp + cb2->txmcp + cb2->txbcp;
> +	stats->multicast =3D cb2->rxmcp;
> +	stats->rx_errors =3D cb2->rxuerr;
> +	stats->rx_bytes =3D cb2->rxo;
> +	stats->tx_bytes =3D cb2->txo;
> +	stats->rx_packets =3D rx_packets;
> +
> +get_stat_exit:
> +	EDEB_EX(7, "");
> +	return stats;
> +}

again, cb2 is not freed.
[...]

> +static inline u64 get_swqe_addr(u64 tmp_addr, int addr_seg)
> +{
> +	u64 addr;
> +	addr =3D tmp_addr;
> +	return addr;
> +}

This is suppsed to change in the future? If not you can get rid of it.=20

> +
> +static inline u64 get_rwqe_addr(u64 tmp_addr)
> +{
> +	return tmp_addr;
> +}

same here.=20

> +
> +static int ehea_poll(struct net_device *dev, int *budget)
> +{
> +	struct ehea_port *port =3D (struct ehea_port*)dev->priv;

Again. no cast, maybe netdev_priv macro.=20

> +	struct ehea_port_res *port_res =3D &port->port_res[0];
> +	struct ehea_cqe *cqe;
> +	struct ehea_qp *qp =3D port_res->qp;
> +	int wqe_index =3D 0;
> +	int last_wqe_index =3D 0;
> +	int x =3D 0;
> +	int processed =3D 0;
> +	int processed_RQ1 =3D 0;
> +	int processed_RQ2 =3D 0;
> +	int processed_RQ3 =3D 0;
> +	int rq;
> +	int intreq;
> +	struct sk_buff **skb_arr_rq1 =3D port_res->skb_arr_rq1;
> +	struct sk_buff **skb_arr_rq2 =3D port_res->skb_arr_rq2;
> +	struct sk_buff **skb_arr_rq3 =3D port_res->skb_arr_rq3;
> +	int skb_arr_rq1_len =3D port_res->skb_arr_rq1_len;
> +	int my_quota =3D min(*budget, dev->quota);
> +
> +	EDEB_EN(7, "dev=3D%p, port_res=3D%p, budget=3D%d, quota=3D%d, qp_nr=
=3D%x",
> +		dev, port_res, *budget, dev->quota,
> +		port_res->qp->init_attr.qp_nr);
> +	my_quota =3D min(my_quota, EHEA_MAX_RWQE);
> +
> +	/* rq0 is low latency RQ */
> +	cqe =3D ehea_poll_rq1(qp, &wqe_index);
> +	while ((my_quota > 0) && cqe) {
> +		ehea_inc_rq1(qp);
> +		processed_RQ1++;
> +		processed++;
> +		my_quota--;
> +
> +		EDEB_DMP(6, (u8*)cqe, 4 * 16, "CQE");
> +		last_wqe_index =3D wqe_index;
> +		rmb();
> +		if (!ehea_check_cqe(cqe, &rq)) {
> +			struct sk_buff *skb;
> +			if (rq =3D=3D 1) {	/* LL RQ1 */
> +				void *pref;
> +
> +				x =3D (wqe_index + 1) % skb_arr_rq1_len;
> +				pref =3D (void*)skb_arr_rq1[x];
> +				prefetchw(pref);
> +				prefetchw(pref + EHEA_CACHE_LINE);
> +
> +				x =3D (wqe_index + 1) % skb_arr_rq1_len;
> +				pref =3D (void*)(skb_arr_rq1[x]->data);
> +				prefetchw(pref);
> +				prefetchw(pref + EHEA_CACHE_LINE);
> +
> +				skb =3D skb_arr_rq1[wqe_index];
> +				if (unlikely(!skb)) {
> +					EDEB_ERR(4, "LL SBK=3DNULL, wqe_index=3D%d",
> +						 wqe_index);
> +					skb =3D dev_alloc_skb(EHEA_LL_PKT_SIZE);
> +					if (!skb)
> +						panic("Alloc SKB failed");
> +				}
> +				skb_arr_rq1[wqe_index] =3D NULL;
> +				ehea_fill_skb_ll(dev, skb, cqe);
> +			} else if (rq =3D=3D 2) {	/* RQ2 */
> +				void *pref;
> +				int skb_index =3D EHEA_BMASK_GET(EHEA_WR_ID_INDEX,
> +							       cqe->wr_id);
> +				x =3D (skb_index + 1) % port_res->skb_arr_rq2_len;
> +				pref =3D (void*)skb_arr_rq2[x];
> +				prefetchw(pref);
> +				prefetchw(pref + EHEA_CACHE_LINE);
> +
> +				x =3D (skb_index + 1) % port_res->skb_arr_rq2_len;
> +				pref =3D (void*)(skb_arr_rq2[x]->data);
> +
> +				prefetch(pref);
> +				prefetch(pref + EHEA_CACHE_LINE);
> +				prefetch(pref + EHEA_CACHE_LINE * 2);
> +				prefetch(pref + EHEA_CACHE_LINE * 3);
> +				skb =3D skb_arr_rq2[skb_index];
> +
> +				if (unlikely(!skb)) {
> +					EDEB_ERR(4, "rq2: SKB=3DNULL, index=3D%d",
> +						 skb_index);
> +					break;
> +				}
> +				skb_arr_rq2[skb_index] =3D NULL;
> +				ehea_fill_skb(dev, skb, cqe);
> +				processed_RQ2++;
> +			} else {
> +				void *pref;
> +				int skb_index =3D EHEA_BMASK_GET(EHEA_WR_ID_INDEX,
> +							       cqe->wr_id);
> +				x =3D (skb_index + 1) % port_res->skb_arr_rq3_len;
> +				pref =3D (void*)skb_arr_rq3[x];
> +				prefetchw(pref);
> +				prefetchw(pref + EHEA_CACHE_LINE);
> +
> +				x =3D (skb_index + 1) % port_res->skb_arr_rq3_len;
> +				pref =3D (void*)(skb_arr_rq3[x]->data);
> +				prefetch(pref);
> +				prefetch(pref + EHEA_CACHE_LINE);
> +				prefetch(pref + EHEA_CACHE_LINE * 2);
> +				prefetch(pref + EHEA_CACHE_LINE * 3);
> +
> +				skb =3D skb_arr_rq3[skb_index];
> +				if (unlikely(!skb)) {
> +					EDEB_ERR(4, "rq3: SKB=3DNULL, index=3D%d",
> +						 skb_index);
> +					break;
> +				}
> +				skb_arr_rq3[skb_index] =3D NULL;
> +				ehea_fill_skb(dev, skb, cqe);
> +				processed_RQ3++;
> +			}
> +
> +			EDEB(6, "About to pass SKB: dev=3D%p\n"
> +			     "skb=3D%p skb->data=3D%p skb->len=3D%d"
> +			     " skb->data_len=3D0x%x nr_frags=3D%d",
> +			     dev,
> +			     skb,
> +			     skb->data,
> +			     skb->len,
> +			     skb->data_len, skb_shinfo(skb)->nr_frags);
> +			if (cqe->status & EHEA_CQE_VLAN_TAG_XTRACT) {
> +				EDEB(7, "VLAN TAG extracted: %4x, vgrp=3D%p",
> +				     cqe->vlan_tag, port->vgrp);
> +				EDEB(7, "vlan_devices[vlan_tag]=3D%p",
> +				     port->vgrp->vlan_devices[cqe->vlan_tag]);
> +				vlan_hwaccel_receive_skb(skb, port->vgrp,
> +							 cqe->vlan_tag);
> +			} else {
> +				EDEB(7, "netif_receive_skb");
> +				netif_receive_skb(skb);
> +			}
> +			EDEB(7, "SKB passed (netif_receive(skb) called)");
> +
> +		} else {
> +			struct sk_buff *skb;
> +
> +			EDEB_ERR(4, "cqe->status indicating error: CQE:");
> +			EDEB_DMP(4, (u8*)cqe, 4 * 16, "");
> +			if (rq =3D=3D 2) {
> +				processed_RQ2++;
> +				skb =3D skb_arr_rq2[
> +					EHEA_BMASK_GET(EHEA_WR_ID_INDEX,
> +							  cqe->wr_id)];
> +				skb_arr_rq2[EHEA_BMASK_GET(EHEA_WR_ID_INDEX,
> +							  cqe->wr_id)] =3D NULL;
> +				dev_kfree_skb(skb);
> +			}
> +			if (rq =3D=3D 3) {
> +				processed_RQ3++;
> +				skb =3D skb_arr_rq3[
> +					EHEA_BMASK_GET(EHEA_WR_ID_INDEX,
> +								cqe->wr_id)];
> +				skb_arr_rq3[EHEA_BMASK_GET(EHEA_WR_ID_INDEX,
> +							  cqe->wr_id)] =3D NULL;
> +				dev_kfree_skb(skb);
> +			}
> +		}
> +		cqe =3D ehea_poll_rq1(qp, &wqe_index);
> +	}
> +
> +	dev->quota -=3D processed;
> +	*budget -=3D processed;
> +
> +	port_res->p_state.ehea_poll +=3D 1;
> +
> +	port_res->rx_packets +=3D processed;
> +
> +	ehea_refill_rq1(port_res, last_wqe_index, processed_RQ1);
> +	ehea_refill_rq2(port_res, processed_RQ2);
> +	ehea_refill_rq3(port_res, processed_RQ3);
> +
> +	intreq =3D ((port_res->p_state.ehea_poll & 0xF) =3D=3D 0xF);
> +
> +	EDEB_EX(7, "processed=3D%d, *budget=3D%d, dev->quota=3D%d",
> +		processed, *budget, dev->quota);
> +
> +	if (!cqe || intreq) {
> +		netif_rx_complete(dev);
> +		ehea_reset_cq_ep(port_res->recv_cq);
> +		ehea_reset_cq_n1(port_res->recv_cq);
> +		cqe =3D ipz_qeit_get_valid(&qp->ipz_rqueue1);
> +		EDEB(7, "CQE=3D%p, break ehea_poll while loop", cqe);
> +		if (!cqe || intreq)
> +			return 0;
> +		if (!netif_rx_reschedule(dev, my_quota))
> +			return 0;
> +	}
> +	return 1;
> +}

The poll function seems too long and therefore hard to review. Please c=
onsider=20
splitting it.=20


--=20
Mit freundlichen Gr=FC=DFen / Best Regards

Christian Borntraeger
Linux Software Engineer zSeries Linux & Virtualization



