From: Patrick McHardy <kaber@trash.net>
Subject: Re: kernel oops after unloading nf_conntrack_netbios_ns_module
Date: Sat, 12 May 2007 17:05:51 +0200
Message-ID: <4645D7CF.20707@trash.net>
References: <20070510090603.GA13059@odin.sis.hu> <20070510033411.6cf042ad.akpm@linux-foundation.org> <20070510110117.GE13059@odin.sis.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090002080406070905080306"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gabor Burjan <buga@buvoshetes.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56011 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755365AbXELPH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2007 11:07:26 -0400
In-Reply-To: <20070510110117.GE13059@odin.sis.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090002080406070905080306
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Gabor Burjan wrote:
> EIP is at destroy_conntrack+0x52/0x127 [nf_conntrack]
>
>>>nmblookup <existing_netbios_name>
>>>cat /proc/net/ip_conntrack
>>>
>>>sleep 3
>>>
>>>rmmod nf_conntrack_netbios_ns


Thanks for the report and good testcase, the crash can only happen with
a sleep of >= 3s after the last nmblookup packet was sent.

Can you try if this patch fixes it please?


--------------090002080406070905080306
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETFILTER]: nf_conntrack: fix use-after-free in helper destroy callback

When the helper module is removed for a master connection that has a
fulfilled expectation, but has already timed out and got removed from
the hash tables, nf_conntrack_helper_unregister can't find the master
connection to unset the helper, causing a use-after-free when the
expected connection is destroyed and releases the last reference to
the master.

The helper destroy callback was introduced for the PPtP helper to clean
up expectations and expected connections when the master connection
times out, but doing this from the destroy_conntrack only works for
unfulfilled expectations since expected connections hold a reference
to the master and it is not destroyed. Move the destroy callback to
the timeout function, which fixes both problems.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 50d2ab6c1353c32b994e6171b231fc771d0a2b73
tree 9b2cd5659dad0b452e59fff4869f7d9db780fd02
parent 6b99a1744ab187073bca84a9fd3ccbf091865ca6
author Patrick McHardy <kaber@trash.net> Sat, 12 May 2007 16:59:07 +0200
committer Patrick McHardy <kaber@trash.net> Sat, 12 May 2007 17:00:18 +0200

 net/netfilter/nf_conntrack_core.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index cb29ba7..0975fee 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -315,7 +315,6 @@ static void
 destroy_conntrack(struct nf_conntrack *nfct)
 {
 	struct nf_conn *ct = (struct nf_conn *)nfct;
-	struct nf_conn_help *help = nfct_help(ct);
 	struct nf_conntrack_l3proto *l3proto;
 	struct nf_conntrack_l4proto *l4proto;
 
@@ -326,9 +325,6 @@ destroy_conntrack(struct nf_conntrack *nfct)
 	nf_conntrack_event(IPCT_DESTROY, ct);
 	set_bit(IPS_DYING_BIT, &ct->status);
 
-	if (help && help->helper && help->helper->destroy)
-		help->helper->destroy(ct);
-
 	/* To make sure we don't get any weird locking issues here:
 	 * destroy_conntrack() MUST NOT be called with a write lock
 	 * to nf_conntrack_lock!!! -HW */
@@ -369,6 +365,10 @@ destroy_conntrack(struct nf_conntrack *nfct)
 static void death_by_timeout(unsigned long ul_conntrack)
 {
 	struct nf_conn *ct = (void *)ul_conntrack;
+	struct nf_conn_help *help = nfct_help(ct);
+
+	if (help && help->helper && help->helper->destroy)
+		help->helper->destroy(ct);
 
 	write_lock_bh(&nf_conntrack_lock);
 	/* Inside lock so preempt is disabled on module removal path.

--------------090002080406070905080306--
