From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net 0/4] net: add rx_unhandled stat counter
Date: Thu, 28 Jan 2016 09:38:07 -0500
Message-ID: <20160128143806.GE59058@redhat.com>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
 <1453926098-40181-1-git-send-email-jarod@redhat.com>
 <1453928987.20722.29.camel@edumazet-glaptop2.roam.corp.google.com>
 <20160128060215.GB59058@redhat.com>
 <20160128061808.GD59058@redhat.com>
 <1453986002.7627.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1453986002.7627.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 28, 2016 at 05:00:02AM -0800, Eric Dumazet wrote:
> On Thu, 2016-01-28 at 01:18 -0500, Jarod Wilson wrote:
> 
> > Or not. Now I remember why I added that in the first place:
> > 
> > In file included from ./arch/x86/include/asm/uaccess.h:7:0,
> >                  from net/core/dev.c:75:
> > net/core/dev.c: In function 'netdev_stats_to_stats64':
> > include/linux/compiler.h:484:20: error: call to '__compiletime_assert_7263' declared with attribute error: BUILD_BUG_ON failed: sizeof(*stats64) != sizeof(*netdev_stats)
> >     prefix ## suffix();    \
> >                     ^
> > 
> > Things are actually hard-wired to require that addition at the moment, or
> > you get the above build failure. Not sure if it's safe to remove that
> > BUILD_BUG_ON() yet, haven't looked closely, it's past my bed time. :)
> > 
> 
> This was done for the transition from "unsigned long" to "u64", which is
> a nop on 64bit arches.
> 
> But as we do not need to be compatible, since no linux kernel in the
> past had this new field in struct net_device_stats,
> 
> and we do not need to add this new field as it is only accessed from
> core networking stack [1], you need to adapt this helper.

Something like this then:

diff --git a/net/core/dev.c b/net/core/dev.c
index 82334c6..2ca3eab 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7262,15 +7262,16 @@ void netdev_run_todo(void)
 void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
 			     const struct net_device_stats *netdev_stats)
 {
+	memset(stats64, 0, sizeof(*stats64));
 #if BITS_PER_LONG == 64
-	BUILD_BUG_ON(sizeof(*stats64) != sizeof(*netdev_stats));
+	BUILD_BUG_ON(sizeof(*stats64) < sizeof(*netdev_stats));
 	memcpy(stats64, netdev_stats, sizeof(*stats64));
 #else
 	size_t i, n = sizeof(*stats64) / sizeof(u64);
 	const unsigned long *src = (const unsigned long *)netdev_stats;
 	u64 *dst = (u64 *)stats64;
 
-	BUILD_BUG_ON(sizeof(*netdev_stats) / sizeof(unsigned long) !=
+	BUILD_BUG_ON(sizeof(*netdev_stats) / sizeof(unsigned long) >
 		     sizeof(*stats64) / sizeof(u64));
 	for (i = 0; i < n; i++)
 		dst[i] = src[i];

Compiles locally w/o that net_device_stats addition, seems sane to me.

-- 
Jarod Wilson
jarod@redhat.com
