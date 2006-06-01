From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: 2.6.17-rc5-mm1 lockdep output
Date: Thu, 01 Jun 2006 08:34:45 +0200
Message-ID: <1149143685.3115.6.camel@laptopd505.fenrus.org>
References: <4807377b0605311704g44fe10f1oc54315276890071@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: NetDEV list <netdev@vger.kernel.org>, mingo@elte.hu,
	Andrew Morton <akpm@osdl.org>,
	"Linux-Kernel," <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a222036.upc-a.chello.nl ([62.163.222.36]:58794 "EHLO
	laptopd505.fenrus.org") by vger.kernel.org with ESMTP
	id S965266AbWFAGe5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jun 2006 02:34:57 -0400
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
In-Reply-To: <4807377b0605311704g44fe10f1oc54315276890071@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-05-31 at 17:04 -0700, Jesse Brandeburg wrote:
> well, when running e1000 through some code paths on FC4 +
> 2.6.17-rc5-mm1 + ingo's latest rollup patch, with this lockdep debug
> option enabled I got this:
> 
> e1000: eth1: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
> 
> ======================================
> [ BUG: bad unlock ordering detected! ]
> --------------------------------------
> mDNSResponder/2361 is trying to release lock (&in_dev->mc_list_lock) at:
>  [<ffffffff81233f5a>] ip_mc_add_src+0x85/0x1f8
> but the next lock to release is:
>  (&im->lock){-+..}, at: [<ffffffff81233f52>] ip_mc_add_src+0x7d/0x1f8
> 
> other info that might help us debug this:
> 2 locks held by mDNSResponder/2361:
>  #0:  (rtnl_mutex){--..}, at: [<ffffffff81253741>] mutex_lock+0x27/0x2c
>  #1:  (&in_dev->mc_list_lock){-.-?}, at: [<ffffffff81233f14>]
> ip_mc_add_src+0x3f/0x1f8

ok another out of order one in igmp ...


Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

---
 net/ipv4/igmp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.17-rc5-mm1.5/net/ipv4/igmp.c
===================================================================
--- linux-2.6.17-rc5-mm1.5.orig/net/ipv4/igmp.c
+++ linux-2.6.17-rc5-mm1.5/net/ipv4/igmp.c
@@ -1646,7 +1646,7 @@ static int ip_mc_add_src(struct in_devic
 		return -ESRCH;
 	}
 	spin_lock_bh(&pmc->lock);
-	read_unlock(&in_dev->mc_list_lock);
+	read_unlock_non_nested(&in_dev->mc_list_lock);
 
 #ifdef CONFIG_IP_MULTICAST
 	sf_markstate(pmc);

