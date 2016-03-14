From: yumkam@gmail.com (Yuriy M. Kaminskiy)
Subject: Re: userns, netns, and quick physical memory consumption by unprivileged user
Date: Mon, 14 Mar 2016 18:12:53 +0300
Message-ID: <m3vb4pgkju.fsf@gmail.com>
References: <m3d1rclioc.fsf@gmail.com> <m3r3fhhx4c.fsf@gmail.com>
	<20160314091417.GA11400@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:37913 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932185AbcCNPNK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2016 11:13:10 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1afUB5-0003C8-UU
	for netdev@vger.kernel.org; Mon, 14 Mar 2016 16:13:03 +0100
Received: from ppp37-190-56-84.pppoe.spdop.ru ([37.190.56.84])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 16:13:03 +0100
Received: from yumkam by ppp37-190-56-84.pppoe.spdop.ru with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 16:13:03 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/14/16 12:14 , Michal Hocko wrote:
> On Fri 11-03-16 18:06:59, Yuriy M. Kaminskiy wrote:
> [...]
>> And also tried with memcg:
>>   t=/sys/fs/cgroup/memory/test1;mkdir $t;echo 0 >$t/tasks;
>>   echo 48M >$t/memory.limit_in_bytes; su testuser [...]
>> and it has not helped at all (rather opposite, it ended up with killed
>> init and kernel panic; well, later is pure (un)luck; but point is, memcg
>> apparently *CANNOT* curb net/ns allocations).
>
> It seems you were using memcg v1 here. This didn't have the kernel
> memory accounting enabled by default. With the v2 you get both user and

Hrr. Indeed. And used (distro) kernel compiled without MEMCG_KMEM, so
this test was useless. (However, as distro kernel lacks MEMCG_KMEM, it
means most users won't be able to use it as well[*], so unpriv userns are
unsafe to use for all of them and should be disabled).

That said, not sure if it would have helped in kernels <= 4.4 (would
those allocation be called in context that allows them to be
accounted by [correct] memcg?), but it looks like with upcoming change to
whitelisting (explicit GPF_ACCOUNT), it won't (as almost nothing in
net/* uses it).

> kernel (well some subset of it) accounting enabled. Whether we account
> also netns related data structures sufficiently is a question. I haven't

Except for conntrack tables, it is not exactly tied to netnes, it's
regular CAP_NET_ADMIN things (routing, addresses, links, iptables, etc
that can be added via netlink messages). Just userns+netns gives right
to tweak with them to regular user.

> checked.  But it would be worth trying and fix.
