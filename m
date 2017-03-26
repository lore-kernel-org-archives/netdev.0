From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the gfs2 tree with the net tree
Date: Mon, 27 Mar 2017 10:52:17 +1100
Message-ID: <20170327105217.1c29fe0b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Hayes Wang <hayeswang@realtek.com>
To: Steven Whitehouse <swhiteho@redhat.com>,
        Bob Peterson <rpeterso@redhat.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:58061 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751191AbdCZXwm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 26 Mar 2017 19:52:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Today's linux-next merge of the gfs2 tree got a conflict in:

  drivers/net/usb/r8152.c

between commit:

  2f25abe6bac5 ("r8152: prevent the driver from transmitting packets with carrier off")

from the net tree and commit:

  ce594e9824ab ("r8152: simply the arguments")

from the gfs2 and net-next trees.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/usb/r8152.c
index c34df33c6d72,3262a326aae6..000000000000
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@@ -3698,27 -3697,19 +3705,29 @@@ static int rtl8152_resume(struct usb_in
  	if (!test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
  		tp->rtl_ops.init(tp);
  		queue_delayed_work(system_long_wq, &tp->hw_phy_work, 0);
- 		netif_device_attach(tp->netdev);
+ 		netif_device_attach(netdev);
  	}
  
- 	if (netif_running(tp->netdev) && tp->netdev->flags & IFF_UP) {
+ 	if (netif_running(netdev) && netdev->flags & IFF_UP) {
  		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
+ 			struct napi_struct *napi = &tp->napi;
+ 
  			tp->rtl_ops.autosuspend_en(tp, false);
- 			napi_disable(&tp->napi);
+ 			napi_disable(napi);
  			set_bit(WORK_ENABLE, &tp->flags);
 -			if (netif_carrier_ok(netdev))
 -				rtl_start_rx(tp);
 +
- 			if (netif_carrier_ok(tp->netdev)) {
++			if (netif_carrier_ok(netdev)) {
 +				if (rtl8152_get_speed(tp) & LINK_STATUS) {
 +					rtl_start_rx(tp);
 +				} else {
- 					netif_carrier_off(tp->netdev);
++					netif_carrier_off(netdev);
 +					tp->rtl_ops.disable(tp);
- 					netif_info(tp, link, tp->netdev,
++					netif_info(tp, link, netdev,
 +						   "linking down\n");
 +				}
 +			}
 +
- 			napi_enable(&tp->napi);
+ 			napi_enable(napi);
  			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
  			smp_mb__after_atomic();
  			if (!list_empty(&tp->rx_done))
