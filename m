From: Konstantinos Kolelis <k.kolelis@sirrix.com>
Subject: Re: [BUG REPORT]  Unencrypted packets after SNAT, allthough IPSEC-Policies
 are present
Date: Thu, 11 Sep 2014 15:11:17 +0200
Message-ID: <54119F75.8090305@sirrix.com>
References: <541089DD.6060307@sirrix.com> <20140911115401.GL6390@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<herbert@gondor.apana.org.au>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.sirrix.com ([176.9.214.66]:58027 "EHLO mx.sirrix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751776AbaIKNN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2014 09:13:28 -0400
In-Reply-To: <20140911115401.GL6390@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 11.09.2014 13:54, schrieb Steffen Klassert:
> On Wed, Sep 10, 2014 at 07:26:53PM +0200, Konstantinos Kolelis wrote:
>> Hi all,
>>
>> i' ve observed a problem with xfrm lookups, SNAT, blackhole route and
>> missing SAs.
>> The problem occures with all Kernels above 3.6.x and might has to do
>> with the changes in
>> ip4_blackhole_route() function in net/route.c.
> 
> Thanks for the report!
> 
> Is kernel v3.6 the first kernel with this issue? It seems that
> we have this problem already longer, at least if my analysis
> is correct.
> 

It worked until Kernel 3.4.103, i did not check with v3.5 though.

>>
>> Let say you have two network interfaces:
>> eth0 with ip 172.16.0.10/24
>> and
>> eth1 with ip 192.168.0.1/24
>>
>> and you have done the following configuration:
>>
>> iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j SNAT --to-source
>> 172.16.0.10
>>
>> and
>>
>> ip xfrm policy add dir out  src 172.16.0.10 dst 0.0.0.0/0 tmpl proto esp
>> src 172.16.0.10 dst 172.31.0.10 mode tunnel
>>
>> with the following routes:
>> default via 172.16.0.1 dev eth0  proto static
>> 172.16.0.0/24 dev eth0  proto kernel  scope link  src 172.16.0.10
>> 192.168.0.0/24 dev eth1  proto kernel  scope link  src 192.168.0.1
>>
>> If for what ever reason IPSEC-SAs can not be established, maybe because
>> 172.31.0.10 is down,
>> the traffic comming from 192.168.0.0/24 will leave unencrypted the
>> external (eth0) interface.
> 
> I can reproduce it with SNAT and MASQUERADE. Looks like this was
> introduced back in 2011 with git commit 2774c131 ("xfrm: Handle
> blackhole route creation via afinfo.").
> 
> Before that commit, xfrm_lookup() and __xfrm_lookup() returned
> an error if we have a matching policy but no states. The route
> lookup functions used __xfrm_lookup() and generated a blackhole
> route if __xfrm_lookup() returned -EREMOTE. All other functions
> used xfrm_lookup() which returned -EAGAIN. This was treated as
> as an error and the packet was dropped immediately.
> 
> After this commit all callers to xfrm_lookup() rely that
> dst_output() is called afterwards. This seems to be not the
> case, at least when postrouting nat is used.
> 
> Maybe we should go back to let only the route lookup functions
> genarate a blackhole route. Everyone else should better drop
> the packets immediately.
> 
> I'll try to do a patch.
> 

You should also check what happens if xfrm_larval_drop is false.
Allthough blackhole route was not used, you could still run into the
same problem. It just took a while longer.
