From: Colin King <colin.king@canonical.com>
Subject: [PATCH] genetlink: fix unsigned int comparison with less than zero
Date: Thu, 10 Nov 2016 15:57:58 +0000
Message-ID: <20161110155758.26996-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        pravin shelar <pshelar@ovn.org>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        Florian Westphal <fw@strlen.de>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

family->id is unsigned, so the less than zero check for
failure return from idr_alloc is never true and so the error exit
is never handled.  Instead, assign err and check if this is less
than zero since this is a signed integer.

Issue found with static analysis with CoverityScan, CID 1375916

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/netlink/genetlink.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index f0b65fe..2ea61ba 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -360,12 +360,10 @@ int genl_register_family(struct genl_family *family)
 	} else
 		family->attrbuf = NULL;
 
-	family->id = idr_alloc(&genl_fam_idr, family,
+	family->id = err = idr_alloc(&genl_fam_idr, family,
 			       start, end + 1, GFP_KERNEL);
-	if (family->id < 0) {
-		err = family->id;
+	if (err < 0)
 		goto errout_free;
-	}
 
 	err = genl_validate_assign_mc_groups(family);
 	if (err)
-- 
2.10.2
