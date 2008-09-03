From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 25/37] dccp: Feature activation handlers
Date: Wed, 3 Sep 2008 06:38:28 +0200
Message-ID: <20080903043828.GC4105@gerrit.erg.abdn.ac.uk>
References: <1219945512-7723-18-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-19-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-20-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-21-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-22-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-23-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-24-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-25-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-26-git-send-email-gerrit@erg.abdn.ac.uk> <48BCDE89.7060909@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:40176 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750877AbYICEjC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 00:39:02 -0400
Content-Disposition: inline
In-Reply-To: <48BCDE89.7060909@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > This patch provides the post-processing of feature negotiation state, after
| > the negotiation has completed.

<snip>
| >  
| > +int dccp_feat_activate_values(struct sock *sk, struct list_head *fn_list)
| > +{
| > +	struct dccp_sock *dp = dccp_sk(sk);
| > +	struct dccp_feat_entry *cur, *next;
| > +	int idx;
| > +	dccp_feat_val *fvals[DCCP_FEAT_SUPPORTED_MAX][2] = {
| > +		 [0 ... DCCP_FEAT_SUPPORTED_MAX-1] = { NULL, NULL }
| > +	};
| > +
| > +	list_for_each_entry(cur, fn_list, node) {
| > +
| > +		idx = dccp_feat_index(cur->feat_num);
| > +		if (idx < 0) {
| > +			DCCP_BUG("Unknown feature %u", cur->feat_num);
| > +			goto activation_failed;
| >   
| 
| idx < 0 is possible, if you goto activation_failed, the connection from
| endpoint which want to change feature we unkonwn, the connection will be
| always fail by reset. So I think it should just continue process the next
| feature(s).
| -----------------------------------
| if (idx < 0)
| continue;
| -----------------------------------
| 
| idx < 0 is happended when we recv a change option with unknown feature type.
| 
| 
No, since an unknown feature at this stage would most definitively be a bug.

The validity checking happens earlier:
 * for NN values every valid value is accepted as per RFC -
   this is ensured via dccp_feat_is_valid_nn_val();
 * for SP values at least the confirmed value must be valid -
   - this is checked in confirm_recv(),
   - setsockopt is protected against registering invalid feature values,
   - for CCIDs, additional a check for availability is made before
     entering negotiation.

These conditions (should) ensure that the above condition is never
triggered, the test is like an assert() clause.
