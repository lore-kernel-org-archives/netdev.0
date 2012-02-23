From: Arun Sharma <asharma@fb.com>
Subject: Re: route add default fails with ESRCH?
Date: Wed, 22 Feb 2012 17:26:26 -0800
Message-ID: <4F4595C2.8000809@fb.com>
References: <alpine.LFD.2.00.1202222319150.1603@ja.ssi.bg> <4F45638B.30305@fb.com> <4F45742F.1070605@fb.com> <20120222.185625.1452176745900047968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ja@ssi.bg>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:49133 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752978Ab2BWB0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 20:26:40 -0500
In-Reply-To: <20120222.185625.1452176745900047968.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/22/12 3:56 PM, David Miller wrote:
>
> It breaks because that script sequence quoted above depends upon the
> order in which the routes are listed.  Since fib_hash and fib_trie use
> different datastructures, the order in which route entries are dumped
> will not be the same and this is completely unavoidable.

Here's a minimal repro case:

# ip route flush default
# route add default gw 192.168.143.2
SIOCADDRT: No such process

This fails for me on both 2.6.38 and 3.2.

I think the dependency we have is the actual format of the default route 
entry:

fib_hash:

# ip route
<bunch of routes>
throw default

fib_trie:

# ip route
default via 192.168.143.2 dev eth0  proto static
<bunch of routes>

when the output was piped to awk '{ print $1 }' we ended up deleting the 
default route for fib_trie case, but not the fib_hash case.

I'll just fix up our scripts. Thanks for looking into it.

  -Arun
