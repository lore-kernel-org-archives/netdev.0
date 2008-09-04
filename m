From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
	feature-negotiation patches
Date: Thu, 4 Sep 2008 08:15:11 +0200
Message-ID: <20080904061511.GA30756@gerrit.erg.abdn.ac.uk>
References: <20080901.142055.193705447.davem@davemloft.net> <20080902135055.GB8346@ghostprotocols.net> <20080903042450.GA4105@gerrit.erg.abdn.ac.uk> <20080902.230655.89921076.davem@davemloft.net> <20080903081839.GA9001@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, acme@redhat.com,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:46857 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751100AbYIDGP6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 02:15:58 -0400
Content-Disposition: inline
In-Reply-To: <20080903081839.GA9001@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an update with regard to Wei's comments. I have re-synched 

	git://eden-feed.erg.abdn.ac.uk/dccp_exp		[subtree `dccp']
	http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=shortlog;h=dccp

Also did some testing with a client that only supports CCID 2/3 talking to a client supporting
CCID 2/3/4. They could still negotiate and settle for a common CCID.

Change-Log:
-----------
	1. relaxed the requirement of checking each and every SP value in change_recv
	   to checking only the value that will actually be used/activated;
	2. fixed an error in yesterdays's update:
	   dccp_feat_is_valid_sp_val() takes an u8 value, not an u8 *pointer;
	3. added Wei's suggestion to skip over empty Confirms when activating the
	   negotiated features in dccp_feat_activate_values().

--------------------------------------------------------------------------------------------	   
List of patches that were updated:
----------------------------------
v3 [PATCH 1/1] dccp: Process incoming Change feature-negotiation options 
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=5a146b97d5e93db2df075c0d820f492bb996d0e3

[PATCH 25/37] dccp: Feature activation handlers
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=c926c6aed3e444e8c88a768f063b2de8fd6ae760

--------------------------------------------------------------------------------------------	   
Interdiff of the submitted changeset relative to yesterday's state:
--------------------------------------------------------------------------------------------
 		1 file changed, 11 insertions(+), 3 deletions(-)
--- b/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -1102,8 +1102,6 @@ static u8 dccp_feat_change_recv(struct list_head *fn, u8 
 	 */
 	entry = dccp_feat_list_lookup(fn, feat, local);
 	if (entry == NULL) {
-		if (!dccp_feat_sp_list_ok(feat, val, len))
-			goto unknown_feature_or_value;
 		/*
 		 * No particular preferences have been registered. We deal with
 		 * this situation by assuming that all valid values are equally
@@ -1121,6 +1119,9 @@ static u8 dccp_feat_change_recv(struct list_head *fn, u8 
 			defval = dccp_feat_default_value(feat);
 			if (dccp_feat_preflist_match(&defval, 1, val, len) > -1)
 				fval.sp.vec[0] = defval;
+		} else if (!dccp_feat_is_valid_sp_val(feat, fval.sp.vec[0])) {
+			kfree(fval.sp.vec);
+			goto unknown_feature_or_value;
 		}
 
 		/* Treat unsupported CCIDs like invalid values */
@@ -1229,7 +1230,7 @@ static u8 dccp_feat_confirm_recv(struct list_head *fn, u8 
 	 * SP value which the peer confirms, the remainder depends on @len.
 	 * Note that only the confirmed value need to be a valid SP value.
 	 */
-	if (!dccp_feat_is_valid_sp_val(feat, val))
+	if (!dccp_feat_is_valid_sp_val(feat, *val))
 		goto confirmation_failed;
 
 	if (len == 1) {		/* peer didn't supply a preference list */
@@ -1471,6 +1472,13 @@ int dccp_feat_activate_values(struct sock *sk, struct
 	};
 
 	list_for_each_entry(cur, fn_list, node) {
+		/*
+		 * An empty Confirm means that either an unknown feature type
+		 * or an invalid value was present. In the first case there is
+		 * nothing to activate, in the other the default value is used.
+		 */
+		if (cur->empty_confirm)
+			continue;
 
 		idx = dccp_feat_index(cur->feat_num);
 		if (idx < 0) {
