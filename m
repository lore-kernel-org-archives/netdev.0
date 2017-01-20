From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] net: sctp: fix array overrun read on sctp_timer_tbl
Date: Fri, 20 Jan 2017 13:45:42 +0000
Message-ID: <20170120134542.21104-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Table sctp_timer_tbl is missing a TIMEOUT_RECONF string so
add this in. Also compare timeout with the size of the array
sctp_timer_tbl rather than SCTP_EVENT_TIMEOUT_MAX.  Also add
a build time check that SCTP_EVENT_TIMEOUT_MAX is correct
so we don't ever get this kind of mismatch between the table
and SCTP_EVENT_TIMEOUT_MAX in the future.

Kudos to Marcel Ricardo Leitner for spotting the missing string
and suggesting the build time sanity check.

Fixes CoverityScan CID#1397639 ("Out-of-bounds read")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/sctp/debug.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sctp/debug.c b/net/sctp/debug.c
index 95d7b15..2e47eb2 100644
--- a/net/sctp/debug.c
+++ b/net/sctp/debug.c
@@ -159,6 +159,7 @@ static const char *const sctp_timer_tbl[] = {
 	"TIMEOUT_T4_RTO",
 	"TIMEOUT_T5_SHUTDOWN_GUARD",
 	"TIMEOUT_HEARTBEAT",
+	"TIMEOUT_RECONF",
 	"TIMEOUT_SACK",
 	"TIMEOUT_AUTOCLOSE",
 };
@@ -166,7 +167,9 @@ static const char *const sctp_timer_tbl[] = {
 /* Lookup timer debug name. */
 const char *sctp_tname(const sctp_subtype_t id)
 {
-	if (id.timeout <= SCTP_EVENT_TIMEOUT_MAX)
+	BUILD_BUG_ON(SCTP_EVENT_TIMEOUT_MAX + 1 != ARRAY_SIZE(sctp_timer_tbl));
+
+	if (id.timeout < ARRAY_SIZE(sctp_timer_tbl))
 		return sctp_timer_tbl[id.timeout];
 	return "unknown_timer";
 }
-- 
2.10.2
