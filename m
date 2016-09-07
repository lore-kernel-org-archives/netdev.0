From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v5 nf] netfilter: seqadj: Drop the packet directly when
 fail to add seqadj extension to avoid dereference NULL pointer later
Date: Wed, 7 Sep 2016 11:18:59 +0200
Message-ID: <20160907091859.GA10315@salvia>
References: <1473173035-2175-1-git-send-email-fgao@ikuai8.com>
 <20160906145117.GB20188@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fgao@ikuai8.com, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59682 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757189AbcIGJTL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 05:19:11 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id E922D2273CE
        for <netdev@vger.kernel.org>; Wed,  7 Sep 2016 11:19:08 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D49CF1150D1
        for <netdev@vger.kernel.org>; Wed,  7 Sep 2016 11:19:08 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E626B114D63
        for <netdev@vger.kernel.org>; Wed,  7 Sep 2016 11:19:04 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20160906145117.GB20188@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 06, 2016 at 04:51:17PM +0200, Florian Westphal wrote:
> fgao@ikuai8.com <fgao@ikuai8.com> wrote:
> > From: Gao Feng <fgao@ikuai8.com>
> > 
> > When memory is exhausted, nfct_seqadj_ext_add may fail to add the seqadj
> > extension. But the function nf_ct_seqadj_init doesn't check if get valid
> > seqadj pointer by the nfct_seqadj.
> > 
> > Now drop the packet directly when fail to add seqadj extension to avoid
> > dereference NULL pointer in nf_ct_seqadj_init.
> > 
> > Signed-off-by: Gao Feng <fgao@ikuai8.com>
> > ---
> >  v5: Return NF_ACCEPT instead of NF_DROP when nfct_seqadj_ext_add failed in nf_nat_setup_info
> >  v4: Drop the packet directly when fail to add seqadj extension;
> >  v3: Remove the warning log when seqadj is null;
> >  v2: Remove the unnessary seqadj check in nf_ct_seq_adjust
> >  v1: Initial patch
> > 
> >  net/netfilter/nf_conntrack_core.c | 6 +++++-
> >  net/netfilter/nf_nat_core.c       | 3 ++-
> >  2 files changed, 7 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> > index dd2c43a..dfa76ce 100644
> > --- a/net/netfilter/nf_conntrack_core.c
> > +++ b/net/netfilter/nf_conntrack_core.c
> > @@ -1036,7 +1036,11 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
> >  		return (struct nf_conntrack_tuple_hash *)ct;
> >  
> >  	if (tmpl && nfct_synproxy(tmpl)) {
> > -		nfct_seqadj_ext_add(ct);
> > +		if (!nfct_seqadj_ext_add(ct)) {
> > +			nf_conntrack_free(ct);
> > +			pr_debug("Can't add seqadj extension\n");
> > +			return NULL;
> > +		}
> 
> if (!nfct_add_synrpxy(ct, tmpl)) {
> 	nf_conntrack_free(ct);
> 	return NULL;
> }
> 
> static bool nf_ct_add_synproxy(struct nf_conn *ct, const struct nf_conn *tmpl)
> {
> 	if (tmpl && nfct_synproxy(tmpl)) {
> 		if (!nfct_seqadj_ext_add(ct))
> 			return false;
> 
> 		if (!nfct_synproxy_ext_add(ct))
> 			return false;
> 	}
> 
> 	return true;
> }

I like this helper idea, please send a v6 using this using what
Florian is proposing.

> > diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
> > index de31818..f8b916a 100644
> > --- a/net/netfilter/nf_nat_core.c
> > +++ b/net/netfilter/nf_nat_core.c
> > @@ -441,7 +441,8 @@ nf_nat_setup_info(struct nf_conn *ct,
> >  			ct->status |= IPS_DST_NAT;
> >  
> >  		if (nfct_help(ct))
> > -			nfct_seqadj_ext_add(ct);
> > +			if (!nfct_seqadj_ext_add(ct))
> > +				return NF_ACCEPT;
> >  	}
> 
> Hmm, why accept?
> 
> We are asked to add extension to rewrite sequence numbers, but
> we cannot.  How can the connection work if we cannot munge/track
> seqno rewrites?

Actually we could just NF_DROP, but if we add support for ctnetlink to
inject entries with sequence adjustment with no NAT. I think we need
this to get synproxy working with conntrackd state synchronization.

Thanks!
