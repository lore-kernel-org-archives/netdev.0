From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/2] tipc: correct the order of
	stopping services at rmmod
Date: Mon,  9 Dec 2013 22:54:46 -0800
Message-ID: <1386658487-5463-2-git-send-email-jon.maloy@ericsson.com>
References: <1386658487-5463-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1386658487-5463-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The 'signal handler' service in TIPC is a mechanism that makes it
possible to postpone execution of functions, by launcing them into
a job queue for execution in a separate tasklet, independent of
the launching execution thread.

When we do rmmod on the tipc module, this service is stopped after
the network service. At the same time, the stopping of the network
service may itself launch jobs for execution, with the risk that these
functions may be scheduled for execution after the data structures
meant to be accessed by the job have already been deleted. We have
seen this happen, most often resulting in an oops.

This commit ensures that the signal handler is the very first to be
stopped when TIPC is shut down, so there are no surprises during
the cleanup of the other services.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/core.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index fd4eeea..c6d3f75 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -113,7 +113,6 @@ err:
 static void tipc_core_stop(void)
 {
 	tipc_netlink_stop();
-	tipc_handler_stop();
 	tipc_cfg_stop();
 	tipc_subscr_stop();
 	tipc_nametbl_stop();
@@ -146,9 +145,10 @@ static int tipc_core_start(void)
 		res = tipc_subscr_start();
 	if (!res)
 		res = tipc_cfg_init();
-	if (res)
+	if (res) {
+		tipc_handler_stop();
 		tipc_core_stop();
-
+	}
 	return res;
 }
 
@@ -178,6 +178,7 @@ static int __init tipc_init(void)
 
 static void __exit tipc_exit(void)
 {
+	tipc_handler_stop();
 	tipc_core_stop_net();
 	tipc_core_stop();
 	pr_info("Deactivated\n");
-- 
1.7.9.5


------------------------------------------------------------------------------
Sponsored by Intel(R) XDK 
Develop, test and display web and hybrid apps with a single code base.
Download it for free now!
http://pubads.g.doubleclick.net/gampad/clk?id=111408631&iu=/4140/ostg.clktrk
