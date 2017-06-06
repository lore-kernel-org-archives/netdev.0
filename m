From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH v2] xfrm: fix xfrm_dev_event() missing when compile
 without CONFIG_XFRM_OFFLOAD
Date: Tue, 6 Jun 2017 17:26:01 +0800
Message-ID: <20170606092600.GC12974@leo.usersys.redhat.com>
References: <1496277502-10642-1-git-send-email-liuhangbin@gmail.com>
 <1496300276-30901-1-git-send-email-liuhangbin@gmail.com>
 <20170606080658.GO2631@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Guy Shapiro <guysh@mellanox.com>,
        David Miller <davem@davemloft.net>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36819 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751246AbdFFJ0M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 05:26:12 -0400
Received: by mail-pf0-f193.google.com with SMTP id y7so5255628pfd.3
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 02:26:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170606080658.GO2631@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 06, 2017 at 10:06:58AM +0200, Steffen Klassert wrote:
> On Thu, Jun 01, 2017 at 02:57:56PM +0800, Hangbin Liu wrote:
> > In commit d77e38e612a0 ("xfrm: Add an IPsec hardware offloading API") we
> > make xfrm_device.o only compiled when enable option CONFIG_XFRM_OFFLOAD.
> > But this will make xfrm_dev_event() missing if we only enable default XFRM
> > options.
> > 
> > Then if we set down and unregister an interface with IPsec on it.
> 
> You should not be able to register an interface with IPsec offload
> without CONFIG_XFRM_OFFLOAD.

Yes, I mean when compile with default CONFIG_XFRM, the xfrm_dev_event() ->
xfrm_dev_down() -> xfrm_garbage_collect() will missing.

> 
> > there
> > will no xfrm_garbage_collect(), which will cause dev usage count hold and
> > get error like:
> > 
> > unregister_netdevice: waiting for <dev> to become free. Usage count = 4
> 
> Can you explain how to reproduce this?
> 

Sure, I didn't try physical drivers, just test latest net-next with
bridge/bonding and could reproduce it everytime.

```
# cat rep.sh
#!/bin/bash
iface=$1
src=$2
dst=$3
run=$4

brctl addbr br0
brctl addif br0 ${iface}
ip link set ${iface} up
ip link set br0 up
ip addr add ${src}/24 dev br0
ip xfrm state flush && ip xfrm policy flush
ip xfrm state add src ${src} dst ${dst} spi 1000 proto esp enc des3_ede _I_want_to_have_chicken_ auth sha1 beef_fish_pork_salad mode transport
ip xfrm state add src ${dst} dst ${src} spi 1000 proto esp enc des3_ede _I_want_to_have_chicken_ auth sha1 beef_fish_pork_salad mode transport
ip xfrm policy add src ${src} dst ${dst} dir out tmpl proto esp spi 1000 mode transport
ip xfrm policy add src ${dst} dst ${src} dir in tmpl proto esp spi 1000 mode transport

if [ "$run" ]; then
        sleep 1
        ping ${dst} -c 4
        ip link set br0 down
        ip link del br0
fi
```

On host A run : # ./rep.sh eth1 192.168.1.1 192.168.1.2
On host B run : # ./rep.sh eth1 192.168.1.2 192.168.1.1 run

Then we will see error like
kernel:unregister_netdevice: waiting for br0 to become free. Usage count = 3

Thanks
Hangbin
