From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 01/20] net: NETDEV_UNREGISTER_PERNET -> NETDEV_UNREGISTER_BATCH
Date: Mon, 30 Nov 2009 11:00:41 -0800
Message-ID: <m1hbsb7s86.fsf@fess.ebiederm.org>
References: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
	<200911301408.33297.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>, Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:51744 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753211AbZK3TAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 14:00:46 -0500
In-Reply-To: <200911301408.33297.opurdila@ixiacom.com> (Octavian Purdila's message of "Mon\, 30 Nov 2009 14\:08\:33 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila <opurdila@ixiacom.com> writes:

> On Monday 30 November 2009 03:45:58 you wrote:
>
>> +       /* Process any work delayed until the end of the batch */
>> +       dev = list_entry(head->next, struct net_device, unreg_list);
>> +       call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
>>  
>> -       list_for_each_entry_safe(dev, aux, head, unreg_list) {
>> -               int new_net = 1;
>> -               list_for_each_entry(fdev, &pernet_list, unreg_list) {
>> -                       if (net_eq(dev_net(dev), dev_net(fdev))) {
>> -                               new_net = 0;
>> -                               dev_put(dev);
>> -                               break;
>> -                       }
>> -               }
>> -               if (new_net)
>> -                       list_move(&dev->unreg_list, &pernet_list);
>> -       }
>> 
>
> This implies that the devices we want to batch unregister needs to be part of 
> the same namespace. It might be worth mentioning that in the 
> unregister_netdevice_many() function comments.

No it does not.  For the route cache flush we have already done the delayed
invalidate per namespace.  So we only need to walk the route cache once and
simply remove the entries that have been invalidated.

For other cases if we really need it, I pass in the first entry of the
unregistration list so we can recover the list if needed.

The implication is that namespaces are not what is important when batching
so it doesn't make sense to turn our list into a pretzel providing information
that is not needed.

> And, fortunately, it seems that all of the current batch unregister users 
> comply with this requirement.

The case I am working on for this patchset is batching of the destruction of
devices across namespace cleanup.  This change reduces my total number of
walks of the route cache from many down to one.

Eric

