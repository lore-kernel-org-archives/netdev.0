From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [net-next,1/3] bonding: fix vlan 0 addition and removal
Date: Tue, 06 Aug 2013 10:16:04 +0200
Message-ID: <5200B0C4.2020101@redhat.com>
References: <1375709304-16778-2-git-send-email-nikolay@redhat.com> <20130805215126.GB3859@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, kaber@trash.net
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52252 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753993Ab3HFIQP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 04:16:15 -0400
In-Reply-To: <20130805215126.GB3859@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/05/2013 11:51 PM, Veaceslav Falico wrote:
> On Mon, Aug 05, 2013 at 03:28:22PM +0200, nikolay@redhat.com wrote:
> ...snip...
>> This is fixed by forbidding the addition/removal of vlan 0 through the
>> bond's ndo_vlan_rx_add/kill_vid functions, and adding/removing it only when
>> vlan 0 is in fact being created (or destroyed) on top of a bond interface
>> in the bond's netdev handling function.
> 
> Isn't that a bit too intrusive/hacky? I don't think we should treat vlan id
> 0 somehow differently in terms of adding/removing, though I might be
> wrong...
> 
I didn't want to touch the vlan code, so I solved the problem entirely in
the bonding, mind you there's still a bug when loading the 8021q module
we'll bump up every slave's vlan 0 refcnt without adding the vlan, and it
won't get bumped down.
In my patch that problem still persists but only when an actual vlan 0 is
being created.

> Maybe we should just fix the bond_vlan_used() function? Something like
> this (I've done only basic testing, can do more thorough if needed), though
> it's also not a really clean fix:
> 
Yes, that would be optimal and I agree.

> From 1c89abefebe90568ed52d2df59fcfdd650bc4696 Mon Sep 17 00:00:00 2001
> From: Veaceslav Falico <vfalico@redhat.com>
> Date: Mon, 5 Aug 2013 23:29:12 +0200
> Subject: [PATCH] bonding: add vlan_uses_dev_rcu() and make bond_vlan_used()
> use it
> 
> Currently, bond_vlan_used() looks for any vlan, including the pseudo-vlan
> id 0, and always returns true if 8021q is loaded. This creates several bad
> situations - some warnings in __bond_release_one() because it thinks that
> we still have vlans while removing, sending LB packets with vlan id 0 and,
> possibly, other caused by vlan id 0.
> 
> Fix it by adding a new call, vlan_uses_dev_rcu(), which is the same as
> vlan_uses_dev(), but uses rcu_dereference() instead of rtnl, and thus we
> can use it in bond_vlan_used() wrapped in rcu_read_lock().
> 
> Also, use the pure vlan_uses_dev() in __bond_release_one() cause the rtnl
> lock is held there.
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: Patrick McHardy <kaber@trash.net>
> CC: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
I'm okay with this fix, if Dave is also okay with this version then you can
submit it as a patch, I'll re-base my third one later and resubmit.
