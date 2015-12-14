From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next v2] Driver for IBM System i/p VNIC protocol
Date: Mon, 14 Dec 2015 12:05:10 -0600
Message-ID: <566F04D6.3030007@linux.vnet.ibm.com>
References: <1449597139-8338-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
 <20151211.195358.1764064794354600517.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nguyendo@us.ibm.com, formosa@us.ibm.com,
	jallen@linux.vnet.ibm.com, brking@linux.vnet.ibm.com,
	nfont@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:32896 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932099AbbLNSFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 13:05:17 -0500
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Mon, 14 Dec 2015 11:05:17 -0700
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id AE9E01FF0045
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 10:53:25 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tBEI5Ewk26148980
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 11:05:14 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tBEI5D6o018187
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 11:05:14 -0700
In-Reply-To: <20151211.195358.1764064794354600517.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/2015 06:53 PM, David Miller wrote:
> From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
> Date: Tue,  8 Dec 2015 11:52:19 -0600
>
>> +static long h_reg_sub_crq(unsigned long unit_address, unsigned long token,
>> +			  unsigned long length, unsigned long *number,
>> +			  unsigned long *irq)
>> +{
>> +	long rc;
>> +	unsigned long retbuf[PLPAR_HCALL_BUFSIZE];
> Please declare local variables from longest to shortest line, otherwise
> known as "reverse christmas tree" order.
>
> Audit this in your entire driver.
>
>> +	pool->rx_buff = kcalloc(pool->size, sizeof(struct ibmvnic_rx_buff),
>> +				GFP_KERNEL);
> Allocation failures not checked until much later in this function, where
> several other resources have been allocated meanwhile.  That doesn't
> make any sense at all.
>
>> +	adapter->closing = 1;
> Please use type 'bool' and values 'true' and 'false' for boolean
> values.
>
> Audit this in your entire driver.
>
>> +	if (ip_hdr(skb)->version == 4)
>> +		tx_crq.v1.flags1 |= IBMVNIC_TX_PROT_IPV4;
>> +	else if (ip_hdr(skb)->version == 6)
>> +		tx_crq.v1.flags1 |= IBMVNIC_TX_PROT_IPV6;
>> +
> You cannot dereference the protocol header of the SKB without
> first checking the skb->protocol value, otherwise you're looking
> at garbage.
>
>> +static int ibmvnic_set_mac(struct net_device *netdev, void *p)
>> +{
>> +	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
>> +	struct sockaddr *addr = p;
>> +	union ibmvnic_crq crq;
>> +
>> +	if (!is_valid_ether_addr(addr->sa_data))
>> +		return -EADDRNOTAVAIL;
>> +
>> +	memset(&crq, 0, sizeof(crq));
>> +	crq.change_mac_addr.first = IBMVNIC_CRQ_CMD;
>> +	crq.change_mac_addr.cmd = CHANGE_MAC_ADDR;
>> +	ether_addr_copy(&crq.change_mac_addr.mac_addr[0], addr->sa_data);
>> +	ibmvnic_send_crq(adapter, &crq);
>> +
>> +	return 0;
>> +}
> You are responsible for copying the new MAC address into dev->dev_addr
> on success.

We do this in another function (handle_change_mac_rsp), which handles the response from firmware indicating whether the CHANGE_MAC_ADDR command was successful.  Is this acceptable? 

Thank you for your review comments and your time.

>
>> +static int ibmvnic_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
>> +			     int cmd)
>> +{
>  ...
>> +	return 0;
>> +}
>> +
>> +static int ibmvnic_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
>> +{
>> +	switch (cmd) {
>> +	case SIOCGMIIPHY:
>> +	case SIOCGMIIREG:
>> +	case SIOCSMIIREG:
>> +		return ibmvnic_mii_ioctl(netdev, ifr, cmd);
>> +	default:
>> +		return -EOPNOTSUPP;
>> +	}
>> +}
> This really doesn't make any sense.  Please just delete this.  You
> don't support MII reads or writes because they logically don't make
> sense on this device.
>
>> +static struct net_device_stats *ibmvnic_get_stats(struct net_device *dev)
>> +{
>> +	struct ibmvnic_adapter *adapter = netdev_priv(dev);
>> +
>> +	/* only return the current stats */
>> +	return &adapter->net_stats;
>> +}
> The default method does this for you as long as you properly use
> net_device's embedded stats, therefore you don't need to provide this
> at all.
>
> That's all I have any energy for, and as you can see nobody else wants
> to even try to review this driver.
>
> It's going to take a lot of respins and time before this driver is
> ready for upstream inclusion.
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev
