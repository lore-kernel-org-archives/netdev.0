From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the block tree
Date: Tue, 18 Apr 2017 13:02:29 +1000
Message-ID: <20170418130229.04289bd6@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Josef Bacik <josef@toxicpanda.com>,
        Johannes Berg <johannes.berg@intel.com>
To: Jens Axboe <axboe@kernel.dk>, David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:33953 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752136AbdDRDCc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Apr 2017 23:02:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

After merging the block tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

drivers/block/nbd.c: In function 'nbd_genl_connect':
drivers/block/nbd.c:1662:10: error: too few arguments to function 'nla_parse_nested'
    ret = nla_parse_nested(socks, NBD_SOCK_MAX, attr,
          ^
In file included from include/net/rtnetlink.h:5:0,
                 from include/net/sch_generic.h:12,
                 from include/linux/filter.h:20,
                 from include/net/sock.h:64,
                 from drivers/block/nbd.c:32:
include/net/netlink.h:754:19: note: declared here
 static inline int nla_parse_nested(struct nlattr *tb[], int maxtype,
                   ^
drivers/block/nbd.c: In function 'nbd_genl_reconfigure':
drivers/block/nbd.c:1818:10: error: too few arguments to function 'nla_parse_nested'
    ret = nla_parse_nested(socks, NBD_SOCK_MAX, attr,
          ^
In file included from include/net/rtnetlink.h:5:0,
                 from include/net/sch_generic.h:12,
                 from include/linux/filter.h:20,
                 from include/net/sock.h:64,
                 from drivers/block/nbd.c:32:
include/net/netlink.h:754:19: note: declared here
 static inline int nla_parse_nested(struct nlattr *tb[], int maxtype,
                   ^

Caused by commits

  e46c7287b1c2 ("nbd: add a basic netlink interface")
  b7aa3d39385d ("nbd: add a reconfigure netlink command")

interacting with commit

  fceb6435e852 ("netlink: pass extended ACK struct to parsing functions")

from the net-next tree.

I have applied the following merge fix patch:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 18 Apr 2017 12:59:05 +1000
Subject: [PATCH] nbd: fix up for nla_parse_nested() API change

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/block/nbd.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
index b78f23ce2395..5049d19f3940 100644
--- a/drivers/block/nbd.c
+++ b/drivers/block/nbd.c
@@ -1660,7 +1660,7 @@ static int nbd_genl_connect(struct sk_buff *skb, struct genl_info *info)
 				goto out;
 			}
 			ret = nla_parse_nested(socks, NBD_SOCK_MAX, attr,
-					       nbd_sock_policy);
+					       nbd_sock_policy, NULL);
 			if (ret != 0) {
 				printk(KERN_ERR "nbd: error processing sock list\n");
 				ret = -EINVAL;
@@ -1816,7 +1816,7 @@ static int nbd_genl_reconfigure(struct sk_buff *skb, struct genl_info *info)
 				goto out;
 			}
 			ret = nla_parse_nested(socks, NBD_SOCK_MAX, attr,
-					       nbd_sock_policy);
+					       nbd_sock_policy, NULL);
 			if (ret != 0) {
 				printk(KERN_ERR "nbd: error processing sock list\n");
 				ret = -EINVAL;
-- 
2.11.0

-- 
Cheers,
Stephen Rothwell
