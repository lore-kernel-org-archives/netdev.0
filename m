From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: rndis gadget: Inconsistent locking
Date: Wed, 12 Jan 2011 12:28:12 +0000
Message-ID: <20110112122811.GA9513@ff.dom.local>
References: <466657.40223.qm@web180306.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?us-ascii?B?PT9JU08tODg1OS0yP1E/TWljaGE9QjNfTmF6YXJld2ljej89?=
	<m.nazarewicz@samsung.com>, Neil Jones <neiljay@gmail.com>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63629 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756110Ab1ALM2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 07:28:21 -0500
Content-Disposition: inline
In-Reply-To: <466657.40223.qm@web180306.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011-01-10 13:14, David Brownell wrote:
> 
> 
>> I have just retested Michals patch but I have found another
>> lockdep failure.
>>
>> It looks like rndis_msg_parser() can call dev_get_stats> too:
> 
> Can someone provide a fully working patch then?
> Or maybe just revert the one that caused all the
> breakage??
> 
> Rememeber that this driver was working fine for
> years before netdev changes added multiple bugs
> because (at least) they didn't update all callers.

Maybe I miss something, but if it's like Michal described something
like this should be enough (not tested nor compiled).

Jarek P.
---

 drivers/usb/gadget/f_phonet.c |    6 ++++++
 drivers/usb/gadget/u_ether.c  |    6 ++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_phonet.c
index 3c6e1a0..bef4622 100644
--- a/drivers/usb/gadget/f_phonet.c
+++ b/drivers/usb/gadget/f_phonet.c
@@ -207,6 +207,11 @@ static int pn_net_close(struct net_device *dev)
 	return 0;
 }
 
+static struct net_device_stats *pn_net_stats(struct net_device *dev)
+{
+	return &dev->stats;
+}
+
 static void pn_tx_complete(struct usb_ep *ep, struct usb_request *req)
 {
 	struct f_phonet *fp = ep->driver_data;
@@ -279,6 +284,7 @@ static int pn_net_mtu(struct net_device *dev, int new_mtu)
 static const struct net_device_ops pn_netdev_ops = {
 	.ndo_open	= pn_net_open,
 	.ndo_stop	= pn_net_close,
+	.ndo_get_stats	= pn_net_stats,
 	.ndo_start_xmit	= pn_net_xmit,
 	.ndo_change_mtu	= pn_net_mtu,
 };
diff --git a/drivers/usb/gadget/u_ether.c b/drivers/usb/gadget/u_ether.c
index 1eda968..f21520f 100644
--- a/drivers/usb/gadget/u_ether.c
+++ b/drivers/usb/gadget/u_ether.c
@@ -702,6 +702,11 @@ static int eth_stop(struct net_device *net)
 	return 0;
 }
 
+static struct net_device_stats *eth_get_stats(struct net_device *net)
+{
+	return &net->stats;
+}
+
 /*-------------------------------------------------------------------------*/
 
 /* initial value, changed by "ifconfig usb0 hw ether xx:xx:xx:xx:xx:xx" */
@@ -740,6 +745,7 @@ static struct eth_dev *the_dev;
 static const struct net_device_ops eth_netdev_ops = {
 	.ndo_open		= eth_open,
 	.ndo_stop		= eth_stop,
+	.ndo_get_stats		= eth_get_stats,
 	.ndo_start_xmit		= eth_start_xmit,
 	.ndo_change_mtu		= ueth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
