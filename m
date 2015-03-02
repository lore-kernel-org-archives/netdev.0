From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: Re: [PATCHi v2] ibmveth: Add function to enable live MAC address
 changes
Date: Mon, 02 Mar 2015 11:52:38 -0600
Message-ID: <54F4A366.90005@linux.vnet.ibm.com>
References: <1425102964-3131-1-git-send-email-tlfalcon@linux.vnet.ibm.com> <20150228085932.GA2012@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	davem@davemloft.net, brking@linux.vnet.ibm.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:48518 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753489AbbCBRxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 12:53:46 -0500
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Mon, 2 Mar 2015 10:53:45 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 463D01FF0021
	for <netdev@vger.kernel.org>; Mon,  2 Mar 2015 10:44:49 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t22Hpt1j29360218
	for <netdev@vger.kernel.org>; Mon, 2 Mar 2015 10:52:03 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t22Hr47t004923
	for <netdev@vger.kernel.org>; Mon, 2 Mar 2015 10:53:05 -0700
In-Reply-To: <20150228085932.GA2012@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/2015 02:59 AM, Jiri Pirko wrote:
> Sat, Feb 28, 2015 at 06:56:04AM CET, tlfalcon@linux.vnet.ibm.com wrote:
>> Add a function that will enable changing the MAC address
>> of an ibmveth interface while it is still running.
>>
>> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
>> ---
>> v2:
>>   If h_change_logical_lan_mac fails, dev->dev_addr will not be changed.
>>
>> drivers/net/ethernet/ibm/ibmveth.c | 25 ++++++++++++++++++++++++-
>> 1 file changed, 24 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
>> index 21978cc..b6ac676 100644
>> --- a/drivers/net/ethernet/ibm/ibmveth.c
>> +++ b/drivers/net/ethernet/ibm/ibmveth.c
>> @@ -1327,6 +1327,29 @@ static unsigned long ibmveth_get_desired_dma(struct vio_dev *vdev)
>> 	return ret;
>> }
>>
>> +static int ibmveth_set_mac_addr(struct net_device *dev, void *p)
>> +{
>> +	struct ibmveth_adapter *adapter = netdev_priv(dev);
>> +	struct sockaddr *addr = p;
>> +	u64 mac_address;
>> +	int rc;
>> +
>> +	if (!is_valid_ether_addr(addr->sa_data))
>> +		return -EADDRNOTAVAIL;
>> +
>> +	mac_address = ibmveth_encode_mac_addr(addr->sa_data);
>> +	rc = h_change_logical_lan_mac(adapter->vdev->unit_address, mac_address);
>> +	if (rc) {
>> +		netdev_err(adapter->netdev, "h_change_logical_lan_mac failed "
>> +			   "with rc=%d\n", rc);
> Please do not wrap text in message. For that, 80-char limit does not apply.

I will send a new patch fixing this shortly.  Thanks to you, Brian, and Dave for reviewing this patch.

>
>
>> +		return rc;
>> +	}
>> +
>> +	ether_addr_copy(dev->dev_addr, addr->sa_data);
>> +
>> +	return 0;
>> +}
>> +
>> static const struct net_device_ops ibmveth_netdev_ops = {
>> 	.ndo_open		= ibmveth_open,
>> 	.ndo_stop		= ibmveth_close,
>> @@ -1337,7 +1360,7 @@ static const struct net_device_ops ibmveth_netdev_ops = {
>> 	.ndo_fix_features	= ibmveth_fix_features,
>> 	.ndo_set_features	= ibmveth_set_features,
>> 	.ndo_validate_addr	= eth_validate_addr,
>> -	.ndo_set_mac_address	= eth_mac_addr,
>> +	.ndo_set_mac_address    = ibmveth_set_mac_addr,
>> #ifdef CONFIG_NET_POLL_CONTROLLER
>> 	.ndo_poll_controller	= ibmveth_poll_controller,
>> #endif
>> -- 
>> 1.8.3.1
>>
