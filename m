From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bonding: fix bond_get_stats()
Date: Fri, 18 Mar 2016 12:26:44 +0100
Message-ID: <56EBE5F4.6020003@cumulusnetworks.com>
References: <1458260616.31963.14.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36607 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbcCRL0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 07:26:47 -0400
Received: by mail-wm0-f53.google.com with SMTP id l124so27081394wmf.1
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 04:26:47 -0700 (PDT)
In-Reply-To: <1458260616.31963.14.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/18/2016 01:23 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> bond_get_stats() can be called from rtnetlink (with RTNL held)
> or from /proc/net/dev seq handler (with RCU held)
> 
> The logic added in commit 5f0c5f73e5ef ("bonding: make global bonding
> stats more reliable") kind of assumed only one cpu could run there.
> 
> If multiple threads are reading /proc/net/dev, stats can be really
> messed up after a while.
> 
> A second problem is that some fields are 32bit, so we need to properly
> handle the wrap around problem.
> 
> Given that RTNL is not always held, we need to use
> bond_for_each_slave_rcu().
> 
> Fixes: 5f0c5f73e5ef ("bonding: make global bonding stats more reliable")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
> Cc: Jay Vosburgh <j.vosburgh@gmail.com>
> Cc: Veaceslav Falico <vfalico@gmail.com>
> ---
>  drivers/net/bonding/bond_main.c |   66 +++++++++++++++---------------
>  include/net/bonding.h           |    1 
>  2 files changed, 36 insertions(+), 31 deletions(-)
> 

Good catches! And the dev_get_stats() in bond_enslave is fine because the slave
is not yet linked thus can't collide with reading/updating the stats via procfs.

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
