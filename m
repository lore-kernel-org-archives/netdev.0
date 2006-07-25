From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Help with bugfix for bond active-backup mode + vlans
Date: Mon, 24 Jul 2006 18:40:30 -0700
Message-ID: <200607250140.k6P1eUhg023141@death.nxdomain.ibm.com>
References: <200607241837.42626.Christophe.Devriese@eurid.eu> <200607241749.k6OHn1hg030011@death.nxdomain.ibm.com> <44C50A5E.80009@candelatech.com> <200607242125.k6OLPPhg019864@death.nxdomain.ibm.com> <44C53D22.6040908@candelatech.com>
Cc: Christophe Devriese <Christophe.Devriese@eurid.eu>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:6605 "EHLO e33.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S932378AbWGYBkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 21:40:33 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6P1eXq3005799
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 24 Jul 2006 21:40:33 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6P1eW7K187102
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 24 Jul 2006 19:40:33 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6P1eWmP027056
	for <netdev@vger.kernel.org>; Mon, 24 Jul 2006 19:40:32 -0600
To: Ben Greear <greearb@candelatech.com>
In-reply-to: <44C53D22.6040908@candelatech.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear <greearb@candelatech.com> wrote:

>Jay Vosburgh wrote:
>> 	Sadly, elegance remains elusive, since the by the time skb_bond
>> is called, the slave device the packet arrived on isn't available
>> (vlan->real_dev points to 'bond0' by this point), and that information
>> is needed to decide whether to drop the packet or not.
>> 	The least grotty solution that comes to mind is to have
>> __vlan_hwaccel_rx call some skb_bond_suppress_dups() function directly,
>> and change skb_bond() to also call that function.
>
>Can you use skb->input_dev?

	Not as it is currently implemented.  It is set by
netif_receive_skb, not by the vlan accelerator, so input_dev ends up
being the vlan device, not the underlying actual ethernet device.  It
looks like input_dev will be inconsistently assigned with vlans over
bonding: if the slave device is vlan accelerated, input_dev will be the
vlan device; if the slave isn't accelerated, input_dev will be the
slave.

	As far as I can tell, the input_dev is only used by the
NET_CLS_IND (input device classification) stuff, which has warnings
saying it might be going away.  I'm not seeing anything else right
offhand that uses it.

	Anyway, the skb_bond logic really needs the enslaved interface,
which isn't necessarily the input_dev (even if input_dev was always the
device that actually had the wire plugged into it).  If the slave is
itself some kind of virtual device (a vlan, for example), then input_dev
wouldn't be the right thing.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

