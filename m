From: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
Subject: ethtool occationally fails to communicate with with ucc_geth
Date: Wed, 6 Feb 2013 15:05:04 -0500
Message-ID: <20130206200504.GJ30788@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	Len Sorensen <lsorense@csclub.uwaterloo.ca>,
	linux-kernel@vger.kernel.org
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.csclub.uwaterloo.ca ([129.97.134.52]:53654 "EHLO
	mail.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758104Ab3BFUMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 15:12:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are occationally seeing ethtool fail to communicate with ucc_geth.
I think I have tracked down why it happens, but I don't see a good way
to fix it.

When the phy state changes, adjust_link() checks if the state has changed
and if the link is up.  If it is it does:

                if (new_state) {
                        /*
                         * To change the MAC configuration we need to disable
                         * the controller. To do so, we have to either grab
                         * ugeth->lock, which is a bad idea since 'graceful
                         * stop' commands might take quite a while, or we can
                         * quiesce driver's activity.
                         */
                        ugeth_quiesce(ugeth);
                        ugeth_disable(ugeth, COMM_DIR_RX_AND_TX);

                        out_be32(&ug_regs->maccfg2, tempval);
                        out_be32(&uf_regs->upsmr, upsmr);

                        ugeth_enable(ugeth, COMM_DIR_RX_AND_TX);
                        ugeth_activate(ugeth);
                }

The problem I believe is that ugeth_quiesce() does netif_device_detach
which clears __LINK_STATE_PRESENT, and hence makes dev_ethtool fail
due to:

        if (!dev || !netif_device_present(dev))
                return -ENODEV;

So if ethtool happens to be run between ugeth_quiesce() and
ugeth_activate(), it fails as if the device simply doesn't exist, which
is of course not true, it's just temporarily disabled.

I don't see any obvious way to make the ethtool requests block while the
adjust_link does it's business.  It seems that that making the device
disappear is the wrong thing to do though.

I am able to make it happen if I do:

'while ethtool ifname; do :; done' while plugging and unplugging the
cable for a few minutes.

Any suggestions?

-- 
len Sorensen
