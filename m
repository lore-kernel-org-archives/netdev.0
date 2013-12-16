From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2 2/9] xen-netback: Change TX path from grant
 copy to mapping
Date: Mon, 16 Dec 2013 18:21:39 +0000
Message-ID: <20131216182138.GD25969@zion.uk.xensource.com>
References: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com>
 <1386892097-15502-3-git-send-email-zoltan.kiss@citrix.com>
 <20131213153612.GM21900@zion.uk.xensource.com>
 <52AF1E5D.20801@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52AF1E5D.20801@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 16, 2013 at 03:38:05PM +0000, Zoltan Kiss wrote:
[...]
> >>+	for (i = 0; i < MAX_PENDING_REQS; ++i) {
> >>+		if (vif->grant_tx_handle[i] != NETBACK_INVALID_HANDLE) {
> >>+			i = 0;
> >>+			unmap_timeout++;
> >>+			msleep(1000);
> >>+			if (unmap_timeout > 9 &&
> >>+				net_ratelimit())
> >>+				netdev_err(vif->dev,
> >>+					"Page still granted! Index: %x\n", i);
> >>+		}
> >>+	}
> >>+
> >>+	free_xenballooned_pages(MAX_PENDING_REQS, vif->mmap_pages);
> >>+
> >
> >If some pages are stuck and you just free them will it cause Dom0 to
> >crash? I mean, if those pages are recycled by other balloon page users.
> >
> >Even if it will not cause Dom0 to crash, will it leak any resource in
> >Dom0? At plain sight it looks like at least grant table entry is leaked,
> >isn't it? We need to be careful about this because a malicious might be
> >able to DoS Dom0 with resource leakage.
> Yes, if we call free_xenballooned_pages while something is still
> mapped, Xen kills Dom0 because balloon driver tries to touch the PTE
> of a grant mapped page. That's why we make sure before that
> everything is unmapped, and repeat an error message if it's not. I'm

The code snippet above doesn't loop ten times over the whole array if
there's stale pages found, nor does it loop ten times on any stale
pages.

So imagine that we have the very last page in the array staled. This
routine sleeps for 1 second then free all ballooned pages. It's still
not guaranteed at the point we call free_xenballooned_pages all pages
are unmapped, right?

> afraid we can't do anything better here, that means a serious
> netback bug.
> But a malicious guest cannot take advantage of this unless it's find
> a way to screw up netback's internal bookkeeping. Then it can block
> here indefinitely the teardown of the VIF, and it's associated
> resources.
> 

OK.

Wei.
