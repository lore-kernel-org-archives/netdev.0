From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next] bonding: don't call alb_set_slave_mac_addr()
 while atomic
Date: Mon, 17 Jun 2013 16:12:27 +0200
Message-ID: <20130617141227.GA30062@redhat.com>
References: <1371403244-2891-1-git-send-email-vfalico@redhat.com>
 <51BEE55E.9070803@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21147 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755911Ab3FQOSI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jun 2013 10:18:08 -0400
Content-Disposition: inline
In-Reply-To: <51BEE55E.9070803@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 17, 2013 at 12:30:54PM +0200, Nikolay Aleksandrov wrote:
>On 06/16/2013 07:20 PM, Veaceslav Falico wrote:
>> alb_set_slave_mac_addr() sets the mac address in alb mode via
>> dev_set_mac_address(), which might sleep. It's called from
>> alb_handle_addr_collision_on_attach() in atomic context (under
>> read_lock(bond->lock)), thus triggering a bug.
>>
>> Fix this by moving the lock inside alb_handle_addr_collision_on_attach().
>>
>> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>
>Hello,
>I have an idea about this function, since the
>alb_handle_addr_collision_on_attach function needs to check if the slave's mac
>address is unique and if it's not it tries to find an address from the other
>slaves' permanent addresses. Instead of doing this, my proposition is:
>1. this function and the only caller are running always inside RTNL, so I don't
>think we need the read_lock at all, there can't be slave manipulation or MAC
>address change during that period (if I'm not missing something).

Yep, I've thought about dropping the lock completely initially, cause
indeed mac address can't change out of rtnl_lock (and anyway it would be
wrong now to drop it in between if it would be otherwise).

My concern was with bond_for_each_slave(), cause it relies on not fiddling
with slaves, and I've decided to play safe - it's really not a hot path
here.

However, I think you're right on that. We manipulate slave list basically
only in bond_attach_slave() and bond_detach_slave(), to which we get either
by sysfs (rtnl_lock() is already held, if we don't have more bugs there,
hopefully...) and ioctl/compat_ioctl, which both get to dev_ioctl() and get
the lock there. Oh, and on init/uninit, but it's also protected by
rtnl_lock() there.

If that's true I think we can benefit from it (read: drop bond->lock) in
quite a few locations, though I didn't dig it. Please correct me if I've
missed something.

I'll try now to remove the bond->lock and test, will update with V2 if it
works out, or will write my findings here.

>2. the collision handling function can instead always succeed:
>  - first walk over the slave list and check if there's a collision and
>    also if any of the slaves has bond's MAC address, if there's no collision
>    just return
>  - if there's a collision:
>   - if bond's address is not in use -> set it to the slave and return
>   - else set a random MAC to the slave (eth_hw_addr_random) and return
> (and if we simplify it even further in the collision case we can just set a
>random MAC always)
>This way the code simplifies very nice and we always get a unique slave's MAC.
>I've tried this and IMO it looks good.
>What do you think ?

I'm really not sure about the "always succeed" part - if bond's using our
address and there's no free address left - it must be some kind of bug and
must be fixed, instead of just adding a random mac and going on.

>
>Cheers,
> Nik
