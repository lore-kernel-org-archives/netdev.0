From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 2/4] C/R: Basic support for network namespaces and devices (v3)
Date: Wed, 10 Feb 2010 11:30:54 -0800
Message-ID: <87hbpohor5.fsf@caffeine.danplanet.com>
References: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
	<1265750713-15749-3-git-send-email-danms@us.ibm.com>
	<87ljf1gemh.fsf@caffeine.danplanet.com>
	<20100210192019.GA18879@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:52794 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751007Ab0BJTa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 14:30:56 -0500
In-Reply-To: <20100210192019.GA18879@us.ibm.com> (Serge E. Hallyn's message of "Wed\, 10 Feb 2010 13\:20\:19 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SH> rw_lockt is effectively a spinlock, so I don't think you can sleep
SH> here.

Yep, thanks.

>> +	for_each_netdev(net, dev) {
>> +		if (!dev->netdev_ops->ndo_checkpoint)
>> +			continue;

SH> Won't the checkpoint_obj() call checkpoint_netdev(), which will return
SH> -EINVAL if ndo_checkpoint is not defined? 

Yes, but this isn't the only place that checkpoint_netdev() could be
called (dev->peer in the veth example) so I figured that it would be
best to test it there too before I blindly call a NULL function
pointer.  It should never happen, but seemed prudent.

SH> But here you skip the checkpoint_obj() call (which seems wrong to
SH> me).  Which do you want to have happen?

What the code is doing is "skipping any interfaces in a netns that
don't have a checkpoint operation" but would fail if you called
checkpoint_obj() on a veth peer that happened to be missing that
operation for some reason.

I suppose you could argue that we should fail in the netns case
instead, which will make this a bit messier for things we get for
"free" in a new netns, like sit0.  If preferable, I can just add an
ndo_checkpoint() to sit0 as well and simply checkpoint the presence of
it until later when we decide if we care about it.

SH> By hard-coding veth stuff into generic-sounding functions in
SH> net/checkpoint_dev.c you seem to be assuming that only veth will
SH> ever be supported for checkpoint/restart?  what about macvlan?
SH> (Not to mention that eventually we intend to support moving
SH> physical nics into containers)

No, that's not what I'm assuming.  The only interface type I need to
control with RTNL is veth right now.  So, if you'd prefer a
single-case of:

  if (type == veth)
    do_veth_message();
  else
    fail();

to record the goal of having more types later I'll happily add that
unreachable code to the patch :)

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
