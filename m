From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH 2/3] cxgb4: function namespace cleanup (v2)
Date: Fri, 15 Oct 2010 18:11:42 -0700
Message-ID: <4CB8FBCE.3090401@chelsio.com>
References: <20101015224309.179898823@vyatta.com>	<20101015224523.633775810@vyatta.com> <20101015171057.409db0f2@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Divy Le Ray <divy@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>,
	Casey Leedom <leedom@chelsio.com>, netdev@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:3459 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993Ab0JPBLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 21:11:49 -0400
In-Reply-To: <20101015171057.409db0f2@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Make functions only used in one file local.
> Remove lots of dead code, relating to unsupported functions
> in mainline driver like RSS, IPv6, and TCP offload.

Thanks, this looks OK.  One exception, cxgb4_get_tcp_stats was intended to 
be used by the rdma driver.  I see that driver doesn't call it presently but 
if you don't mind can we give Steve a few hours to tell us if he has any 
imminent plans to use it.  If he doesn't offer to do something to use it for 
.37 it goes.

> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> Patch against version in linux-next. It keeps the hooks
> necessary for iscsi.
> 
>  drivers/net/cxgb4/cxgb4.h      |   17 -
>  drivers/net/cxgb4/cxgb4_main.c |   78 --------
>  drivers/net/cxgb4/cxgb4_uld.h  |    8 
>  drivers/net/cxgb4/l2t.c        |   34 ---
>  drivers/net/cxgb4/l2t.h        |    3 
>  drivers/net/cxgb4/t4_hw.c      |  394 -----------------------------------------
>  6 files changed, 3 insertions(+), 531 deletions(-)
> 
> --- a/drivers/net/cxgb4/cxgb4_main.c	2010-10-15 16:58:22.899742447 -0700
> +++ b/drivers/net/cxgb4/cxgb4_main.c	2010-10-15 17:02:22.336255220 -0700
> @@ -880,7 +880,7 @@ void *t4_alloc_mem(size_t size)
>  /*
>   * Free memory allocated through alloc_mem().
>   */
> -void t4_free_mem(void *addr)
> +static void t4_free_mem(void *addr)
>  {
>  	if (is_vmalloc_addr(addr))
>  		vfree(addr);
> @@ -2207,8 +2207,8 @@ static void mk_tid_release(struct sk_buf
>   * Queue a TID release request and if necessary schedule a work queue to
>   * process it.
>   */
> -void cxgb4_queue_tid_release(struct tid_info *t, unsigned int chan,
> -			     unsigned int tid)
> +static void cxgb4_queue_tid_release(struct tid_info *t, unsigned int chan,
> +				    unsigned int tid)
>  {
>  	void **p = &t->tid_tab[tid];
>  	struct adapter *adap = container_of(t, struct adapter, tids);
> @@ -2223,7 +2223,6 @@ void cxgb4_queue_tid_release(struct tid_
>  	}
>  	spin_unlock_bh(&adap->tid_release_lock);
>  }
> -EXPORT_SYMBOL(cxgb4_queue_tid_release);
>  
>  /*
>   * Process the list of pending TID release requests.
> @@ -2356,48 +2355,6 @@ int cxgb4_create_server(const struct net
>  EXPORT_SYMBOL(cxgb4_create_server);
>  
>  /**
> - *	cxgb4_create_server6 - create an IPv6 server
> - *	@dev: the device
> - *	@stid: the server TID
> - *	@sip: local IPv6 address to bind server to
> - *	@sport: the server's TCP port
> - *	@queue: queue to direct messages from this server to
> - *
> - *	Create an IPv6 server for the given port and address.
> - *	Returns <0 on error and one of the %NET_XMIT_* values on success.
> - */
> -int cxgb4_create_server6(const struct net_device *dev, unsigned int stid,
> -			 const struct in6_addr *sip, __be16 sport,
> -			 unsigned int queue)
> -{
> -	unsigned int chan;
> -	struct sk_buff *skb;
> -	struct adapter *adap;
> -	struct cpl_pass_open_req6 *req;
> -
> -	skb = alloc_skb(sizeof(*req), GFP_KERNEL);
> -	if (!skb)
> -		return -ENOMEM;
> -
> -	adap = netdev2adap(dev);
> -	req = (struct cpl_pass_open_req6 *)__skb_put(skb, sizeof(*req));
> -	INIT_TP_WR(req, 0);
> -	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_PASS_OPEN_REQ6, stid));
> -	req->local_port = sport;
> -	req->peer_port = htons(0);
> -	req->local_ip_hi = *(__be64 *)(sip->s6_addr);
> -	req->local_ip_lo = *(__be64 *)(sip->s6_addr + 8);
> -	req->peer_ip_hi = cpu_to_be64(0);
> -	req->peer_ip_lo = cpu_to_be64(0);
> -	chan = rxq_to_chan(&adap->sge, queue);
> -	req->opt0 = cpu_to_be64(TX_CHAN(chan));
> -	req->opt1 = cpu_to_be64(CONN_POLICY_ASK |
> -				SYN_RSS_ENABLE | SYN_RSS_QUEUE(queue));
> -	return t4_mgmt_tx(adap, skb);
> -}
> -EXPORT_SYMBOL(cxgb4_create_server6);
> -
> -/**
>   *	cxgb4_best_mtu - find the entry in the MTU table closest to an MTU
>   *	@mtus: the HW MTU table
>   *	@mtu: the target MTU
> @@ -2456,35 +2413,6 @@ unsigned int cxgb4_port_idx(const struct
>  }
>  EXPORT_SYMBOL(cxgb4_port_idx);
>  
> -/**
> - *	cxgb4_netdev_by_hwid - return the net device of a HW port
> - *	@pdev: identifies the adapter
> - *	@id: the HW port id
> - *
> - *	Return the net device associated with the interface with the given HW
> - *	id.
> - */
> -struct net_device *cxgb4_netdev_by_hwid(struct pci_dev *pdev, unsigned int id)
> -{
> -	const struct adapter *adap = pci_get_drvdata(pdev);
> -
> -	if (!adap || id >= NCHAN)
> -		return NULL;
> -	id = adap->chan_map[id];
> -	return id < MAX_NPORTS ? adap->port[id] : NULL;
> -}
> -EXPORT_SYMBOL(cxgb4_netdev_by_hwid);
> -
> -void cxgb4_get_tcp_stats(struct pci_dev *pdev, struct tp_tcp_stats *v4,
> -			 struct tp_tcp_stats *v6)
> -{
> -	struct adapter *adap = pci_get_drvdata(pdev);
> -
> -	spin_lock(&adap->stats_lock);
> -	t4_tp_get_tcp_stats(adap, v4, v6);
> -	spin_unlock(&adap->stats_lock);
> -}
> -EXPORT_SYMBOL(cxgb4_get_tcp_stats);
>  
>  void cxgb4_iscsi_init(struct net_device *dev, unsigned int tag_mask,
>  		      const unsigned int *pgsz_order)
> --- a/drivers/net/cxgb4/cxgb4_uld.h	2010-10-15 16:58:22.875741593 -0700
> +++ b/drivers/net/cxgb4/cxgb4_uld.h	2010-10-15 17:07:33.695516682 -0700
> @@ -139,16 +139,11 @@ int cxgb4_alloc_stid(struct tid_info *t,
>  void cxgb4_free_atid(struct tid_info *t, unsigned int atid);
>  void cxgb4_free_stid(struct tid_info *t, unsigned int stid, int family);
>  void cxgb4_remove_tid(struct tid_info *t, unsigned int qid, unsigned int tid);
> -void cxgb4_queue_tid_release(struct tid_info *t, unsigned int chan,
> -			     unsigned int tid);
>  
>  struct in6_addr;
>  
>  int cxgb4_create_server(const struct net_device *dev, unsigned int stid,
>  			__be32 sip, __be16 sport, unsigned int queue);
> -int cxgb4_create_server6(const struct net_device *dev, unsigned int stid,
> -			 const struct in6_addr *sip, __be16 sport,
> -			 unsigned int queue);
>  
>  static inline void set_wr_txq(struct sk_buff *skb, int prio, int queue)
>  {
> @@ -233,11 +228,8 @@ int cxgb4_ofld_send(struct net_device *d
>  unsigned int cxgb4_port_chan(const struct net_device *dev);
>  unsigned int cxgb4_port_viid(const struct net_device *dev);
>  unsigned int cxgb4_port_idx(const struct net_device *dev);
> -struct net_device *cxgb4_netdev_by_hwid(struct pci_dev *pdev, unsigned int id);
>  unsigned int cxgb4_best_mtu(const unsigned short *mtus, unsigned short mtu,
>  			    unsigned int *idx);
> -void cxgb4_get_tcp_stats(struct pci_dev *pdev, struct tp_tcp_stats *v4,
> -			 struct tp_tcp_stats *v6);
>  void cxgb4_iscsi_init(struct net_device *dev, unsigned int tag_mask,
>  		      const unsigned int *pgsz_order);
>  struct sk_buff *cxgb4_pktgl_to_skb(const struct pkt_gl *gl,
> --- a/drivers/net/cxgb4/cxgb4.h	2010-10-15 16:58:22.847740597 -0700
> +++ b/drivers/net/cxgb4/cxgb4.h	2010-10-15 17:00:42.852719427 -0700
> @@ -592,7 +592,6 @@ void t4_os_portmod_changed(const struct
>  void t4_os_link_changed(struct adapter *adap, int port_id, int link_stat);
>  
>  void *t4_alloc_mem(size_t size);
> -void t4_free_mem(void *addr);
>  
>  void t4_free_sge_resources(struct adapter *adap);
>  irq_handler_t t4_intr_handler(struct adapter *adap);
> @@ -651,7 +650,6 @@ static inline int t4_wr_mbox_ns(struct a
>  
>  void t4_intr_enable(struct adapter *adapter);
>  void t4_intr_disable(struct adapter *adapter);
> -void t4_intr_clear(struct adapter *adapter);
>  int t4_slow_intr_handler(struct adapter *adapter);
>  
>  int t4_wait_dev_ready(struct adapter *adap);
> @@ -664,26 +662,16 @@ int t4_check_fw_version(struct adapter *
>  int t4_prep_adapter(struct adapter *adapter);
>  int t4_port_init(struct adapter *adap, int mbox, int pf, int vf);
>  void t4_fatal_err(struct adapter *adapter);
> -int t4_set_trace_filter(struct adapter *adapter, const struct trace_params *tp,
> -			int filter_index, int enable);
> -void t4_get_trace_filter(struct adapter *adapter, struct trace_params *tp,
> -			 int filter_index, int *enabled);
>  int t4_config_rss_range(struct adapter *adapter, int mbox, unsigned int viid,
>  			int start, int n, const u16 *rspq, unsigned int nrspq);
>  int t4_config_glbl_rss(struct adapter *adapter, int mbox, unsigned int mode,
>  		       unsigned int flags);
> -int t4_read_rss(struct adapter *adapter, u16 *entries);
>  int t4_mc_read(struct adapter *adap, u32 addr, __be32 *data, u64 *parity);
>  int t4_edc_read(struct adapter *adap, int idx, u32 addr, __be32 *data,
>  		u64 *parity);
>  
>  void t4_get_port_stats(struct adapter *adap, int idx, struct port_stats *p);
> -void t4_get_lb_stats(struct adapter *adap, int idx, struct lb_port_stats *p);
> -
>  void t4_read_mtu_tbl(struct adapter *adap, u16 *mtus, u8 *mtu_log);
> -void t4_tp_get_err_stats(struct adapter *adap, struct tp_err_stats *st);
> -void t4_tp_get_tcp_stats(struct adapter *adap, struct tp_tcp_stats *v4,
> -			 struct tp_tcp_stats *v6);
>  void t4_load_mtus(struct adapter *adap, const unsigned short *mtus,
>  		  const unsigned short *alpha, const unsigned short *beta);
>  
> @@ -711,8 +699,6 @@ int t4_cfg_pfvf(struct adapter *adap, un
>  int t4_alloc_vi(struct adapter *adap, unsigned int mbox, unsigned int port,
>  		unsigned int pf, unsigned int vf, unsigned int nmac, u8 *mac,
>  		unsigned int *rss_size);
> -int t4_free_vi(struct adapter *adap, unsigned int mbox, unsigned int pf,
> -	       unsigned int vf, unsigned int viid);
>  int t4_set_rxmode(struct adapter *adap, unsigned int mbox, unsigned int viid,
>  		int mtu, int promisc, int all_multi, int bcast, int vlanex,
>  		bool sleep_ok);
> @@ -731,9 +717,6 @@ int t4_mdio_rd(struct adapter *adap, uns
>  	       unsigned int mmd, unsigned int reg, u16 *valp);
>  int t4_mdio_wr(struct adapter *adap, unsigned int mbox, unsigned int phy_addr,
>  	       unsigned int mmd, unsigned int reg, u16 val);
> -int t4_iq_start_stop(struct adapter *adap, unsigned int mbox, bool start,
> -		     unsigned int pf, unsigned int vf, unsigned int iqid,
> -		     unsigned int fl0id, unsigned int fl1id);
>  int t4_iq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
>  	       unsigned int vf, unsigned int iqtype, unsigned int iqid,
>  	       unsigned int fl0id, unsigned int fl1id);
> --- a/drivers/net/cxgb4/l2t.c	2010-10-15 16:58:22.883741877 -0700
> +++ b/drivers/net/cxgb4/l2t.c	2010-10-15 17:00:42.856719569 -0700
> @@ -481,40 +481,6 @@ void t4_l2t_update(struct adapter *adap,
>  		handle_failed_resolution(adap, arpq);
>  }
>  
> -/*
> - * Allocate an L2T entry for use by a switching rule.  Such entries need to be
> - * explicitly freed and while busy they are not on any hash chain, so normal
> - * address resolution updates do not see them.
> - */
> -struct l2t_entry *t4_l2t_alloc_switching(struct l2t_data *d)
> -{
> -	struct l2t_entry *e;
> -
> -	write_lock_bh(&d->lock);
> -	e = alloc_l2e(d);
> -	if (e) {
> -		spin_lock(&e->lock);          /* avoid race with t4_l2t_free */
> -		e->state = L2T_STATE_SWITCHING;
> -		atomic_set(&e->refcnt, 1);
> -		spin_unlock(&e->lock);
> -	}
> -	write_unlock_bh(&d->lock);
> -	return e;
> -}
> -
> -/*
> - * Sets/updates the contents of a switching L2T entry that has been allocated
> - * with an earlier call to @t4_l2t_alloc_switching.
> - */
> -int t4_l2t_set_switching(struct adapter *adap, struct l2t_entry *e, u16 vlan,
> -			 u8 port, u8 *eth_addr)
> -{
> -	e->vlan = vlan;
> -	e->lport = port;
> -	memcpy(e->dmac, eth_addr, ETH_ALEN);
> -	return write_l2e(adap, e, 0);
> -}
> -
>  struct l2t_data *t4_init_l2t(void)
>  {
>  	int i;
> --- a/drivers/net/cxgb4/l2t.h	2010-10-15 16:58:22.855740881 -0700
> +++ b/drivers/net/cxgb4/l2t.h	2010-10-15 17:00:42.856719569 -0700
> @@ -100,9 +100,6 @@ struct l2t_entry *cxgb4_l2t_get(struct l
>  				unsigned int priority);
>  
>  void t4_l2t_update(struct adapter *adap, struct neighbour *neigh);
> -struct l2t_entry *t4_l2t_alloc_switching(struct l2t_data *d);
> -int t4_l2t_set_switching(struct adapter *adap, struct l2t_entry *e, u16 vlan,
> -			 u8 port, u8 *eth_addr);
>  struct l2t_data *t4_init_l2t(void);
>  void do_l2t_write_rpl(struct adapter *p, const struct cpl_l2t_write_rpl *rpl);
>  
> --- a/drivers/net/cxgb4/t4_hw.c	2010-10-15 16:58:22.839740313 -0700
> +++ b/drivers/net/cxgb4/t4_hw.c	2010-10-15 17:00:42.860719711 -0700
> @@ -97,53 +97,6 @@ void t4_set_reg_field(struct adapter *ad
>  	(void) t4_read_reg(adapter, addr);      /* flush */
>  }
>  
> -/**
> - *	t4_read_indirect - read indirectly addressed registers
> - *	@adap: the adapter
> - *	@addr_reg: register holding the indirect address
> - *	@data_reg: register holding the value of the indirect register
> - *	@vals: where the read register values are stored
> - *	@nregs: how many indirect registers to read
> - *	@start_idx: index of first indirect register to read
> - *
> - *	Reads registers that are accessed indirectly through an address/data
> - *	register pair.
> - */
> -static void t4_read_indirect(struct adapter *adap, unsigned int addr_reg,
> -			     unsigned int data_reg, u32 *vals,
> -			     unsigned int nregs, unsigned int start_idx)
> -{
> -	while (nregs--) {
> -		t4_write_reg(adap, addr_reg, start_idx);
> -		*vals++ = t4_read_reg(adap, data_reg);
> -		start_idx++;
> -	}
> -}
> -
> -#if 0
> -/**
> - *	t4_write_indirect - write indirectly addressed registers
> - *	@adap: the adapter
> - *	@addr_reg: register holding the indirect addresses
> - *	@data_reg: register holding the value for the indirect registers
> - *	@vals: values to write
> - *	@nregs: how many indirect registers to write
> - *	@start_idx: address of first indirect register to write
> - *
> - *	Writes a sequential block of registers that are accessed indirectly
> - *	through an address/data register pair.
> - */
> -static void t4_write_indirect(struct adapter *adap, unsigned int addr_reg,
> -			      unsigned int data_reg, const u32 *vals,
> -			      unsigned int nregs, unsigned int start_idx)
> -{
> -	while (nregs--) {
> -		t4_write_reg(adap, addr_reg, start_idx++);
> -		t4_write_reg(adap, data_reg, *vals++);
> -	}
> -}
> -#endif
> -
>  /*
>   * Get the reply to a mailbox command and store it in @rpl in big-endian order.
>   */
> @@ -1560,44 +1513,6 @@ void t4_intr_disable(struct adapter *ada
>  }
>  
>  /**
> - *	t4_intr_clear - clear all interrupts
> - *	@adapter: the adapter whose interrupts should be cleared
> - *
> - *	Clears all interrupts.  The caller must be a PCI function managing
> - *	global interrupts.
> - */
> -void t4_intr_clear(struct adapter *adapter)
> -{
> -	static const unsigned int cause_reg[] = {
> -		SGE_INT_CAUSE1, SGE_INT_CAUSE2, SGE_INT_CAUSE3,
> -		PCIE_CORE_UTL_SYSTEM_BUS_AGENT_STATUS,
> -		PCIE_CORE_UTL_PCI_EXPRESS_PORT_STATUS,
> -		PCIE_NONFAT_ERR, PCIE_INT_CAUSE,
> -		MC_INT_CAUSE,
> -		MA_INT_WRAP_STATUS, MA_PARITY_ERROR_STATUS, MA_INT_CAUSE,
> -		EDC_INT_CAUSE, EDC_REG(EDC_INT_CAUSE, 1),
> -		CIM_HOST_INT_CAUSE, CIM_HOST_UPACC_INT_CAUSE,
> -		MYPF_REG(CIM_PF_HOST_INT_CAUSE),
> -		TP_INT_CAUSE,
> -		ULP_RX_INT_CAUSE, ULP_TX_INT_CAUSE,
> -		PM_RX_INT_CAUSE, PM_TX_INT_CAUSE,
> -		MPS_RX_PERR_INT_CAUSE,
> -		CPL_INTR_CAUSE,
> -		MYPF_REG(PL_PF_INT_CAUSE),
> -		PL_PL_INT_CAUSE,
> -		LE_DB_INT_CAUSE,
> -	};
> -
> -	unsigned int i;
> -
> -	for (i = 0; i < ARRAY_SIZE(cause_reg); ++i)
> -		t4_write_reg(adapter, cause_reg[i], 0xffffffff);
> -
> -	t4_write_reg(adapter, PL_INT_CAUSE, GLBL_INTR_MASK);
> -	(void) t4_read_reg(adapter, PL_INT_CAUSE);          /* flush */
> -}
> -
> -/**
>   *	hash_mac_addr - return the hash value of a MAC address
>   *	@addr: the 48-bit Ethernet MAC address
>   *
> @@ -1709,98 +1624,6 @@ int t4_config_glbl_rss(struct adapter *a
>  	return t4_wr_mbox(adapter, mbox, &c, sizeof(c), NULL);
>  }
>  
> -/* Read an RSS table row */
> -static int rd_rss_row(struct adapter *adap, int row, u32 *val)
> -{
> -	t4_write_reg(adap, TP_RSS_LKP_TABLE, 0xfff00000 | row);
> -	return t4_wait_op_done_val(adap, TP_RSS_LKP_TABLE, LKPTBLROWVLD, 1,
> -				   5, 0, val);
> -}
> -
> -/**
> - *	t4_read_rss - read the contents of the RSS mapping table
> - *	@adapter: the adapter
> - *	@map: holds the contents of the RSS mapping table
> - *
> - *	Reads the contents of the RSS hash->queue mapping table.
> - */
> -int t4_read_rss(struct adapter *adapter, u16 *map)
> -{
> -	u32 val;
> -	int i, ret;
> -
> -	for (i = 0; i < RSS_NENTRIES / 2; ++i) {
> -		ret = rd_rss_row(adapter, i, &val);
> -		if (ret)
> -			return ret;
> -		*map++ = LKPTBLQUEUE0_GET(val);
> -		*map++ = LKPTBLQUEUE1_GET(val);
> -	}
> -	return 0;
> -}
> -
> -/**
> - *	t4_tp_get_tcp_stats - read TP's TCP MIB counters
> - *	@adap: the adapter
> - *	@v4: holds the TCP/IP counter values
> - *	@v6: holds the TCP/IPv6 counter values
> - *
> - *	Returns the values of TP's TCP/IP and TCP/IPv6 MIB counters.
> - *	Either @v4 or @v6 may be %NULL to skip the corresponding stats.
> - */
> -void t4_tp_get_tcp_stats(struct adapter *adap, struct tp_tcp_stats *v4,
> -			 struct tp_tcp_stats *v6)
> -{
> -	u32 val[TP_MIB_TCP_RXT_SEG_LO - TP_MIB_TCP_OUT_RST + 1];
> -
> -#define STAT_IDX(x) ((TP_MIB_TCP_##x) - TP_MIB_TCP_OUT_RST)
> -#define STAT(x)     val[STAT_IDX(x)]
> -#define STAT64(x)   (((u64)STAT(x##_HI) << 32) | STAT(x##_LO))
> -
> -	if (v4) {
> -		t4_read_indirect(adap, TP_MIB_INDEX, TP_MIB_DATA, val,
> -				 ARRAY_SIZE(val), TP_MIB_TCP_OUT_RST);
> -		v4->tcpOutRsts = STAT(OUT_RST);
> -		v4->tcpInSegs  = STAT64(IN_SEG);
> -		v4->tcpOutSegs = STAT64(OUT_SEG);
> -		v4->tcpRetransSegs = STAT64(RXT_SEG);
> -	}
> -	if (v6) {
> -		t4_read_indirect(adap, TP_MIB_INDEX, TP_MIB_DATA, val,
> -				 ARRAY_SIZE(val), TP_MIB_TCP_V6OUT_RST);
> -		v6->tcpOutRsts = STAT(OUT_RST);
> -		v6->tcpInSegs  = STAT64(IN_SEG);
> -		v6->tcpOutSegs = STAT64(OUT_SEG);
> -		v6->tcpRetransSegs = STAT64(RXT_SEG);
> -	}
> -#undef STAT64
> -#undef STAT
> -#undef STAT_IDX
> -}
> -
> -/**
> - *	t4_tp_get_err_stats - read TP's error MIB counters
> - *	@adap: the adapter
> - *	@st: holds the counter values
> - *
> - *	Returns the values of TP's error counters.
> - */
> -void t4_tp_get_err_stats(struct adapter *adap, struct tp_err_stats *st)
> -{
> -	t4_read_indirect(adap, TP_MIB_INDEX, TP_MIB_DATA, st->macInErrs,
> -			 12, TP_MIB_MAC_IN_ERR_0);
> -	t4_read_indirect(adap, TP_MIB_INDEX, TP_MIB_DATA, st->tnlCongDrops,
> -			 8, TP_MIB_TNL_CNG_DROP_0);
> -	t4_read_indirect(adap, TP_MIB_INDEX, TP_MIB_DATA, st->tnlTxDrops,
> -			 4, TP_MIB_TNL_DROP_0);
> -	t4_read_indirect(adap, TP_MIB_INDEX, TP_MIB_DATA, st->ofldVlanDrops,
> -			 4, TP_MIB_OFD_VLN_DROP_0);
> -	t4_read_indirect(adap, TP_MIB_INDEX, TP_MIB_DATA, st->tcp6InErrs,
> -			 4, TP_MIB_TCP_V6IN_ERR_0);
> -	t4_read_indirect(adap, TP_MIB_INDEX, TP_MIB_DATA, &st->ofldNoNeigh,
> -			 2, TP_MIB_OFD_ARP_DROP);
> -}
> -
>  /**
>   *	t4_read_mtu_tbl - returns the values in the HW path MTU table
>   *	@adap: the adapter
> @@ -1916,122 +1739,6 @@ void t4_load_mtus(struct adapter *adap,
>  }
>  
>  /**
> - *	t4_set_trace_filter - configure one of the tracing filters
> - *	@adap: the adapter
> - *	@tp: the desired trace filter parameters
> - *	@idx: which filter to configure
> - *	@enable: whether to enable or disable the filter
> - *
> - *	Configures one of the tracing filters available in HW.  If @enable is
> - *	%0 @tp is not examined and may be %NULL.
> - */
> -int t4_set_trace_filter(struct adapter *adap, const struct trace_params *tp,
> -			int idx, int enable)
> -{
> -	int i, ofst = idx * 4;
> -	u32 data_reg, mask_reg, cfg;
> -	u32 multitrc = TRCMULTIFILTER;
> -
> -	if (!enable) {
> -		t4_write_reg(adap, MPS_TRC_FILTER_MATCH_CTL_A + ofst, 0);
> -		goto out;
> -	}
> -
> -	if (tp->port > 11 || tp->invert > 1 || tp->skip_len > 0x1f ||
> -	    tp->skip_ofst > 0x1f || tp->min_len > 0x1ff ||
> -	    tp->snap_len > 9600 || (idx && tp->snap_len > 256))
> -		return -EINVAL;
> -
> -	if (tp->snap_len > 256) {            /* must be tracer 0 */
> -		if ((t4_read_reg(adap, MPS_TRC_FILTER_MATCH_CTL_A + 4) |
> -		     t4_read_reg(adap, MPS_TRC_FILTER_MATCH_CTL_A + 8) |
> -		     t4_read_reg(adap, MPS_TRC_FILTER_MATCH_CTL_A + 12)) & TFEN)
> -			return -EINVAL;  /* other tracers are enabled */
> -		multitrc = 0;
> -	} else if (idx) {
> -		i = t4_read_reg(adap, MPS_TRC_FILTER_MATCH_CTL_B);
> -		if (TFCAPTUREMAX_GET(i) > 256 &&
> -		    (t4_read_reg(adap, MPS_TRC_FILTER_MATCH_CTL_A) & TFEN))
> -			return -EINVAL;
> -	}
> -
> -	/* stop the tracer we'll be changing */
> -	t4_write_reg(adap, MPS_TRC_FILTER_MATCH_CTL_A + ofst, 0);
> -
> -	/* disable tracing globally if running in the wrong single/multi mode */
> -	cfg = t4_read_reg(adap, MPS_TRC_CFG);
> -	if ((cfg & TRCEN) && multitrc != (cfg & TRCMULTIFILTER)) {
> -		t4_write_reg(adap, MPS_TRC_CFG, cfg ^ TRCEN);
> -		t4_read_reg(adap, MPS_TRC_CFG);                  /* flush */
> -		msleep(1);
> -		if (!(t4_read_reg(adap, MPS_TRC_CFG) & TRCFIFOEMPTY))
> -			return -ETIMEDOUT;
> -	}
> -	/*
> -	 * At this point either the tracing is enabled and in the right mode or
> -	 * disabled.
> -	 */
> -
> -	idx *= (MPS_TRC_FILTER1_MATCH - MPS_TRC_FILTER0_MATCH);
> -	data_reg = MPS_TRC_FILTER0_MATCH + idx;
> -	mask_reg = MPS_TRC_FILTER0_DONT_CARE + idx;
> -
> -	for (i = 0; i < TRACE_LEN / 4; i++, data_reg += 4, mask_reg += 4) {
> -		t4_write_reg(adap, data_reg, tp->data[i]);
> -		t4_write_reg(adap, mask_reg, ~tp->mask[i]);
> -	}
> -	t4_write_reg(adap, MPS_TRC_FILTER_MATCH_CTL_B + ofst,
> -		     TFCAPTUREMAX(tp->snap_len) |
> -		     TFMINPKTSIZE(tp->min_len));
> -	t4_write_reg(adap, MPS_TRC_FILTER_MATCH_CTL_A + ofst,
> -		     TFOFFSET(tp->skip_ofst) | TFLENGTH(tp->skip_len) |
> -		     TFPORT(tp->port) | TFEN |
> -		     (tp->invert ? TFINVERTMATCH : 0));
> -
> -	cfg &= ~TRCMULTIFILTER;
> -	t4_write_reg(adap, MPS_TRC_CFG, cfg | TRCEN | multitrc);
> -out:	t4_read_reg(adap, MPS_TRC_CFG);  /* flush */
> -	return 0;
> -}
> -
> -/**
> - *	t4_get_trace_filter - query one of the tracing filters
> - *	@adap: the adapter
> - *	@tp: the current trace filter parameters
> - *	@idx: which trace filter to query
> - *	@enabled: non-zero if the filter is enabled
> - *
> - *	Returns the current settings of one of the HW tracing filters.
> - */
> -void t4_get_trace_filter(struct adapter *adap, struct trace_params *tp, int idx,
> -			 int *enabled)
> -{
> -	u32 ctla, ctlb;
> -	int i, ofst = idx * 4;
> -	u32 data_reg, mask_reg;
> -
> -	ctla = t4_read_reg(adap, MPS_TRC_FILTER_MATCH_CTL_A + ofst);
> -	ctlb = t4_read_reg(adap, MPS_TRC_FILTER_MATCH_CTL_B + ofst);
> -
> -	*enabled = !!(ctla & TFEN);
> -	tp->snap_len = TFCAPTUREMAX_GET(ctlb);
> -	tp->min_len = TFMINPKTSIZE_GET(ctlb);
> -	tp->skip_ofst = TFOFFSET_GET(ctla);
> -	tp->skip_len = TFLENGTH_GET(ctla);
> -	tp->invert = !!(ctla & TFINVERTMATCH);
> -	tp->port = TFPORT_GET(ctla);
> -
> -	ofst = (MPS_TRC_FILTER1_MATCH - MPS_TRC_FILTER0_MATCH) * idx;
> -	data_reg = MPS_TRC_FILTER0_MATCH + ofst;
> -	mask_reg = MPS_TRC_FILTER0_DONT_CARE + ofst;
> -
> -	for (i = 0; i < TRACE_LEN / 4; i++, data_reg += 4, mask_reg += 4) {
> -		tp->mask[i] = ~t4_read_reg(adap, mask_reg);
> -		tp->data[i] = t4_read_reg(adap, data_reg) & tp->mask[i];
> -	}
> -}
> -
> -/**
>   *	get_mps_bg_map - return the buffer groups associated with a port
>   *	@adap: the adapter
>   *	@idx: the port index
> @@ -2133,52 +1840,6 @@ void t4_get_port_stats(struct adapter *a
>  }
>  
>  /**
> - *	t4_get_lb_stats - collect loopback port statistics
> - *	@adap: the adapter
> - *	@idx: the loopback port index
> - *	@p: the stats structure to fill
> - *
> - *	Return HW statistics for the given loopback port.
> - */
> -void t4_get_lb_stats(struct adapter *adap, int idx, struct lb_port_stats *p)
> -{
> -	u32 bgmap = get_mps_bg_map(adap, idx);
> -
> -#define GET_STAT(name) \
> -	t4_read_reg64(adap, PORT_REG(idx, MPS_PORT_STAT_LB_PORT_##name##_L))
> -#define GET_STAT_COM(name) t4_read_reg64(adap, MPS_STAT_##name##_L)
> -
> -	p->octets           = GET_STAT(BYTES);
> -	p->frames           = GET_STAT(FRAMES);
> -	p->bcast_frames     = GET_STAT(BCAST);
> -	p->mcast_frames     = GET_STAT(MCAST);
> -	p->ucast_frames     = GET_STAT(UCAST);
> -	p->error_frames     = GET_STAT(ERROR);
> -
> -	p->frames_64        = GET_STAT(64B);
> -	p->frames_65_127    = GET_STAT(65B_127B);
> -	p->frames_128_255   = GET_STAT(128B_255B);
> -	p->frames_256_511   = GET_STAT(256B_511B);
> -	p->frames_512_1023  = GET_STAT(512B_1023B);
> -	p->frames_1024_1518 = GET_STAT(1024B_1518B);
> -	p->frames_1519_max  = GET_STAT(1519B_MAX);
> -	p->drop             = t4_read_reg(adap, PORT_REG(idx,
> -					  MPS_PORT_STAT_LB_PORT_DROP_FRAMES));
> -
> -	p->ovflow0 = (bgmap & 1) ? GET_STAT_COM(RX_BG_0_LB_DROP_FRAME) : 0;
> -	p->ovflow1 = (bgmap & 2) ? GET_STAT_COM(RX_BG_1_LB_DROP_FRAME) : 0;
> -	p->ovflow2 = (bgmap & 4) ? GET_STAT_COM(RX_BG_2_LB_DROP_FRAME) : 0;
> -	p->ovflow3 = (bgmap & 8) ? GET_STAT_COM(RX_BG_3_LB_DROP_FRAME) : 0;
> -	p->trunc0 = (bgmap & 1) ? GET_STAT_COM(RX_BG_0_LB_TRUNC_FRAME) : 0;
> -	p->trunc1 = (bgmap & 2) ? GET_STAT_COM(RX_BG_1_LB_TRUNC_FRAME) : 0;
> -	p->trunc2 = (bgmap & 4) ? GET_STAT_COM(RX_BG_2_LB_TRUNC_FRAME) : 0;
> -	p->trunc3 = (bgmap & 8) ? GET_STAT_COM(RX_BG_3_LB_TRUNC_FRAME) : 0;
> -
> -#undef GET_STAT
> -#undef GET_STAT_COM
> -}
> -
> -/**
>   *	t4_wol_magic_enable - enable/disable magic packet WoL
>   *	@adap: the adapter
>   *	@port: the physical port index
> @@ -2584,30 +2245,6 @@ int t4_alloc_vi(struct adapter *adap, un
>  }
>  
>  /**
> - *	t4_free_vi - free a virtual interface
> - *	@adap: the adapter
> - *	@mbox: mailbox to use for the FW command
> - *	@pf: the PF owning the VI
> - *	@vf: the VF owning the VI
> - *	@viid: virtual interface identifiler
> - *
> - *	Free a previously allocated virtual interface.
> - */
> -int t4_free_vi(struct adapter *adap, unsigned int mbox, unsigned int pf,
> -	       unsigned int vf, unsigned int viid)
> -{
> -	struct fw_vi_cmd c;
> -
> -	memset(&c, 0, sizeof(c));
> -	c.op_to_vfn = htonl(FW_CMD_OP(FW_VI_CMD) | FW_CMD_REQUEST |
> -			    FW_CMD_EXEC | FW_VI_CMD_PFN(pf) |
> -			    FW_VI_CMD_VFN(vf));
> -	c.alloc_to_len16 = htonl(FW_VI_CMD_FREE | FW_LEN16(c));
> -	c.type_viid = htons(FW_VI_CMD_VIID(viid));
> -	return t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
> -}
> -
> -/**
>   *	t4_set_rxmode - set Rx properties of a virtual interface
>   *	@adap: the adapter
>   *	@mbox: mailbox to use for the FW command
> @@ -2832,37 +2469,6 @@ int t4_identify_port(struct adapter *ada
>  	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
>  }
>  
> -/**
> - *	t4_iq_start_stop - enable/disable an ingress queue and its FLs
> - *	@adap: the adapter
> - *	@mbox: mailbox to use for the FW command
> - *	@start: %true to enable the queues, %false to disable them
> - *	@pf: the PF owning the queues
> - *	@vf: the VF owning the queues
> - *	@iqid: ingress queue id
> - *	@fl0id: FL0 queue id or 0xffff if no attached FL0
> - *	@fl1id: FL1 queue id or 0xffff if no attached FL1
> - *
> - *	Starts or stops an ingress queue and its associated FLs, if any.
> - */
> -int t4_iq_start_stop(struct adapter *adap, unsigned int mbox, bool start,
> -		     unsigned int pf, unsigned int vf, unsigned int iqid,
> -		     unsigned int fl0id, unsigned int fl1id)
> -{
> -	struct fw_iq_cmd c;
> -
> -	memset(&c, 0, sizeof(c));
> -	c.op_to_vfn = htonl(FW_CMD_OP(FW_IQ_CMD) | FW_CMD_REQUEST |
> -			    FW_CMD_EXEC | FW_IQ_CMD_PFN(pf) |
> -			    FW_IQ_CMD_VFN(vf));
> -	c.alloc_to_len16 = htonl(FW_IQ_CMD_IQSTART(start) |
> -				 FW_IQ_CMD_IQSTOP(!start) | FW_LEN16(c));
> -	c.iqid = htons(iqid);
> -	c.fl0id = htons(fl0id);
> -	c.fl1id = htons(fl1id);
> -	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
> -}
> -
>  /**
>   *	t4_iq_free - free an ingress queue and its FLs
>   *	@adap: the adapter

