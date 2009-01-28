From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] NetEffect, iw_nes and kernel warning
Date: Wed, 28 Jan 2009 13:52:15 -0800
Message-ID: <adawscfumi8.fsf@cisco.com>
References: <497EF9AC.70104@poczta.onet.pl> <adawscgwbkj.fsf@cisco.com>
	<20090127.160750.120120703.davem@davemloft.net>
	<adaljsvwbkm.fsf@cisco.com> <20090128110514.2191c7a8@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	general@lists.openfabrics.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:36561 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283AbZA1VwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 16:52:16 -0500
In-Reply-To: <20090128110514.2191c7a8@extreme> (Stephen Hemminger's message of
	"Wed, 28 Jan 2009 11:05:14 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > > OK, thanks... what confused me is that several other drivers also do
 > > skb_linearize() in their hard_start_xmit method... eg bnx2x,
 > > via-velocity, mv643xx_eth.  So there are several other lurking bugs to
 > > deal with here I guess.

 > They all look like lurking (and untested) bug paths. mv643xx is especially
 > bad since it can leak skb. But it should be possible to call pull_tail
 > if bh is disabled (as long as irqs are enabled).

Yes.  The only obvious problem with __pskb_pull_tail() with BHs disabled
is that with CONFIG_HIGHMEM set, it goes into kmap_skb_frag(), which
then unconditionally does local_bh_disable()/local_bh_enable().  There's
no reason in principle that kmap_skb_frag() couldn't do
local_save_flags()/local_restore_flags() instead.

Just grepping around I see other potential issues related to this, for
example the (unused but exported) function fcoe_fc_crc() does
kmap_atomic(KM_SKB_DATA_SOFTIRQ) without any particular BH disabling,
which might run into trouble if used in the wrong context...

 - R.
