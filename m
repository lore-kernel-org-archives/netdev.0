From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] bonding: allow bond in mode balance-alb to work
 properly in bridge
Date: Sun, 15 Mar 2009 16:12:17 -0700
Message-ID: <20090315161217.7fa2c3a7@nehalam>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com>
	<20090313223932.50ebbd88@nehalam>
	<20090314094911.GA3455@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, davem@davemloft.net,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53547 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752748AbZCOXNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 19:13:36 -0400
In-Reply-To: <20090314094911.GA3455@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 14 Mar 2009 10:49:11 +0100
Jiri Pirko <jpirko@redhat.com> wrote:

> Sat, Mar 14, 2009 at 06:39:32AM CET, shemminger@linux-foundation.org wrote:
> >On Fri, 13 Mar 2009 19:33:04 +0100
> >Jiri Pirko <jpirko@redhat.com> wrote:
> >
> >> Hi all.
> >> 
> >> This is only a draft of patch to consult. I'm aware that it should be divided
> >> into multiple patches. I want to know opinion from you folks.
> >> 
> >> The problem is described in following bugzilla:
> >> https://bugzilla.redhat.com/show_bug.cgi?id=487763
> >> 
> >> Basically here's what's going on. In every mode, bonding interface uses the same
> >> mac address for all enslaved devices. Except for mode balance-alb. When you put
> >> this kind of bond device into a bridge it will only add one of mac adresses into
> >> a hash list of mac addresses, say X. This mac address is marked as local. But
> >> this bonding interface also has mac address Y. Now then packet arrives with
> >> destination address Y, this address is not marked as local and the packed looks
> >> like it needs to be forwarded. This packet is then lost which is wrong.
> >> 
> >> Notice that interfaces can be added and removed from bond while it is in bridge.
> >> Therefore I introduce another function pointer in struct net_device_ops -
> >> ndo_check_mac_address. This function when it's implemented should check passed
> >> mac address against the one set in device. I'm using this in bonding driver when
> >> the bond is in mode balance-alb to walk thru all slaves and checking if any of
> >> them equals passed address.
> >> 
> >> Then in bridge function br_handle_frame_finish() I'm using ndo_check_mac_address
> >> to recognize the destination mac address as local.
> >> 
> >> Please look at this and tell me what you think about it.
> >> 
> >> Thanks
> >> 
> >> Jirka
> >>
> >
> >A better and more general way to do this have the dev_set_mac_address
> >function check the return of the notifier and unwind. Then any protocol
> >can easily prevent address from changing.
> 
> Can you please describe this thougth a bit more? I can't understand it now...
> 
> Thanks
> 
> Jirka

Something like this:

--- a/net/core/dev.c	2009-03-15 15:55:02.098126056 -0700
+++ b/net/core/dev.c	2009-03-15 16:02:43.999251305 -0700
@@ -3830,6 +3830,7 @@ int dev_set_mac_address(struct net_devic
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 	int err;
+	char save_addr[MAX_ADDR_LEN];
 
 	if (!ops->ndo_set_mac_address)
 		return -EOPNOTSUPP;
@@ -3837,9 +3838,17 @@ int dev_set_mac_address(struct net_devic
 		return -EINVAL;
 	if (!netif_device_present(dev))
 		return -ENODEV;
+
+	memcpy(save_addr, dev->dev_addr, dev->addr_len);
 	err = ops->ndo_set_mac_address(dev, sa);
-	if (!err)
-		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+	if (err)
+		return err;
+
+	err = call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+	if (err) {
+		memcpy(sa->sa_data, save_addr, dev->addr_len);
+		ops->ndo_set_mac_address(dev, sa);
+	}
 	return err;
 }
 

And something like this:

--- a/drivers/net/bonding/bond_main.c	2009-03-15 16:03:53.909000973 -0700
+++ b/drivers/net/bonding/bond_main.c	2009-03-15 16:11:43.227127031 -0700
@@ -3534,6 +3534,7 @@ static int bond_slave_netdev_event(unsig
 {
 	struct net_device *bond_dev = slave_dev->master;
 	struct bonding *bond = netdev_priv(bond_dev);
+	int err;
 
 	switch (event) {
 	case NETDEV_UNREGISTER:
@@ -3570,6 +3571,15 @@ static int bond_slave_netdev_event(unsig
 		 * servitude.
 		 */
 		break;
+	case NETDEV_CHANGEADDR:
+		if (bond->params.mode == BOND_MODE_ALB)
+			err = bond_alb_check_mac_address(bond);
+		else if (compare_ether_addr(bond_dev->dev_addr, addr) != 0)
+			err = -EINVAL;
+
+		if (err)
+			return notifier_from_errno(err);
+		break;
 	case NETDEV_CHANGENAME:
 		/*
 		 * TODO: handle changing the primary's name



