From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v2 02/13] net: add lower_dev_list to net_device
 and make a full mesh
Date: Wed, 28 Aug 2013 16:15:17 +0200
Message-ID: <20130828141517.GI1992@redhat.com>
References: <1377691352-4146-1-git-send-email-vfalico@redhat.com>
 <1377691352-4146-3-git-send-email-vfalico@redhat.com>
 <20130828135926.GA1403@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30077 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752735Ab3H1OQe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 10:16:34 -0400
Content-Disposition: inline
In-Reply-To: <20130828135926.GA1403@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 28, 2013 at 03:59:26PM +0200, Jiri Pirko wrote:
>Wed, Aug 28, 2013 at 02:02:21PM CEST, vfalico@redhat.com wrote:
>>This patch adds lower_dev_list list_head to net_device, which is the same
>>as upper_dev_list, only for lower devices, and begins to use it in the same
>>way as the upper list.
>>
>>It also changes the way the whole adjacent device lists work - now they
>>contain *all* of upper/lower devices, not only the first level. The first
>>level devices are distinguished by the bool neighbour field in
>>netdev_adjacent, also added by this patch.
>>
>>There are cases when a device can be added several times to the adjacent
>>list, the simplest would be:
>>
>>     /---- eth0.10 ---\
>>eth0-		       --- bond0
>>     \---- eth0.20 ---/
>>
>>where both bond0 and eth0 'see' each other in the adjacent lists two times.
>>To avoid duplication of netdev_adjacent structures ref_nr is being kept as
>>the number of times the device was added to the list.
>>
>>The 'full view' is achieved by adding, on link creation, all of the
>>upper_dev's upper_dev_list devices as upper devices to all of the
>>lower_dev's lower_dev_list devices (and to the lower_dev itself), and vice
>>versa. On unlink they are removed using the same logic.
>>
>>I've tested it with thousands vlans/bonds/bridges, everything works ok and
>>no observable lags even on a huge number of interfaces.
>>
>>Memory footprint for 128 devices interconnected with each other via both
>>upper and lower (which is impossible, but for the comparison) lists would be:
>>
>>128*128*2*sizeof(netdev_adjacent) = 1.5MB
>>
>>but in the real world we usualy have at most several devices with slaves
>>and a lot of vlans, so the footprint will be much lower.
>>
>>v2: new patch
>
>
>Hmm. I'm not sure if recursive searches in read paths wouldn't be better
>afterall. This looks a bit too complex

On the other hand it gives us linear speed and really easy access to upper
(and, if needed, lower) devices. And, till the end, it looks complex, but
at the bottom it's only messing with some lists :). I personally like this
approach a lot more than recursive, cause once done - it will be a pleasure
to work with.

...snip...
>> struct netdev_adjacent {
>> 	struct net_device *dev;
>>+	/* master device, we can only have one */
>> 	bool master;
>>+	/* is it first-level lower/upper or not */
>>+	bool neighbour;
>>+	/* how many times we've tried added this link. if it becomes 0 -
>>+	 * we can remove the link and free the structure. For neighbour
>>+	 * links it should always be 1.
>
>	From this comment, I'm do not understand what is going on.
>	Also for bool use "false" and "true" instead of "0" and "1".
>
>>+	 */
>>+	u16 ref_nr;

This comment is about the ref_nr, I'll rephrase and rearrange it in the
next version.

...snip...
>>+#define __netdev_find_upper(d, ud) __netdev_find_adj(d, ud, true)
>>+#define __netdev_find_lower(d, ld) __netdev_find_adj(d, ld, false)
>
>Please make these 2 simple functions.

Ok.

...snip...
>> 	upper = list_first_entry(&dev->upper_dev_list,
>>-				 struct netdev_upper, list);
>>+				 struct netdev_adjacent, list);
>
>I believe this should be part of previous patch. Just to be save, try to
>compile in between the patch application in series.

Jeez, I did compile it, seen this, however I've git commit --ammend-ed the
wrong commit :-/.

Sorry, will fix.

...snip...
>> 	upper = list_first_or_null_rcu(&dev->upper_dev_list,
>>-				       struct netdev_upper, list);
>>+				       struct netdev_adjacent, list);
>
>Same as previous

Yup... :(

...snip...
>>+#define __netdev_upper_dev_insert(dev, adev, m, d) \
>>+		__netdev_adjacent_dev_insert(dev, adev, d, m, true)
>>+#define __netdev_lower_dev_insert(dev, adev, d) \
>>+		__netdev_adjacent_dev_insert(dev, adev, d, false, false)
>
>Also, make these functions.

Ok.

...snip...
>>+	/* try to maintain the mesh, sorry people, if you've paniced here -
>>+	 * you've tried to remove an unexisting link, and that is bad.
>>+	 */
>
>Unnecessary comment

Ok, will remove.

...snip...
>>+#define __netdev_upper_dev_remove(d, ud) \
>>+		__netdev_adjacent_dev_remove(d, ud, true)
>>+#define __netdev_lower_dev_remove(d, ld) \
>>+		__netdev_adjacent_dev_remove(d, ld, false)
>
>Also, make these functions.

Ok.

...snip...
>>+#define __netdev_adjacent_dev_link(d, ud) \
>>+		__netdev_adjacent_dev_insert_link(d, ud, false, false)
>>+#define __netdev_adjacent_dev_link_neighbour(d, ud, m) \
>>+		__netdev_adjacent_dev_insert_link(d, ud, m, true)
>
>Also, make these functions.

Ok.

...snip...
>>+	/* Now that we interconnected these devs, make all the upper_dev's
>>+	 * upper_dev_list visible to every dev's lower_dev_list and vice
>>+	 * versa, and don't forget the devices itself. All of these
>>+	 * connections are non-neighbours.
>
>	Please use same terms. ConnectionsXlinks

Ok, will rephrase.

Thanks a lot for the review!
