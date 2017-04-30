From: kys@exchange.microsoft.com
Subject: [PATCH 1/6] Tools: hv: vss: Thaw the filesystem and continue if
 freeze call has timed out
Date: Sun, 30 Apr 2017 16:21:14 -0700
Message-ID: <1493594479-25329-1-git-send-email-kys@exchange.microsoft.com>
References: <1493594420-25214-1-git-send-email-kys@exchange.microsoft.com>
Reply-To: kys@microsoft.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alex Ng <alexng@messages.microsoft.com>, Michael Gissing <mg@faulpeltz.net>
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com, leann.ogasawara@canonical.comi,
 marcelo.cerri@canonical.com, sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1493594420-25214-1-git-send-email-kys@exchange.microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Alex Ng <alexng@messages.microsoft.com>

If a FREEZE operation takes too long, the driver may time out and move on
to another  operation. The daemon is unaware of this and attempts to
notify the driver that the FREEZE succeeded. This results in an error from
the driver and the daemon leaves the filesystem in frozen state.

Fix this by thawing the filesystem and continuing.

Signed-off-by: Michael Gissing <mg@faulpeltz.net>
Signed-off-by: Alex Ng <alexng@messages.microsoft.com>
Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 tools/hv/hv_vss_daemon.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/tools/hv/hv_vss_daemon.c b/tools/hv/hv_vss_daemon.c
index e082980..7ba5419 100644
--- a/tools/hv/hv_vss_daemon.c
+++ b/tools/hv/hv_vss_daemon.c
@@ -261,7 +261,9 @@ int main(int argc, char *argv[])
 		if (len != sizeof(struct hv_vss_msg)) {
 			syslog(LOG_ERR, "write failed; error: %d %s", errno,
 			       strerror(errno));
-			exit(EXIT_FAILURE);
+
+			if (op == VSS_OP_FREEZE)
+				vss_operate(VSS_OP_THAW);
 		}
 	}
 
-- 
1.7.1
