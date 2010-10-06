From: <Narendra_K@Dell.com>
Subject: Re: [RFC] bonding: fix workqueue re-arming races
Date: Wed, 6 Oct 2010 13:06:09 +0530
Message-ID: <20101006073341.GA16786@libnet-test.oslab.blr.amer.dell.com>
References: <20100901183113.GA25227@midget.suse.cz> <12656.1283371238@death>
 <20100901205656.GA14982@smudla-wifi.bakulak.kosire.czf>
 <3617.1283388840@death> <20100902170847.GB8840@midget.suse.cz>
 <9698.1283990791@death> <25924.1284677073@death>
 <20100924112352.GA32716@auslistsprd01.us.dell.com>
 <20101001182232.GB25971@midget.suse.cz>
 <20101005150317.GA15555@libnet-test.oslab.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <fubar@us.ibm.com>, <bonding-devel@lists.sourceforge.net>,
	<markine@google.com>, <jarkao2@gmail.com>, <chavey@google.com>,
	<netdev@vger.kernel.org>
To: <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:22667 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873Ab0JFHlc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 03:41:32 -0400
In-Reply-To: <20101005150317.GA15555@libnet-test.oslab.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 05, 2010 at 08:33:29PM +0530, K, Narendra wrote:
>    On Fri, Oct 01, 2010 at 11:52:32PM +0530, Jiri Bohac wrote:
>    >    On Fri, Sep 24, 2010 at 06:23:53AM -0500, Narendra K wrote:
>    >    > On Fri, Sep 17, 2010 at 04:14:33AM +0530, Jay Vosburgh wrote:
>    >    > > Jay Vosburgh <fubar@us.ibm.com> wrote:
>    >    > The follwing call trace was seen -
>    >
>    >    This should be the BUG_ON(cwq->nr_active) in
>    >    destroy_workqueue()
>    >
>    >    This is really strange. bondng_store_bonds() can do two things:
>    >    create or delete a bonding device.
>    >
>    >    I checked the delete path, where I would normally expect such a
>    >    problem, but I can't find a way it could fail in this way.
>    >    bondng_store_bonds() calls unregister_netdevice(), which
>    >    - calls rollback_registered() -> bond_close()
>    >    - puts the device on the net_todo_list.
>    >    On rtnl_unlock() netdev_run_todo() gets called and that calls
>    >    bond_destructor().
>    >
>    >    bond_close() now makes sure the rearming work items are not
>    >    pending, thus, the only work items that may still be pending on
>    >    the workqueue are the non-rearming "commit" work items.
>    >    flush_workqueue(), called at the beginning of destroy_workqueue()
>    >    should have waited for these to finish.
>    >    If all of the above is correct, this BUG_ON should never trigger.
>    >
>    >    Maybe I am overlooking something, or it may be some kind of
>    >    failure/race condition in the create path, resulting in
>    >    bond_destructor() being called as well.
>    >
>    >    Narendra, any chance to capture the dmesg lines preceeding the
>    >    BUG message? This should show which of the above cases it is.
>
>    Jiri, I will try to reproduce the issue with ignore_loglevel to capture
>    more data on the serial console and share it shortly.

Here is a more verbose sequence of log messages just before the issue is
hit. I have attached logs beginning two iterations before the failure.
Please let me know if you need logs further back in the sequence.

