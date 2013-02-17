From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 5/6] qlcnic: fix ping resumption to a VM after a live migration
Date: Sat, 16 Feb 2013 23:53:50 -0500
Message-ID: <1361076831-31746-6-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1361076831-31746-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:2357 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757242Ab3BSGcZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2013 01:32:25 -0500
In-Reply-To: <1361076831-31746-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Delete the MAC address of a VM, from the adapter's embedded switch,
after the VM had been migrated out of this adapter/server.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |    5 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c   |   18 +++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c   |  145 ++++++++++++++++++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   21 +++
 4 files changed, 177 insertions(+), 12 deletions(-)

XXXX --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
XXXXX 61b594c..01e9ea1 100644
XXX a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
XXX b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
XX -1008,9 +1008,12 @@ struct qlcnic_adapter {
 	XXXXXX delayed_work idc_aen_work;
 
 	XXXXXX qlcnic_filter_hash fhash;
X	struct qlcnic_filter_hash rx_fhash;
 
 	XXXXXXXXXX tx_clean_lock;
 	XXXXXXXXXX mac_learn_lock;
X	/* spinlock for catching rcv filters for eswitch traffic */
X	spinlock_t rx_mac_learn_lock;
 	XXX file_prd_off;	/*File fw product offset*/
 	XXX fw_version;
 	XXXXX struct firmware *fw;
XX -1506,6 +1509,8 @@ int qlcnic_init_pci_info(struct qlcnic_adapter *);
 XXX qlcnic_set_default_offload_settings(struct qlcnic_adapter *);
 XXX qlcnic_reset_npar_config(struct qlcnic_adapter *);
 XXX qlcnic_set_eswitch_port_config(struct qlcnic_adapter *);
XXXXX qlcnic_add_lb_filter(struct qlcnic_adapter *, struct sk_buff *, int,
X			  __le16);
 XX
  X QLOGIC Board information
  XX
XXXX --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
XXXXX 51716ab..325e11e 100644
XXX a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
XXX b/drivers/net/ethernet/qlogicXXXXXXXXXXXXXXXXXXX
XX -578,7 +578,8 @@ void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter)
 	XXXXXX qlcnic_filter *tmp_fil;
 	XXXXXX hlist_node *tmp_hnode, *n;
 	XXXXXX hlist_head *head;
X	int i, time;
X	int i;
X	unsigned long time;
 	XX cmd;
 
 	XXX (i = 0; i < adapter->fhash.fbucket_size; i++) {
XX -600,6 +601,21 @@ void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter)
 			X
 		X
 	X
X	for (i = 0; i < adapter->rx_fhash.fbucket_size; i++) {
X		head = &(adapter->rx_fhash.fhead[i]);
X
X		hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode)
X		{
X			time = tmp_fil->ftime;
X			if (jiffies > (QLCNIC_FILTER_AGE * HZ + time)) {
X				spin_lock_bh(&adapter->rx_mac_learn_lock);
X				adapter->rx_fhash.fnum--;
X				hlist_del(&tmp_fil->fnode);
X				spin_unlock_bh(&adapter->rx_mac_learn_lock);
X				kfree(tmp_fil);
X			}
X		}
X	}
 X
 
 XXXX qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter)
