From: Adam Baker <linux@baker-net.org.uk>
Subject: Re: [Patch net-next v5 1/3] bridge: use the bridge IP addr as source
 addr for querier
Date: Sat, 25 May 2013 21:52:24 +0100
Message-ID: <51A12488.7080203@baker-net.org.uk>
References: <1369209176-6841-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from anakin.london.02.net ([87.194.255.134]:49388 "EHLO
	anakin.london.02.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758016Ab3EYU6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 May 2013 16:58:36 -0400
In-Reply-To: <1369209176-6841-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/05/13 08:52, Cong Wang wrote:
> From: Cong Wang<amwang@redhat.com>
>
> Quote from Adam:
> "If it is believed that the use of 0.0.0.0
> as the IP address is what is causing strange behaviour on other devices
> then is there a good reason that a bridge rather than a router shouldn't
> be the active querier? If not then using the bridge IP address and
> having the querier enabled by default may be a reasonable solution
> (provided that our querier obeys the election rules and shuts up if it
> sees a query from a lower IP address that isn't 0.0.0.0). Just because a
> device is the elected querier for IGMP doesn't appear to mean it is
> required to perform any other routing functions."
>
> And introduce a new troggle for it, as suggested by Herbert.

I've now tested this series applied to a 3.9.4 kernel

Using wireshark I can see that if the multicast_querier and 
multicast_query_use_ifaddr flags are set then queries do get the correct 
IP address in them and if multicast_querier is set and 
multicast_query_use_ifaddr isn't we get queries with the address set to 
0.0.0.0

I next tested with 2 bridges configured on different nodes (this is my 
normal network configuration with the 2 bridge devices acting as 
wireless routers with different coverage areas with a wired network 
between them). If multicast_query_use_ifaddr is set whichever device 
starts querying first will act as the querier and the other will shut 
up. According to RFC 2236 it should be the device with the lower IP 
address that ends up as the querier in that scenario but I can't imagine 
a situation where that exact behaviour matters

If multicast_query_use_ifaddr is not set but multicast_querier is then 
both bridges end up generating queries with a source address of 0.0.0.0. 
Whilst this results in a small amount of unnecessary network traffic it 
does provide a functional setup.

In all of these cases I also verified that multicast UPnP AV 
applications on different network segments remain able to talk to each 
other.

I would therefore suggest that making multicast_query_use_ifaddr the 
default and making the querier only shut up if it sees a query from a 
lower non zero address rather than any non zero address would constitute 
minor improvements to this patch but as it stands it is still an 
improvement on the current behaviour.

Tested-By: Adam Baker <linux@baker-net.org.uk>
