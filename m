From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCH net-next v2 2/2] Re-check for a VIO_DESC_READY data descriptor
 after short udelay()
Date: Mon, 08 Sep 2014 09:45:56 -0400
Message-ID: <540DB314.3090809@oracle.com>
References: <20140902162029.GC31516@oracle.com> <5405EFE7.4090302@oracle.com> <20140904.223648.559995846094457545.davem@davemloft.net> <20140905134758.GB1256@oracle.com> <20140906210253.GA5710@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24578 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbaIHNqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 09:46:02 -0400
In-Reply-To: <20140906210253.GA5710@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sowmini,

On 09/06/2014 05:02 PM, Sowmini Varadhan wrote:

> Stared at this a bit over the last two days, checked
> the documentation, discussed with dls offline - looks like 
> (a) the rmb() thing was mostly a red-herring/fud 
> (b) we do need the wmb()

	I don't think this has anything to do with your patch, but my (new) concern with the
wmb() and no matching rmb() is this text from Documentation/memory-barrier.txt:

> SMP BARRIER PAIRING
> -------------------
> 
> When dealing with CPU-CPU interactions, certain types of memory barrier should
> always be paired.  A lack of appropriate pairing is almost certainly an error.

I'm no mb expert, and I know of no symptoms, but it appears to be saying that
load reordering could result in a race where the READY flag could be set with
old data in other descriptor fields due to loading them in a different order --
something it says wmb() on another CPU explicitly does not prevent.

The particular case would be adding to the ring at the same time the other side
is removing from the ring, so no locks or LDC traffic would affect it.

So, it appears to me we have a missing rmb() that is needed and I don't know what
leads you to believe it isn't.

							+-DLS
