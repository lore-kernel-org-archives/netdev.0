From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next 1/2] macvtap: Let TUNSETOFFLOAD actually controll offload features.
Date: Thu, 20 Jun 2013 00:38:47 +0200
Message-ID: <201306200038.47859.arnd@arndb.de>
References: <1371653272-11703-1-git-send-email-vyasevic@redhat.com> <51C1DA58.4010204@redhat.com> <51C1FF7B.9050502@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, mst@redhat.com, jasowang@redhat.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:61415 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935300Ab3FSWi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 18:38:57 -0400
In-Reply-To: <51C1FF7B.9050502@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 19 June 2013, Vlad Yasevich wrote:
> Arnd
> 
> MST suggested I add you.  Do you remember the reason
> why macvtap uses rcu_read_lock_bh() instead of plain
> rcu_read_lock()?  Additionally it seems to use
> synchronize_rcu(), not the _bh() version.

I don't actually remember, but looking back at the git history, it
seemst to come from one of the earliest versions of the code, and
the locking was changed soon after that. Originally I needed
rcu_read_lock for any function called from the network stack,
which is equivalent to rcu_read_lock_bh as it is run from the
network softirq. Using rcu_read_lock_bh for functions called from
the chardev file operations might not be necessary but was
consistent at the time.

Looking at the state now, I think calling synchronize_rcu()
instead of synchronize_rcu_bh() is not a bug but implies
a longer grace period than necessary (I'm not sure about that)
and extra overhead from disabling softirqs in rcu_read_lock.
It's probably a good idea to revisit this and do it right.

	Arnd
