From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Wed, 21 Dec 2011 11:03:54 +0000
Message-ID: <1324465434.7877.11.camel@zakaz.uk.xensource.com>
References: <1323177878.2448.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1323264929.23681.178.camel@zakaz.uk.xensource.com>
	 <1323438427.20077.57.camel@zakaz.uk.xensource.com>
	 <20111209.133407.2156473837364120429.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"jesse.brandeburg@intel.com" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:50390 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782Ab1LULD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 06:03:56 -0500
In-Reply-To: <20111209.133407.2156473837364120429.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-12-09 at 18:34 +0000, David Miller wrote:
> From: Ian Campbell <Ian.Campbell@citrix.com>
> Date: Fri, 9 Dec 2011 13:47:07 +0000
> 
> > If we had a concept like MAX_SKB_PAGES then it would perhaps make
> > sense to have + 2 there, but AFAICT drivers etc are already
> > accounting for this appropriately by adding a further + 2 (or
> > sometimes + 1) to MAX_SKB_FRAGS.
> 
> Any kind of code like this, including the "+ 2" in the skbuff header,
> should be coded to use some kind of macro so we can track this
> dependency instead of stumbling onto it and accidently breaking lots
> of stuff if we want to change this "2" value.

Agreed.

Part of the problem is that no one seems to have any idea what this
particular + 2 means. My best hypothesis is that it accounts for the
pages used by the linear area (which potentially crosses a page
boundary).

On that basis I propose to do the following + a sweep of the tree to
determine who means which. There's quite a lot of MAX_SKB_FRAGS in the
tree but based on quick inspection many are related specifically to the
bounds of the frags list and so don't need to change.

        /* To allow 64K frame to be packed as single skb without frag_list. Since
         * GRO uses frags we allocate at least 16 regardless of page size.
         */
        #if (65536/PAGE_SIZE) < 16
        #define MAX_SKB_FRAGS 16UL
        #else
        #define MAX_SKB_FRAGS (65536/PAGE_SIZE)
        #endif
        
        /* The linear area can cross a page boundary */
        #define MAX_SKB_HEAD_PAGES 2UL
        #define MAX_SKB_PAGES (MAX_SKB_FRAGS + MAX_SKB_HEAD_PAGES)

This means that MAX_SKB_FRAGS will shrink by 2. The new symbol
MAX_SKB_PAGES will have the old value of MAX_SKB_FRAGS.

I'm also considering getting rid of the #if since I don't think we
support pages < 4K on any arch, do we?

To aid sequencing the transition it might be best to go with
MAX_SKB_FRAGS (16 + 2) and MAX_SKB_HEADER_PAGES (0) first, then convert
everyone to use the one they really meant and finally move the 2 from
SKB_FRAGS to SKB_HEADER_PAGES. I need to think about that.

Some drivers currently use MAX_SKB_FRAGS + 1 which I think is accounting
for the linear area in cases where the hardware cannot receive one cross
a page boundary. I'm considering defining MIN_SKB_HEAD_PAGES to use in
these circumstances.

Ian.
