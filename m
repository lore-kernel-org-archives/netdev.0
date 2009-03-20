From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH]: sunvnet netdev ops conversion...
Date: Fri, 20 Mar 2009 12:43:00 +0100
Message-ID: <87prgcju7v.fsf@nemi.mork.no>
References: <20090320.005205.65922171.davem@davemloft.net>
	<49C35443.8020604@cn.fujitsu.com>
	<20090320.013448.251351318.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:38928 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752179AbZCTLnO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 07:43:14 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Lkd82-0001bv-2B
	for netdev@vger.kernel.org; Fri, 20 Mar 2009 11:43:10 +0000
Received: from 193.160.199.2 ([193.160.199.2])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2009 11:43:10 +0000
Received: from bjorn by 193.160.199.2 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2009 11:43:10 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:
> From: Yang Hongyang <yanghy@cn.fujitsu.com>
> Date: Fri, 20 Mar 2009 16:30:59 +0800
>
>> David Miller wrote:
>> > Committed to net-next-2.6...
>> >=20
>> > sunvnet: Convert to net_device_ops.
>>=20
>> I noticed that there are other drivers's  net_device_ops=20
>> need to be converted,is these convert nessary?
>
> Not necessary, but desirable.  Once all drivers are
> converted we can remove the compatability code.

Just thinking... Would it make sense, at some point before removing the
compatibility layer, to add tests for partial conversions?  I noticed
the sungem bug just fixed by Stephen Hemminger=20
( http://permalink.gmane.org/gmane.linux.network/122756 )
which could have been caught by the patch below.

This will also ease the transition of "driver sets", like usbnet and
it's children, where a number of drivers need to make the conversion
together.  Don't know if that's a big problem, but it did stop my first
attempt to convert usbnet because I was uncertain whether I had caught
all of the necessary mini driver conversions.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---

 net/core/dev.c |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f112970..ad3e780 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4359,6 +4359,34 @@ int register_netdevice(struct net_device *dev)
 	 * This is temporary until all network devices are converted.
 	 */
 	if (dev->netdev_ops) {
+		/* drivers using netdev_ops should not set any of these */
+		if (dev->init ||
+		    dev->uninit ||
+		    dev->open ||
+		    dev->change_rx_flags ||
+		    dev->set_rx_mode ||
+		    dev->set_multicast_list ||
+		    dev->set_mac_address ||
+		    dev->validate_addr ||
+		    dev->do_ioctl ||
+		    dev->set_config ||
+		    dev->change_mtu ||
+		    dev->neigh_setup ||
+		    dev->tx_timeout ||
+		    dev->get_stats ||
+		    dev->vlan_rx_register ||
+		    dev->vlan_rx_add_vid ||
+		    dev->vlan_rx_kill_vid
+#ifdef CONFIG_NET_POLL_CONTROLLER
+		    || dev->poll_controller
+#endif
+			) {
+			char drivername[64];
+
+			pr_info("%s (%s): mixing netdev_ops and old API\n",
+				dev->name, netdev_drivername(dev, drivername,=20
+							     64));
+		}
 		netdev_resync_ops(dev);
 	} else {
 		char drivername[64];

