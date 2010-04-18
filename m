From: Franco Fichtner <franco@lastsummer.de>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Sun, 18 Apr 2010 12:06:24 +0100
Message-ID: <4BCAE7B0.6070200@lastsummer.de>
References: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com> 	<20100415.233334.242114544.davem@davemloft.net> <1271401007.16881.3762.camel@edumazet-laptop> 	<l2m65634d661004161135h1c1466afi54787022bfc2ce12@mail.gmail.com> 	<1271443994.16881.4249.camel@edumazet-laptop> <u2t65634d661004161342zeadb5602w73c369ec717dc6e1@mail.gmail.com> 	<1271452358.16881.4486.camel@edumazet-laptop> <1271520633.16881.4754.camel@edumazet-laptop> 	<h2h65634d661004171038g75160e7avae118dfd1cb1441d@mail.gmail.com> <h2q412e6f7f1004171706w905cc5c8u51f82cad221642f4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.kissl.de ([213.239.241.64]:53570 "EHLO host64.kissl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756576Ab0DRK2p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Apr 2010 06:28:45 -0400
In-Reply-To: <h2q412e6f7f1004171706w905cc5c8u51f82cad221642f4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> On Sun, Apr 18, 2010 at 1:38 AM, Tom Herbert <therbert@google.com> wrote:
>   
>> That's cool!, but I still like the idea that this hash is treated as
>> an opaque value getting the hash from the device to avoid the jhash
>> or cache misses on the packet can also be a win...  Maybe connection
>> tracking/firewall could use the skb->rxhash which provides the
>> consistency and also eliminates the need to do more jhashes.
>>
>>     
>
> consistent rxhash only adds the risk of the hash collision, and I
> don't think it is a big problem. For connection tracking/firewall use,
> I am afraid that we have to recompute this value after defrag.  So we
> have to export the hash function we used in RPS.
>
> As NIC's hash function can be changed dynamically, the rxhash isn't
> consistent, so the rxhash can't be used by connection tracking, socket
> lookup and others come later.
>
>   
I have to agree with Eric and Changli here.

It's especially true if you're passively tracking via one NIC, where all 
traffic is just forwarded.
In this scenario, you need to compute consistent hashes. rxhashes by NIC 
will be different for
"incoming" and "outgoing" traffic...

Where rxhash by NIC can be used (note: didn't say _useful_) are 
scenarios with different net
ports for incoming and outgoing traffic (in active but also passive 
traffic scenarios). Here,
rxhashes could be used on a per-port basis, but associating two 
seemingly separate rxhashes
with one another to match CPUs is a really annoying task. This would 
involve computing the
corresponding "txhash" and looking it up, which is what we'd be doing 
with the jhash anyway.

For proper flow tracking Eric's suggestion is the way to go. And if 
there are worries about
collisions, why not add IPPROTO_* to the mix.


Franco
