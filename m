From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 03/37] dccp: List management for new feature negotiation
Date: Sat, 30 Aug 2008 15:51:52 +0200
Message-ID: <20080830135152.GB17190@gerrit.erg.abdn.ac.uk>
References: <1219945512-7723-1-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-2-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-3-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-4-git-send-email-gerrit@erg.abdn.ac.uk> <20080828194336.GJ9193@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:33645 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750817AbYH3NwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Aug 2008 09:52:09 -0400
Content-Disposition: inline
In-Reply-To: <20080828194336.GJ9193@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > +static struct dccp_feat_entry *
| > +	      dccp_feat_entry_new(struct list_head *fn, u8 feat, u8 is_local)
| > +{
| > +	struct dccp_feat_entry *entry;
| > +	struct list_head *pos_head = fn;
| > +
| > +	list_for_each(pos_head, fn) {
| > +		entry = list_entry(pos_head, struct dccp_feat_entry, node);
| > +		if (feat < entry->feat_num)
| > +			break;
| 
| Why not use list_for_each_entry()?
| 
I know now why list_for_each() was chosen - if the list does not contain
a feat/is_local entry yet, the pos_head is used later for the 
		list_add_tail(&entry->node, pos_head);
statement. I have rewritten the function now with list_for_each_entry
and will resubmit the new version.

| > +		if (entry->feat_num == feat && entry->is_local == is_local) {
| > +			dccp_feat_val_destructor(entry->feat_num, &entry->val);
| 
| <first reaction>
| You call dccp_feat_val_destructor on entry->val, that kfrees a field and
| then return it? I havent checked, but would it be safer to set the field
| kfree'ed in dccp_feat_val_destructor to NULL since
| dccp_feat_val_destructor is not a destructor (i.e. its not the last
| function in the life of dccp_feat_val)?
|
Yes that is correct. As far as I can see, my own use of these functions is
consistent, but it does not allow someone else to use the functions in a
different setting. But the place to fix it was Patch 2/37, which has been
changed as follows:

 static void dccp_feat_val_destructor(u8 feat_num, dccp_feat_val *val)
 {
-	if (val && dccp_feat_type(feat_num) == FEAT_SP)
+	if (unlikely(val == NULL))
+		return;
+	if (dccp_feat_type(feat_num) == FEAT_SP)
 		kfree(val->sp.vec);
+	memset(val, 0, sizeof(*val));
 }


| I got confused with a _new routine that ends up not being a constructor
| and _destructor being called on an object, then not setting what it
| frees to NULL and then reusing it somehow
| 
Suggestions for better names are welcome. I thought it over, and _new
was the best I could come up with. But I have rewritten the documentation
and added more text. Hopefully this will make things clearer.

I also thought about the two other suggestions
 (a) Whether to use dccp_feat_list_lookup() in the _new constructor to
     reduce code duplication:
     The constructor also keeps the list always sorted. So when the
     lookup function returns NULL, the search becomes O(2*n) instead
     of n. I tried it with a routine `dccp_feat_lookup_nearest' which
     returns the next list_head before which to insert. But then one
     would need to repeat the test
	if (entry->feat_num == feat && entry->is_local == is_local) {
     I think this is ugly.
 (b) Whether to use hlist instead:
     This is an optimisation. It seems in principle possible. However,
     as I am doing DCCP in my (limited) spare time and since there are
     many other things to fix - missing functionality or causes of
     failure - I'd suggest to enqueue this at the end of the todo list.

Gerrit
