From: Avner Ben Hanoch <avnerb@mellanox.com>
Subject: Re: [PATCH v2 net-next 2/3] net: change
 sysctl_net_ll_poll into an unsigned int
Date: Wed, 12 Jun 2013 12:04:11 +0000
Message-ID: <1A1A58E4DB34914CB8A94FD5DAE569ED7367A8BF@MTLDAG01.mtl.com>
References: <20130612111942.19288.12131.stgit@ladj378.jer.intel.com>
	<20130612112005.19288.81197.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Kehati <ork@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	HPA <hpa@zytor.com>, Amir Vadai <amirv@mellanox.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Eliezer Tamir <eliezer@tamir.org.il>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Andi Kleen <andi@firstfloor.org>, Alex Rosenbaum <Alexr@mellanox.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <erdnetdev@gmail.com>, Eilon Greenstien <eilong@broadcom.com>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>, David Miller
	<davem@davemloft.net>, "sockperf-dev@googlegroups.com"
	<sockperf-dev@googlegroups.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130612112005.19288.81197.stgit@ladj378.jer.intel.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

Please make sure to include sockperf-dev@googlegroups.com among the recipients of this thread (I just added).
Maybe better, I suggest opening an issue in sockperf issue system - https://code.google.com/p/sockperf/issues/list .  Then anyone can add notes or read/receive them.

You can see an example for similar issue (patch for supporting IP_TOS) here: https://code.google.com/p/sockperf/issues/detail?id=44
Cheers,
  Avner

-----Original Message-----
From: Eliezer Tamir [mailto:eliezer.tamir@linux.intel.com] 
Sent: Wednesday, June 12, 2013 14:20
To: David Miller
Cc: linux-kernel@vger.kernel.org; netdev@vger.kernel.org; Jesse Brandeburg; Don Skidmore; e1000-devel@lists.sourceforge.net; Willem de Bruijn; Eric Dumazet; Ben Hutchings; Andi Kleen; HPA; Eilon Greenstien; Or Gerlitz; Amir Vadai; Alex Rosenbaum; Avner Ben Hanoch; Or Kehati; Eliezer Tamir
Subject: [PATCH v2 net-next 2/3] net: change sysctl_net_ll_poll into an unsigned int

There is no reason for sysctl_net_ll_poll to be an unsigned long.
Change it into an unsigned int.
Fix the proc handler.
Add a cast in ll_end_time()

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 include/net/ll_poll.h      |    5 +++--
 net/core/sysctl_net_core.c |    4 ++--
 net/socket.c               |    2 +-
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h index bc262f8..d20508d 100644
--- a/include/net/ll_poll.h
+++ b/include/net/ll_poll.h
@@ -34,7 +34,7 @@
 #ifdef CONFIG_NET_LL_RX_POLL
 
 struct napi_struct;
-extern unsigned long sysctl_net_ll_poll __read_mostly;
+extern unsigned int sysctl_net_ll_poll __read_mostly;
 
 /* return values from ndo_ll_poll */
 #define LL_FLUSH_FAILED		-1
@@ -45,7 +45,8 @@ extern unsigned long sysctl_net_ll_poll __read_mostly;
 
 static inline cycles_t ll_end_time(void)  {
-	return TSC_MHZ * ACCESS_ONCE(sysctl_net_ll_poll) + get_cycles();
+	return (cycles_t)TSC_MHZ * ACCESS_ONCE(sysctl_net_ll_poll)
+		 + get_cycles();
 }
 
 static inline bool sk_valid_ll(struct sock *sk) diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c index 4b48f39..3c78b75 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -289,9 +289,9 @@ static struct ctl_table net_core_table[] = {
 	{
 		.procname	= "low_latency_poll",
 		.data		= &sysctl_net_ll_poll,
-		.maxlen		= sizeof(unsigned long),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_doulongvec_minmax
+		.proc_handler	= proc_dointvec
 	},
 #endif
 #endif /* CONFIG_NET */
diff --git a/net/socket.c b/net/socket.c index 21fd29f..caaffa1 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -107,7 +107,7 @@
 #include <net/ll_poll.h>
 
 #ifdef CONFIG_NET_LL_RX_POLL
-unsigned long sysctl_net_ll_poll __read_mostly;
+unsigned int sysctl_net_ll_poll __read_mostly;
 EXPORT_SYMBOL_GPL(sysctl_net_ll_poll);
 #endif
 

------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
