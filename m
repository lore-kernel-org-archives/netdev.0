From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: KVM VM shutdown triggers BUG from network bridge code in 3.9.9
Date: Fri, 5 Jul 2013 08:31:43 +0000 (UTC)
Message-ID: <kr609f$aon$1@ger.gmane.org>
References: <51D64BEC.7090208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 05 Jul 2013 at 04:30 GMT, Robert Hancock <hancockrwd@gmail.com> wrote:
> I've run into a problem after updating to Fedora 19 where if I shut down 
> a Windows 7 KVM virtual machine, the machine hits a kernel panic. There 
> are a few reports of this on 3.9.8 and 3.9.9 kernels here:
>
> https://bugzilla.redhat.com/show_bug.cgi?id=981437
>
> The panic is "kernel BUG at kernel/timer.c:729!" and the stack traces 
> all seem basically the same, something like this one (captured with kdump):
>
>   #7 [ffff880214d25c10] mod_timer+501 at ffffffff8106d905
>   #8 [ffff880214d25c50] br_multicast_del_pg.isra.20+261 at 
> ffffffffa0731d25 [bridge]

Yeah, I got some similar bug report on Fedora...

Could you try the following patch? Thanks!

----------

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 81befac..69af490 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -270,7 +270,7 @@ static void br_multicast_del_pg(struct net_bridge *br,
 		del_timer(&p->timer);
 		call_rcu_bh(&p->rcu, br_multicast_free_pg);
 
-		if (!mp->ports && !mp->mglist &&
+		if (!mp->ports && !mp->mglist && mp->timer_armed &&
 		    netif_running(br->dev))
 			mod_timer(&mp->timer, jiffies);
 
