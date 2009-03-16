From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] bonding: allow bond in mode balance-alb to work
	properly in bridge
Date: Mon, 16 Mar 2009 12:11:28 +0100
Message-ID: <20090316111127.GB3484@psychotron.englab.brq.redhat.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com> <20090313223932.50ebbd88@nehalam> <20090314094911.GA3455@psychotron.englab.brq.redhat.com> <20090315161217.7fa2c3a7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, davem@davemloft.net,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36678 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751772AbZCPLM5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2009 07:12:57 -0400
Content-Disposition: inline
In-Reply-To: <20090315161217.7fa2c3a7@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 16, 2009 at 12:12:17AM CET, shemminger@linux-foundation.org wrote:
>On Sat, 14 Mar 2009 10:49:11 +0100
>Jiri Pirko <jpirko@redhat.com> wrote:
>
>> Sat, Mar 14, 2009 at 06:39:32AM CET, shemminger@linux-foundation.org wrote:
>> >On Fri, 13 Mar 2009 19:33:04 +0100
>> >Jiri Pirko <jpirko@redhat.com> wrote:
>> >
>> >> Hi all.
>> >> 
>> >> This is only a draft of patch to consult. I'm aware that it should be divided
>> >> into multiple patches. I want to know opinion from you folks.
>> >> 
>> >> The problem is described in following bugzilla:
>> >> https://bugzilla.redhat.com/show_bug.cgi?id=487763
>> >> 
>> >> Basically here's what's going on. In every mode, bonding interface uses the same
>> >> mac address for all enslaved devices. Except for mode balance-alb. When you put
>> >> this kind of bond device into a bridge it will only add one of mac adresses into
>> >> a hash list of mac addresses, say X. This mac address is marked as local. But
>> >> this bonding interface also has mac address Y. Now then packet arrives with
>> >> destination address Y, this address is not marked as local and the packed looks
>> >> like it needs to be forwarded. This packet is then lost which is wrong.
>> >> 
>> >> Notice that interfaces can be added and removed from bond while it is in bridge.
>> >> Therefore I introduce another function pointer in struct net_device_ops -
>> >> ndo_check_mac_address. This function when it's implemented should check passed
>> >> mac address against the one set in device. I'm using this in bonding driver when
>> >> the bond is in mode balance-alb to walk thru all slaves and checking if any of
>> >> them equals passed address.
>> >> 
>> >> Then in bridge function br_handle_frame_finish() I'm using ndo_check_mac_address
>> >> to recognize the destination mac address as local.
>> >> 
>> >> Please look at this and tell me what you think about it.
>> >> 
>> >> Thanks
>> >> 
>> >> Jirka
>> >>
>> >
>> >A better and more general way to do this have the dev_set_mac_address
>> >function check the return of the notifier and unwind. Then any protocol
>> >can easily prevent address from changing.
>> 
>> Can you please describe this thougth a bit more? I can't understand it now...
>> 
>> Thanks
>> 
>> Jirka
>
>Something like this:
>
>--- a/net/core/dev.c	2009-03-15 15:55:02.098126056 -0700
>+++ b/net/core/dev.c	2009-03-15 16:02:43.999251305 -0700
>@@ -3830,6 +3830,7 @@ int dev_set_mac_address(struct net_devic
> {
> 	const struct net_device_ops *ops = dev->netdev_ops;
> 	int err;
>+	char save_addr[MAX_ADDR_LEN];
> 
> 	if (!ops->ndo_set_mac_address)
> 		return -EOPNOTSUPP;
>@@ -3837,9 +3838,17 @@ int dev_set_mac_address(struct net_devic
> 		return -EINVAL;
> 	if (!netif_device_present(dev))
> 		return -ENODEV;
>+
>+	memcpy(save_addr, dev->dev_addr, dev->addr_len);
> 	err = ops->ndo_set_mac_address(dev, sa);
>-	if (!err)
>-		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
>+	if (err)
>+		return err;
>+
>+	err = call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
>+	if (err) {
>+		memcpy(sa->sa_data, save_addr, dev->addr_len);
>+		ops->ndo_set_mac_address(dev, sa);
>+	}
> 	return err;
> }
> 
>
>And something like this:
>
>--- a/drivers/net/bonding/bond_main.c	2009-03-15 16:03:53.909000973 -0700
>+++ b/drivers/net/bonding/bond_main.c	2009-03-15 16:11:43.227127031 -0700
>@@ -3534,6 +3534,7 @@ static int bond_slave_netdev_event(unsig
> {
> 	struct net_device *bond_dev = slave_dev->master;
> 	struct bonding *bond = netdev_priv(bond_dev);
>+	int err;
> 
> 	switch (event) {
> 	case NETDEV_UNREGISTER:
>@@ -3570,6 +3571,15 @@ static int bond_slave_netdev_event(unsig
> 		 * servitude.
> 		 */
> 		break;
>+	case NETDEV_CHANGEADDR:
>+		if (bond->params.mode == BOND_MODE_ALB)
>+			err = bond_alb_check_mac_address(bond);
>+		else if (compare_ether_addr(bond_dev->dev_addr, addr) != 0)
>+			err = -EINVAL;
>+
>+		if (err)
>+			return notifier_from_errno(err);
>+		break;
> 	case NETDEV_CHANGENAME:
> 		/*
> 		 * TODO: handle changing the primary's name
>
Yes, I think the changing mac address of slaves should be also handled by
bonding driver. But my patch fixes a different issue. See, unlike in any other
bonding modes, in balance-alb mode incoming packets have multiple MAC adresses
(of any of enslaved devices). This causes problem because bridge only recognize
one of them (the mac of master which is the mac on one of the slaves) as local -
the other MAC's are not recognized as they are a part of port and therefore
handled as general MAC adresses. This is the problem.

I can see two solutions. Either like my patch or somehow allow bridge to know
more MAC addressses per port (maybe netdev can be changed to know more then
one MAC address).

Any thoughts?

Thanks

Jirka
>
>
