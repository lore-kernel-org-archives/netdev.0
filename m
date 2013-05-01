From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH V5 6/7] xen-netback: coalesce slots in TX
 path and fix regressions
Date: Wed, 1 May 2013 10:22:11 +0100
Message-ID: <20130501092211.GA9780@zion.uk.xensource.com>
References: <1366045581-31349-1-git-send-email-wei.liu2@citrix.com>
 <1366045581-31349-7-git-send-email-wei.liu2@citrix.com>
 <51800809.9070407@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	"jbeulich@suse.com" <jbeulich@suse.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>
To: annie li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:12349 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757143Ab3EAJWM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 May 2013 05:22:12 -0400
Content-Disposition: inline
In-Reply-To: <51800809.9070407@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 30, 2013 at 07:06:01PM +0100, annie li wrote:
> 
> On 2013-4-15 13:06, Wei Liu wrote:
> > This patch tries to coalesce tx requests when constructing grant copy
> > structures. It enables netback to deal with situation when frontend's
> > MAX_SKB_FRAGS is larger than backend's MAX_SKB_FRAGS.
> >
> > With the help of coalescing, this patch tries to address two regressions and
> > avoid reopening the security hole in XSA-39.
> >
> > Regression 1. The reduction of the number of supported ring entries (slots)
> > per packet (from 18 to 17). This regression has been around for some time but
> > remains unnoticed until XSA-39 security fix. This is fixed by coalescing
> > slots.
> >
> > Regression 2. The XSA-39 security fix turning "too many frags" errors from
> > just dropping the packet to a fatal error and disabling the VIF. This is fixed
> > by coalescing slots (handling 18 slots when backend's MAX_SKB_FRAGS is 17)
> > which rules out false positive (using 18 slots is legit) and dropping packets
> > using 19 to `max_skb_slots` slots.
> >
> > To avoid reopening security hole in XSA-39, frontend sending packet using more
> > than max_skb_slots is considered malicious.
> >
> > The behavior of netback for packet is thus:
> >
> >      1-18            slots: valid
> >     19-max_skb_slots slots: drop and respond with an error
> >     max_skb_slots+   slots: fatal error
> >
> > max_skb_slots is configurable by admin, default value is 20.
> >
> > Also change variable name from "frags" to "slots" in netbk_count_requests.
> >
> > Please note that RX path still has dependency on MAX_SKB_FRAGS. This will be
> > fixed with separate patch.
> 
> Wei,
> 
> The RX path dependency on MAX_SKB_FRAGS in netback should not cause 
> packet dropping issue like TX path, RX path only calls netif_stop_queue 
> if RX ring is full.
> What is your plan on RX path? Is it in your schedule or you started it 
> already?
> 

Not yet planned or started. My general idea is that we need to remove
all dependency on MAX_SKB_FRAGS.

I'm working on bug fix for libxl now, so I might get to that later.


Wei.

> Thanks
> Annie
