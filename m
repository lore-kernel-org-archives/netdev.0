From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCHv1 2/2] xen-netback: unref frags when
 handling a from-guest skb with a frag list
Date: Wed, 4 Mar 2015 10:02:01 +0000
Message-ID: <1425463321.25940.103.camel@citrix.com>
References: <1425399971-27630-1-git-send-email-david.vrabel@citrix.com>
		<1425399971-27630-3-git-send-email-david.vrabel@citrix.com>
	 <1425462482.25940.93.camel@citrix.com> <54F6D6EB.5020104@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Wei Liu <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:9693 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932776AbbCDKCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 05:02:04 -0500
In-Reply-To: <54F6D6EB.5020104@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-04 at 09:56 +0000, David Vrabel wrote:
> On 04/03/15 09:48, Ian Campbell wrote:
> > On Tue, 2015-03-03 at 16:26 +0000, David Vrabel wrote:
> >> Every time a VIF is destroyed up-to 256 pages may be leaked if packets
> >> with more than MAX_SKB_FRAGS frags where transmitted from the guest.
> >> Even worse, if another user of ballooned pages allocated one of these
> >> ballooned pages it would not handle the the unexpectedly non-zero page
> >> count (e.g., gntdev would deadlock when unmapping a grant because the
> >> page count would never reach 1).
> >>
> >> When handling a from-guest skb with a frag list, unref the frags
> >> before releasing them so they are freed correctly when the VIF is
> >> destroyed.
> > 
> > Am I right that the majority of the first 2 hunks (and various bits of
> > the 3rd) are just switching the outer loop to nr_frags instead of i, to
> > free up i for use in the new code below? And also to switch j to the now
> > available i in the inner loop.
> 
> Yes.  If you prefer I can split this into one patch that adds the
> skb_frag_unref() calls and one that reorders/refactors.

If you can be bothered that might make things easier to read, thanks.


> >> Also swap over to the new (local) frags /after/ calling the skb
> >> destructor.  This isn't strictly necessary but it's less confusing.
> > 
> > My only concern would be that this now means there is a period where the
> > frags list is invalid. However I think the calling context is such that
> > nobody else can have a reference to an skb which has the same shinfo as
> > the one in our hand. Is that right?
> 
> That is correct.  This skb is allocated by netback and has not yet been
> passed up to the network stack.

Phew! ;-)
