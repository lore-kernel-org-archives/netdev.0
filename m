From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 01/20] net: NETDEV_UNREGISTER_PERNET -> NETDEV_UNREGISTER_BATCH
Date: Mon, 30 Nov 2009 15:42:13 -0800
Message-ID: <m1d42zoa0a.fsf@fess.ebiederm.org>
References: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
	<20091130.144917.233710214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, dlezcano@fr.ibm.com,
	adobriyan@gmail.com, kaber@trash.net, opurdila@ixiacom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58615 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbZK3XmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 18:42:18 -0500
In-Reply-To: <20091130.144917.233710214.davem@davemloft.net> (David Miller's message of "Mon\, 30 Nov 2009 14\:49\:17 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: "Eric W. Biederman" <ebiederm@xmission.com>
> Date: Sun, 29 Nov 2009 17:45:58 -0800
>
>> Additionally it appears that we moved the route cache flush after
>> the final synchronize_net, which seems wrong and there was no
>> explanation.  So I have restored the original location of the final
>> synchronize_net.
>
> I think the idea was that it's important for all pending stale
> RCU references to the device to be gone before we send out the
> notifier.  And that's why the synchronize_net() comes first.
>
> This needs more thought.

The only case the affects (today) is the invalidation of the route/flow cache.

The routing table until the addition of NETDEV_UNREGISTER_PERNET happened
in the notifier NETDEV_UNREGISTER, which comes before the final synchronize_net.

The routing cache has rcu references to the network device.

So it appears to me that with the current pernet batched routing code cleanup we
can end up calling kfree before all of the call_rcu functions triggered by
rt_do_flush will be run.

    netdev_run_todo()
       kobject_put()
         netdev_release()
           kfree()

NETDEV_UNREGISTER_PERCPU
    rt_cache_flush(xxx, 0)
       rt_do_flush()
         rt_free
           call_rcu

So it appears to me that moving the final syncrhonize_net() back where it was before
the NETDEV_UNREGISTER_PERNET changes (as I did) is necessary for correctness.

Eric
