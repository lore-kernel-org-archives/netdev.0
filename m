From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] liquidio: Fix checkpatch errors with
 references crossing single line
Date: Wed, 31 May 2017 17:31:06 -0700
Message-ID: <1496277066.2618.62.camel@perches.com>
References: <20170531174515.GA1539@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0152.hostedemail.com ([216.40.44.152]:32954 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751028AbdFAAbK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 20:31:10 -0400
In-Reply-To: <20170531174515.GA1539@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-05-31 at 10:45 -0700, Felix Manlunas wrote:
> > From: Satanand Burla <satananda.burla@cavium.com>
> 
> > Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
> > Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> > Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> ---
>  drivers/net/ethernet/cavium/liquidio/lio_ethtool.c     |  8 ++++----

Much better would be not to separate out the object onto
multiple lines, but use temporaries to make the code "volume"
much smaller and it also saves a bit of object code.

For this file, perhaps

Subject: [PATCH] liquidio: Reduce dereferences

Multiple dereferences of the same object are hard to read.

Use temporaries to reduce the code volume and also reduce
overall object size a bit.

$ size drivers/net/ethernet/cavium/liquidio/lio_ethtool.o*
   text	   data	    bss	    dec	    hex	filename
  22038	      0	      0	  22038	   5616	drivers/net/ethernet/cavium/liquidio/lio_ethtool.o.new
  22246	      0	      0	  22246	   56e6	drivers/net/ethernet/cavium/liquidio/lio_ethtool.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 450 ++++++++++-----------
 1 file changed, 215 insertions(+), 235 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 579dc7336f58..bd2db6382377 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -786,257 +786,245 @@ lio_get_ethtool_stats(struct net_device *netdev,
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct_dev = lio->oct_dev;
 	struct net_device_stats *netstats = &netdev->stats;
+	struct nic_tx_stats *tstats = &oct_dev->link_stats.fromhost;
+	struct nic_rx_stats *rstats = &oct_dev->link_stats.fromwire;
 	int i = 0, j;
 
 	netdev->netdev_ops->ndo_get_stats(netdev);
 	octnet_get_link_stats(netdev);
 
-	/*sum of oct->droq[oq_no]->stats->rx_pkts_received */
+	/* sum of oct->droq[oq_no]->stats->rx_pkts_received */
 	data[i++] = CVM_CAST64(netstats->rx_packets);
-	/*sum of oct->instr_queue[iq_no]->stats.tx_done */
+	/* sum of oct->instr_queue[iq_no]->stats.tx_done */
 	data[i++] = CVM_CAST64(netstats->tx_packets);
-	/*sum of oct->droq[oq_no]->stats->rx_bytes_received */
+	/* sum of oct->droq[oq_no]->stats->rx_bytes_received */
 	data[i++] = CVM_CAST64(netstats->rx_bytes);
-	/*sum of oct->instr_queue[iq_no]->stats.tx_tot_bytes */
+	/* sum of oct->instr_queue[iq_no]->stats.tx_tot_bytes */
 	data[i++] = CVM_CAST64(netstats->tx_bytes);
 	data[i++] = CVM_CAST64(netstats->rx_errors);
 	data[i++] = CVM_CAST64(netstats->tx_errors);
-	/*sum of oct->droq[oq_no]->stats->rx_dropped +
-	 *oct->droq[oq_no]->stats->dropped_nodispatch +
-	 *oct->droq[oq_no]->stats->dropped_toomany +
-	 *oct->droq[oq_no]->stats->dropped_nomem
+	/* sum of oct->droq[oq_no]->stats->rx_dropped +
+	 * oct->droq[oq_no]->stats->dropped_nodispatch +
+	 * oct->droq[oq_no]->stats->dropped_toomany +
+	 * oct->droq[oq_no]->stats->dropped_nomem
 	 */
 	data[i++] = CVM_CAST64(netstats->rx_dropped);
-	/*sum of oct->instr_queue[iq_no]->stats.tx_dropped */
+	/* sum of oct->instr_queue[iq_no]->stats.tx_dropped */
 	data[i++] = CVM_CAST64(netstats->tx_dropped);
 
 	/* firmware tx stats */
-	/*per_core_stats[cvmx_get_core_num()].link_stats[mdata->from_ifidx].
-	 *fromhost.fw_total_sent
+	/* per_core_stats[cvmx_get_core_num()].link_stats[mdata->from_ifidx].
+	 * fromhost.fw_total_sent
 	 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_total_sent);
-	/*per_core_stats[i].link_stats[port].fromwire.fw_total_fwd */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_total_fwd);
-	/*per_core_stats[j].link_stats[i].fromhost.fw_err_pko */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_err_pko);
-	/*per_core_stats[j].link_stats[i].fromhost.fw_err_link */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_err_link);
-	/*per_core_stats[cvmx_get_core_num()].link_stats[idx].fromhost.
-	 *fw_err_drop
+	data[i++] = CVM_CAST64(tstats->fw_total_sent);
+	/* per_core_stats[i].link_stats[port].fromwire.fw_total_fwd */
+	data[i++] = CVM_CAST64(tstats->fw_total_fwd);
+	/* per_core_stats[j].link_stats[i].fromhost.fw_err_pko */
+	data[i++] = CVM_CAST64(tstats->fw_err_pko);
+	/* per_core_stats[j].link_stats[i].fromhost.fw_err_link */
+	data[i++] = CVM_CAST64(tstats->fw_err_link);
+	/* per_core_stats[cvmx_get_core_num()].link_stats[idx].fromhost.
+	 * fw_err_drop
 	 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_err_drop);
+	data[i++] = CVM_CAST64(tstats->fw_err_drop);
 
-	/*per_core_stats[cvmx_get_core_num()].link_stats[idx].fromhost.fw_tso */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_tso);
-	/*per_core_stats[cvmx_get_core_num()].link_stats[idx].fromhost.
-	 *fw_tso_fwd
+	/* per_core_stats[cvmx_get_core_num()].link_stats[idx].fromhost.fw_tso */
+	data[i++] = CVM_CAST64(tstats->fw_tso);
+	/* per_core_stats[cvmx_get_core_num()].link_stats[idx].fromhost.
+	 * fw_tso_fwd
 	 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_tso_fwd);
-	/*per_core_stats[cvmx_get_core_num()].link_stats[idx].fromhost.
-	 *fw_err_tso
+	data[i++] = CVM_CAST64(tstats->fw_tso_fwd);
+	/* per_core_stats[cvmx_get_core_num()].link_stats[idx].fromhost.
+	 * fw_err_tso
 	 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_err_tso);
-	/*per_core_stats[cvmx_get_core_num()].link_stats[idx].fromhost.
-	 *fw_tx_vxlan
+	data[i++] = CVM_CAST64(tstats->fw_err_tso);
+	/* per_core_stats[cvmx_get_core_num()].link_stats[idx].fromhost.
+	 * fw_tx_vxlan
 	 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_tx_vxlan);
+	data[i++] = CVM_CAST64(tstats->fw_tx_vxlan);
 
 	/* mac tx statistics */
