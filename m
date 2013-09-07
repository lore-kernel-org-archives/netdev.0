From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [net v6 1/8] i40e: main driver core
Date: Sat, 07 Sep 2013 09:15:23 +0200
Message-ID: <522AD28B.5050507@redhat.com>
References: <1378510875-10704-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1378510875-10704-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>, gospo@redhat.com,
	davem@davemloft.net, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1378510875-10704-2-git-send-email-jeffrey.t.kirsher@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

[...]

> +/**
> + * i40e_config_netdev - Setup the netdev flags
> + * @vsi: the VSI being configured
> + *
> + * Returns 0 on success, negative value on failure
> + **/
> +static s32 i40e_config_netdev(struct i40e_vsi *vsi)
> +{
> +	struct i40e_pf *pf = vsi->back;
> +	struct i40e_hw *hw = &pf->hw;
> +	struct i40e_netdev_priv *np;
> +	struct net_device *netdev;
> +	u8 mac_addr[ETH_ALEN];
> +	int etherdev_size;
> +
> +	etherdev_size = sizeof(struct i40e_netdev_priv);
> +	netdev = alloc_etherdev_mq(etherdev_size, vsi->alloc_queue_pairs);
> +	if (!netdev)
> +		return -ENOMEM;
> +
> +	vsi->netdev = netdev;
> +	np = netdev_priv(netdev);
> +	np->vsi = vsi;
> +
> +	netdev->hw_enc_features = NETIF_F_IP_CSUM	 |
> +				  NETIF_F_GSO_UDP_TUNNEL |
> +				  NETIF_F_TSO		 |
> +				  NETIF_F_SG;
> +
> +	netdev->features = NETIF_F_SG		       |
> +			   NETIF_F_IP_CSUM	       |
> +			   NETIF_F_SCTP_CSUM	       |

Thanks for including SCTP! ;-)

> +			   NETIF_F_HIGHDMA	       |
> +			   NETIF_F_GSO_UDP_TUNNEL      |
> +			   NETIF_F_HW_VLAN_CTAG_TX     |
> +			   NETIF_F_HW_VLAN_CTAG_RX     |
> +			   NETIF_F_HW_VLAN_CTAG_FILTER |
> +			   NETIF_F_IPV6_CSUM	       |
> +			   NETIF_F_TSO		       |
> +			   NETIF_F_TSO6		       |
> +			   NETIF_F_RXCSUM	       |
> +			   NETIF_F_RXHASH	       |
> +			   0;
[..]

> +/**
> + * i40e_veb_mem_alloc - Allocates the next available struct veb in the PF
> + * @pf: board private structure
> + *
> + * On error: returns error code (negative)
> + * On success: returns vsi index in PF (positive)
> + **/
> +static s32 i40e_veb_mem_alloc(struct i40e_pf *pf)
> +{
> +	int ret = I40E_ERR_NO_AVAILABLE_VSI;
> +	struct i40e_veb *veb;
> +	int i;
> +
> +	/* Need to protect the allocation of switch elements at the PF level */
> +	mutex_lock(&pf->switch_mutex);
> +
> +	/* VEB list may be fragmented if VEB creation/destruction has
> +	 * been happening.  We can afford to do a quick scan to look
> +	 * for any free slots in the list.
> +	 *
> +	 * find next empty veb slot, looping back around if necessary
> +	 */
> +	i = 0;
> +	while ((i < I40E_MAX_VEB) && (pf->veb[i] != NULL))
> +		i++;
> +	if (i >= I40E_MAX_VEB) {
> +		ret = I40E_ERR_NO_MEMORY;
> +		goto err_alloc_veb;  /* out of VEB slots! */
> +	}
> +
> +	veb = kzalloc(sizeof(*veb), GFP_KERNEL);
> +	if (!veb) {
> +		ret = -ENOMEM;
> +		goto err_alloc_veb;
> +	}

Here as well, I40E_ERR_NO_MEMORY vs -ENOMEM.

> +	veb->pf = pf;
> +	veb->idx = i;
> +	veb->enabled_tc = 1;
> +
> +	pf->veb[i] = veb;
> +	ret = i;
> +err_alloc_veb:
> +	mutex_unlock(&pf->switch_mutex);
> +	return ret;
> +}

