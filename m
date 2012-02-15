From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Question with commit 299b0767(ipv6: Fix IPsec slowpath
 fragmentation problem)
Date: Wed, 15 Feb 2012 11:40:21 +0100
Message-ID: <20120215104021.GC31660@secunet.com>
References: <4F38C57F.5000706@cn.fujitsu.com>
 <20120214110414.GA31660@secunet.com>
 <4F3B57F4.10106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:59715 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758173Ab2BOKka (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 05:40:30 -0500
Content-Disposition: inline
In-Reply-To: <4F3B57F4.10106@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 15, 2012 at 03:00:04PM +0800, Li Wei wrote:
> 
> Hi Steffen,
> 
> Thank you for your reply!
> 
> I see in your patch that you use the "mtu" of &rt->dst (which taken IPSec
> into account) instead of rt->dst.path, but the "exthdrlen" and "dst_exthdrlen"
> things process IPSec again. Does some duplication there?
> 
> After reverted the patch and put some "printk" things in the slow_path of
> ip6_fragment(), setup IPSec transport mode between two hosts, when sending
> some echo request which exceeds the MTU, I don't see any "printk" in slow_path
> outputed. Could you tell me how to reproduce the slow_path things?
> 

Ok, I see what's going on. The slowpath fragmentation problem appeared
in tunnel mode. This is because commit ad0081e43a 
"ipv6: Fragment locally generated tunnel-mode IPSec6 packets as needed"
changed tunnel mode to do fragmentation before the transformation
while transport mode still does fragmentation after transformation.
Now, tunnel mode needs IPsec headers and trailer for all fragments,
while on transport mode it is sufficient to add the headers to the
first fragment and the trailer to the last.

Not quite sure what to do here. We would have the information
to check for tunnel/transport mode when we calculate the packet
lenght in ip6_append_data(), but it would look quite ugly to
search through the xfrm state bundle to figure out which mode
this is using.