-	/*CVMX_BGXX_CMRX_TX_STAT5 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.total_pkts_sent);
-	/*CVMX_BGXX_CMRX_TX_STAT4 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.total_bytes_sent);
-	/*CVMX_BGXX_CMRX_TX_STAT15 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.mcast_pkts_sent);
-	/*CVMX_BGXX_CMRX_TX_STAT14 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.bcast_pkts_sent);
-	/*CVMX_BGXX_CMRX_TX_STAT17 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.ctl_sent);
-	/*CVMX_BGXX_CMRX_TX_STAT0 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.total_collisions);
-	/*CVMX_BGXX_CMRX_TX_STAT3 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.one_collision_sent);
-	/*CVMX_BGXX_CMRX_TX_STAT2 */
-	data[i++] =
-		CVM_CAST64(oct_dev->link_stats.fromhost.multi_collision_sent);
-	/*CVMX_BGXX_CMRX_TX_STAT0 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.max_collision_fail);
-	/*CVMX_BGXX_CMRX_TX_STAT1 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.max_deferral_fail);
-	/*CVMX_BGXX_CMRX_TX_STAT16 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fifo_err);
-	/*CVMX_BGXX_CMRX_TX_STAT6 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.runts);
+	/* CVMX_BGXX_CMRX_TX_STAT5 */
+	data[i++] = CVM_CAST64(tstats->total_pkts_sent);
+	/* CVMX_BGXX_CMRX_TX_STAT4 */
+	data[i++] = CVM_CAST64(tstats->total_bytes_sent);
+	/* CVMX_BGXX_CMRX_TX_STAT15 */
+	data[i++] = CVM_CAST64(tstats->mcast_pkts_sent);
+	/* CVMX_BGXX_CMRX_TX_STAT14 */
+	data[i++] = CVM_CAST64(tstats->bcast_pkts_sent);
+	/* CVMX_BGXX_CMRX_TX_STAT17 */
+	data[i++] = CVM_CAST64(tstats->ctl_sent);
+	/* CVMX_BGXX_CMRX_TX_STAT0 */
+	data[i++] = CVM_CAST64(tstats->total_collisions);
+	/* CVMX_BGXX_CMRX_TX_STAT3 */
+	data[i++] = CVM_CAST64(tstats->one_collision_sent);
+	/* CVMX_BGXX_CMRX_TX_STAT2 */
+	data[i++] = CVM_CAST64(tstats->multi_collision_sent);
+	/* CVMX_BGXX_CMRX_TX_STAT0 */
+	data[i++] = CVM_CAST64(tstats->max_collision_fail);
+	/* CVMX_BGXX_CMRX_TX_STAT1 */
+	data[i++] = CVM_CAST64(tstats->max_deferral_fail);
+	/* CVMX_BGXX_CMRX_TX_STAT16 */
+	data[i++] = CVM_CAST64(tstats->fifo_err);
+	/* CVMX_BGXX_CMRX_TX_STAT6 */
+	data[i++] = CVM_CAST64(tstats->runts);
 
 	/* RX firmware stats */