[...]

> +/**
> + * i40e_add_veb - create the VEB in the switch
> + * @veb: the VEB to be instantiated
> + * @vsi: the controlling VSI
> + **/
> +static s32 i40e_add_veb(struct i40e_veb *veb, struct i40e_vsi *vsi)
> +{
> +	bool is_default = (vsi->idx == vsi->back->lan_vsi);
> +	int ret;
> +
> +	/* get a VEB from the hardware */
> +	ret = i40e_aq_add_veb(&veb->pf->hw, veb->uplink_seid, vsi->seid,
> +			      veb->enabled_tc, is_default, &veb->seid, NULL);
> +	if (ret != I40E_SUCCESS) {
> +		dev_info(&veb->pf->pdev->dev,
> +			 "couldn't add VEB, err %d, aq_err %d\n",
> +			 ret, veb->pf->hw.aq.asq_last_status);
> +		return ret;
> +	}

Nitpick: why s32 in the signature? There are a lot of such places, just int would have
been fine probably.

> +
> +	return I40E_SUCCESS;
> +}

[...]

> +struct i40e_veb *i40e_veb_setup(struct i40e_pf *pf, u16 flags,
> +				u16 uplink_seid, u16 vsi_seid,
> +				u8 enabled_tc)
> +{
[...]
> +
> +	/* get veb sw struct */
> +	veb_idx = i40e_veb_mem_alloc(pf);
> +	if (veb_idx < 0)
> +		goto err_alloc;

See below.

> +	veb = pf->veb[veb_idx];
> +	veb->flags = flags;
> +	veb->uplink_seid = uplink_seid;
> +	veb->veb_idx = (uplink_veb ? uplink_veb->idx : I40E_NO_VEB);
> +	veb->enabled_tc = (enabled_tc ? enabled_tc : 0x1);
> +
> +	/* create the VEB in the switch */
> +	ret = i40e_add_veb(veb, pf->vsi[vsi_idx]);
> +	if (ret != I40E_SUCCESS)
> +		goto err_veb;
> +
> +	return veb;
> +
> +err_veb:
> +	i40e_veb_clear(veb);
> +err_alloc:
> +	return NULL;
> +}
> +
> +/**
> + * i40e_setup_pf_switch_element - set pf vars based on switch type
> + * @pf: board private structure
> + * @ele: element we are building info from
> + * @num_reported: total number of elements
> + * @printconfig: should we print the contents
> + *
> + * helper function to assist in extracting a few useful SEID values.
> + **/
> +static void i40e_setup_pf_switch_element(struct i40e_pf *pf,
> +				struct i40e_aqc_switch_config_element_resp *ele,
> +				u16 num_reported, bool printconfig)
> +{
> +	u16 downlink_seid = le16_to_cpu(ele->downlink_seid);
> +	u16 uplink_seid = le16_to_cpu(ele->uplink_seid);
> +	u8 element_type = ele->element_type;
> +	u16 seid = le16_to_cpu(ele->seid);
> +
> +	if (printconfig)
> +		dev_info(&pf->pdev->dev,
> +			 "type=%d seid=%d uplink=%d downlink=%d\n",
> +			 element_type, seid, uplink_seid, downlink_seid);
> +
> +	switch (element_type) {
> +	case I40E_SWITCH_ELEMENT_TYPE_MAC:
> +		pf->mac_seid = seid;
> +		break;
> +	case I40E_SWITCH_ELEMENT_TYPE_VEB:
> +		/* Main VEB? */
> +		if (uplink_seid != pf->mac_seid)
> +			break;
> +		if (pf->lan_veb == I40E_NO_VEB) {
> +			int v;
> +
> +			/* find existing or else empty VEB */
> +			for (v = 0; v < I40E_MAX_VEB; v++) {
> +				if (pf->veb[v] && (pf->veb[v]->seid == seid)) {
> +					pf->lan_veb = v;
> +					break;
> +				}
> +			}
> +			if (pf->lan_veb == I40E_NO_VEB) {
> +				v = i40e_veb_mem_alloc(pf);
> +				if (v < 0)
> +					break;

Nitpick: I'd expect from *alloc() functions to return NULL, but fair enough.

> +				pf->lan_veb = v;
> +			}
> +		}
> +
> +		pf->veb[pf->lan_veb]->seid = seid;
> +		pf->veb[pf->lan_veb]->uplink_seid = pf->mac_seid;
> +		pf->veb[pf->lan_veb]->pf = pf;
> +		pf->veb[pf->lan_veb]->veb_idx = I40E_NO_VEB;
> +		break;
> +	case I40E_SWITCH_ELEMENT_TYPE_VSI:
> +		if (num_reported != 1)
> +			break;
> +		/* This is immediately after a reset so we can assume this is
> +		 * the PF's VSI
> +		 */
> +		pf->mac_seid = uplink_seid;
> +		pf->pf_seid = downlink_seid;
> +		pf->main_vsi_seid = seid;
> +		if (printconfig)
> +			dev_info(&pf->pdev->dev,
> +				 "pf_seid=%d main_vsi_seid=%d\n",
> +				 pf->pf_seid, pf->main_vsi_seid);
> +		break;
> +	case I40E_SWITCH_ELEMENT_TYPE_PF:
> +	case I40E_SWITCH_ELEMENT_TYPE_VF:
> +	case I40E_SWITCH_ELEMENT_TYPE_EMP:
> +	case I40E_SWITCH_ELEMENT_TYPE_BMC:
> +	case I40E_SWITCH_ELEMENT_TYPE_PE:
> +	case I40E_SWITCH_ELEMENT_TYPE_PA:
> +		/* ignore these for now */
> +		break;
> +	default:
> +		dev_info(&pf->pdev->dev, "unknown element type=%d seid=%d\n",
> +			 element_type, seid);
> +		break;
> +	}
> +}

