From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v2 net] bonding: Fix stacked device detection in arp
 monitoring
Date: Wed, 7 May 2014 20:11:00 +0200
Message-ID: <20140507181100.GU6295@redhat.com>
References: <1399470461-22213-1-git-send-email-vyasevic@redhat.com>
 <29645.1399481039@localhost.localdomain>
 <536A6879.8070303@redhat.com>
 <20140507174910.GT6295@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>,
	Ding Tianhong <dingtianhong@huawei.com>,
	Patric McHardy <kaber@trash.net>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51801 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752438AbaEGSLY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2014 14:11:24 -0400
Content-Disposition: inline
In-Reply-To: <20140507174910.GT6295@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 07, 2014 at 07:49:10PM +0200, Veaceslav Falico wrote:
>On Wed, May 07, 2014 at 01:08:09PM -0400, Vlad Yasevich wrote:
>...snip...
>>Yes.  I verified that it works.  The reason is that we are traversing
>>the all_adj_list.upper list which contains all of the upper devices at
>>each level.  So, at vlan100 level, we will see vlan200 and all will be
>>well.
>
>Hrm, two scenarios, with the following config:
>
>bond0 -> whatever1 -> vlan1 -> whatever2 -> vlan2 -> whatever3_IP
>
>end == whatever3_IP
>
...snip...
>
>So, the end patch (not compiled, not tested...) would look something like
>(only the bond_check_path() is changed and copied here, everything else
>remains the same):
>
>+       bool upper_found = false;
>+
>+       netdev_for_each_all_upper_dev_rcu(start, upper, iter) {
>+               if (upper == end)
>+                       upper_found = true;
>+
>+               if (idx < 2 && is_vlan_dev(upper) &&
>+                   bond_check_path(upper, end, tag, idx+1)) {
>+                       tag[idx].vlan_proto = vlan_dev_vlan_proto(upper);
>+                       tag[idx].vlan_id = vlan_dev_vlan_id(upper);
>+                       return true;

Actually, screw that, we might find here the vlan2 first and end up with
only 1 vlan (vlan2, skipping vlan1).

The way to fix this might be to get the most "lengthy" path of vlans, as
in:

+ * Return the maximum length of stacked vlans + device found, 0 if the end
+ * device is not found.
+ */
+static int bond_check_path(struct net_device *start, struct net_device *end,
+                          struct bond_vlan_tag *tag, int idx)
+{
+       struct net_device *upper;
+       struct list_head  *iter;
+       int length, max_length = 0;
+
+       netdev_for_each_all_upper_dev_rcu(start, upper, iter) {
+               if (upper == end && !max_length)
+                       max_length = 1;
+
+               if (idx < 2 && is_vlan_dev(upper)) {
+                       length = bond_check_path(upper, end, tag, idx + 1);
+
+                       if (max_length < length + 1) {
+                               tag[idx].vlan_proto = vlan_dev_vlan_proto(upper);
+                               tag[idx].vlan_id = vlan_dev_vlan_id(upper);
+                               max_length = length + 1;
+                       }
+               }
+       }
+       return max_length;
+}

Hope that helps.

>+               }
>+       }
>+       return upper_found;
...snip...
