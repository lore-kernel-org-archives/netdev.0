From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH] IPv6: only modify checksum for UDP
Date: Tue, 14 Nov 2006 01:18:33 +0000
Message-ID: <20061114011833.GV29920@ftp.linux.org.uk>
References: <4554A7CD.6040907@hp.com> <OFF1265537.E903A772-ON88257222.006212AE-88257222.00626AB7@us.ibm.com> <20061113.165058.15265737.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dlstevens@us.ibm.com, brian.haley@hp.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:443 "EHLO ZenIV.linux.org.uk")
	by vger.kernel.org with ESMTP id S1755213AbWKNBSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Nov 2006 20:18:37 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061113.165058.15265737.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 13, 2006 at 04:50:58PM -0800, David Miller wrote:
> From: David Stevens <dlstevens@us.ibm.com>
> Date: Fri, 10 Nov 2006 09:54:58 -0800
> 
> > The Internet checksum is defined as a 1's-complement sum, so if  the
> > alternate 0 does not have a special meaning in a protocol, then by
> > 1's-complement arithmetic, 0 == ~0.

Nope.  It isn't.

> >         So, it looks to me without the remapping that a valid checksum
> > may also fail, if it is simply computed in a different way (or on a 
> > different
> > architecture) such that one gets 0 and one gets ~0 as un-modified answers.
> >         Since we're checking for equality on 2's-complement machines,
> > I think the easiest thing is to still re-map it. Otherwise, instead of 
> > testing
> > for 0, we have to test for both 0 and ~0 in the validity checks, right?
> 
> Puzzling :-)  Then why is the transformation only performed for
> UDP in the ipv4 stack?  It seems by your logic TCP would need
> to either do the "if (sum==0) sum=~0;"  thing or it would need
> to accept both "0" and "~0" in the checksum checking path.

The check is "1's compelement sum of entire packet (including the checksum)
is 0xffff".  So unless *everything* *else* in the packet is 0, 0x0000 and
0xffff in checksum are the same.  And for very obvious reasons "everything
else is 0" won't be recognized as valid packet anyway...

The following is true:
	for any x except 0 we have x # 0xffff equal to x
	for any x we have x # 0 equal to x
	x # y is 0 if and only if both x and y are 0.

So unless the sum of all words except the checksum is 0 (i.e. all words
are except the checksum are 0), 0 and 0xffff in checksum will result in
the same total sums.