[...]

> +/**
> + * i40e_fetch_switch_configuration - Get switch config from firmware
> + * @pf: board private structure
> + * @printconfig: should we print the contents
> + *
> + * Get the current switch configuration from the device and
> + * extract a few useful SEID values.
> + **/
> +s32 i40e_fetch_switch_configuration(struct i40e_pf *pf, bool printconfig)
> +{
> +	struct i40e_aqc_get_switch_config_resp *sw_config;
> +	int ret = I40E_SUCCESS;
> +	u16 next_seid = 0;
> +	u8 *aq_buf;
> +	int i;
> +
> +	if (!pf)
> +		return I40E_ERR_BAD_PTR;
> +
> +	aq_buf = kzalloc(I40E_AQ_LARGE_BUF, GFP_KERNEL);
> +	if (!aq_buf)
> +		return -ENOMEM;

More of such examples ... ;-) I40E_ERR_BAD_PTR vs. -ENOMEM on a s32 instead of int.

> +	sw_config = (struct i40e_aqc_get_switch_config_resp *)aq_buf;
> +	do {
> +		u16 num_reported, num_total;
> +
> +		ret = i40e_aq_get_switch_config(&pf->hw, sw_config,
> +						I40E_AQ_LARGE_BUF,
> +						&next_seid, NULL);
> +		if (ret) {
> +			dev_info(&pf->pdev->dev,
> +				 "get switch config failed %d aq_err=%x\n",
> +				 ret, pf->hw.aq.asq_last_status);
> +			kfree(aq_buf);
> +			return ret;
> +		}
> +
> +		num_reported = le16_to_cpu(sw_config->header.num_reported);
> +		num_total = le16_to_cpu(sw_config->header.num_total);
> +
> +		if (printconfig)
> +			dev_info(&pf->pdev->dev,
> +				 "header: %d reported %d total\n",
> +				 num_reported, num_total);
> +
> +		if (num_reported) {
> +			int sz = sizeof(*sw_config) * num_reported;
> +
> +			kfree(pf->sw_config);
> +			pf->sw_config = kzalloc(sz, GFP_KERNEL);
> +			if (pf->sw_config)
> +				memcpy(pf->sw_config, sw_config, sz);
> +		}
> +
> +		for (i = 0; i < num_reported; i++) {
> +			struct i40e_aqc_switch_config_element_resp *ele =
> +				&sw_config->element[i];
> +
> +			i40e_setup_pf_switch_element(pf, ele, num_reported,
> +						     printconfig);
> +		}
> +	} while (next_seid != 0);
> +
> +	kfree(aq_buf);
> +	return ret;
> +}

