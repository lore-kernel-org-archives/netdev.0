From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH v2 net-next] mlx4: optimize xmit path
Date: Thu, 2 Oct 2014 14:56:15 +0300
Message-ID: <542D3D5F.5090900@mellanox.com>
References: <1411692382-8898-1-git-send-email-ast@plumgrid.com>		 <1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>		 <1411717322.16953.99.camel@edumazet-glaptop2.roam.corp.google.com>		 <1411850590.15768.6.camel@edumazet-glaptop2.roam.corp.google.com>		 <CAJ3xEMhQCf7j48Yn5sjH6jaYYdLQUgOe2hk-OZhhdZ7taOyx+Q@mail.gmail.com>		 <1411853441.15768.13.camel@edumazet-glaptop2.roam.corp.google.com>		 <1411858593.15768.51.camel@edumazet-glaptop2.roam.corp.google.com>		 <1411964353.30721.6.camel@edumazet-glaptop2.roam.corp.google.com>	 <1412224524.16704.75.camel@edumazet-glaptop2.roam.corp.google.com>	 <542D06C1.6090802@mellanox.com> <1412250327.16704.84.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Or Gerlitz" <or.gerlitz@gmail.com>, <amira@mellanox.com>,
	<idos@mellanox.com>, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	<eyalpe@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog126.obsmtp.com ([207.126.144.174]:44754 "EHLO
	eu1sys200aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752385AbaJBL4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 07:56:31 -0400
In-Reply-To: <1412250327.16704.84.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/2/2014 2:45 PM, Eric Dumazet wrote:
> On Thu, 2014-10-02 at 11:03 +0300, Amir Vadai wrote:
> 
>> Hi,
>>
>> Will take it into the split patchset - we just hit this bug when tried
>> to run benchmarks with blueflame disabled (easy to test by using ethtool
>> priv flag blueflame).
> 
> Hmm, I do not know this ethtool command, please share ;)

$ ethtool --set-priv-flags eth0 blueflame off

> 
>>
>> I'm still working on it, but I can't reproduce the numbers that you
>> show. On my development machine, I get ~5.5Mpps with burst=8 and ~2Mpps
>> with burst=1.
> 
> You have to be careful with the 'clone X' : If you choose a too big
> value, TX completion competes with the sender thread.
> 
>>
>> In addition, I see no improvements when adding the optimization to the
>> xmit path.
After making sure the sender thread and the TX completions are not on
the same CPU, I see the expected improvement. +0.5Mpps with tx
optimizations.

>> I use the net-next kernel + pktgen burst support patch, with and without
>> this xmit path optimization patch.
>>
>> Do you use other patches not upstream in your environment?
> 
> Nope, this is with David net-next tree.
> 
>> Can you share the .config/pktgen configuration?
> 
> Sure.
> 
>>
>> One other note: we're checking now that blueflame could be used with
>> xmit_more. It might result with packets reordering/drops. Still under
>> investigation.
> 
> I noticed no reorders. I tweaked the stack to force a gso segmentation
> (in software) instead of using NIC TSO for small packets (2 or 3 MSS)
> 
> 200 concurrent netperf -t TCP_RR -- -r 2000,2000    performance was
> increased by ~100%.
> 
> 
> #!/bin/bash
> #
> # on the destination, drop packets with
> #   iptables -A PREROUTING -t raw -p udp --dport 9 -j DROP
> #   Or run a recent enough kernel with global ICMP rate limiting to 1000 packets/sec
> #   ( http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=4cdf507d54525842dfd9f6313fdafba039084046 )
> #
> #### Configure
> 
> # Yeah, if you use PKTSIZE <= 104, performance is lower because of inline (copy whole frame content into tx desc)
> PKTSIZE=105
You can also set the module parameter to turn it off:
$ modprobe mlx4_en inline_thold=17

> 
[...]

Thanks,
Amir
