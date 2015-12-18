From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [RFC 5/5] i40e/ethtool: support coalesce setting by queue
Date: Fri, 18 Dec 2015 21:05:57 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F077019C0D63@SHSMSX103.ccr.corp.intel.com>
References: <1450335081-3012-1-git-send-email-kan.liang@intel.com>
 <1450335081-3012-5-git-send-email-kan.liang@intel.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFD1CAC@fmsmsx115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"jiri@mellanox.com" <jiri@mellanox.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"sasha.levin@oracle.com" <sasha.levin@oracle.com>,
	"dsahern@gmail.com" <dsahern@gmail.com>,
	"tj@kernel.org" <tj@kernel.org>,
	"cascardo@redhat.com" <cascardo@redhat.com>,
	"corbet@lwn.net" <corbet@lwn.net>,
	"ben@decadent.org.uk" <ben@decadent.org
To: "Nelson, Shannon" <shannon.nelson@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"bwh@kernel.org" <bwh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:61062 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965135AbbLRVGD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 16:06:03 -0500
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E418AFD1CAC@fmsmsx115.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> > b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> > index b41f0be..5a35fdb 100644
> > --- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> > +++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> > @@ -1901,14 +1901,29 @@ static int
> i40e_get_per_queue_coalesce(struct
> > net_device *netdev, int queue,
> >  	return __i40e_get_coalesce(netdev, ec, queue);  }
> >
> > -static int i40e_set_coalesce(struct net_device *netdev,
> > -			     struct ethtool_coalesce *ec)
> > +static void i40e_set_itr_for_queue(struct i40e_vsi *vsi, int queue,
> > +u16
> > vector)
> >  {
> > -	struct i40e_netdev_priv *np = netdev_priv(netdev);
> >  	struct i40e_q_vector *q_vector;
> > -	struct i40e_vsi *vsi = np->vsi;
> >  	struct i40e_pf *pf = vsi->back;
> >  	struct i40e_hw *hw = &pf->hw;
> > +	u16 intrl = INTRL_USEC_TO_REG(vsi->int_rate_limit);
> > +
> > +	q_vector = vsi->q_vectors[queue];
> 
> Again, the problem here is that there can be more queues than vectors, so
> you'll need to check the requested queue number against vsi-
> >num_queue_pairs for the max queue check, then look at vsi-
> >tx_rings[queue].q_vector and/or vsi->rx_rings[queue].q_vector to find
> the actual q_vector for the requested queue.
> 
> Also, this means that it would be possible for the user to try to assign
> different values to queues on the same vector.  How do you want to
> handle that?  My first inclination is to not do anything and just let the last
> value assigned win.
> 

Hi sln,

Thanks for the comments. I will fix it in V2.

Could you please check if the following code can find and set/get vector correctly?

Get rx_usecs and tx_usecs per queue

+	if (queue > 0) {
+		if (queue >= vsi->num_queue_pairs) {
+			netif_info(pf, drv, netdev, "Invalid queue number\n");
+			return -EINVAL;
+		}
+
+		q_vector = vsi->rx_rings[queue]->q_vector;
+		vector = vsi->base_vector + q_vector->v_idx;
+		ec->rx_coalesce_usecs = ITR_REG_TO_USEC(rd32(hw, I40E_PFINT_ITRN(0, vector - 1)));
+
+		q_vector = vsi->tx_rings[queue]->q_vector;
+		vector = vsi->base_vector + q_vector->v_idx;
+		ec->tx_coalesce_usecs = ITR_REG_TO_USEC(rd32(hw, I40E_PFINT_ITRN(1, vector - 1)));
+	}

Set rx_usecs and tx_usecs per queue

+		if (queue >= vsi->num_queue_pairs) {
+			netif_info(pf, drv, netdev, "Invalid queue value, queue range is 0 - %d\n", vsi->num_queue_pairs - 1);
+			return -EINVAL;
+		}
+		intrl = INTRL_USEC_TO_REG(vsi->int_rate_limit);
 
-		q_vector = vsi->q_vectors[i];
+		q_vector = vsi->rx_rings[queue]->q_vector;
+		vector = vsi->base_vector + q_vector->v_idx;
 		q_vector->rx.itr = ITR_TO_REG(vsi->rx_itr_setting);
 		wr32(hw, I40E_PFINT_ITRN(0, vector - 1), q_vector->rx.itr);
+
+		q_vector = vsi->tx_rings[queue]->q_vector;
+		vector = vsi->base_vector + q_vector->v_idx;
 		q_vector->tx.itr = ITR_TO_REG(vsi->tx_itr_setting);
 		wr32(hw, I40E_PFINT_ITRN(1, vector - 1), q_vector->tx.itr);
+
 		wr32(hw, I40E_PFINT_RATEN(vector - 1), intrl);
 		i40e_flush(hw);


Thanks,
Kan
