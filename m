From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH][MCAST]IPv6: doubt about ipv6_sk_mc_lock usage.
Date: Mon, 31 Oct 2005 13:37:46 -0800
Message-ID: <OFF1E5FA9D.8ED1B981-ON882570AB.00756304-882570AB.0076CB1C@us.ibm.com>
References: <4365775B.9080209@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932541AbVJaVhg@vger.kernel.org>
In-Reply-To: <4365775B.9080209@21cn.com>
To: Yan Zheng <yanzheng@21cn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I have one more question. 
> Why ip6_mc_source() uses read_lock_bh(&ipv6_sk_mc_lock) and 
ip6_mc_msfilter() 
> doesn't use ipv6_sk_mc_lock at all. 
> when ipv6_mc_list's sflist are accessed by inet6_mc_check(), Can it be 
> modified by ip6_mc_source() or ip6_mc_msfilter() ?
> (For example ipv6_mc_list's sflist is freed up by sock_kfree_s(), when 
> inet6_mc_check() uses it)

Yan,

There certainly may be a bug, but removing the lock isn't the fix. :-)

inet6_mc_check() does not have the socket locked, but is acquiring a
read lock on ipv6_sk_mc_lock.

I've looked some more into this, and I believe ip6_mc_msfilter() needs
at least a read lock on ipv6_sk_mc_lock to protect it from races with
changes to the list, just as ip6_mc_source() has.

I convinced myself at the time that the sflist does not require an
additional lock, but I don't see that now. It seems to me now that
there should be a lock on each individual socklist entry and changes
to the socket source filter should be protected by that. A simpler,
but less performant, fix would be to make both ipv6_mc_source() and
ip6_mc_msfilter() acquire ipv6_sk_mc_lock for writing, to prevent
races with inet6_mc_check's search of the sflist.

It'd be much better if only that socklist entry is locked, of course.

I'll look some more.

                        +-DLS
