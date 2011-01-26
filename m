From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] xen: netfront: Drop GSO SKBs which do
 not have csum_blank.
Date: Tue, 25 Jan 2011 19:44:05 -0800 (PST)
Message-ID: <20110125.194405.226769333.davem@davemloft.net>
References: <1295975376.14780.6595.camel@zakaz.uk.xensource.com>
	<1295975400-538-2-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeremy@goop.org, xen-devel@lists.xensource.com
To: ian.campbell@citrix.com
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1295975400-538-2-git-send-email-ian.campbell@citrix.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

From: Ian Campbell <ian.campbell@citrix.com>
Date: Tue, 25 Jan 2011 17:10:00 +0000

> The Linux network stack expects all GSO SKBs to have ip_summed ==
> CHECKSUM_PARTIAL (which implies that the frame contains a partial
> checksum) and the Xen network ring protocol similarly expects an SKB
> which has GSO set to also have NETRX_csum_blank (which also implies a
> partial checksum). Therefore drop such frames on receive otherwise
> they will trigger the warning in skb_gso_segment.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>

The GSO code does in fact warn in the logs about this situation, but
it _DOES NOT_ drop the packet.  Therefore, either you guys should do
the same or we should make the generic code drop too.

I think the generic code is doing the right thing, therefore what you
should probably do is put the checksum of the SKB into the right state
when you detect this situation (and perhaps bump a ethtool driver
local statistic which specifically tracks this exact event).

Or, even better, you should fix whatever causes this in the first
place.

Dropping frames ought to be the last option, stuff like this is
impossible to debug if someone starts wondering why they are getting
frame drops.

You don't even account for this in a unique statistic somewhere, so
people can figure out the actual spcific _reason_ for the drop.  They
will just see "rx_error" and scratch their heads.

Anyways, I think dropping is fundamentally wrong, so I'm not applying
this.
