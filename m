From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: Adding vlan to DSA port causes lockdep splat
Date: Wed, 29 Mar 2017 17:55:26 +0100
Message-ID: <20170329165526.GB7909@n2100.armlinux.org.uk>
References: <CAJGZr0JNsL3HG_CUs_jhavYJ5Z6Z6S-bhmE4sONkk++uEZL7nw@mail.gmail.com>
 <33d9c12c-7b76-a790-555e-ae10176548e4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Maxim Uvarov <muvarov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:47190 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752782AbdC2Qzi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 12:55:38 -0400
Content-Disposition: inline
In-Reply-To: <33d9c12c-7b76-a790-555e-ae10176548e4@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 29, 2017 at 09:45:16AM -0700, Florian Fainelli wrote:
> On 02/21/2017 12:38 AM, Maxim Uvarov wrote:
> > Is there any progress on subj issue?

I'm afraid the report got completely ignored.  Hope you have better luck.

> > I see it was investigated here:
> > https://www.spinics.net/lists/netdev/msg361434.html
> 
> I was just able to reproduce this and will try to look into it. At first
> glance, the reason why we usually don't see it, is that VLAN
> configuration goes through bridge vlan, which exercises a slightly
> different code path.
> 
> FWIW: using bridge vlan (VLAN filtering) allows you to define your
> switch's default VLAN (ID and tag/untag flag) whereas the traditional
> vlan device does not really allow you to do that.
> 
> > 
> > But it still exist on later kernels:
> > 
> > [   37.320301] ip/1047 is trying to acquire lock:
> > [   37.324764]  (_xmit_ETHER/1){+.....}, at: [<c06ad228>] dev_mc_sync+0x4c/0x88
> > [   37.331882]
> > [   37.331882] but task is already holding lock:
> > [   37.337738]  (_xmit_ETHER/1){+.....}, at: [<c06ad228>] dev_mc_sync+0x4c/0x88
> > [   37.344828]
> > [   37.344828] other info that might help us debug this:
> > [   37.351384]  Possible unsafe locking scenario:
> > [   37.351384]
> > [   37.357326]        CPU0
> > [   37.359778]        ----
> > [   37.362230]   lock(_xmit_ETHER/1);
> > [   37.365650]   lock(_xmit_ETHER/1);
> > [   37.369069]
> > [   37.369069]  *** DEADLOCK ***
> > [   37.369069]
> > [   37.375013]  May be due to missing lock nesting notation
> > [   37.375013]
> > [   37.381830] 3 locks held by ip/1047:
> > [   37.385416]  #0:  (rtnl_mutex){+.+.+.}, at: [<c06b8248>]
> > rtnetlink_rcv+0x1c/0x38
> > [   37.392860]  #1:  (&vlan_netdev_addr_lock_key/1){+.....}, at:
> > [<c06a4f94>] dev_set_rx_mode+0x1c/0x30
> > [   37.402046]  #2:  (_xmit_ETHER/1){+.....}, at: [<c06ad228>]
> > dev_mc_sync+0x4c/0x88
> > [   37.409574]
> > [   37.409574] stack backtrace:
> > [   37.413952] CPU: 0 PID: 1047 Comm: ip Not tainted
> > 4.10.0maxdebug-00008-g9d55486 #22
> > [   37.421639] Hardware name: Generic AM33XX (Flattened Device Tree)
> > [   37.427756] Backtrace:
> > [   37.430237] [<c010bf78>] (dump_backtrace) from [<c010c220>]
> > (show_stack+0x18/0x1c)
> > [   37.437842]  r7:c140f7ec r6:c13e29e0 r5:dc316780 r4:c0db8408
> > [   37.443537] [<c010c208>] (show_stack) from [<c0402ab0>]
> > (dump_stack+0x20/0x28)
> > [   37.450800] [<c0402a90>] (dump_stack) from [<c016b294>]
> > (__lock_acquire+0x15d4/0x18ec)
> > [   37.458753] [<c0169cc0>] (__lock_acquire) from [<c016b958>]
> > (lock_acquire+0x74/0x94)
> > [   37.466532]  r10:dc2260c0 r9:dd747910 r8:00000000 r7:00000001
> > r6:00000001 r5:600d0013
> > [   37.474393]  r4:00000000
> > [   37.476946] [<c016b8e4>] (lock_acquire) from [<c07f802c>]
> > (_raw_spin_lock_nested+0x44/0x54)
> > [   37.485334]  r7:00001002 r6:dd4fd988 r5:dc1f3000 r4:dd4fd988
> > [   37.491022] [<c07f7fe8>] (_raw_spin_lock_nested) from [<c06ad228>]
> > (dev_mc_sync+0x4c/0x88)
> > [   37.499320]  r4:dd4fd800
> > [   37.501870] [<c06ad1dc>] (dev_mc_sync) from [<c0796b60>]
> > (dsa_slave_set_rx_mode+0x28/0x38)
> > [   37.510171]  r7:00001002 r6:00000000 r5:dd4fd800 r4:dc1f3000
> > [   37.515856] [<c0796b38>] (dsa_slave_set_rx_mode) from [<c06a4f40>]
> > (__dev_set_rx_mode+0x64/0x9c)
> > 
> 
> 
> -- 
> Florian

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