[...]

> +/**
> + * i40e_determine_queue_usage - Work out queue distribution
> + * @pf: board private structure
> + **/
> +static i40e_status i40e_determine_queue_usage(struct i40e_pf *pf)
> +{
> +	int accum_tc_size;
> +	int queues_left;
> +	int num_tc0;
> +
> +	pf->num_lan_qps = 0;
> +	pf->num_tc_qps = rounddown_pow_of_two(pf->num_tc_qps);
> +	accum_tc_size = (I40E_MAX_TRAFFIC_CLASS - 1) * pf->num_tc_qps;
> +
> +	/* a quicky macro for a repeated set of lines */
> +#define SET_RSS_SIZE do { \
> +num_tc0 = min_t(int, queues_left, pf->rss_size_max);           \
> +num_tc0 = min_t(int, num_tc0, nr_cpus_node(numa_node_id()));   \
> +num_tc0 = rounddown_pow_of_two(num_tc0);                       \
> +pf->rss_size = num_tc0;                                        \
> +} while (0)
> +
> +	/* Find the max queues to be put into basic use.  We'll always be
> +	 * using TC0, whether or not DCB is running, and TC0 will get the
> +	 * big RSS set.
> +	 */
> +	queues_left = pf->hw.func_caps.num_tx_qp;
> +
> +	if   (!((pf->flags & I40E_FLAG_MSIX_ENABLED)		 &&
> +		(pf->flags & I40E_FLAG_MQ_ENABLED))		 ||
> +		!(pf->flags & (I40E_FLAG_RSS_ENABLED |
> +		I40E_FLAG_FDIR_ENABLED | I40E_FLAG_DCB_ENABLED)) ||
> +		(queues_left == 1)) {
> +
> +		/* one qp for PF, no queues for anything else */
> +		queues_left = 0;
> +		pf->rss_size = pf->num_lan_qps = 1;
> +
> +		/* make sure all the fancies are disabled */
> +		pf->flags &= ~(I40E_FLAG_RSS_ENABLED       |
> +				I40E_FLAG_MQ_ENABLED	   |
> +				I40E_FLAG_FDIR_ENABLED	   |
> +				I40E_FLAG_FDIR_ATR_ENABLED |
> +				I40E_FLAG_DCB_ENABLED	   |
> +				I40E_FLAG_SRIOV_ENABLED	   |
> +				I40E_FLAG_VMDQ_ENABLED);
> +
> +	} else if (pf->flags & I40E_FLAG_RSS_ENABLED	  &&
> +		   !(pf->flags & I40E_FLAG_FDIR_ENABLED)  &&
> +		   !(pf->flags & I40E_FLAG_DCB_ENABLED)) {
> +
> +		SET_RSS_SIZE;

Can't these macros be done in a small inline function instead?

> +		queues_left -= pf->rss_size;
> +		pf->num_lan_qps = pf->rss_size;
> +
> +	} else if (pf->flags & I40E_FLAG_RSS_ENABLED	  &&
> +		   !(pf->flags & I40E_FLAG_FDIR_ENABLED)  &&
> +		   (pf->flags & I40E_FLAG_DCB_ENABLED)) {
> +
> +		/* save num_tc_qps queues for TCs 1 thru 7 and the rest
> +		 * are set up for RSS in TC0
> +		 */
> +		queues_left -= accum_tc_size;
> +
> +		SET_RSS_SIZE;

ditto

> +		queues_left -= pf->rss_size;
> +		if (queues_left < 0) {
> +			dev_info(&pf->pdev->dev, "not enough queues for DCB\n");
> +			return I40E_ERR_CONFIG;
> +		}
> +
> +		pf->num_lan_qps = pf->rss_size + accum_tc_size;
> +
> +	} else if (pf->flags & I40E_FLAG_RSS_ENABLED   &&
> +		  (pf->flags & I40E_FLAG_FDIR_ENABLED) &&
> +		  !(pf->flags & I40E_FLAG_DCB_ENABLED)) {
> +
> +		queues_left -= 1; /* save 1 queue for FD */
> +
> +		SET_RSS_SIZE;

ditto

> +		queues_left -= pf->rss_size;
> +		if (queues_left < 0) {
> +			dev_info(&pf->pdev->dev, "not enough queues for Flow Director\n");
> +			return I40E_ERR_CONFIG;
> +		}
> +
> +		pf->num_lan_qps = pf->rss_size;
> +
> +	} else if (pf->flags & I40E_FLAG_RSS_ENABLED   &&
> +		  (pf->flags & I40E_FLAG_FDIR_ENABLED) &&
> +		  (pf->flags & I40E_FLAG_DCB_ENABLED)) {
> +
> +		/* save 1 queue for TCs 1 thru 7,
> +		 * 1 queue for flow director,
> +		 * and the rest are set up for RSS in TC0
> +		 */
> +		queues_left -= 1;
> +		queues_left -= accum_tc_size;
> +
> +		SET_RSS_SIZE;

ditto

> +		queues_left -= pf->rss_size;
> +		if (queues_left < 0) {
> +			dev_info(&pf->pdev->dev, "not enough queues for DCB and Flow Director\n");
> +			return I40E_ERR_CONFIG;
> +		}
> +
> +		pf->num_lan_qps = pf->rss_size + accum_tc_size;
> +
> +	} else {
> +		dev_info(&pf->pdev->dev,
> +			 "Invalid configuration, flags=0x%08llx\n", pf->flags);
> +		return I40E_ERR_CONFIG;
> +	}
> +
> +	if ((pf->flags & I40E_FLAG_SRIOV_ENABLED) &&
> +	    pf->num_vf_qps && pf->num_req_vfs && queues_left) {
> +		pf->num_req_vfs = min_t(int, pf->num_req_vfs, (queues_left /
> +							       pf->num_vf_qps));
> +		queues_left -= (pf->num_req_vfs * pf->num_vf_qps);
> +	}
> +
> +	if ((pf->flags & I40E_FLAG_VMDQ_ENABLED) &&
> +	    pf->num_vmdq_vsis && pf->num_vmdq_qps && queues_left) {
> +		pf->num_vmdq_vsis = min_t(int, pf->num_vmdq_vsis,
> +					  (queues_left / pf->num_vmdq_qps));
> +		queues_left -= (pf->num_vmdq_vsis * pf->num_vmdq_qps);
> +	}
> +
> +	return I40E_SUCCESS;
> +}

------------------------------------------------------------------------------
Learn the latest--Visual Studio 2012, SharePoint 2013, SQL 2012, more!
Discover the easy way to master current and previous Microsoft technologies
and advance your career. Get an incredible 1,500+ hours of step-by-step
tutorial videos with LearnDevNow. Subscribe today and save!
http://pubads.g.doubleclick.net/gampad/clk?id=58041391&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
