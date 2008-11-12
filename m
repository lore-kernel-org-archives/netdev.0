From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: v2 [PATCH 0/4] dccp: Feature negotiation - conclusion of Part I
	(basis)
Date: Wed, 12 Nov 2008 07:36:43 +0100
Message-ID: <20081112063643.GB6405@gerrit.erg.abdn.ac.uk>
References: <20081104.235652.27274000.davem@davemloft.net> <1225950014-6337-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:53145 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751086AbYKLGgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 01:36:50 -0500
Content-Disposition: inline
In-Reply-To: <1225950014-6337-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

please find attached the correct set of 4 patches, taken from up-to-date
copies. Text below (URL) also updated.

Gerrit


Changes relative to revision-01
-------------------------------
Patch 2/4 in the first revision was in an outdated format which lead to 
several hunks missing. This set contains the correct/up-to-date versions.
For reference, an inter-diff to the previous set is below.


Commit summary
--------------
The set concludes the first set of the feature negotiation patches to provide
a self-contained feature negotiation API for the DCCP protocol (RFC 4340-2).

The whole set is structured into 3 main blocks - (1) basis, (2) core,
(3) integration and cleanup.

Within these blocks, this is the second set and its purpose is to conclude
the base implementation, preparing for the (15) core patches in the second set.


List of patches in this set:
----------------------------
Patch #1: Changes the existing policy to allow anytime changes as that lead
          to unpredictable results.
Patch #2: Adds registration routines. These form part of the user interface
          and are later used by the socket API to set individual preferences.
Patch #3: CCIDs are a negotiable feature. This patch adds support to query the
          supported CCIDs, so as to advertise only the locally supported ones.
Patch #4: The choice of CCID in turn creates new feature dependencies. The patch
          adds automatic tracking of such dependencies to avoid later failure.

The set is also available for viewing online, beginning at
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=287242dd8caa65415c219e3163a8b6744067508f


Patch stats:
------------
 Documentation/networking/dccp.txt |    4 
 include/linux/dccp.h              |    1 
 net/dccp/ccid.c                   |   48 ++++
 net/dccp/ccid.h                   |    5 
 net/dccp/ccids/ccid2.c            |    6 
 net/dccp/dccp.h                   |    1 
 net/dccp/feat.c                   |  375 ++++++++++++++++++++++++++++++++++----
 net/dccp/feat.h                   |   25 ++
 net/dccp/options.c                |   18 -
 net/dccp/output.c                 |    4 
 net/dccp/proto.c                  |    7 
 net/dccp/timer.c                  |   12 -
 12 files changed, 437 insertions(+), 69 deletions(-)



		------------------------------------
		Appendix: Inter-diff to previous set
		------------------------------------

 --- a/net/dccp/feat.c
 +++ b/net/dccp/feat.c
 @@ -92,6 +92,18 @@ static u8 dccp_feat_type(u8 feat_num)
  	return dccp_feat_table[idx].reconciliation;
  }
  
 +static int dccp_feat_default_value(u8 feat_num)
 +{
 +	int idx = dccp_feat_index(feat_num);
 +	/*
 +	 * There are no default values for unknown features, so encountering a
 +	 * negative index here indicates a serious problem somewhere else.
 +	 */
 +	DCCP_BUG_ON(idx < 0);
 +
 +	return idx < 0 ? 0 : dccp_feat_table[idx].default_value;
 +}
 +
  /* copy constructor, fval must not already contain allocated memory */
  static int dccp_feat_clone_sp_val(dccp_feat_val *fval, u8 const *val, u8 len)
  {
 @@ -155,6 +167,63 @@ static void dccp_feat_entry_destructor(struct dccp_feat_entry *entry)
   * - list is sorted in increasing order of feature number (faster lookup)
   */
  
 +/**
 + * dccp_feat_entry_new  -  Central list update routine (called by all others)
 + * @head:  list to add to
 + * @feat:  feature number
 + * @local: whether the local (1) or remote feature with number @feat is meant
 + * This is the only constructor and serves to ensure the above invariants.
 + */
 +static struct dccp_feat_entry *
 +	      dccp_feat_entry_new(struct list_head *head, u8 feat, bool local)
 +{
 +	struct dccp_feat_entry *entry;
 +
 +	list_for_each_entry(entry, head, node)
 +		if (entry->feat_num == feat && entry->is_local == local) {
 +			dccp_feat_val_destructor(entry->feat_num, &entry->val);
 +			return entry;
 +		} else if (entry->feat_num > feat) {
 +			head = &entry->node;
 +			break;
 +		}
 +
 +	entry = kmalloc(sizeof(*entry), gfp_any());
 +	if (entry != NULL) {
 +		entry->feat_num = feat;
 +		entry->is_local = local;
 +		list_add_tail(&entry->node, head);
 +	}
 +	return entry;
 +}
 +
 +/**
 + * dccp_feat_push_change  -  Add/overwrite a Change option in the list
 + * @fn_list: feature-negotiation list to update
 + * @feat: one of %dccp_feature_numbers
 + * @local: whether local (1) or remote (0) @feat_num is meant
 + * @needs_mandatory: whether to use Mandatory feature negotiation options
 + * @fval: pointer to NN/SP value to be inserted (will be copied)
 + */
 +static int dccp_feat_push_change(struct list_head *fn_list, u8 feat, u8 local,
 +				 u8 mandatory, dccp_feat_val *fval)
 +{
 +	struct dccp_feat_entry *new = dccp_feat_entry_new(fn_list, feat, local);
 +
 +	if (new == NULL)
 +		return -ENOMEM;
 +
 +	new->feat_num	     = feat;
 +	new->is_local	     = local;
 +	new->state	     = FEAT_INITIALISING;
 +	new->needs_confirm   = 0;
 +	new->empty_confirm   = 0;
 +	new->val	     = *fval;
 +	new->needs_mandatory = mandatory;
 +
 +	return 0;
 +}
 +
  static inline void dccp_feat_list_pop(struct dccp_feat_entry *entry)
  {
  	list_del(&entry->node);
 
--- 
