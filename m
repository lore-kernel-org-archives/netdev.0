From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [net-next,1/3] bonding: fix vlan 0 addition and removal
Date: Tue, 6 Aug 2013 10:59:41 +0200
Message-ID: <20130806085941.GM22756@redhat.com>
References: <1375709304-16778-2-git-send-email-nikolay@redhat.com>
 <20130805215126.GB3859@redhat.com>
 <5200B63A.5070900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, kaber@trash.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34045 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754922Ab3HFJAo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 05:00:44 -0400
Content-Disposition: inline
In-Reply-To: <5200B63A.5070900@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 06, 2013 at 10:39:22AM +0200, Nikolay Aleksandrov wrote:
>> From 1c89abefebe90568ed52d2df59fcfdd650bc4696 Mon Sep 17 00:00:00 2001
>> From: Veaceslav Falico <vfalico@redhat.com>
>> Date: Mon, 5 Aug 2013 23:29:12 +0200
>> Subject: [PATCH] bonding: add vlan_uses_dev_rcu() and make bond_vlan_used()
>> use it
>>
>> Currently, bond_vlan_used() looks for any vlan, including the pseudo-vlan
>> id 0, and always returns true if 8021q is loaded. This creates several bad
>> situations - some warnings in __bond_release_one() because it thinks that
>> we still have vlans while removing, sending LB packets with vlan id 0 and,
>> possibly, other caused by vlan id 0.
>>
>> Fix it by adding a new call, vlan_uses_dev_rcu(), which is the same as
>> vlan_uses_dev(), but uses rcu_dereference() instead of rtnl, and thus we
>> can use it in bond_vlan_used() wrapped in rcu_read_lock().
>>
>> Also, use the pure vlan_uses_dev() in __bond_release_one() cause the rtnl
>> lock is held there.
>>
>Just 1 more note, you can't trust nr_vlan_devs under RCU.

Yes, you're right, however we actually don't care anyway if we race with
(un)register_vlan_dev() - we'll end up either in using the (un)registered
vlan or not, and in both cases it's ok. So I don't see a real problem here,
tbh, though I'll look into this also.