-	/*per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
-	 *fw_total_rcvd
+	/* per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
+	 * fw_total_rcvd
 	 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_total_rcvd);
-	/*per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
-	 *fw_total_fwd
+	data[i++] = CVM_CAST64(rstats->fw_total_rcvd);
+	/* per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
+	 * fw_total_fwd
 	 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_total_fwd);
-	/*per_core_stats[core_id].link_stats[ifidx].fromwire.jabber_err */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.jabber_err);
-	/*per_core_stats[core_id].link_stats[ifidx].fromwire.l2_err */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.l2_err);
-	/*per_core_stats[core_id].link_stats[ifidx].fromwire.frame_err */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.frame_err);
-	/*per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
-	 *fw_err_pko
+	data[i++] = CVM_CAST64(rstats->fw_total_fwd);
+	/* per_core_stats[core_id].link_stats[ifidx].fromwire.jabber_err */
+	data[i++] = CVM_CAST64(rstats->jabber_err);
+	/* per_core_stats[core_id].link_stats[ifidx].fromwire.l2_err */
+	data[i++] = CVM_CAST64(rstats->l2_err);
+	/* per_core_stats[core_id].link_stats[ifidx].fromwire.frame_err */
+	data[i++] = CVM_CAST64(rstats->frame_err);
+	/* per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
+	 * fw_err_pko
 	 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_err_pko);
-	/*per_core_stats[j].link_stats[i].fromwire.fw_err_link */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_err_link);
-	/*per_core_stats[cvmx_get_core_num()].link_stats[lro_ctx->ifidx].
-	 *fromwire.fw_err_drop
+	data[i++] = CVM_CAST64(rstats->fw_err_pko);
+	/* per_core_stats[j].link_stats[i].fromwire.fw_err_link */
+	data[i++] = CVM_CAST64(rstats->fw_err_link);
+	/* per_core_stats[cvmx_get_core_num()].link_stats[lro_ctx->ifidx].
+	 * fromwire.fw_err_drop
 	 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_err_drop);
+	data[i++] = CVM_CAST64(rstats->fw_err_drop);
 
-	/*per_core_stats[cvmx_get_core_num()].link_stats[lro_ctx->ifidx].
-	 *fromwire.fw_rx_vxlan
+	/* per_core_stats[cvmx_get_core_num()].link_stats[lro_ctx->ifidx].
+	 * fromwire.fw_rx_vxlan
 	 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_rx_vxlan);
-	/*per_core_stats[cvmx_get_core_num()].link_stats[lro_ctx->ifidx].
-	 *fromwire.fw_rx_vxlan_err
+	data[i++] = CVM_CAST64(rstats->fw_rx_vxlan);
+	/* per_core_stats[cvmx_get_core_num()].link_stats[lro_ctx->ifidx].
+	 * fromwire.fw_rx_vxlan_err
 	 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_rx_vxlan_err);
+	data[i++] = CVM_CAST64(rstats->fw_rx_vxlan_err);
 
 	/* LRO */