[ 6139.115628] bonding: bond0 is being created...
[ 6139.122159] bonding: bond0: setting mode to balance-alb (6).
[ 6139.128537] bonding: bond0: Setting MII monitoring interval to 100.
[ 6139.137702] ADDRCONF(NETDEV_UP): bond0: link is not ready
[ 6139.145516] bonding: bond0: Adding slave eth0.
[ 6139.173964] bnx2 0000:01:00.0: irq 79 for MSI/MSI-X
[ 6139.179111] bnx2 0000:01:00.0: irq 80 for MSI/MSI-X
[ 6139.184262] bnx2 0000:01:00.0: irq 81 for MSI/MSI-X
[ 6139.189424] bnx2 0000:01:00.0: irq 82 for MSI/MSI-X
[ 6139.194559] bnx2 0000:01:00.0: irq 83 for MSI/MSI-X
[ 6139.199701] bnx2 0000:01:00.0: irq 84 for MSI/MSI-X
[ 6139.204873] bnx2 0000:01:00.0: irq 85 for MSI/MSI-X
[ 6139.210016] bnx2 0000:01:00.0: irq 86 for MSI/MSI-X
[ 6139.215158] bnx2 0000:01:00.0: irq 87 for MSI/MSI-X
[ 6139.270975] bnx2 0000:01:00.0: eth0: using MSIX
[ 6139.278893] bonding: bond0: enslaving eth0 as an active interface with a down link.
[ 6139.291007] bonding: bond0: Adding slave eth1.
[ 6139.321113] bnx2 0000:01:00.1: irq 88 for MSI/MSI-X
[ 6139.325991] bnx2 0000:01:00.1: irq 89 for MSI/MSI-X
[ 6139.330866] bnx2 0000:01:00.1: irq 90 for MSI/MSI-X
[ 6139.335752] bnx2 0000:01:00.1: irq 91 for MSI/MSI-X
[ 6139.340626] bnx2 0000:01:00.1: irq 92 for MSI/MSI-X
[ 6139.345500] bnx2 0000:01:00.1: irq 93 for MSI/MSI-X
[ 6139.350373] bnx2 0000:01:00.1: irq 94 for MSI/MSI-X
[ 6139.355246] bnx2 0000:01:00.1: irq 95 for MSI/MSI-X
[ 6139.360119] bnx2 0000:01:00.1: irq 96 for MSI/MSI-X
[ 6139.418765] bnx2 0000:01:00.1: eth1: using MSIX
[ 6139.426671] bonding: bond0: enslaving eth1 as an active interface with a down link.
[ 6139.438664] bonding: bond0: Adding slave eth2.
[ 6139.469101] bnx2 0000:02:00.0: irq 97 for MSI/MSI-X
[ 6139.473980] bnx2 0000:02:00.0: irq 98 for MSI/MSI-X
[ 6139.478856] bnx2 0000:02:00.0: irq 99 for MSI/MSI-X
[ 6139.483743] bnx2 0000:02:00.0: irq 100 for MSI/MSI-X
[ 6139.488706] bnx2 0000:02:00.0: irq 101 for MSI/MSI-X
[ 6139.493670] bnx2 0000:02:00.0: irq 102 for MSI/MSI-X
[ 6139.498641] bnx2 0000:02:00.0: irq 103 for MSI/MSI-X
[ 6139.503604] bnx2 0000:02:00.0: irq 104 for MSI/MSI-X
[ 6139.508566] bnx2 0000:02:00.0: irq 105 for MSI/MSI-X
[ 6139.566908] bnx2 0000:02:00.0: eth2: using MSIX
[ 6139.574815] bonding: bond0: enslaving eth2 as an active interface with a down link.
[ 6139.586686] bonding: bond0: Adding slave eth3.
[ 6139.617042] bnx2 0000:02:00.1: irq 106 for MSI/MSI-X
[ 6139.622011] bnx2 0000:02:00.1: irq 107 for MSI/MSI-X
[ 6139.626974] bnx2 0000:02:00.1: irq 108 for MSI/MSI-X
[ 6139.631942] bnx2 0000:02:00.1: irq 109 for MSI/MSI-X
[ 6139.636904] bnx2 0000:02:00.1: irq 110 for MSI/MSI-X
[ 6139.641867] bnx2 0000:02:00.1: irq 111 for MSI/MSI-X
[ 6139.646835] bnx2 0000:02:00.1: irq 112 for MSI/MSI-X
[ 6139.651798] bnx2 0000:02:00.1: irq 113 for MSI/MSI-X
[ 6139.656760] bnx2 0000:02:00.1: irq 114 for MSI/MSI-X
[ 6139.714833] bnx2 0000:02:00.1: eth3: using MSIX
[ 6139.722929] bonding: bond0: enslaving eth3 as an active interface with a down link.
[ 6141.684544] bnx2 0000:01:00.0: eth0: NIC Copper Link is Up, 1000 Mbps full duplex
[ 6141.732924] bonding: bond0: link status definitely up for interface eth0.
[ 6141.739714] bonding: bond0: making interface eth0 the new active one.
[ 6141.749618] bonding: bond0: first active interface up!
[ 6141.756427] ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
[ 6141.832597] bnx2 0000:01:00.1: eth1: NIC Copper Link is Up, 1000 Mbps full duplex
[ 6141.840185] bonding: bond0: link status definitely up for interface eth1.
[ 6142.013511] bnx2 0000:02:00.0: eth2: NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
[ 6142.037019] bonding: bond0: link status definitely up for interface eth2.
[ 6146.252919] bonding: bond0: link status definitely down for interface eth0, disabling it
[ 6146.261009] bonding: bond0: making interface eth1 the new active one.
[ 6146.305466] bnx2 0000:01:00.0: irq 79 for MSI/MSI-X
[ 6146.310347] bnx2 0000:01:00.0: irq 80 for MSI/MSI-X
[ 6146.315223] bnx2 0000:01:00.0: irq 81 for MSI/MSI-X
[ 6146.320100] bnx2 0000:01:00.0: irq 82 for MSI/MSI-X
[ 6146.324983] bnx2 0000:01:00.0: irq 83 for MSI/MSI-X
[ 6146.329858] bnx2 0000:01:00.0: irq 84 for MSI/MSI-X
[ 6146.334735] bnx2 0000:01:00.0: irq 85 for MSI/MSI-X
[ 6146.339611] bnx2 0000:01:00.0: irq 86 for MSI/MSI-X
[ 6146.344535] bnx2 0000:01:00.0: irq 87 for MSI/MSI-X
[ 6146.402416] bnx2 0000:01:00.0: eth0: using MSIX
[ 6147.100849] bonding: bond0: link status definitely down for interface eth1, disabling it
[ 6147.108943] bonding: bond0: making interface eth2 the new active one.
[ 6147.153439] bnx2 0000:01:00.1: irq 88 for MSI/MSI-X
[ 6147.158322] bnx2 0000:01:00.1: irq 89 for MSI/MSI-X
[ 6147.163199] bnx2 0000:01:00.1: irq 90 for MSI/MSI-X
[ 6147.168081] bnx2 0000:01:00.1: irq 91 for MSI/MSI-X
[ 6147.172957] bnx2 0000:01:00.1: irq 92 for MSI/MSI-X
[ 6147.177833] bnx2 0000:01:00.1: irq 93 for MSI/MSI-X
[ 6147.182717] bnx2 0000:01:00.1: irq 94 for MSI/MSI-X
[ 6147.187597] bnx2 0000:01:00.1: irq 95 for MSI/MSI-X
[ 6147.192584] bnx2 0000:01:00.1: irq 96 for MSI/MSI-X
[ 6147.250432] bnx2 0000:01:00.1: eth1: using MSIX
[ 6147.956727] bonding: bond0: link status definitely down for interface eth2, disabling it
[ 6147.964821] bonding: bond0: now running without any active interface !
[ 6148.005316] bnx2 0000:02:00.0: irq 97 for MSI/MSI-X
[ 6148.010198] bnx2 0000:02:00.0: irq 98 for MSI/MSI-X
[ 6148.015072] bnx2 0000:02:00.0: irq 99 for MSI/MSI-X
[ 6148.019949] bnx2 0000:02:00.0: irq 100 for MSI/MSI-X
[ 6148.024911] bnx2 0000:02:00.0: irq 101 for MSI/MSI-X
[ 6148.029872] bnx2 0000:02:00.0: irq 102 for MSI/MSI-X
[ 6148.034833] bnx2 0000:02:00.0: irq 103 for MSI/MSI-X
[ 6148.039793] bnx2 0000:02:00.0: irq 104 for MSI/MSI-X
[ 6148.044756] bnx2 0000:02:00.0: irq 105 for MSI/MSI-X
[ 6148.102286] bnx2 0000:02:00.0: eth2: using MSIX
[ 6148.873352] bnx2 0000:02:00.1: irq 106 for MSI/MSI-X
[ 6148.878319] bnx2 0000:02:00.1: irq 107 for MSI/MSI-X
[ 6148.883293] bnx2 0000:02:00.1: irq 108 for MSI/MSI-X
[ 6148.888253] bnx2 0000:02:00.1: irq 109 for MSI/MSI-X
[ 6148.893213] bnx2 0000:02:00.1: irq 110 for MSI/MSI-X
[ 6148.898174] bnx2 0000:02:00.1: irq 111 for MSI/MSI-X
[ 6148.903134] bnx2 0000:02:00.1: irq 112 for MSI/MSI-X
[ 6148.908094] bnx2 0000:02:00.1: irq 113 for MSI/MSI-X
[ 6148.913060] bnx2 0000:02:00.1: irq 114 for MSI/MSI-X
[ 6148.970345] bnx2 0000:02:00.1: eth3: using MSIX
[ 6149.445381] bnx2 0000:01:00.0: eth0: NIC Copper Link is Up, 1000 Mbps full duplex
[ 6149.540563] bonding: bond0: link status definitely up for interface eth0.
[ 6149.547352] bonding: bond0: making interface eth0 the new active one.
[ 6149.557274] bonding: bond0: first active interface up!
[ 6149.941355] bonding: bond0: Removing slave eth0.
[ 6149.945983] bonding: bond0: Warning: the permanent HWaddr of eth0 - 00:22:19:cc:9a:25 - is still in use by bond0. Set the HWaddr of eth0 to a different address to avoid conflicts.
[ 6149.962010] bonding: bond0: releasing active interface eth0
[ 6150.074401] bonding: bond0: Removing slave eth1.
[ 6150.079027] bonding: bond0: releasing active interface eth1
[ 6150.202403] bonding: bond0: Removing slave eth2.
[ 6150.207028] bonding: bond0: releasing active interface eth2
[ 6150.330275] bonding: bond0: Removing slave eth3.
[ 6150.334900] bonding: bond0: releasing active interface eth3
[ 6150.552776] bonding: bond0 is being deleted...
[ 6156.145939] bonding: bond0 is being created...
[ 6156.152253] bonding: bond0: setting mode to balance-alb (6).
[ 6156.158899] bonding: bond0: Setting MII monitoring interval to 100.
[ 6156.168142] ADDRCONF(NETDEV_UP): bond0: link is not ready
[ 6156.176120] bonding: bond0: Adding slave eth0.
[ 6156.205188] bnx2 0000:01:00.0: irq 79 for MSI/MSI-X
[ 6156.210066] bnx2 0000:01:00.0: irq 80 for MSI/MSI-X
[ 6156.214942] bnx2 0000:01:00.0: irq 81 for MSI/MSI-X
[ 6156.219817] bnx2 0000:01:00.0: irq 82 for MSI/MSI-X
[ 6156.224724] bnx2 0000:01:00.0: irq 83 for MSI/MSI-X
[ 6156.229599] bnx2 0000:01:00.0: irq 84 for MSI/MSI-X
[ 6156.234473] bnx2 0000:01:00.0: irq 85 for MSI/MSI-X
[ 6156.239347] bnx2 0000:01:00.0: irq 86 for MSI/MSI-X
[ 6156.244222] bnx2 0000:01:00.0: irq 87 for MSI/MSI-X
[ 6156.301985] bnx2 0000:01:00.0: eth0: using MSIX
[ 6156.309899] bonding: bond0: enslaving eth0 as an active interface with a down link.
[ 6156.321860] bonding: bond0: Adding slave eth1.
[ 6156.348184] bnx2 0000:01:00.1: irq 88 for MSI/MSI-X
[ 6156.353066] bnx2 0000:01:00.1: irq 89 for MSI/MSI-X
[ 6156.357942] bnx2 0000:01:00.1: irq 90 for MSI/MSI-X
[ 6156.362818] bnx2 0000:01:00.1: irq 91 for MSI/MSI-X
[ 6156.367694] bnx2 0000:01:00.1: irq 92 for MSI/MSI-X
[ 6156.372570] bnx2 0000:01:00.1: irq 93 for MSI/MSI-X
[ 6156.377445] bnx2 0000:01:00.1: irq 94 for MSI/MSI-X
[ 6156.382325] bnx2 0000:01:00.1: irq 95 for MSI/MSI-X
[ 6156.387199] bnx2 0000:01:00.1: irq 96 for MSI/MSI-X
[ 6156.445966] bnx2 0000:01:00.1: eth1: using MSIX
[ 6156.453878] bonding: bond0: enslaving eth1 as an active interface with a down link.
[ 6156.465826] bonding: bond0: Adding slave eth2.
[ 6156.496230] bnx2 0000:02:00.0: irq 97 for MSI/MSI-X
[ 6156.501110] bnx2 0000:02:00.0: irq 98 for MSI/MSI-X
[ 6156.505986] bnx2 0000:02:00.0: irq 99 for MSI/MSI-X
[ 6156.510868] bnx2 0000:02:00.0: irq 100 for MSI/MSI-X
[ 6156.515832] bnx2 0000:02:00.0: irq 101 for MSI/MSI-X
[ 6156.520794] bnx2 0000:02:00.0: irq 102 for MSI/MSI-X
[ 6156.525760] bnx2 0000:02:00.0: irq 103 for MSI/MSI-X
[ 6156.530723] bnx2 0000:02:00.0: irq 104 for MSI/MSI-X
[ 6156.535685] bnx2 0000:02:00.0: irq 105 for MSI/MSI-X
[ 6156.594017] bnx2 0000:02:00.0: eth2: using MSIX
[ 6156.601932] bonding: bond0: enslaving eth2 as an active interface with a down link.
[ 6156.613845] bonding: bond0: Adding slave eth3.
[ 6156.644229] bnx2 0000:02:00.1: irq 106 for MSI/MSI-X
[ 6156.649197] bnx2 0000:02:00.1: irq 107 for MSI/MSI-X
[ 6156.654161] bnx2 0000:02:00.1: irq 108 for MSI/MSI-X
[ 6156.659130] bnx2 0000:02:00.1: irq 109 for MSI/MSI-X
[ 6156.664093] bnx2 0000:02:00.1: irq 110 for MSI/MSI-X
[ 6156.669056] bnx2 0000:02:00.1: irq 111 for MSI/MSI-X
[ 6156.674023] bnx2 0000:02:00.1: irq 112 for MSI/MSI-X
[ 6156.678985] bnx2 0000:02:00.1: irq 113 for MSI/MSI-X
[ 6156.683947] bnx2 0000:02:00.1: irq 114 for MSI/MSI-X
[ 6156.742024] bnx2 0000:02:00.1: eth3: using MSIX
[ 6156.749940] bonding: bond0: enslaving eth3 as an active interface with a down link.
[ 6158.808483] bnx2 0000:01:00.0: eth0: NIC Copper Link is Up, 1000 Mbps full duplex
[ 6158.868054] bonding: bond0: link status definitely up for interface eth0.
[ 6158.874846] bonding: bond0: making interface eth0 the new active one.
[ 6158.884753] bonding: bond0: first active interface up!
[ 6158.891563] ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
[ 6158.922727] bnx2 0000:01:00.1: eth1: NIC Copper Link is Up, 1000 Mbps full duplex
[ 6158.968157] bonding: bond0: link status definitely up for interface eth1.
[ 6159.021517] bnx2 0000:02:00.0: eth2: NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
[ 6159.068235] bonding: bond0: link status definitely up for interface eth2.
[ 6160.040150] bnx2 0000:01:00.1: eth1: NIC Copper Link is Down
[ 6160.069773] bonding: bond0: link status definitely down for interface eth1, disabling it
[ 6162.460199] bnx2 0000:01:00.1: eth1: NIC Copper Link is Up, 1000 Mbps full duplex
[ 6162.467865] bonding: bond0: link status definitely up for interface eth1.
[ 6163.168061] bonding: bond0: link status definitely down for interface eth0, disabling it
[ 6163.176149] bonding: bond0: making interface eth1 the new active one.
[ 6163.220460] bnx2 0000:01:00.0: irq 79 for MSI/MSI-X
[ 6163.225481] bnx2 0000:01:00.0: irq 80 for MSI/MSI-X
[ 6163.230413] bnx2 0000:01:00.0: irq 81 for MSI/MSI-X
[ 6163.235342] bnx2 0000:01:00.0: irq 82 for MSI/MSI-X
[ 6163.240282] bnx2 0000:01:00.0: irq 83 for MSI/MSI-X
[ 6163.245212] bnx2 0000:01:00.0: irq 84 for MSI/MSI-X
[ 6163.250142] bnx2 0000:01:00.0: irq 85 for MSI/MSI-X
[ 6163.255080] bnx2 0000:01:00.0: irq 86 for MSI/MSI-X
[ 6163.260009] bnx2 0000:01:00.0: irq 87 for MSI/MSI-X
[ 6163.317682] bnx2 0000:01:00.0: eth0: using MSIX
[ 6164.032023] bonding: bond0: link status definitely down for interface eth1, disabling it
[ 6164.040115] bonding: bond0: making interface eth2 the new active one.
[ 6164.084607] bnx2 0000:01:00.1: irq 88 for MSI/MSI-X
[ 6164.089488] bnx2 0000:01:00.1: irq 89 for MSI/MSI-X
[ 6164.094361] bnx2 0000:01:00.1: irq 90 for MSI/MSI-X
[ 6164.099236] bnx2 0000:01:00.1: irq 91 for MSI/MSI-X
[ 6164.104111] bnx2 0000:01:00.1: irq 92 for MSI/MSI-X
[ 6164.108986] bnx2 0000:01:00.1: irq 93 for MSI/MSI-X
[ 6164.113860] bnx2 0000:01:00.1: irq 94 for MSI/MSI-X
[ 6164.118733] bnx2 0000:01:00.1: irq 95 for MSI/MSI-X
[ 6164.123608] bnx2 0000:01:00.1: irq 96 for MSI/MSI-X
[ 6164.181533] bnx2 0000:01:00.1: eth1: using MSIX
[ 6164.880097] bonding: bond0: link status definitely down for interface eth2, disabling it
[ 6164.888191] bonding: bond0: now running without any active interface !
[ 6164.932440] bnx2 0000:02:00.0: irq 97 for MSI/MSI-X
[ 6164.937322] bnx2 0000:02:00.0: irq 98 for MSI/MSI-X
[ 6164.942253] bnx2 0000:02:00.0: irq 99 for MSI/MSI-X
[ 6164.947192] bnx2 0000:02:00.0: irq 100 for MSI/MSI-X
[ 6164.952208] bnx2 0000:02:00.0: irq 101 for MSI/MSI-X
[ 6164.957234] bnx2 0000:02:00.0: irq 102 for MSI/MSI-X
[ 6164.962247] bnx2 0000:02:00.0: irq 103 for MSI/MSI-X
[ 6164.967274] bnx2 0000:02:00.0: irq 104 for MSI/MSI-X
[ 6164.972290] bnx2 0000:02:00.0: irq 105 for MSI/MSI-X
[ 6165.029585] bnx2 0000:02:00.0: eth2: using MSIX
[ 6165.776479] bnx2 0000:02:00.1: irq 106 for MSI/MSI-X
[ 6165.781449] bnx2 0000:02:00.1: irq 107 for MSI/MSI-X
[ 6165.786422] bnx2 0000:02:00.1: irq 108 for MSI/MSI-X
[ 6165.791385] bnx2 0000:02:00.1: irq 109 for MSI/MSI-X
[ 6165.796345] bnx2 0000:02:00.1: irq 110 for MSI/MSI-X
[ 6165.801312] bnx2 0000:02:00.1: irq 111 for MSI/MSI-X
[ 6165.806273] bnx2 0000:02:00.1: irq 112 for MSI/MSI-X
[ 6165.811233] bnx2 0000:02:00.1: irq 113 for MSI/MSI-X
[ 6165.816199] bnx2 0000:02:00.1: irq 114 for MSI/MSI-X
[ 6165.873445] bnx2 0000:02:00.1: eth3: using MSIX
[ 6165.951287] bnx2 0000:01:00.0: eth0: NIC Copper Link is Up, 1000 Mbps full duplex
[ 6165.967840] bonding: bond0: link status definitely up for interface eth0.
[ 6165.974631] bonding: bond0: making interface eth0 the new active one.
[ 6165.984534] bonding: bond0: first active interface up!
[ 6166.836175] bnx2 0000:01:00.1: eth1: NIC Copper Link is Up, 1000 Mbps full duplex
[ 6166.839757] bonding: bond0: Removing slave eth0.
[ 6166.839768] bonding: bond0: Warning: the permanent HWaddr of eth0 - 00:22:19:cc:9a:25 - is still in use by bond0. Set the HWaddr of eth0 to a different address to avoid conflicts.
[ 6166.839772] bonding: bond0: releasing active interface eth0
[ 6166.870004]
[ 6166.999414] bonding: bond0: Removing slave eth1.
[ 6167.004041] bonding: bond0: releasing active interface eth1
[ 6167.125571] bonding: bond0: Removing slave eth2.
[ 6167.130196] bonding: bond0: releasing active interface eth2
[ 6167.253539] bonding: bond0: Removing slave eth3.
[ 6167.258162] bonding: bond0: releasing active interface eth3
[ 6167.443911] bonding: bond0 is being deleted...
[ 6167.508557] ------------[ cut here ]------------
[ 6167.513167] kernel BUG at kernel/workqueue.c:2844!
[ 6167.517948] invalid opcode: 0000 [#1] SMP
[ 6167.522058] last sysfs file: /sys/class/net/bonding_masters
[ 6167.527619] CPU 0
[ 6167.529452] Modules linked in: af_packet bonding ipv6 mperf microcode fuse loop dm_mod joydev usbhid hid tpm_tis tpm usb_storage iTCO_wdt tpm_bios iTCO_vendor_support rtc_cmos rtc_core rtc_lib sg mptctl sr_mod cdrom dcdbas power_meter bnx2 serio_raw button pcspkr uhci_hcd ehci_hcd usbcore sd_mod crc_t10dif edd ext3 mbcache jbd fan processor ide_pci_generic ide_core ata_generic ata_piix libata mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 6167.571721]
[ 6167.573209] Pid: 13848, comm: ifdown-bonding Not tainted 2.6.35.with.upstream.patch-next-20100811-0.7-default+ #1 0M233H/PowerEdge R710
[ 6167.585362] RIP: 0010:[<ffffffff81067b50>]  [<ffffffff81067b50>] destroy_workqueue+0x1d0/0x1e0
[ 6167.593977] RSP: 0018:ffff880229981d88  EFLAGS: 00010286
[ 6167.599278] RAX: 000000000000003c RBX: ffff880127646800 RCX: ffff880128324700
[ 6167.606401] RDX: 0000000000001000 RSI: 0000000000000002 RDI: 000000000000001a
[ 6167.613523] RBP: ffff880229981da8 R08: ffff880229981cf8 R09: 0000000000000000
[ 6167.620646] R10: 00000000ffffffff R11: 0000000000000000 R12: 0000000000000002
[ 6167.627769] R13: ffffffff817b8560 R14: ffff88012a028480 R15: ffff88012a028488
[ 6167.634892] FS:  00007fb251db3700(0000) GS:ffff880133a00000(0000) knlGS:0000000000000000
[ 6167.642969] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 6167.648705] CR2: 00007fb251de6000 CR3: 00000001283ca000 CR4: 00000000000006f0
[ 6167.655827] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 6167.662950] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 6167.670073] Process ifdown-bonding (pid: 13848, threadinfo ffff880229980000, task ffff88021db9a600)
[ 6167.679103] Stack:
[ 6167.681110]  ffff880229981da8 ffff88012a028000 ffff88012a028000 000000010016619c
[ 6167.688354] <0> ffff880229981dc8 ffffffffa03bf91d ffff88012a028000 000000010016619c
[ 6167.696053] <0> ffff880229981e28 ffffffff812e0a08 ffff880229981e38 ffff880229981de8
[ 6167.703936] Call Trace:
[ 6167.706382]  [<ffffffffa03bf91d>] bond_destructor+0x1d/0x30 [bonding]
[ 6167.712816]  [<ffffffff812e0a08>] netdev_run_todo+0x1a8/0x270
[ 6167.718555]  [<ffffffff812ee859>] rtnl_unlock+0x9/0x10
[ 6167.723752]  [<ffffffffa03cc824>] bonding_store_bonds+0x1c4/0x1f0 [bonding]
[ 6167.730705]  [<ffffffff810f26be>] ? alloc_pages_current+0x9e/0x110
[ 6167.736876]  [<ffffffff81285c9e>] class_attr_store+0x1e/0x20
[ 6167.742528]  [<ffffffff8116e365>] sysfs_write_file+0xc5/0x140
[ 6167.748267]  [<ffffffff8110a68f>] vfs_write+0xcf/0x190
[ 6167.753397]  [<ffffffff8110a840>] sys_write+0x50/0x90
[ 6167.758444]  [<ffffffff81002ec2>] system_call_fastpath+0x16/0x1b
[ 6167.764439] Code: 00 7f 14 8b 3b eb 91 3d 00 10 00 00 89 c2 77 10 8b 3b e9 07 ff ff ff 3d 00 10 00 00 89 c2 76 f0 8b 3b e9 a9 fe ff ff 0f 0b eb fe <0f> 0b eb fe 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 8b 3d 00
[ 6167.783930] RIP  [<ffffffff81067b50>] destroy_workqueue+0x1d0/0x1e0
[ 6167.790200]  RSP <ffff880229981d88>
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu


--
With regards,
Narendra K
