From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: Re: [PATCH 6/9] s390: qeth driver fixes [3/6]
Date: Fri, 15 Sep 2006 18:50:13 +0200
Message-ID: <20060915165013.GA1375@de.ibm.com>
References: <20060915142619.GF10043@de.ibm.com> <200609151551.k8FFpPZt001753@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:3943 "EHLO
	mtagate4.de.ibm.com") by vger.kernel.org with ESMTP
	id S1750723AbWIOQwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Sep 2006 12:52:46 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id k8FGqj6M060480
	for <netdev@vger.kernel.org>; Fri, 15 Sep 2006 16:52:45 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8FGvOZm2470062
	for <netdev@vger.kernel.org>; Fri, 15 Sep 2006 18:57:24 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8FGqji9001569
	for <netdev@vger.kernel.org>; Fri, 15 Sep 2006 18:52:45 +0200
To: Jay Vosburgh <fubar@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200609151551.k8FFpPZt001753@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

yes it would but the problem in qeth is not only bonding related.
We just have found it in a bonding scenario . But this kernel
panic could also occur without bonding. 

But thanks for reviewing it 
On Fri, Sep 15, 2006 at 08:51:25AM -0700, Jay Vosburgh wrote:
> Frank Pavlic <fpavlic@de.ibm.com> wrote:
> 
> >[PATCH 6/9] s390: qeth driver fixes [3/6]
> >
> >From: Frank Pavlic <fpavlic@de.ibm.com>
> >       	fixed kernel panic caused by qeth driver:
> >        Using a bonding device qeth driver will realloc
> >        headroom for every skb coming from the bond device.
> >        Once this happens qeth frees the original skb and
> >        set the skb pointer to the new realloced skb.
> 
> 	Frank, does the following patch to bonding (to track larger than
> usual hard_header_len) resolve this problem without changing qeth?  I
> believe this patch is queued for 2.6.19.
> 
> To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
> Cc: Jeff Garzik <jgarzik@pobox.com>
> Subject: [PATCH 5/7] bonding: Handle large hard_header_len
> X-Mailer: MH-E 7.83; nmh 1.1-RC4; GNU Emacs 21.4.1
> Date: Fri, 01 Sep 2006 15:12:44 -0700
> From: Jay Vosburgh <fubar@death>
> 
> 
> The bonding driver fails to adjust its hard_header_len when enslaving
> interfaces.  Whenever an interface with a hard_header_len greater than the
> ETH_HLEN default is enslaved, the potential for an oops exists, and if the
> oops happens while responding to an arp request, for example, the system
> panics.  GIANFAR devices may use an extended hard_header for VLAN or
> hardware checksumming.  Enslaving such a device and then transmitting over
> it causes a kernel panic.
> 
> Patch modified from submitter's original, but submitter agreed with this
> patch in private email.
> 
> Signed-off-by: Mark Huth <mhuth@mvista.com>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> 
> 
> --- netdev-2.6.git-upstream/drivers/net/bonding/bond_main.c	2006/08/19 14:46:07	1.3
> +++ netdev-2.6.git-upstream/drivers/net/bonding/bond_main.c	2006/08/19 15:47:27	1.4
> @@ -1211,10 +1211,14 @@ static int bond_compute_features(struct 
>  	unsigned long features = BOND_INTERSECT_FEATURES;
>  	struct slave *slave;
>  	struct net_device *bond_dev = bond->dev;
> +	unsigned short max_hard_header_len = ETH_HLEN;
>  	int i;
>  
> -	bond_for_each_slave(bond, slave, i)
> +	bond_for_each_slave(bond, slave, i) {
>  		features &= (slave->dev->features & BOND_INTERSECT_FEATURES);
> +		if (slave->dev->hard_header_len > max_hard_header_len)
> +			max_hard_header_len = slave->dev->hard_header_len;
> +	}
>  
>  	if ((features & NETIF_F_SG) && 
>  	    !(features & NETIF_F_ALL_CSUM))
> @@ -1232,6 +1236,7 @@ static int bond_compute_features(struct 
>  
>  	features |= (bond_dev->features & ~BOND_INTERSECT_FEATURES);
>  	bond_dev->features = features;
> +	bond_dev->hard_header_len = max_hard_header_len;
>  
>  	return 0;
>  }
> 
> 
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
