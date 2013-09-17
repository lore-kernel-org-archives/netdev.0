From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH -net] netpoll: fix NULL pointer dereference in netpoll_cleanup
Date: Tue, 17 Sep 2013 16:37:05 +0200
Message-ID: <52386911.2010504@redhat.com>
References: <1379427155-8561-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22093 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753076Ab3IQOkm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 10:40:42 -0400
In-Reply-To: <1379427155-8561-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/17/2013 04:12 PM, Nikolay Aleksandrov wrote:
> I've been hitting a NULL ptr deref while using netconsole because the
> np->dev check and the pointer manipulation in netpoll_cleanup are done
> without rtnl and the following sequence happens when having a netconsole
> over a vlan and we remove the vlan while disabling the netconsole:
> 	CPU 1					CPU2
> 					removes vlan and calls the notifier
> enters store_enabled(), calls
> netdev_cleanup which checks np->dev
> and then waits for rtnl
> 					executes the netconsole netdev
> 					release notifier making np->dev
> 					== NULL and releases rtnl
> continues to dereference a member of
> np->dev which at this point is == NULL
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---

Just FYI there seems to be a deadlock in netconsole as well:
rtnl -> nt->mutex in the notifier coupled with
nt->mutex -> rtnl in store_enabled()

I can re-post a patchset that fixes these together, because after this is
applied the NULL pointer dereference is not hit, but the deadlock is easily hit.
The deadlock was introduced in commit 7a163bfb7ce50895bbe67300ea610d31b9c09230
("netconsole: avoid a crash with multiple sysfs writers").

Nik
