From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/2] net: Fix sysctl restarts...
Date: Fri, 19 Feb 2010 15:58:53 -0800
Message-ID: <m1aav4srpe.fsf@fess.ebiederm.org>
References: <m14olcu7xo.fsf@fess.ebiederm.org>
	<20100219.152954.39315470.davem@davemloft.net>
	<m1ocjksssg.fsf@fess.ebiederm.org>
	<20100219.154140.77047519.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57099 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752961Ab0BSX66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 18:58:58 -0500
In-Reply-To: <20100219.154140.77047519.davem@davemloft.net> (David Miller's message of "Fri\, 19 Feb 2010 15\:41\:40 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

2> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Fri, 19 Feb 2010 15:35:27 -0800
>
>> When we I fixed the deadlock that can happen if you write to forwarding
>> while removing the device.  The deadlock was fixed, the restart worked
>> but I somehow missed the fact that proc_dointvec modifies state and so
>> defeated the change detection.  *embarrassing*
>
> Ok, I'll have to push these around to Linus and a couple -stable
> releases.

The second patch fixes an issue which isn't quite as old.

I caught it when I was looking for other rtnl_lock issues that
I may have missed.  Thankfully the worst sysfs does is re-read
the string from userspace on a restart so none of the sysfs
rtnl_trylock cases have a nasty deadlock associated.

Eric


commit a160ee69c6a4622ed30c377a978554015e9931cb
Author: Johannes Berg <johannes@sipsolutions.net>
Date:   Mon Oct 5 02:22:23 2009 -0700

    wext: let get_wireless_stats() sleep
    
    A number of drivers (recently including cfg80211-based ones)
    assume that all wireless handlers, including statistics, can
    sleep and they often also implicitly assume that the rtnl is
    held around their invocation. This is almost always true now
    except when reading from sysfs:
    
      BUG: sleeping function called from invalid context at kernel/mutex.c:280
      in_atomic(): 1, irqs_disabled(): 0, pid: 10450, name: head
      2 locks held by head/10450:
       #0:  (&buffer->mutex){+.+.+.}, at: [<c10ceb99>] sysfs_read_file+0x24/0xf4
       #1:  (dev_base_lock){++.?..}, at: [<c12844ee>] wireless_show+0x1a/0x4c
      Pid: 10450, comm: head Not tainted 2.6.32-rc3 #1
      Call Trace:
       [<c102301c>] __might_sleep+0xf0/0xf7
       [<c1324355>] mutex_lock_nested+0x1a/0x33
       [<f8cea53b>] wdev_lock+0xd/0xf [cfg80211]
       [<f8cea58f>] cfg80211_wireless_stats+0x45/0x12d [cfg80211]
       [<c13118d6>] get_wireless_stats+0x16/0x1c
       [<c12844fe>] wireless_show+0x2a/0x4c
    
    Fix this by using the rtnl instead of dev_base_lock.
    
    Reported-by: Miles Lane <miles.lane@gmail.com>
    Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>
