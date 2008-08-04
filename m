From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Warning when unloading the nf_conntack module (regression?)
Date: Mon, 4 Aug 2008 22:56:49 +0100
Message-ID: <20080804215649.GZ28946@ZenIV.linux.org.uk>
References: <20080803143730.7747e9a8@infradead.org> <Pine.LNX.4.64.0808032344510.16818@bizon.gios.gov.pl> <Pine.LNX.4.64.0808042027080.4338@bizon.gios.gov.pl> <Pine.LNX.4.64.0808042039400.4338@bizon.gios.gov.pl> <Pine.LNX.4.64.0808042130570.23688@bizon.gios.gov.pl> <20080804200058.GX28946@ZenIV.linux.org.uk> <20080804203021.GY28946@ZenIV.linux.org.uk> <Pine.LNX.4.64.0808042258370.29400@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@vger.kernel.org,
	kaber@trash.net
To: Krzysztof Oledzki <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:51277 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764727AbYHDV4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 17:56:53 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0808042258370.29400@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 04, 2008 at 11:16:07PM +0200, Krzysztof Oledzki wrote:

> Solves partially: no more WARNING, however entries are still missing & 
> duplicated:
>
> # sysctl -a 2>/dev/null|grep net.netfilter
> net.netfilter.nf_conntrack_generic_timeout = 600
> net.netfilter.nf_conntrack_acct = 1
> net.netfilter.nf_conntrack_generic_timeout = 600
> net.netfilter.nf_conntrack_acct = 1

Very interesting.  Could you see at which point duplicates appear?  I.e.
in which sequence do you get registrations, at least on the level of "this
module is loaded first, no duplicates, this one comes after, etc."

	... ah, hell.  I see what's going on.  The trouble is in
nf_conntrack_standalone; you get a table that has _both_ net.netfilter.* and
net.nf_conntrack_max, which means that it's attached to unified tree at
net; if we already have something with net.netfilter, you've got trouble -
which entry net.netfilter will come from?

_All_ this crap comes from lousy historical API; it's too much for this
cycle, but for .28 I'm going to clean that mess up.  For now, split that
table in two and register them separately.  I.e. register nf_ct_sysctl_table[]
at nf_net_netfilter_sysctl_path *and* remove the "netfilter" entry from
nf_ct_netfilter_table[].

I'm really going down right now; will follow up after I get some sleep...
