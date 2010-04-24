From: Chris Wright <chrisw@redhat.com>
Subject: Re: [net-next-2.6 PATCH 2/2] add enic ndo_vf_set_port_profile op
 support for dynamic vnics
Date: Fri, 23 Apr 2010 19:21:21 -0700
Message-ID: <20100424022121.GE3843@x200.localdomain>
References: <20100424003540.12745.81403.stgit@savbu-pc100.cisco.com>
 <20100424003546.12745.83769.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com,
	arnd@arndb.de
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9592 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755774Ab0DXDAi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Apr 2010 23:00:38 -0400
Content-Disposition: inline
In-Reply-To: <20100424003546.12745.83769.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Scott Feldman (scofeldm@cisco.com) wrote:
> -#define DRV_VERSION		"1.3.1.1"
> +#define DRV_VERSION		"1.3.1.1-iov"

not a version bump?

> @@ -810,14 +819,24 @@ static void enic_reset_mcaddrs(struct enic *enic)
>  
>  static int enic_set_mac_addr(struct net_device *netdev, char *addr)
>  {
> -	if (!is_valid_ether_addr(addr))
> -		return -EADDRNOTAVAIL;
> +	struct enic *enic = netdev_priv(netdev);
>  
> -	memcpy(netdev->dev_addr, addr, netdev->addr_len);
> +	if (enic_is_dynamic(enic)) {
> +		random_ether_addr(netdev->dev_addr);

Would it make more sense to just ignore this?  Then the default (not
port profile configured yet) mac is still a useful identifier.

> +	} else {
> +		if (!is_valid_ether_addr(addr))
> +			return -EADDRNOTAVAIL;
> +		memcpy(netdev->dev_addr, addr, netdev->addr_len);
> +	}
>  
>  	return 0;
>  }
>  
> +static int enic_set_mac_address(struct net_device *netdev, void *p)
> +{
> +	return -EOPNOTSUPP;
> +}
> +

Ever?  Even on non-dynamic enic?  Oh, I see, this was just a lie before ;-)

> +static int enic_set_vf_port_profile(struct net_device *netdev, int vf,
> +	u8 *port_profile, u8 *mac, u8 *host_uuid, u8 *client_uuid,
> +	u8 *client_name)
> +{
> +	struct enic *enic = netdev_priv(netdev);
> +	struct vic_provinfo *vp;
> +	u8 oui[3] = VIC_PROVINFO_CISCO_OUI;
> +	int err;
> +
> +	if (!enic_is_dynamic(enic))
> +		return -EOPNOTSUPP;

Do you want to validate vf (like require it to be 0) or something?
How should userspace know to talk directly to the VF (dynamic enic) in
this device, but a PF + VF_index for another device?

> +	if (strlen(port_profile) == 0)
> +		return enic_vnic_dev_deinit(enic);
> +
> +	vp = vic_provinfo_alloc(GFP_KERNEL, oui, VIC_PROVINFO_LINUX_TYPE);
> +	if (!vp)
> +		return -ENOMEM;
> +
> +	enic_provinfo_add_tlv_str(vp, VIC_LINUX_PROV_TLV_PORT_PROFILE_NAME_STR,
> +		port_profile);
> +	vic_provinfo_add_tlv(vp, VIC_LINUX_PROV_TLV_CLIENT_MAC_ADDR,
> +		ETH_ALEN, mac);
> +	enic_provinfo_add_tlv_str(vp, VIC_LINUX_PROV_TLV_HOST_UUID_STR,
> +		host_uuid);
> +	enic_provinfo_add_tlv_str(vp, VIC_LINUX_PROV_TLV_CLIENT_UUID_STR,
> +		client_uuid);
> +	enic_provinfo_add_tlv_str(vp, VIC_LINUX_PROV_TLV_CLIENT_NAME_STR,
> +		client_name);
> +
> +	err = enic_vnic_dev_deinit(enic);
> +	if (err)
> +		goto err_out;
> +
> +	err = enic_dev_init_prov(enic, vp);
> +
> +err_out:
> +	vic_provinfo_free(vp);
> +
> +	enic_set_multicast_list(netdev);

Should that happen in error case (and is the locking correct)?

