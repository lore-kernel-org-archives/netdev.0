From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next v3] Add support of Cavium Liquidio ethernet adapters
Date: Fri, 19 Dec 2014 22:48:20 +0100
Message-ID: <54949D24.1040707@gmx.de>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com> <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:62632 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751336AbaLSVsg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2014 16:48:36 -0500
In-Reply-To: <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19.12.2014 04:25, Raghu Vatsavayi wrote:
> +static int setup_nic_devices(struct octeon_device *octeon_dev)
> +{
> +	struct lio *lio = NULL;
> +	struct net_device *netdev;
> +	uint8_t macaddr[6], i, j;
> +	int octeon_id;
> +	struct octeon_soft_command *sc;
> +	struct liquidio_if_cfg_resp *resp;
> +	int retval;
> +	int num_iqueues;
> +	int num_oqueues;
> +	int q_no;
> +	uint64_t q_mask;
> +	int num_cpus = num_online_cpus();
> +
> +	if (num_cpus & (num_cpus - 1))
> +		/* numcpus is not a power of 2 */
> +		num_cpus = 1U << (fls(num_cpus) - 1);
> +	octeon_id = octeon_dev->octeon_id;
> +
> +	sc = kmalloc(sizeof(*sc), GFP_ATOMIC);
> +	if (!sc)
> +		return -ENOMEM;
> +
> +	resp = kmalloc(sizeof(*resp), GFP_KERNEL);
> +	if (!resp) {
> +		kfree(sc);
> +		return -ENOMEM;
> +	}
> +
> +	for (i = 0; i < octeon_dev->props.ifcount; i++) {
> +		memset(sc, 0, sizeof(struct octeon_soft_command));
> +		memset(resp, 0, sizeof(struct liquidio_if_cfg_resp));
> +		num_iqueues =
> +			CFG_GET_NUM_TXQS_NIC_IF(octeon_get_conf(octeon_dev), i);
> +		num_oqueues =
> +			CFG_GET_NUM_RXQS_NIC_IF(octeon_get_conf(octeon_dev), i);
> +		if (num_iqueues > num_cpus)
> +			num_iqueues = num_cpus;
> +		if (num_oqueues > num_cpus)
> +			num_oqueues = num_cpus;
> +		lio_dev_dbg(octeon_dev,
> +			    "requesting config for interface %d, iqs %d, oqs %d\n",
> +			    i, num_iqueues, num_oqueues);
> +		ACCESS_ONCE(resp->s.cond) = 0;
> +		resp->s.octeon_id = get_octeon_device_id(octeon_dev);
> +		init_waitqueue_head(&resp->s.wc);
> +
> +		octeon_prepare_soft_command(octeon_dev, sc, OPCODE_NIC,
> +					    OPCODE_NIC_IF_CFG, i, num_iqueues,
> +					    num_oqueues, NULL, 0, &resp->rh,
> +					    (sizeof(struct liquidio_if_cfg_resp)
> +					     - sizeof(resp->s)));
> +
> +		sc->callback = if_cfg_callback;
> +		sc->callback_arg = resp;
> +		sc->wait_time = 1000;
> +
> +		retval = octeon_send_soft_command(octeon_dev, sc);
> +		if (retval) {
> +			lio_dev_err(octeon_dev,
> +				    "Link status instruction failed status: %x\n",
> +				    retval);
> +			/* Soft instr is freed by driver in case of failure. */
> +			goto setup_nic_dev_fail;
> +		}
> +
> +		/* Sleep on a wait queue till the cond flag indicates that the
> +		 * response arrived or timed-out.
> +		 */
> +		sleep_cond(&resp->s.wc, &resp->s.cond);
> +		retval = resp->status;
> +		if (retval) {
> +			lio_dev_err(octeon_dev, "Link status failed\n");
> +			goto setup_nic_dev_fail;
> +		}
> +		octeon_swap_8B_data((uint64_t *)(&resp->cfg_info),
> +				    (sizeof(struct liquidio_if_cfg_info)) >> 3);
> +
> +		num_iqueues = hweight64(resp->cfg_info.iqmask);
> +		num_oqueues = hweight64(resp->cfg_info.oqmask);
> +
> +		if (!(num_iqueues) || !(num_oqueues)) {
> +			lio_dev_err(octeon_dev,
> +				    "Got bad iqueues (%016llx) or oqueues (%016llx) from firmware.\n",
> +				    resp->cfg_info.iqmask,
> +				    resp->cfg_info.oqmask);
> +			goto setup_nic_dev_fail;
> +		}
> +		lio_dev_dbg(octeon_dev,
> +			    "interface %d, iqmask %016llx, oqmask %016llx, numiqueues %d, numoqueues %d\n",
> +			    i, resp->cfg_info.iqmask, resp->cfg_info.oqmask,
> +			    num_iqueues, num_oqueues);
> +		netdev = liquidio_alloc_netdev(LIO_SIZE, num_iqueues);
> +
> +		if (!netdev) {
> +			lio_dev_err(octeon_dev, "Device allocation failed\n");
> +			goto setup_nic_dev_fail;
> +		}
> +
> +		octeon_dev->props.netdev[i] = netdev;
> +
> +		if (num_iqueues > 1)
> +			lionetdevops.ndo_select_queue = select_q;
> +
> +		/* Associate the routines that will handle different
> +		 * netdev tasks.
> +		 */
> +		netdev->netdev_ops = &lionetdevops;
> +
> +		lio = GET_LIO(netdev);
> +
> +		memset(lio, 0, sizeof(struct lio));
> +
> +		lio->linfo.ifidx = resp->cfg_info.ifidx;
> +		lio->ifidx = resp->cfg_info.ifidx;
> +
> +		lio->linfo.num_rxpciq = num_oqueues;
> +		lio->linfo.num_txpciq = num_iqueues;
> +		q_mask = resp->cfg_info.oqmask;
> +		/* q_mask is 0-based and already verified mask is nonzero */
> +		for (j = 0; j < num_oqueues; j++) {
> +			q_no = __ffs64(q_mask);
> +			q_mask &= (~(1UL << q_no));
> +			lio->linfo.rxpciq[j] = q_no;
> +		}
> +		q_mask = resp->cfg_info.iqmask;
> +		for (j = 0; j < num_iqueues; j++) {
> +			q_no = __ffs64(q_mask);
> +			q_mask &= (~(1UL << q_no));
> +			lio->linfo.txpciq[j] = q_no;
> +		}
> +		retval = get_inittime_link_status(octeon_dev,
> +						  &octeon_dev->props, i);
> +		if (retval) {
> +			lio_dev_err(octeon_dev, "link status failed\n");
> +			goto setup_nic_dev_fail;
> +		}
> +		lio->linfo.hw_addr = octeon_dev->props.ls->link_info.hw_addr;
> +		lio->linfo.gmxport = octeon_dev->props.ls->link_info.gmxport;
> +
> +		lio->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
> +
> +		lio->dev_capability =
> +			NETIF_F_HW_CSUM | NETIF_F_SG | NETIF_F_RXCSUM;
> +		lio->dev_capability |=
> +			(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_LRO);
> +		netif_set_gso_max_size(netdev, GSO_MAX_SIZE - ETH_HLEN - 4);
> +
> +		netdev->features = lio->dev_capability;
> +		netdev->vlan_features = lio->dev_capability;
> +
> +		netdev->hw_features = lio->dev_capability;
> +
> +		/* Point to the  properties for octeon device to which this
> +		 * interface belongs.
> +		 */
> +		lio->oct_dev = get_octeon_device_ptr(octeon_id);
> +		lio->octprops = &octeon_dev->props;
> +		lio->netdev = netdev;
> +		spin_lock_init(&lio->lock);
> +
> +		lio_dev_dbg(octeon_dev, "if%d gmx: %d hw_addr: 0x%llx\n", i,
> +			    lio->linfo.gmxport, CVM_CAST64(lio->linfo.hw_addr));
> +
> +		/* 64-bit swap required on LE machines */
> +		octeon_swap_8B_data(&lio->linfo.hw_addr, 1);
> +		for (j = 0; j < 6; j++)
> +			macaddr[j] =
> +				*((uint8_t *)(((uint8_t *)&lio->linfo.hw_addr) +
> +					     2 + j));
> +
> +		/* Copy MAC Address to OS network device structure */
> +
> +		ether_addr_copy(netdev->dev_addr, macaddr);
> +
> +		lio->linfo.link.u64 = octeon_dev->props.ls->link_info.link.u64;
> +		spin_lock_init(&lio->link_update_lock);
> +
> +		if (setup_io_queues(octeon_dev, netdev)) {
> +			lio_dev_err(octeon_dev, "I/O queues creation failed\n");
> +			goto setup_nic_dev_fail;
> +		}
> +
> +		ifstate_set(lio, LIO_IFSTATE_DROQ_OPS);
> +
> +		/* By default all interfaces on a single Octeon uses the same
> +		 * tx and rx queues
> +		 */
> +		lio->txq = lio->linfo.txpciq[0];
> +		lio->rxq = lio->linfo.rxpciq[0];
> +
> +		lio->tx_qsize = octeon_get_tx_qsize(octeon_id, lio->txq);
> +		lio->rx_qsize = octeon_get_rx_qsize(octeon_id, lio->rxq);
> +
> +		if (setup_glist(lio)) {
> +			lio_dev_err(octeon_dev,
> +				    "Gather list allocation failed\n");
> +			goto setup_nic_dev_fail;
> +		}
> +
> +		/* Register ethtool support */
> +		liquidio_set_ethtool_ops(netdev);
> +
> +		/* Register the network device with the OS */
> +		if (register_netdev(netdev)) {
> +			lio_dev_err(octeon_dev, "Device registration failed\n");
> +			goto setup_nic_dev_fail;
> +		}
> +
> +		lio_dev_dbg(octeon_dev,
> +			    "Setup NIC ifidx:%d mac:%02x%02x%02x%02x%02x%02x\n",
> +			    i, macaddr[0], macaddr[1], macaddr[2], macaddr[3],
> +			    macaddr[4], macaddr[5]);
> +		netif_carrier_off(netdev);
> +
> +		if (lio->linfo.link.s.status) {
> +			netif_carrier_on(netdev);
> +			start_txq(netdev);
> +		} else {
> +			netif_carrier_off(netdev);
> +		}
> +
> +		ifstate_set(lio, LIO_IFSTATE_REGISTERED);
> +
> +		liquidio_set_lro(netdev, OCTNET_CMD_LRO_ENABLE);
> +
> +		print_link_info(netdev);
> +		lio_dev_dbg(octeon_dev, "NIC ifidx:%d Setup successful\n", i);
> +	}
> +	kfree(sc);
> +	kfree(resp);

I wonder if this is correct. AFAICS sc is the same memory that we put on
the octeon_instr_queue (see send_soft_command() ->
send_command()->add_to_nrlist()). Is that queue cleared before sc is freed?
