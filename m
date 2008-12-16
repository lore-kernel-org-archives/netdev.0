From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
	negotiation
Date: Tue, 16 Dec 2008 06:44:16 +0100
Message-ID: <20081216054416.GB6199@gerrit.erg.abdn.ac.uk>
References: <20081208.011917.176472177.davem@davemloft.net> <1229175685-18716-1-git-send-email-gerrit@erg.abdn.ac.uk> <1229175685-18716-2-git-send-email-gerrit@erg.abdn.ac.uk> <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk> <20081215134822.GD4775@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, davem@davemloft.net,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:50610 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750787AbYLPFol (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2008 00:44:41 -0500
Content-Disposition: inline
In-Reply-To: <20081215134822.GD4775@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > +/**
| > + * ccid_request_module  -  Pre-load CCID module for later use
| > + * This should be called only from process context (e.g. during connection
| > + * setup) and is necessary for later calls to ccid_new (typically in software
| > + * interrupt), so that it has the modules available when they are needed.
| > + */
| > +static int ccid_request_module(u8 id)
| > +{
| > +	if (!in_atomic()) {
| 
| Shouldn't the above be in a BUG_ON? It looks strange to simply refuse to
| do that and return OK. 
| 
| > +		ccids_read_lock();
| > +		if (ccids[id] == NULL) {
| > +			ccids_read_unlock();
| > +			return request_module("net-dccp-ccid-%d", id);
| > +		}
| > +		ccids_read_unlock();
| > +	}
| > +	return 0;
| > +}
We can do this if you want, but in a way this is a suggestion for the
existing code, compare with the original from ccid_new() below

	ccids_read_lock();
#ifdef CONFIG_MODULES
	if (ccids[id] == NULL) {
		/* We only try to load if in process context */
		ccids_read_unlock();
		if (gfp & GFP_ATOMIC)
			goto out;
		request_module("net-dccp-ccid-%d", id);
		ccids_read_lock();
	}
#endif

==> gfp is atomic when called from dccp_feat_update_ccid(), which is why
    in the previous feature-negotiation code DCCP crashed when trying to
    negotiate any CCID module that had not been loaded:
    
	new_ccid = ccid_new(new_ccid_nr, sk, rx, GFP_ATOMIC);

    meant that the module would not be reloaded.

==> On the other hand, when called via ccid_hc_{rx,tx}_new(), gfp=GFP_KERNEL
    and so an attempted module load would succeed. This explains why loading
    worked when starting with the default (non-negotiated) CCIDs.



==> So how do we remain? I am ok turning the above into a BUG_ON.
    As an alternative, since the function is only called in a single
    place (the initialisation of feat.c), we could consider removing the
    function entirely and merge its contents into dccp_feat_init().
    Would that be better?
