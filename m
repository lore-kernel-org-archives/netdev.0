From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: RE: [PATCH net-next] netxen: write IP address to firmware when
 using bonding
Date: Mon, 28 Nov 2011 00:02:28 -0600
Message-ID: <13A253B3F9BEFE43B93C09CF75F63CAA81602BBE98@MNEXMB1.qlogic.org>
References: <1322073791-15223-1-git-send-email-andy@greyhouse.net>
	<20111123.160922.1983654308126240492.davem@davemloft.net>
	<20111124032426.GG25132@gospo.rdu.redhat.com>,<20111124.003855.1498231373002177172.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Sony Chacko <sony.chacko@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"andy@greyhouse.net" <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:57990
	"EHLO VA3EHSOBE007.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751908Ab1K1GDA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 01:03:00 -0500
In-Reply-To: <20111124.003855.1498231373002177172.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy,

We need to restore the ip address after the adapter reset.
netxen_restore_indev_addr is the function that restores normal ip addresses
and vlan ip addresses. If we could find bond device directly from slave then 
we can use netxen_config_indev_addr to add the ip address of the bond device.
Otherwise we may need to cache the bond ip address in function netxen_list_config_vlan_ip
and change the condition from

if (!is_vlan_dev(dev))
                return;

to

if (!is_vlan_dev(dev) && !is_bond_dev(dev))
                return;


Some of the code in if and else part is repeated.
If possible can we have small functions for that ?
eg:
if (!is_netxen_netdev(dev))
+                       goto done;
+
+               adapter = netdev_priv(dev);
+               if (!adapter)
+                       goto done;
+
+               if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
+                       goto done;
+
+               netxen_config_indev_addr(adapter, orig_dev, event);


Rajesh
________________________________________
From: David Miller [davem@davemloft.net]
Sent: Thursday, November 24, 2011 11:08 AM
To: andy@greyhouse.net
Cc: netdev; Sony Chacko; Rajesh Borundia
Subject: Re: [PATCH net-next] netxen: write IP address to firmware when using bonding

From: Andy Gospodarek <andy@greyhouse.net>
Date: Wed, 23 Nov 2011 22:24:27 -0500

> Are you talking about adding a macro like this:
>
>       for_each_dev_in_bond(bond,slave) {
>               [...]
>       }
>
> to replace the statements I added that were like this:
>
>       for_each_netdev_rcu(&init_net, slave) {
>               if (slave->master == dev) {
>                       [...]
>               }
>       }
>
> If so, that totally seems reasonable.  If were requesting something
> else, please let me know.

Yes, some helper that walks the device list and tries to find
a device whose ->master matches 'dev'.
