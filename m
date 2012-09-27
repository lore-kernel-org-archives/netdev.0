From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv5 net-next] vxlan: virtual extensible lan
Date: Thu, 27 Sep 2012 18:47:40 -0400 (EDT)
Message-ID: <20120927.184740.975766966558033959.davem@davemloft.net>
References: <20120924145031.3b0122e6@nehalam.linuxnetplumber.net>
	<CAEP_g=_PQSx_OVcU47OJFKgO_MpWSKStmGnVB76vSm=Z7r6mvg@mail.gmail.com>
	<20120925150957.78591205@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, chrisw@redhat.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755235Ab2I0Wrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 18:47:42 -0400
In-Reply-To: <20120925150957.78591205@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 25 Sep 2012 15:09:57 -0700

> +/* Hash Ethernet address */
> +static u32 eth_hash(const unsigned char *addr)
> +{
> +	/* could be optimized for unaligned access */
> +	u32 a = addr[5] << 8 | addr[4];
> +	u32 b = addr[3] << 24 | addr[2] << 16 | addr[1] << 8 | addr[0];
> +
> +	return jhash_2words(a, b, vxlan_salt);
> +}
> +
> +/* Hash chain to use given mac address */
> +static inline struct hlist_head *vxlan_fdb_head(struct vxlan_dev *vxlan,
> +						const u8 *mac)
> +{
> +	return &vxlan->fdb_head[hash_32(eth_hash(mac), FDB_HASH_BITS)];
> +}

This hashing is way overkill, and in fact is a mis-use of Jenkins.

Jenkins can work fine with power-of-two hash sizes, so using hash_32()
on the Jenkins hash result is nothing short of silly.

I would go one step further and change this to:

	(a ^ b) * vxlan_salt

much like how we hash IP addresses in the ipv4 ARP tables.  That
function is a universal hash, and therefore provides whatever kind
of protection you're trying to obtain using the salt.

But I wonder if this matters at all, the administrator controls
the contents of this table, rather than external entitites.
