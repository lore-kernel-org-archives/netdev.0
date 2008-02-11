From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: Re: [patch 1/2] qeth: new qeth device driver
Date: Mon, 11 Feb 2008 08:55:41 +0100
Message-ID: <47AFFF7D.70101@linux.vnet.ibm.com>
References: <20080208140959.259912000@de.ibm.com> <20080208141535.271607000@de.ibm.com> <20080208155416.GB12085@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:45275 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952AbYBKHzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 02:55:19 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m1B7tIwK269232
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 07:55:18 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1B7tIV9876794
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 07:55:18 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1B7tFiD021453
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 07:55:15 GMT
In-Reply-To: <20080208155416.GB12085@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney schrieb:
> On Fri, Feb 08, 2008 at 03:10:00PM +0100, Frank.Blaschka@de.ibm.com wrote:
>> From: Frank Blaschka <frank.blaschka@de.ibm.com>
>>
>> List of major changes and improvements:
>>  no manipulation of the global ARP constructor
>>  clean code split into core, layer 2 and layer 3 functionality
>>  better exploitation of the ethtool interface
>>  better representation of the various hardware capabilities
>>  fix packet socket support (tcpdump), no fake_ll required
>>  osasnmpd notification via udev events
>>  coding style and beautification
> 
> One question below...
> 
>> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
>> ---
> 
> [ . . . ]
> 
>> +static void qeth_l3_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
>> +{
>> +	struct net_device *vlandev;
>> +	struct qeth_card *card = (struct qeth_card *) dev->priv;
>> +	struct in_device *in_dev;
>> +
>> +	if (card->info.type == QETH_CARD_TYPE_IQD)
>> +		return;
>> +
>> +	vlandev = vlan_group_get_device(card->vlangrp, vid);
>> +	vlandev->neigh_setup = qeth_l3_neigh_setup;
>> +
>> +	in_dev = __in_dev_get_rcu(vlandev);
> 
> Is this really in an RCU read-side critical section?  Or is this just
> using common code?
> 
> 						Thanx, Paul
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Hi Paul,

thanks for pointing at this. Using __in_dev_get_rcu without the rcu lock
is probably a bug at this place (right?). Using in_dev_get/in_dev_put
would be more appropriate. Same for qeth_l3_free_vlan_addresses4(), here
we take the rcu read lock, but in_dev_get/in_dev_put would be the better
choice. What do you think?

Best regards,
		Frank

