From: "Rosen, Rami" <rami.rosen@intel.com>
Subject: RE: [RFC PATCH net-next] switchdev: don't abort hardware ipv4 fib
 offload on failure to program fib entry in hardware
Date: Sun, 3 May 2015 09:28:36 +0000
Message-ID: <9B0331B6EBBD0E4684FBFAEDA55776F9193A4364@HASMSX110.ger.corp.intel.com>
References: <1430583883-3514-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"jiri@resnulli.us" <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:26729 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751016AbbECJ2m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 05:28:42 -0400
In-Reply-To: <1430583883-3514-1-git-send-email-roopa@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Removing the netdev_switch_fib_ipv4_abort() when there is an error in programming fib entry in hardware seems reasonable to me. I Just want to note that this is not only a matter of CPU strength; even if the switches' CPUs were powerful enough to do routing in software, still doing so seems not a good option, as routing is implemented in different ways by different switch vendors.

Regards,
Rami 

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of roopa@cumulusnetworks.com
Sent: Saturday, May 02, 2015 19:25
To: davem@davemloft.net; sfeldma@gmail.com; john.fastabend@gmail.com; jiri@resnulli.us
Cc: netdev@vger.kernel.org
Subject: [RFC PATCH net-next] switchdev: don't abort hardware ipv4 fib offload on failure to program fib entry in hardware

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This basically removes the calls to netdev_switch_fib_ipv4_abort when there is an error in programming fib entry in hardware.

On most systems where you can offload routes to hardware, doing routing in software is not an option (the cpu's are not powerful to route in software).

I understand that this was added to keep the first fib offload support simple. This RFC patch is to start a discussion around why the fib abort will not work for most hardware and to discuss alternate options for default behaviour.

Available options:
a) Dont abort hardware offload and return appropriate error to the user on fib offload failure by default (this patch)
b) make the behaviour in a) conditional on a global flag/sysctl (a per fib entry flag will not work because by default user/routing-daemons dont care if they are hardware offloaded)
c) for the users/routing-daemons interested in controlling the hardware offload behaviour there is always the per fib entry flag RTF_F_EXTERNAL (and special error codes -EOFFLOAD could perhaps indicate that the hardware offload failed)

Considering the characteristics of the systems that support fib offloads,
a) above seems to be the right default.

PS: This patch currently removes use of the netdev_switch_fib_ipv4_abort function but not the function itself. This will be fixed if we converge on the default behaviour.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/ipv4/fib_trie.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c index e13fcc6..05b6439 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1171,7 +1171,6 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 							 cfg->fc_nlflags,
 							 tb->tb_id);
 			if (err) {
-				netdev_switch_fib_ipv4_abort(fi);
 				kmem_cache_free(fn_alias_kmem, new_fa);
 				goto out;
 			}
@@ -1219,10 +1218,8 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 					 cfg->fc_type,
 					 cfg->fc_nlflags,
 					 tb->tb_id);
-	if (err) {
-		netdev_switch_fib_ipv4_abort(fi);
+	if (err)
 		goto out_free_new_fa;
-	}
 
 	/* Insert new entry to the list. */
 	err = fib_insert_alias(t, tp, l, new_fa, fa, key);
--
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe netdev" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