-	/*per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
-	 *fw_lro_pkts
+	/* per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
+	 * fw_lro_pkts
 	 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_lro_pkts);
-	/*per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
-	 *fw_lro_octs
+	data[i++] = CVM_CAST64(rstats->fw_lro_pkts);
+	/* per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
+	 * fw_lro_octs
 	 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_lro_octs);
-	/*per_core_stats[j].link_stats[i].fromwire.fw_total_lro */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_total_lro);
-	/*per_core_stats[j].link_stats[i].fromwire.fw_lro_aborts */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_lro_aborts);
-	/*per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
-	 *fw_lro_aborts_port
+	data[i++] = CVM_CAST64(rstats->fw_lro_octs);
+	/* per_core_stats[j].link_stats[i].fromwire.fw_total_lro */
+	data[i++] = CVM_CAST64(rstats->fw_total_lro);
+	/* per_core_stats[j].link_stats[i].fromwire.fw_lro_aborts */
+	data[i++] = CVM_CAST64(rstats->fw_lro_aborts);
+	/* per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
+	 * fw_lro_aborts_port
 	 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_lro_aborts_port);
-	/*per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
-	 *fw_lro_aborts_seq
+	data[i++] = CVM_CAST64(rstats->fw_lro_aborts_port);
+	/* per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
+	 * fw_lro_aborts_seq
 	 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_lro_aborts_seq);
-	/*per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
-	 *fw_lro_aborts_tsval
+	data[i++] = CVM_CAST64(rstats->fw_lro_aborts_seq);
+	/* per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
+	 * fw_lro_aborts_tsval
 	 */
-	data[i++] =
-		CVM_CAST64(oct_dev->link_stats.fromwire.fw_lro_aborts_tsval);
-	/*per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
-	 *fw_lro_aborts_timer
+	data[i++] = CVM_CAST64(rstats->fw_lro_aborts_tsval);
+	/* per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
+	 * fw_lro_aborts_timer
 	 */
 	/* intrmod: packet forward rate */
-	data[i++] =
-		CVM_CAST64(oct_dev->link_stats.fromwire.fw_lro_aborts_timer);
-	/*per_core_stats[j].link_stats[i].fromwire.fw_lro_aborts */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fwd_rate);
+	data[i++] = CVM_CAST64(rstats->fw_lro_aborts_timer);
+	/* per_core_stats[j].link_stats[i].fromwire.fw_lro_aborts */
+	data[i++] = CVM_CAST64(rstats->fwd_rate);
 
 	/* mac: link-level stats */
