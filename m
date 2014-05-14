From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: xen-netfront possibly rides the rocket too often
Date: Wed, 14 May 2014 20:49:40 +0100
Message-ID: <5373C8D4.2010803@citrix.com>
References: <537262AB.5010408@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
To: Stefan Bader <stefan.bader@canonical.com>,
	<xen-devel@lists.xenproject.org>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:61646 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118AbaENTtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 15:49:42 -0400
In-Reply-To: <537262AB.5010408@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/05/14 19:21, Stefan Bader wrote:
> We had reports about this message being seen on EC2 for a while but finally a
> reporter did notice some details about the guests and was able to provide a
> simple way to reproduce[1].
>
> For my local experiments I use a Xen-4.2.2 based host (though I would say the
> host versions are not important). The host has one NIC which is used as the
> outgoing port of a Linux based (not openvswitch) bridge. And the PV guests use
> that bridge. I set the mtu to 9001 (which was seen on affected instance types)
> and also inside the guests. As described in the report one guests runs
> redis-server and the other nodejs through two scripts (for me I had to do the
> two sub.js calls in separate shells). After a bit the error messages appear on
> the guest running the redis-server.
>
> I added some debug printk's to show a bit more detail about the skb and got the
> following (<length>@<offset (after masking off complete pages)>):
>
> [ 698.108119] xen_netfront: xennet: skb rides the rocket: 19 slots
> [ 698.108134] header 1490@238 -> 1 slots
> [ 698.108139] frag #0 1614@2164 -> + 1 pages
> [ 698.108143] frag #1 3038@1296 -> + 2 pages
> [ 698.108147] frag #2 6076@1852 -> + 2 pages
> [ 698.108151] frag #3 6076@292 -> + 2 pages
> [ 698.108156] frag #4 6076@2828 -> + 3 pages
> [ 698.108160] frag #5 3038@1268 -> + 2 pages
> [ 698.108164] frag #6 2272@1824 -> + 1 pages
> [ 698.108168] frag #7 3804@0 -> + 1 pages
> [ 698.108172] frag #8 6076@264 -> + 2 pages
> [ 698.108177] frag #9 3946@2800 -> + 2 pages
> [ 698.108180] frags adding 18 slots
>
> Since I am not deeply familiar with the networking code, I wonder about two things:
> - is there something that should limit the skb data length from all frags
>    to stay below the 64K which the definition of MAX_SKB_FRAGS hints?
I think netfront should be able to handle 64K packets at most.
> - is multiple frags having offsets expected?
Yes, since compound pages a frag could over the 4K page boundary. The 
problem is, that in the netback/front protocol the assumption is that 
every slot is a single page, because grant operations could be done only 
on a 4K page. And every slot ends up as a frag (expect maybe the first, 
it can happen it is grant copied straight to the linear buffer), 
therefore the frontend cannot send an skb which occupies more than 
MAX_SKB_FRAGS individual 4k page.
The problem is known for a while, the solution is not, unfortunately.
>
> The latter is the problem here. If I did the maths right, the overall data size
> is around 41K. But since frags 1,4,5, and 9 have an offset big enough to require
> an additional page, the overall slot count goes up to 19.
>
> If such a layout is valid, maybe the xen-netfront driver needs to reduce its
> XEN_NETIF_MAX_TX_SIZE which currently is set to 64K? Or something else...
>
> -Stefan
>
> [1] https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1317811
>
