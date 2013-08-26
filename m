From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 1/8] net: move netdev_upper to netdevice.h
Date: Mon, 26 Aug 2013 18:55:35 +0200
Message-ID: <20130826165535.GG1992@redhat.com>
References: <1377534533-6944-1-git-send-email-vfalico@redhat.com>
 <1377534533-6944-2-git-send-email-vfalico@redhat.com>
 <20130826164115.GA1413@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17342 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752065Ab3HZQ4v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 12:56:51 -0400
Content-Disposition: inline
In-Reply-To: <20130826164115.GA1413@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 26, 2013 at 06:41:15PM +0200, Jiri Pirko wrote:
>Mon, Aug 26, 2013 at 06:28:46PM CEST, vfalico@redhat.com wrote:
...snip...
>>+struct netdev_upper {
>>+	struct net_device *dev;
>>+	bool master;
>>+	struct list_head list;
>>+	struct rcu_head rcu;
>>+	struct list_head search_list;
>>+};
>>+
>
>
>I like your patchset.  However I'm not entirely comfortable with exposing
>this struct. I would love to have it "under control" in net/core/dev.c

I've taken this approach first, however the change to non-bonding stuff
became a bit too big to justify the (only) bonding use.

bonding only reads from it, and there are already primitives in dev.c to
modify it, so if they will be used for it it's still the dev.c who controls
it (if someone writes directly to it - it's a bug, and can be NAKed).

>
>I'm thinking of some getter/iterator for this use. It can work by
>type as well so you would be able to remove the checks from bonding
>code.

There are 3 checks in bonding - looking for vlan devs, for a specific dev
and for a specific ip address. list_for_each_entry() fits here perfectly
for each case, otherwise the best way to do this would be to

while ((next_dev = netdev_upper_get_next_dev(dev, next_dev)))

or something like that, which adds quite a bit of overhead (looking for the
previous dev and then returning the next one on each iteration), and looks
ugly.

So, given that it's a plain list actually, and any modification to this
list can (and should be) done via functions from dev.c, while reading can
be done with standard list_for_each_entry(_rcu)(), I think it's better to
expose it this way.
