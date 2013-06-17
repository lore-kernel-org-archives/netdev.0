From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next] bonding: don't call alb_set_slave_mac_addr()
 while atomic
Date: Mon, 17 Jun 2013 12:30:54 +0200
Message-ID: <51BEE55E.9070803@redhat.com>
References: <1371403244-2891-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36973 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932412Ab3FQKdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jun 2013 06:33:47 -0400
In-Reply-To: <1371403244-2891-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/16/2013 07:20 PM, Veaceslav Falico wrote:
> alb_set_slave_mac_addr() sets the mac address in alb mode via
> dev_set_mac_address(), which might sleep. It's called from
> alb_handle_addr_collision_on_attach() in atomic context (under
> read_lock(bond->lock)), thus triggering a bug.
> 
> Fix this by moving the lock inside alb_handle_addr_collision_on_attach().
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Hello,
I have an idea about this function, since the
alb_handle_addr_collision_on_attach function needs to check if the slave's mac
address is unique and if it's not it tries to find an address from the other
slaves' permanent addresses. Instead of doing this, my proposition is:
1. this function and the only caller are running always inside RTNL, so I don't
think we need the read_lock at all, there can't be slave manipulation or MAC
address change during that period (if I'm not missing something).
2. the collision handling function can instead always succeed:
  - first walk over the slave list and check if there's a collision and
    also if any of the slaves has bond's MAC address, if there's no collision
    just return
  - if there's a collision:
   - if bond's address is not in use -> set it to the slave and return
   - else set a random MAC to the slave (eth_hw_addr_random) and return
 (and if we simplify it even further in the collision case we can just set a
random MAC always)
This way the code simplifies very nice and we always get a unique slave's MAC.
I've tried this and IMO it looks good.
What do you think ?

Cheers,
 Nik
