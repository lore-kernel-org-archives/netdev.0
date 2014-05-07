From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v2 net] bonding: Fix stacked device detection in arp
 monitoring
Date: Wed, 7 May 2014 19:49:10 +0200
Message-ID: <20140507174910.GT6295@redhat.com>
References: <1399470461-22213-1-git-send-email-vyasevic@redhat.com>
 <29645.1399481039@localhost.localdomain>
 <536A6879.8070303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>,
	Ding Tianhong <dingtianhong@huawei.com>,
	Patric McHardy <kaber@trash.net>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2398 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751884AbaEGRtl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2014 13:49:41 -0400
Content-Disposition: inline
In-Reply-To: <536A6879.8070303@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 07, 2014 at 01:08:09PM -0400, Vlad Yasevich wrote:
...snip...
>Yes.  I verified that it works.  The reason is that we are traversing
>the all_adj_list.upper list which contains all of the upper devices at
>each level.  So, at vlan100 level, we will see vlan200 and all will be
>well.

Hrm, two scenarios, with the following config:

bond0 -> whatever1 -> vlan1 -> whatever2 -> vlan2 -> whatever3_IP

end == whatever3_IP

1) IIRC there are no guarantees on order of all_upper list, so, if
whatever3_IP dev is the first in the list - bond_check_patch() will return
true right away.

I might be wrong, though, it's 8PM and my brain farts when trying to look
at that code.

That's fixable (from first sight) by introducing a variable upper_found:

+       netdev_for_each_all_upper_dev_rcu(start, upper, iter) {
...
+               if (upper == end)
+                       upper_found = true;
...
+       }
+       return upper_found;

This way it will first try to go through all nested vlans and, if none
found, will return true. Basically, "return upper_found (=true)" has the
meaning that upper was found and there are no vlans in between.

The "wrong" order might be achieved by creating a bridge for whatever2,
creating and linking vlan2 and whatever3_IP, and only *after* that adding
vlan1 as a port to bridge whatever2.

2) (with the fix from #1 applied)

bond_check_path start==bond0 idx=0
finds vlan1, tag[0] set, recursion start==vlan1 idx=1
bond_check_path start==vlan1 idx=1
finds vlan2, tag[1] set, recursion start==vlan2 idx=2
returns right away with false as idx >= 2.

That's wrong as there might be vlan3 on top of whatever2, and tag[1] might
be set to it, whilst vlan3 has nothing to do with whatever3_IP.

The fix here would be to halt on idx > 2, or, rather, to NOT use
recursion/vlan checks if idx == 2, thus leaving us with only upper_found
logic.

So, the end patch (not compiled, not tested...) would look something like
(only the bond_check_path() is changed and copied here, everything else
remains the same):

+       bool upper_found = false;
+
+       netdev_for_each_all_upper_dev_rcu(start, upper, iter) {
+               if (upper == end)
+                       upper_found = true;
+
+               if (idx < 2 && is_vlan_dev(upper) &&
+                   bond_check_path(upper, end, tag, idx+1)) {
+                       tag[idx].vlan_proto = vlan_dev_vlan_proto(upper);
+                       tag[idx].vlan_id = vlan_dev_vlan_id(upper);
+                       return true;
+               }
+       }
+       return upper_found;

This way we'll collect the maximum ammount of stacked vlans on our trip
from bond0 to whatever3_IP (the limit is 2, however it might be removed
afterwards if needed, will still work with long enough tag[]).

Hope that makes at least some sense.

>
>-vlad
...snip...