-	/*CVMX_BGXX_CMRX_RX_STAT0 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.total_rcvd);
-	/*CVMX_BGXX_CMRX_RX_STAT1 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.bytes_rcvd);
-	/*CVMX_PKI_STATX_STAT5 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.total_bcst);
-	/*CVMX_PKI_STATX_STAT5 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.total_mcst);
-	/*wqe->word2.err_code or wqe->word2.err_level */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.runts);
-	/*CVMX_BGXX_CMRX_RX_STAT2 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.ctl_rcvd);
-	/*CVMX_BGXX_CMRX_RX_STAT6 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fifo_err);
-	/*CVMX_BGXX_CMRX_RX_STAT4 */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.dmac_drop);
-	/*wqe->word2.err_code or wqe->word2.err_level */
-	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fcs_err);
-	/*lio->link_changes*/
+	/* CVMX_BGXX_CMRX_RX_STAT0 */
+	data[i++] = CVM_CAST64(rstats->total_rcvd);
+	/* CVMX_BGXX_CMRX_RX_STAT1 */
+	data[i++] = CVM_CAST64(rstats->bytes_rcvd);
+	/* CVMX_PKI_STATX_STAT5 */
+	data[i++] = CVM_CAST64(rstats->total_bcst);
+	/* CVMX_PKI_STATX_STAT5 */
+	data[i++] = CVM_CAST64(rstats->total_mcst);
+	/* wqe->word2.err_code or wqe->word2.err_level */
+	data[i++] = CVM_CAST64(rstats->runts);
+	/* CVMX_BGXX_CMRX_RX_STAT2 */
+	data[i++] = CVM_CAST64(rstats->ctl_rcvd);
+	/* CVMX_BGXX_CMRX_RX_STAT6 */
+	data[i++] = CVM_CAST64(rstats->fifo_err);
+	/* CVMX_BGXX_CMRX_RX_STAT4 */
+	data[i++] = CVM_CAST64(rstats->dmac_drop);
+	/* wqe->word2.err_code or wqe->word2.err_level */
+	data[i++] = CVM_CAST64(rstats->fcs_err);
+	/* lio->link_changes*/
 	data[i++] = CVM_CAST64(lio->link_changes);
 
 	for (j = 0; j < MAX_OCTEON_INSTR_QUEUES(oct_dev); j++) {
+		struct oct_iq_stats *stats;
+
 		if (!(oct_dev->io_qmask.iq & BIT_ULL(j)))
 			continue;
-		/*packets to network port*/
-		/*# of packets tx to network */
-		data[i++] = CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_done);
-		/*# of bytes tx to network */
-		data[i++] =
-			CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_tot_bytes);
-		/*# of packets dropped */
-		data[i++] =
-			CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_dropped);
-		/*# of tx fails due to queue full */
-		data[i++] =
-			CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_iq_busy);
-		/*XXX gather entries sent */
-		data[i++] =
-			CVM_CAST64(oct_dev->instr_queue[j]->stats.sgentry_sent);
-
-		/*instruction to firmware: data and control */
-		/*# of instructions to the queue */
-		data[i++] =
-			CVM_CAST64(oct_dev->instr_queue[j]->stats.instr_posted);
-		/*# of instructions processed */
-		data[i++] = CVM_CAST64(oct_dev->instr_queue[j]->
-				       stats.instr_processed);
-		/*# of instructions could not be processed */
-		data[i++] = CVM_CAST64(oct_dev->instr_queue[j]->
-				       stats.instr_dropped);
-		/*bytes sent through the queue */
-		data[i++] =
-			CVM_CAST64(oct_dev->instr_queue[j]->stats.bytes_sent);
-
-		/*tso request*/
-		data[i++] = CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_gso);
-		/*vxlan request*/
-		data[i++] = CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_vxlan);
-		/*txq restart*/
-		data[i++] =
-			CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_restart);
+
+		stats = &oct_dev->instr_queue[j]->stats;
+
+		/* packets to network port */
+		/* # of packets tx to network */
+		data[i++] = CVM_CAST64(stats->tx_done);
+		/* # of bytes tx to network */
+		data[i++] = CVM_CAST64(stats->tx_tot_bytes);
+		/* # of packets dropped */
+		data[i++] = CVM_CAST64(stats->tx_dropped);
+		/* # of tx fails due to queue full */
+		data[i++] = CVM_CAST64(stats->tx_iq_busy);
+		/* XXX gather entries sent */
+		data[i++] = CVM_CAST64(stats->sgentry_sent);
+
+		/* instruction to firmware: data and control */
+		/* # of instructions to the queue */
+		data[i++] = CVM_CAST64(stats->instr_posted);
+		/* # of instructions processed */
+		data[i++] = CVM_CAST64(stats->instr_processed);
+		/* # of instructions could not be processed */
+		data[i++] = CVM_CAST64(stats->instr_dropped);
+		/* bytes sent through the queue */
+		data[i++] = CVM_CAST64(stats->bytes_sent);
+
+		/* tso request */
+		data[i++] = CVM_CAST64(stats->tx_gso);
+		/* vxlan request */
+		data[i++] = CVM_CAST64(stats->tx_vxlan);
+		/* txq restart */
+		data[i++] = CVM_CAST64(stats->tx_restart);
 	}
 
 	/* RX */
 	for (j = 0; j < MAX_OCTEON_OUTPUT_QUEUES(oct_dev); j++) {
+		struct oct_droq_stats *stats;
+
 		if (!(oct_dev->io_qmask.oq & BIT_ULL(j)))
 			continue;
 
-		/*packets send to TCP/IP network stack */
-		/*# of packets to network stack */
-		data[i++] =
-			CVM_CAST64(oct_dev->droq[j]->stats.rx_pkts_received);
-		/*# of bytes to network stack */
-		data[i++] =
-			CVM_CAST64(oct_dev->droq[j]->stats.rx_bytes_received);
-		/*# of packets dropped */
-		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.dropped_nomem +
-				       oct_dev->droq[j]->stats.dropped_toomany +
-				       oct_dev->droq[j]->stats.rx_dropped);
-		data[i++] =
-			CVM_CAST64(oct_dev->droq[j]->stats.dropped_nomem);
-		data[i++] =
-			CVM_CAST64(oct_dev->droq[j]->stats.dropped_toomany);
-		data[i++] =
-			CVM_CAST64(oct_dev->droq[j]->stats.rx_dropped);
-
-		/*control and data path*/
-		data[i++] =
-			CVM_CAST64(oct_dev->droq[j]->stats.pkts_received);
-		data[i++] =
-			CVM_CAST64(oct_dev->droq[j]->stats.bytes_received);
-		data[i++] =
-			CVM_CAST64(oct_dev->droq[j]->stats.dropped_nodispatch);
-
-		data[i++] =
-			CVM_CAST64(oct_dev->droq[j]->stats.rx_vxlan);
-		data[i++] =
-			CVM_CAST64(oct_dev->droq[j]->stats.rx_alloc_failure);
+		stats = &oct_dev->droq[j]->stats;
+		/* packets send to TCP/IP network stack */
+		/* # of packets to network stack */
+		data[i++] = CVM_CAST64(stats->rx_pkts_received);
+		/* # of bytes to network stack */
+		data[i++] = CVM_CAST64(stats->rx_bytes_received);
+		/* # of packets dropped */
+		data[i++] = CVM_CAST64(stats->dropped_nomem +
+				       stats->dropped_toomany +
+				       stats->rx_dropped);
+		data[i++] = CVM_CAST64(stats->dropped_nomem);
+		data[i++] = CVM_CAST64(stats->dropped_toomany);
+		data[i++] = CVM_CAST64(stats->rx_dropped);
+
+		/* control and data path */
+		data[i++] = CVM_CAST64(stats->pkts_received);
+		data[i++] = CVM_CAST64(stats->bytes_received);
+		data[i++] = CVM_CAST64(stats->dropped_nodispatch);
+
+		data[i++] = CVM_CAST64(stats->rx_vxlan);
+		data[i++] = CVM_CAST64(stats->rx_alloc_failure);
 	}
 }
 