XXXX --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
XXXXX 2990f45..6387e0c 100644
XXX a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
XXX b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
XX -152,6 +152,89 @@ static inline u32 qlcnic_get_ref_handle(struct qlcnic_adapter *adapter,
 		XXXXXX handle;
 X
 
XXXXXXX inline int qlcniXXXXXXXXXXXXXXXXXXXX sts_data)
XX
X	return (qlcnic_get_sts_status(sts_data) == STATUS_CKSUM_LOOP) ? 1 : 0;
XX
X
XXXXX qlcnic_add_lb_filter(struct qlcnic_adapter *adapter, struct sk_buff *skb,
X			  int loopback_pkt, __le16 vlan_id)
XX
X	struct ethhdr *phdr = (struct ethhdr *)(skb->data);
X	struct qlcnic_filter *fil, *tmp_fil;
X	struct hlist_node *tmp_hnode, *n;
X	struct hlist_head *head;
X	unsigned long time;
X	u64 src_addr = 0;
X	u8 hindex, found = 0, op;
X	int ret;
X
X	memcpy(&src_addr, phdr->h_source, ETH_ALEN);
X
X	if (loopback_pkt) {
X		if (adapter->rx_fhash.fnum >= adapter->rx_fhash.fmax)
X			return;
X
X		hindex = qlcnic_mac_hash(src_addr) &
X			 (adapter->fhash.fbucket_size - 1);
X		head = &(adapter->rx_fhash.fhead[hindex]);
X
X		hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode) {
X			if (!memcmp(tmp_fil->faddr, &src_addr, ETH_ALEN) &&
X			    tmp_fil->vlan_id == vlan_id) {
X				time = tmp_fil->ftime;
X				if (jiffies > (QLCNIC_READD_AGE * HZ + time))
X					tmp_fil->ftime = jiffies;
X				return;
X			}
X		}
X
X		fil = kzalloc(sizeof(struct qlcnic_filter), GFP_ATOMIC);
X		if (!fil)
X			return;
X
X		fil->ftime = jiffies;
X		memcpy(fil->faddr, &src_addr, ETH_ALEN);
X		fil->vlan_id = vlan_id;
X		spin_lock(&adapter->rx_mac_learn_lock);
X		hlist_add_head(&(fil->fnode), hXXXXX
X		adapter->rx_fhash.fnum++;
X		spin_unlock(&adapter->rx_mac_learn_lock);
X	} else {
X		hindex = qlcnic_mac_hash(src_addr) &
X			 (adapter->fhash.fbucket_size - 1);
X		head = &(adapter->rx_fhash.fhead[hindex]);
X		spin_lock(&adapter->rx_mac_learn_lock);
X		hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode) {
X			if (!memcmp(tmp_fil->faddr, &src_addr, ETH_ALEN) &&
X			    tmp_fil->vlan_id == vlan_id) {
X				found = 1;
X				break;
X			}
X		}
X
X		if (!found) {
X			spin_unlock(&adapter->rx_mac_learn_lock);
X			return;
X		}
X
X		op = vlan_id ? QLCNIC_MAC_VLAN_ADD : QLCNIC_MAC_ADD;
X		ret = qlcnic_sre_macaddr_change(adapter, (u8 *)&src_addr,
X						vlan_id, op);
X		if (!ret) {
X			op = vlan_id ? QLCNIC_MAC_VLAN_DEL : QLCNIC_MAC_DEL;
X			ret = qlcnic_sre_macaddr_change(adapter,
X							(u8 *)&src_addr,
X							vlan_id, op);
X			if (!ret) {
X				hlist_del(&(tmp_fil->fnode));
X				adapter->rx_fhash.fnum--;
X			}
X		}
X		spin_unlock(&adapter->rx_mac_learn_lock);
X	}
XX
X
 XXXX qlcnic_82xx_change_filter(struct qlcnic_adapter *adapter, u64 *uaddr,
 			       XXXXXX vlan_id)
 X
