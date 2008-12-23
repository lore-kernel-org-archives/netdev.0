From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC] [Patch 2/4] dccp: Lockless use of CCID blocks
Date: Tue, 23 Dec 2008 18:17:29 +0100
Message-ID: <20081223171729.GB3855@gerrit.erg.abdn.ac.uk>
References: <20081218053349.GA6172@gerrit.erg.abdn.ac.uk> <20081218.191534.194793981.davem@davemloft.net> <20081219052446.GA3651@gerrit.erg.abdn.ac.uk> <20081218.222842.174783235.davem@davemloft.net> <20081220080813.GC3853@gerrit.erg.abdn.ac.uk> <20081221003239.GA5700@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:50146 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750955AbYLWRXP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Dec 2008 12:23:15 -0500
Content-Disposition: inline
In-Reply-To: <20081221003239.GA5700@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > -int ccid_unregister(struct ccid_operations *ccid_ops)
| > +static int ccid_unregister(struct ccid_operations *ccid_ops)
| >  {
<snip>
| 
| And "register/unregister" now don't make much sense since there is no
| registration being done, just allocating/deallocating resources
| 
Yes agree - this needs revision. We can also drop the EXPORT_SYMBOLS
from the now-static routines.

| > +
| > +static struct ccid_operations *ccid_find_by_id(const u8 id)
| >  {
| > -	struct ccid *ccid = kmem_cache_alloc(rx ? ccid_ops->ccid_hc_rx_slab :
| > -						  ccid_ops->ccid_hc_tx_slab, gfp);
| > +	int i;
| > +
| > +	for (i = 0; i < ARRAY_SIZE(ccids); i++)
| > +		if (ccids[i]->ccid_id == id)
| > +			return ccids[i];
| > +	return NULL;
| 
| Why the we searching? Can't we just do:
| 
| {
| 	if (id > ARRAY_SIZE(ccids) - 2)
| 		return NULL;
| 	return ccids[id - 2];
| }
| 
Agree 100%, I don't like the routine myself and have been thinking about
how to rewrite it. Current idea is to go back to the original and use

static struct ccid_operations *ccids[CCIDS_MAX] = {
	[DCCPC_CCID2] = &ccid2_ops,
#ifdef CONFIG_IP_DCCP_CCID3
	[DCCPC_CCID3] = &ccid3_ops,
#endif
};

And then use 
	
	if (id < 0 || id >= CCIDS_MAX)
		return NULL;
	return ccids[id];		

which may be NULL if there is no entry in the array. Better?	

Gerrit
