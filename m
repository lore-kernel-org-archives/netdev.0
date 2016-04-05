From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Tue, 5 Apr 2016 17:15:20 +0300
Message-ID: <5703C878.7050307@mellanox.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
 <1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
 <1459562911.6473.299.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160402024710.GA59703@ast-mbp.thefacebook.com>
 <20160404165701.2a25a17a@redhat.com>
 <1459783323.6473.341.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160404185010.GD68392@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Brenden Blanco <bblanco@plumgrid.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <tom@herbertland.com>,
	<daniel@iogearbox.net>, <john.fastabend@gmail.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Matan Barak <matanb@mellanox.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0059.outbound.protection.outlook.com ([157.56.112.59]:17680
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752428AbcDEQtB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 12:49:01 -0400
In-Reply-To: <20160404185010.GD68392@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/4/2016 9:50 PM, Alexei Starovoitov wrote:
> On Mon, Apr 04, 2016 at 08:22:03AM -0700, Eric Dumazet wrote:
>> A single flow is able to use 40Gbit on those 40Gbit NIC, so there is not
>> a single 10GB trunk used for a given flow.
>>
>> This 14Mpps thing seems to be a queue limitation on mlx4.
> yeah, could be queueing related. Multiple cpus can send ~30Mpps of the same 64 byte packet,
> but mlx4 can only receive 14.5Mpps. Odd.
>
> Or (and other mellanox guys), what is really going on inside 40G nic?

Hi Alexei,

Not that I know everything that goes inside there, and not that if I 
knew it all I could have posted that here (I heard HWs sometimes have 
IP)... but, anyway, as for your questions:

ConnectX3 40Gbs NIC can receive > 10Gbs packet-worthy (14.5M) in single 
ring and Mellanox
100Gbs NICs can receive > 25Gbs packet-worthy (37.5M) in single ring, 
people that use DPDK (...) even see this numbers and AFAIU we now 
attempt to see that in the kernel with XDP :)

I realize that we might have some issues in the mlx4 driver reporting on 
HW drops. Eran (cc-ed) and Co are looking on that.

In parallel to doing so, I would suggest you to do some experiments that 
might shed some more light, if on the TX side you do

$ ./pktgen_sample03_burst_single_flow.sh -i $DEV -d $IP -m $MAC -t 4

On the RX side,  skip RSS and force the packets that match that traffic 
pattern to go to (say) ring (==action) 0

$ ethtool -U $DEV flow-type ip4 dst-mac $MAC dst-ip $IP action 0 loc 0

to go back to RSS remove the rule

$ ethtool -U $DEV delete action 0

FWIW (not that I see how it helps you now), you can do HW drop on the RX 
side with ring -1

$ ethtool -U $DEV flow-type ip4 dst-mac $MAC dst-ip $IP action -1 loc 0

Or.
