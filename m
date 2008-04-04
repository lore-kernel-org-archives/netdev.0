From: Thomas Graf <tgraf@suug.ch>
Subject: Re: 2.6.25-rc8-mm1 -- INFO: possible circular locking dependency detected (while using iw to debug a wireless issue)
Date: Fri, 4 Apr 2008 21:53:23 +0200
Message-ID: <20080404195323.GF20815@postel.suug.ch>
References: <a44ae5cd0804030741jc9c7aebx21a7635e827b190f@mail.gmail.com> <1207323936.19189.58.camel@johannes.berg> <20080404104302.7445e41f.akpm@linux-foundation.org> <20080404121133.7b0983d8@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Miles Lane <miles.lane@gmail.com>, netdev@vger.kernel.org,
	ALSA development <alsa-devel@alsa-project.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:51060 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756713AbYDDTxF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 15:53:05 -0400
Content-Disposition: inline
In-Reply-To: <20080404121133.7b0983d8@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Stephen Hemminger <shemminger@vyatta.com> 2008-04-04 12:11
> The changes in git-net don't look locking related.  I suspect either:
> wireless is calling netlink without holding rtnl_lock;
> or more likely conditional locking ctrl_dumpfamily is confusing lockdep.
> 
> ctrl_dumpfamily only acquires genl_lock if one of the incoming parameters (chains_to_skip)
> is non-zero. Not sure what the design reason is, Thomas could you add a comment?

First call to ctrl_dumpfamily() is coming directly from the message
processing context where genl_lock is already held. Subsequence calls
come from netlink_recvmsg() so we have to take the lock separately.

However, I just noticed the condition should really be
	chains_to_skip != 0 || fams_to_skip != 0