XX -207,9 +290,6 @@ static void qlcnic_send_filter(struct qlcnic_adapter *adapter,
 		XXXXXXX
 	X
 
X	/* Only NPAR capable devices support vlan based learning */
X	if (adapter->flags & QLCNIC_ESWITCH_ENXXXXXX
X		vlan_id = first_desc->vlan_TCI;
 	XXXXXXXXXXXXXXXXX phdr->h_source, ETH_ALEN);
 	XXXXXX = qlcnic_mac_hash(src_addr) & (adapter->fhash.fbucket_size - 1);
 	XXXX = &(adapter->fhash.fhead[hindex]);
XX -920,8 +1000,8 @@ qlcnic_process_rcv(struct qlcnic_adapter *adapter,
 	XXXXXX qlcnic_rx_buffer *buffer;
 	XXXXXX sk_buff *skb;
 	XXXXXX qlcnic_host_rds_ring *rds_ring;
X	int index, length, cksum, pkt_offset;
X	u16 vid = 0xffff;
X	int index, length, cksum, pkt_offset, is_lb_pkt;
X	u16 vid = 0xffff, t_vid;
 
 	XX (unlikely(ring >= adapter->max_rds_rings))
 		XXXXXX NULL;
XX -941,6 +1021,14 @@ qlcnic_process_rcv(struct qlcnic_adapter *adapter,
 	XX (!skb)
 		XXXXXX buffer;
 
X	if (adapter->drv_mac_learn &&
X	    (adapter->flags & QLCNIC_ESWITCH_ENABLED)) {
X		t_vid = 0;
X		is_lb_pkt = qlcnic_82xx_is_lb_pkt(sts_data0);
X		qlcnic_add_lb_filter(adapter, skb, is_lb_pkt,
X				     cpu_to_le16(t_vid));
X	}
X
 	XX (length > rds_ring->skb_size)
 		XXXXXXXXXXXX rds_ring->skb_size);
 	XXXX
XX -985,8 +1073,8 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,
 	XXXXXX ipv6hdr *ipv6h;
 	XXXXXX tcphdr *th;
 	XXXX push, timestamp;
X	int index, l2_hdr_offset, l4_hdr_offset;
X	u16 lro_length, length, data_offset, vid = 0xffff;
X	int index, l2_hdr_offset, l4_hdr_offset, is_lb_pkt;
X	u16 lro_length, lengXXX data_offset, t_vid, vid = 0xffff;
 	XXX seq_number;
 
 	XX (unlikely(ring > adapter->max_rds_rings))
XX -1011,6 +1099,14 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,
 	XX (!skb)
 		XXXXXX buffer;
 
X	if (adapter->drv_mac_learn &&
X	    (adapter->flags & QLCNIC_ESWITCH_ENABLED)) {
X		t_vid = 0;
X		is_lb_pkt = qlcnic_82xx_is_lb_pkt(sts_data0);
X		qlcnic_add_lb_filter(adapter, skb, is_lb_pkt,
X				     cpu_to_le16(t_vid));
X	}
X
 	XX (timestamp)
 		XXXXXXXXXXX = l4_hdr_offset + QLC_TCP_TS_HDR_SIZE;
 	XXXX
XX -1357,6 +1453,17 @@ void qlcnic_82xx_napi_disable(struct qlcnic_adapter *adapter)
 	X
 X
 
XXXXXXXX QLC_83XX_NORMAL_LB_PKT	(1ULL << 36)
XXXXXXXX QLC_83XX_LRO_LB_PKT	(1ULL << 46)
X
XXXXXXX inline int qlcnic_83xx_is_lb_pkt(u64 sts_data, int lro_pkt)
XX
X	if (lro_pkt)
X		return (sts_data & QLC_83XX_LRO_LB_PKT) ? 1 : 0;
X	else
X		return (sts_data & QLC_83XX_NORMAL_LB_PKT) ? 1 : 0;
XX
X
 XXXXXX struct qlcnic_rx_buffer *
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX qlcnic_adapter *adapter,
 			XXXXXX qlcnic_host_sds_ring *sds_ring,
XX -1367,8 +1474,8 @@ qlcnic_83xx_process_rcv(struct qlcnic_adapter *adapter,
 	XXXXXX qlcnic_rx_buffer *buffer;
 	XXXXXX sk_buff *skb;
 	XXXXXX qlcnic_host_rds_ring *rds_ring;
X	int index, length, cksum;
X	u16 vid = 0xffff;
X	int index, length, cksum, is_lb_pktX
X	u16 vid = 0xffff, t_vid;
 
 	XX (unlikely(ring >= adapter->max_rds_rings))
 		XXXXXX NULL;
XX -1386,6 +1493,14 @@ qlcnic_83xx_process_rcv(struct qlcnic_adapter *adapter,
 	XX (!skb)
 		XXXXXX buffer;
 
X	if (adapter->drv_mac_learn &&
X	    (adapter->flags & QLCNIC_ESWITCH_ENABLED)) {
X		t_vid = 0;
X		is_lb_pkt = qlcnic_83xx_is_lb_pkt(sts_data[1], 0);
X		qlcnic_add_lb_filter(adapter, skb, is_lb_pkt,
X				     cpu_to_le16(t_vid));
X	}
X
 	XX (length > rds_ring->skb_size)
 		XXXXXXXXXXXX rds_ring->skb_size);
 	XXXX
XX -1424,9 +1539,9 @@ qlcnic_83xx_process_lro(struct qlcnic_adapter *adapter,
 	XXXXXX tcphdr *th;
 	XXXX push;
 	XXX l2_hdr_offset, l4_hdr_offset;
X	int index;
X	int index, is_lb_pkt;
 	XXX lro_length, length, data_offset, gso_size;
X	u16 vid = 0xffff;
X	u16 vid = 0xffff, t_vid;
 
 	XX (unlikely(ring > adapter->max_rds_rings))
 		XXXXXX NULL;
XX -1447,6 +1562,14 @@ qlcnic_83xx_process_lro(struct qlcnic_adapter *adapter,
 	XXX = qlcnic_process_rxbuf(adapter, rds_ring, index, STATUS_CKSUM_OK);
 	XX (!skb)
 		XXXXXX buffer;
X
X	if (adapter->drv_mac_learn &&
X	    (adapter->flags & QLCNIC_ESWITCH_ENABLED)) {
X		t_vid = 0;
X		is_lb_pkt = qlcnic_83xx_is_lb_pkt(sts_data[1], 1);
X		qlcnic_add_lb_filter(adapter, skb, is_lb_pkt,
X				     cpu_to_le16(t_vid));
X	}
 	XX (qlcnic_83xxXXXXXXXXXXXXXXXXXXXXXXXX
 		XXXXXXXXXXX = l4_hdr_offset + QLCNIC_TCP_TS_HDR_SIZE;
 	XXXX
XXXX --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
XXXXX e03017a..5d5fd06 100644
XXX a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
XXX b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
XX -2208,6 +2208,7 @@ void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter)
 
 	XXXXXXXXXXXX = adapter->ahw->act_pci_func;
 	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
X	spin_lock_init(&adapter->rx_mac_learn_lock);
 
 	XX (qlcnic_82xx_check(adapter)) {
 		XXXXXXXXXXX = QLCNIC_LB_MAX_FILTERS;
XX -2231,6 +2232,20 @@ void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter)
 
 	XXX (i = 0; i < adapter->fhash.fbucket_size; i++)
 		XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
X
X	adapter->rx_fhash.fbucket_size = adapter->fhash.fbucket_size;
X
X	head = kcalloc(adapter->rx_fhash.fbucket_size,
X		       sizeof(struct hlist_head), GFP_ATOMIC);
X
X	if (!head)
X		return;
X
X	adapter->rx_fhash.fmax = (filter_size / act_pci_func);
X	adapter->rx_fhash.fhead = head;
X
X	for (i = 0; i < adapter->rx_fhash.fbucket_size; i++)
X		INIT_HLIST_HEAD(&adapter->rx_fhash.fhead[i]);
 X
 
 XXXXXX void qlcnic_free_lb_filters_mem(struct qlcnic_adapter *adapter)
XX -2240,6 XXXXXXXX @@ static void qlcnic_free_lb_filters_mem(struct qlcnic_adapter *adapter)
 
 	XXXXXXXXXXXXXXXXXXXX = NULL;
 	XXXXXXXXXXXXXXXXXXX = 0;
X
X	if (adapter->rx_fhash.fmax && adapter->rx_fhash.fhead)
X		kfree(adapter->rx_fhash.fhead);
X
X	adapter->rx_fhash.fmax = 0;
X	adapter->rx_fhash.fhead = NULL;
 X
 
 XXX qlcnic_check_temp(struct qlcnic_adapter *adapter)
XX 
XXXXX