@@ -1073,73 +1061,65 @@ static void lio_vf_get_ethtool_stats(struct net_device *netdev,
 	data[i++] = CVM_CAST64(lio->link_changes);
 
 	for (vj = 0; vj < lio->linfo.num_txpciq; vj++) {
+		struct oct_iq_stats *stats;
+
 		j = lio->linfo.txpciq[vj].s.q_no;
 
+		stats = &oct_dev->instr_queue[j]->stats;
 		/* packets to network port */
 		/* # of packets tx to network */
-		data[i++] = CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_done);
+		data[i++] = CVM_CAST64(stats->tx_done);
 		 /* # of bytes tx to network */
-		data[i++] = CVM_CAST64(
-				oct_dev->instr_queue[j]->stats.tx_tot_bytes);
+		data[i++] = CVM_CAST64(stats->tx_tot_bytes);
 		/* # of packets dropped */
-		data[i++] = CVM_CAST64(
-				oct_dev->instr_queue[j]->stats.tx_dropped);
+		data[i++] = CVM_CAST64(stats->tx_dropped);
 		/* # of tx fails due to queue full */
-		data[i++] = CVM_CAST64(
-				oct_dev->instr_queue[j]->stats.tx_iq_busy);
+		data[i++] = CVM_CAST64(stats->tx_iq_busy);
 		/* XXX gather entries sent */
-		data[i++] = CVM_CAST64(
-				oct_dev->instr_queue[j]->stats.sgentry_sent);
+		data[i++] = CVM_CAST64(stats->sgentry_sent);
 
 		/* instruction to firmware: data and control */
 		/* # of instructions to the queue */
-		data[i++] = CVM_CAST64(
-				oct_dev->instr_queue[j]->stats.instr_posted);
+		data[i++] = CVM_CAST64(stats->instr_posted);
 		/* # of instructions processed */
-		data[i++] =
-		    CVM_CAST64(oct_dev->instr_queue[j]->stats.instr_processed);
+		data[i++] = CVM_CAST64(stats->instr_processed);
 		/* # of instructions could not be processed */
-		data[i++] =
-		    CVM_CAST64(oct_dev->instr_queue[j]->stats.instr_dropped);
+		data[i++] = CVM_CAST64(stats->instr_dropped);
 		/* bytes sent through the queue */
-		data[i++] = CVM_CAST64(
-				oct_dev->instr_queue[j]->stats.bytes_sent);
+		data[i++] = CVM_CAST64(stats->bytes_sent);
 		/* tso request */
-		data[i++] = CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_gso);
+		data[i++] = CVM_CAST64(stats->tx_gso);
 		/* vxlan request */
