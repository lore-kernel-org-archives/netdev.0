From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH] xfrm: fix handling of XFRM policies mark and mask.
Date: Mon, 11 Feb 2013 14:04:47 +0100
Message-ID: <20130211130447.GE17794@secunet.com>
References: <9E57ADA1-5770-47A8-8EBF-7FC262EEF1C7@ipflavors.com>
 <20130205081232.GF23291@secunet.com>
 <51125744.3030905@gmail.com>
 <D4563759-CEC5-4F33-BF0A-9FA10716F8DF@telecom-bretagne.eu>
 <20130207104908.GA17794@secunet.com>
 <2BEAF521-7218-415B-98ED-EC0812903479@telecom-bretagne.eu>
 <20130207125437.GC17794@secunet.com>
 <1854603B-3AD1-4245-A8BA-53D841BCEA63@telecom-bretagne.eu>
 <9EFD8AF1-2EDC-4361-A6CA-52FD5D42ED9E@ipflavors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <j.hadi123@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	Emmanuel THIERRY <emmanuel.thierry@telecom-bretagne.eu>,
	linux-kernel@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: Romain KUNTZ <r.kuntz@ipflavors.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9EFD8AF1-2EDC-4361-A6CA-52FD5D42ED9E@ipflavors.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 11, 2013 at 01:57:59PM +0100, Romain KUNTZ wrote:
> Hi Steffen,
> 
> Do you plan to resubmit a patch to the mailing list or shall we take care of that?
> 

I'm testing with the patch below. If it shows no regression,
I'll apply it to the ipsec-next tree.

Subject: [PATCH] xfrm: Allow inserting policies with matching mark and
 different priorities

We currently can not insert policies with mark and mask
such that some flows would be matched from both policies.
We make this possible when the priority of these policies
are different. If both policies match a flow, the one with
the higher priority is used.

Reported-by: Emmanuel Thierry <emmanuel.thierry@telecom-bretagne.eu>
Reported-by: Romain Kuntz <r.kuntz@ipflavors.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c |   18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 456b11b..257dfb1 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -607,6 +607,21 @@ static void xfrm_policy_requeue(struct xfrm_policy *old,
 	spin_unlock_bh(&pq->hold_queue.lock);
 }
 
+static bool xfrm_policy_mark_match(struct xfrm_policy *policy,
+				   struct xfrm_policy *pol)
+{
+	u32 mark = policy->mark.v & policy->mark.m;
+
+	if (policy->mark.v == pol->mark.v && policy->mark.m == pol->mark.m)
+		return true;
+
+	if ((mark & pol->mark.m) == pol->mark.v &&
+	    policy->priority == pol->priority)
+		return true;
+
+	return false;
+}
+
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 {
 	struct net *net = xp_net(policy);
@@ -614,7 +629,6 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	struct xfrm_policy *delpol;
 	struct hlist_head *chain;
 	struct hlist_node *entry, *newpos;
-	u32 mark = policy->mark.v & policy->mark.m;
 
 	write_lock_bh(&xfrm_policy_lock);
 	chain = policy_hash_bysel(net, &policy->selector, policy->family, dir);
@@ -623,7 +637,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	hlist_for_each_entry(pol, entry, chain, bydst) {
 		if (pol->type == policy->type &&
 		    !selector_cmp(&pol->selector, &policy->selector) &&
-		    (mark & pol->mark.m) == pol->mark.v &&
+		    xfrm_policy_mark_match(policy, pol) &&
 		    xfrm_sec_ctx_match(pol->security, policy->security) &&
 		    !WARN_ON(delpol)) {
 			if (excl) {
-- 
1.7.9.5
