From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipv4: Cache source address in nexthop entries.
Date: Thu, 10 Mar 2011 01:32:18 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103100014430.2160@ja.ssi.bg>
References: <alpine.LFD.2.00.1103081030090.1529@ja.ssi.bg> <20110308.103801.193702247.davem@davemloft.net> <alpine.LFD.2.00.1103090157400.2880@ja.ssi.bg> <20110309.130817.115943793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:43201 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751249Ab1CIX1g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 18:27:36 -0500
In-Reply-To: <20110309.130817.115943793.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Hello,

On Wed, 9 Mar 2011, David Miller wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Wed, 9 Mar 2011 02:49:49 +0200 (EET)
>
>> 	But we still need to propagate the address events
>> to nexthops on all devices. Even if it is slow, I see it in
>> this way (not tested):
>
> Ok, I think it is even more involved than what you propose.
>
> We have to potentially re-run inet_select_addr() on all nexthops, even
> those pointing to devices other than the one being modified, because
> when an interface loses it's last IP address we have to look for a
> source address to use on other active interfaces.

 	Yes. The common case is addresses to be scope
global. That means they can influence any nexthop on
any device. Only when address has scope >= LINK we can
use version that walks single table row for the same device.
In the default case we need to walk all table rows.

 	Additionally, it is possible same address to exist
on different devices, possibly with different scope. That is
why reacting only on "last_ip" indication when deleting IP
is not enough. May be while we delete scope-link address on the
concerned device, there can be same address as scope-link
on another device but its scope is not enough to keep
it as nh_saddr, so the right thing is to get different
IP as saddr. That is why in my version of fib_update_nh_saddrs
I don't care about "last_ip" indication. I think, my
version of fib_update_nh_saddrs is ok for IP add/del but
as I said, device UP events should recalc nh_saddr too.
In my version the logic is:

- add IP:
 	- check all NHs on all devices
 	- goal: if the added IP-scope is suitable for NH
 	it can replace other less-priority IPs, where the
 	priority depends on factors such as device, placement in
 	device list and scope
 	- if NH has same nh_saddr then nothing to do
 	- IP scope and DEV should be allowed for the nh_cfg_scope
 	to change the nh_saddr

- del IP:
 	- check all NHs on all devices
 	- goal: if the removed IP-scope was nh_saddr somewhere
 	then we should recalc NH, even when IP is not the
 	last address with same value
 	- if NH has different nh_saddr then nothing to do
 	- IP scope and DEV should be allowed for the nh_cfg_scope
 	to change the nh_saddr because may be this IP-scope-DEV
 	was used as nh_saddr

> Probably it makes sense to recompute this at use time instead of
> walking all of this stuff at every event.

 	Yes, it looks less dangerous.

> So device address operations increment a generation ID and
> FIB_RES_PREFSRC() checks that ID against one stored in the nexthop.

 	Yes, may be it is better this generation ID to be global
value for netns, because the global addresses should cause
refresh for all nexthops on all devices. The ID should be
matched with corresponding value in NH. Another option is
to use per-device gen_id instead of netns gen_id but in this
case scope-global address event should increment gen_id for all
devices while the device_UP event will increment only
gen_id for the concerned DEV.

 	I.e. there are 2 variants:

1. global netns gen_id:
 	- add/del IP, device UP => netns->gen_id ++

2. dev->gen_id:
 	- add/del IP with scope < LINK => increment
 	dev->gen_id for all devices
 	- add/del IP with scope >= LINK => increment
 	dev->gen_id only for concerned device
 	- device UP: increment dev->gen_id only for
 	concerned device

Regards

--
Julian Anastasov <ja@ssi.bg>