-		data[i++] = CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_vxlan);
+		data[i++] = CVM_CAST64(stats->tx_vxlan);
 		/* txq restart */
-		data[i++] = CVM_CAST64(
-				oct_dev->instr_queue[j]->stats.tx_restart);
+		data[i++] = CVM_CAST64(stats->tx_restart);
 	}
 
 	/* RX */
 	for (vj = 0; vj < lio->linfo.num_rxpciq; vj++) {
-		j = lio->linfo.rxpciq[vj].s.q_no;
+		struct oct_droq_stats *stats;
 
+		j = lio->linfo.rxpciq[vj].s.q_no;
+		stats = &oct_dev->droq[j]->stats;
 		/* packets send to TCP/IP network stack */
 		/* # of packets to network stack */
-		data[i++] = CVM_CAST64(
-				oct_dev->droq[j]->stats.rx_pkts_received);
+		data[i++] = CVM_CAST64(stats->rx_pkts_received);
 		/* # of bytes to network stack */
-		data[i++] = CVM_CAST64(
-				oct_dev->droq[j]->stats.rx_bytes_received);
-		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.dropped_nomem +
-				       oct_dev->droq[j]->stats.dropped_toomany +
-				       oct_dev->droq[j]->stats.rx_dropped);
-		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.dropped_nomem);
-		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.dropped_toomany);
-		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.rx_dropped);
+		data[i++] = CVM_CAST64(stats->rx_bytes_received);
+		data[i++] = CVM_CAST64(stats->dropped_nomem +
+				       stats->dropped_toomany +
+				       stats->rx_dropped);
+		data[i++] = CVM_CAST64(stats->dropped_nomem);
+		data[i++] = CVM_CAST64(stats->dropped_toomany);
+		data[i++] = CVM_CAST64(stats->rx_dropped);
 
 		/* control and data path */
-		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.pkts_received);
-		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.bytes_received);
-		data[i++] =
-			CVM_CAST64(oct_dev->droq[j]->stats.dropped_nodispatch);
-
-		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.rx_vxlan);
-		data[i++] =
-		    CVM_CAST64(oct_dev->droq[j]->stats.rx_alloc_failure);
+		data[i++] = CVM_CAST64(stats->pkts_received);
+		data[i++] = CVM_CAST64(stats->bytes_received);
+		data[i++] = CVM_CAST64(stats->dropped_nodispatch);
+
+		data[i++] = CVM_CAST64(stats->rx_vxlan);
+		data[i++] = CVM_CAST64(stats->rx_alloc_failure);
 	}
 }
 
