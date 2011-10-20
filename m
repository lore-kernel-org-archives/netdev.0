From: =?iso-8859-1?Q?Hans_Schillstr=F6m?= <hans.schillstrom@ericsson.com>
Subject: RE: [v3 PATCH 0/2] NETFILTER new target module, HMARK
Date: Thu, 20 Oct 2011 17:16:20 +0200
Message-ID: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903194@ESESSCMS0356.eemea.ericsson.se>
References: <1318532530-29446-1-git-send-email-hans.schillstrom@ericsson.com>,<20111020085411.GA19050@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20111020085411.GA19050@1984>
Content-Language: en-US
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello
>Hi Hans,
>
>On Thu, Oct 13, 2011 at 09:02:08PM +0200, Hans Schillstrom wrote:
>> The target allows you to create rules in the "raw" and "mangle" tables
>> which alter the netfilter mark (nfmark) field within a given range.
>> First a 32 bit hash value is generated then modulus by <limit> and
>> finally an offset is added before it's written to nfmark.
>> Prior to routing, the nfmark can influence the routing method (see
>> "Use netfilter MARK value as routing key") and can also be used by
>> other subsystems to change their behaviour.
[snip]
>> Example:
>>                                       App Server (Real Server)
>>
>>                                            +---------+
>>                                         -->| Service |
>>      Gateway A                             +---------+
>>                           /
>>             +----------+ /     +----+      +---------+
>> --- if -A---| selector |---->  |ipvs|  --->| Service |
>>             +----------+ \     +----+      +---------+
>>                           \
>>                                +----+      +---------+
>>                                |ipvs|   -->| Service |
>>                                +----+      +---------+
>>       Gateway C
>>             +----------+ /     +----+
>> --- if-B ---| selector | --->  |ipvs|
>>             +----------+ \     +----+      +---------+
>>                                            | Service |
>>                                            +---------+
>>                           /
>>             +----------+ /     +----+     ..
>> --- if-B ---| selector | --->  |ipvs|      +---------+
>>             +----------+ \     +----+      | Service |
>>                           \                +---------+
>> #
>> # Example with four ipvs loadbalancers
>> #
>> iptables -t mangle -I PREROUTING -d $IPADDR -j HMARK --hmark-mod 4 --hmark-offs 100
>
>I think you can replace this rule by:
>
>iptables -t mangle -I PREROUTING -d $IPADDR -m cluster \
>        --cluster-total-nodes 4 --cluster-local-node 1
>        --cluster-hash-seed 0xdeadbeef -j MARK --set-mark 100
>iptables -t mangle -I PREROUTING -d $IPADDR -m cluster \
>        --cluster-total-nodes 4 --cluster-local-node 2
>        --cluster-hash-seed 0xdeadbeef -j MARK --set-mark 101
>iptables -t mangle -I PREROUTING -d $IPADDR -m cluster \
>        --cluster-total-nodes 4 --cluster-local-node 3
>        --cluster-hash-seed 0xdeadbeef -j MARK --set-mark 103
>iptables -t mangle -I PREROUTING -d $IPADDR -m cluster \
>        --cluster-total-nodes 4 --cluster-local-node 4
>        --cluster-hash-seed 0xdeadbeef -j MARK --set-mark 104
>
>The hashing is done by the cluster match, which is currently based on
>the source address.
>
>This match currently depends on the connection tracking system, so you
>could save the ctmark with CONNMARK. Thus, you only has to hash the
>first packet of the flow, instead of hashing every single packet.
>

In our case we have 256 destinations and 1-20 different HMARK targets so, the no of iptables rules will be > 5000
(20 x 256 rules ...) with cluster target.

One other important difference is that HMARK can spread the packages based on a 5 tuple not only source
and of course skip any field.  That is usually important for load distribution.

I also dig into ICMP errors so the packet can be marked based on the original packet
i.e. routed to the right machine.

I some way the cluster target and hmark targets are similar, in other where different.
One of the main ideas with hmark is to place it in-front of a a clusters (and load balancers) where you have multiple 10G lines in.
(and in that case contrack is not our friend...) i.e. do partitioning of the load balancers.

Regards
Hans



