From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH 2/2] xen: netfront: Drop GSO SKBs which do not have
 csum_blank.
Date: Wed, 26 Jan 2011 11:56:21 +0000
Message-ID: <1296042981.14780.6813.camel@zakaz.uk.xensource.com>
References: <1295975376.14780.6595.camel@zakaz.uk.xensource.com>
	 <1295975400-538-2-git-send-email-ian.campbell@citrix.com>
	 <20110125.194405.226769333.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "jeremy@goop.org" <jeremy@goop.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:30371 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487Ab1AZL4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 06:56:24 -0500
In-Reply-To: <20110125.194405.226769333.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-01-26 at 03:44 +0000, David Miller wrote:
> From: Ian Campbell <ian.campbell@citrix.com>
> Date: Tue, 25 Jan 2011 17:10:00 +0000
> 
> > The Linux network stack expects all GSO SKBs to have ip_summed ==
> > CHECKSUM_PARTIAL (which implies that the frame contains a partial
> > checksum) and the Xen network ring protocol similarly expects an SKB
> > which has GSO set to also have NETRX_csum_blank (which also implies a
> > partial checksum). Therefore drop such frames on receive otherwise
> > they will trigger the warning in skb_gso_segment.
> > 
> > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> 
> The GSO code does in fact warn in the logs about this situation, but
> it _DOES NOT_ drop the packet.  Therefore, either you guys should do
> the same or we should make the generic code drop too.

Ah, yes. I misread the handling of an error from pskb_expand_head() in
skb_gso_segment() and thought it was a more general error return
covering the entire case.

> I think the generic code is doing the right thing, therefore what you
> should probably do is put the checksum of the SKB into the right state
> when you detect this situation (and perhaps bump a ethtool driver
> local statistic which specifically tracks this exact event).

Yes, I think this is a good idea. I'll come up with a patch which does
this.

> Or, even better, you should fix whatever causes this in the first
> place.

Sure, that has already been done but the proper fix is in another guest,
with a secondary robustness fix in netback (similar to this one, so I'll
take your advice from above on board in that context too).

The intention here was to be robust in the face of unfixed guests
sharing the same host or future netback bugs etc.

> Dropping frames ought to be the last option, stuff like this is
> impossible to debug if someone starts wondering why they are getting
> frame drops.
> 
> You don't even account for this in a unique statistic somewhere, so
> people can figure out the actual spcific _reason_ for the drop.  They
> will just see "rx_error" and scratch their heads.
> 
> Anyways, I think dropping is fundamentally wrong, so I'm not applying
> this.

You've convinced me too, thanks for the feedback.

Thanks,
Ian.

