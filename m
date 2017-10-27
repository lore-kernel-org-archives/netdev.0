From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH V2 net-next 1/2] liquidio: switchdev support for
 LiquidIO NIC
Date: Fri, 27 Oct 2017 16:45:05 -0700
Message-ID: <20171027164505.4cc0df92@cakuba.netronome.com>
References: <20171027190833.GA19806@felix-thinkpad.cavium.com>
        <20171027190917.GA19831@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, vijaya.guvva@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:50149 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932279AbdJ0XpN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 19:45:13 -0400
Received: by mail-wm0-f66.google.com with SMTP id b189so5905514wmd.4
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 16:45:12 -0700 (PDT)
In-Reply-To: <20171027190917.GA19831@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Oct 2017 12:09:17 -0700, Felix Manlunas wrote:
> From: Vijaya Mohan Guvva <vijaya.guvva@cavium.com>
> 
> Enable switchdev for SRIOV capable LiquidIO NIC. It registers
> a representor netdev (with switchdev_ops) for each SRIOV VF created.
> It also has changes to send representor interface configurations like
> admin state and MTU to LiquidIO firmware and to retrieve HW counted
> VF stats for VF representor.
> 
> Signed-off-by: Vijaya Mohan Guvva <vijaya.guvva@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Thanks for making the changes!  One more thing caught my eye this time
around.

> +static int
> +lio_pf_switchdev_attr_get(struct net_device *dev, struct switchdev_attr *attr)
> +{
> +	struct lio *lio = GET_LIO(dev);
> +	struct octeon_device *oct = lio->oct_dev;
> +	char phy_switch_id[] = {0x17, 0x7d, 0x97, 0x02, 0x00};
> +	int len = sizeof(phy_switch_id);
> +
> +	switch (attr->id) {
> +	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
> +		phy_switch_id[len - 1] = oct->pf_num;
> +		attr->u.ppid.id_len = len;
> +		memcpy(attr->u.ppid.id, phy_switch_id, len);
> +		break;
> +
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +
> +	return 0;
> +}

> +static int
> +lio_vf_rep_attr_get(struct net_device *dev, struct switchdev_attr *attr)
> +{
> +	char phy_switch_id[] = {0x17, 0x7d, 0x97, 0x02, 0x00};
> +	struct lio_vf_rep_desc *vf_rep = netdev_priv(dev);
> +	struct octeon_device *oct = vf_rep->oct;
> +	int len = sizeof(phy_switch_id);
> +
> +	switch (attr->id) {
> +	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
> +		phy_switch_id[len - 1] = oct->pf_num;
> +		attr->u.ppid.id_len = len;
> +		memcpy(attr->u.ppid.id, phy_switch_id, len);
> +		break;
> +
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +
> +	return 0;
> +}

SWITCHDEV_ATTR_ID_PORT_PARENT_ID is generally used to determine whether
two ports belong to the same switch.  Do you not want to support rules
which redirect packets from one PF (and it's VFs) to the other?

Also if you plug two cards into one system, the above will make you
offload redirect between the cards.  Is that what you want?  Commonly
the MAC address of the first port or serial number would be used here
to make sure IDs are unique for each device.
