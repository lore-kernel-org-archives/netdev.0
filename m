From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH][RFC] cxgb4: Not need to hold the adap_rcu_lock lock when
 read adap_rcu_list
Date: Tue, 24 Jun 2014 08:20:44 +0800
Message-ID: <CAJFZqHzsEByhY02=4_WoGsGMTY1FPGzavNhnot6Bm-qiyOi3aA@mail.gmail.com>
References: <1403256756-6557-1-git-send-email-rongqing.li@windriver.com>
	<20140623.145035.915335524137481573.davem@davemloft.net>
	<53A8ABAD.9090904@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Rongqing Li <rongqing.li@windriver.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>, hariprasad@chelsio.com,
	Ben Greear <greearb@candelatech.com>
To: Casey Leedom <leedom@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f48.google.com ([209.85.216.48]:51764 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754274AbaFXAUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 20:20:45 -0400
Received: by mail-qa0-f48.google.com with SMTP id x12so6292024qac.21
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2014 17:20:44 -0700 (PDT)
In-Reply-To: <53A8ABAD.9090904@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 24, 2014 at 6:35 AM, Casey Leedom <leedom@chelsio.com> wrote:
>> I think this change is fine, and correct, but I would like to see some
>> reviews from the cxgb4 maintainers.
>
>
>   Thanks David.  Hari is gone on PTO so I think I'm the next logical person
> ... :-)
>
>   I've gone back and reviewed the original patch, Eric Dumazet6's reply and
> revised patch and compared that against this proposed patch.  Li RongQing is
> submitting the same patch that Eric suggested with the addition of a call to
> synchronize_rcu() the in driver remove() function.  I'm not super familiar
> with the RCU system but that addition certainly seems innocuous enough.
> Other than that, everything looks fine.

I think the synchronize_rcu is needed, as explanation of
Documentation/RCU/whatisRCU.txt the RCU update sequence is:

So the typical RCU update sequence goes something like the following:

a.      Remove pointers to a data structure, so that subsequent
        readers cannot gain a reference to it.

b.      Wait for all previous readers to complete their RCU read-side
        critical sections.

c.      At this point, there cannot be any readers who hold references
        to the data structure, so it now may safely be reclaimed
        (e.g., kfree()d).


To achieve the step b, synchronize_rcu() or call_rcu() or kfree_rcu are needed,
since this removing happens little, I add a synchronize_rcu(), to
avoid to add the
rcu_head to struct adapter or to change codes largely.

-Roy
