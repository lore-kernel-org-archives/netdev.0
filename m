From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: vxlan: do not use vxlan_net before
 checking event type
Date: Fri, 17 Jan 2014 18:50:30 -0800 (PST)
Message-ID: <20140117.185030.1516625575623978541.davem@davemloft.net>
References: <1389959706-30976-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	jesse.brandeburg@intel.com, xiyou.wangcong@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165AbaARCub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 21:50:31 -0500
In-Reply-To: <1389959706-30976-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 17 Jan 2014 12:55:06 +0100

> Jesse Brandeburg reported that commit acaf4e70997f caused a panic
> when adding a network namespace while vxlan module was present in
> the system:
 ...
> Apparently loopback device is being registered first and thus we
> receive an event notification when vxlan_net is not ready. Hence,
> when we call net_generic() and request vxlan_net_id, we seem to
> access garbage at that point in time. In setup_net() where we set
> up a newly allocated network namespace, we traverse the list of
> pernet ops ...
> 
> list_for_each_entry(ops, &pernet_list, list) {
> 	error = ops_init(ops, net);
> 	if (error < 0)
> 		goto out_undo;
> }
> 
> ... and loopback_net_init() is invoked first here, so in the middle
> of setup_net() we get this notification in vxlan. As currently we
> only care about devices that unregister, move access through
> net_generic() there. Fix is based on Cong Wang's proposal, but
> only changes what is needed here. It sucks a bit as we only work
> around the actual cure: right now it seems the only way to check if
> a netns actually finished traversing all init ops would be to check
> if it's part of net_namespace_list. But that I find quite expensive
> each time we go through a notifier callback. Anyway, did a couple
> of tests and it seems good for now.
> 
> Fixes: acaf4e70997f ("net: vxlan: when lower dev unregisters remove vxlan dev as well")
> Reported-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks.
