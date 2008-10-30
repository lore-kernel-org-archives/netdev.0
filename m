From: almaop@poczta.fm
Subject: Re: New filter 'flow' bug?
Date: 30 Oct 2008 10:39:52 +0100
Message-ID: <20081030093953.4517510BFA8@f30.poczta.interia.pl>
Mime-Version: 1.0
Content-Type: TEXT/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "linux-net@vger.kernel.org" <linux-net@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>,
	"almaop@poczta.fm" <almaop@poczta.fm>
Return-path: <linux-net-owner@vger.kernel.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> almaop@poczta.fm wrote:
> >>> From: almaop@poczta.fm
> >>>> I'm not sure where is the bug - in the flow filter or in the sfq
> >> qdisc.
> >>
> >> Which SFQ qdisc is stalling?
> >>
> > Thanks for reply.
> > So I've done few tests. I've removed quantum 64 (it  was qdisc with
> small packets). It made no difference. It looks like the key is the first
> sfq qdisc (tc qdisc add dev $DEV parent 1:2 handle 2: sfq - in my example).
> When there is no traffic in this qdisc for about 45 seconds (shorter time
> when there is no traffic at all on the interface) - it stalls. Other qdiscs
> stall also. So there is no packet flow on that interface. Removing filters
> ('flow' filters) does'nt help. I have to remove (all) sfq qdiscs. And then
> the traffic is resumed.
> 
> Please capture the output of "tc -s -d qdisc show dev <dev>" and
> "tc -s -d class show dev <dev>" immediately after it stalls.
> I'm interested in the amount of bytes/packets queued at the moment.
> 

I've captured it eve
It looks like this:
Example 1:

qdisc htb 1: root r2q 10 default 4 direct_packets_stat 3 ver 3.17
 Sent 1206781 bytes 12855 pkt (dropped 0, overlimits 10539 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0 
qdisc sfq 2: parent 1:2 limit 127p quantum 1514b flows 127/1024 
 Sent 647460 bytes 9862 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
qdisc sfq 3: parent 1:3 limit 127p quantum 1514b flows 127/1024 
 Sent 449824 bytes 2745 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
qdisc sfq 4: parent 1:4 limit 127p quantum 1514b flows 127/1024 
 Sent 109233 bytes 244 pkt (dropped 1, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
class htb 1:1 root rate 624000bit ceil 624000bit burst 1912b/8 mpu 0b overhead 0b cburst 1912b/8 mpu 0b overhead 0b level 7 
 Sent 1206583 bytes 12852 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 19104bit 13pps backlog 0b 0p requeues 0 
 lended: 4987 borrowed: 0 giants: 0
 tokens: 22624 ctokens: 22624

class htb 1:2 parent 1:1 leaf 2: prio 3 quantum 1500 rate 120000bit ceil 160000bit burst 1659b/8 mpu 0b overhead 0b cburst 1679b/8 mpu 0b overhead 0b level 0 
 Sent 647460 bytes 9862 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 4552bit 9pps backlog 0b 0p requeues 0 
 lended: 5451 borrowed: 4411 giants: 0
 tokens: 101172 ctokens: 79297

class htb 1:3 parent 1:1 leaf 3: prio 4 quantum 3000 rate 240000bit ceil 560000bit burst 1719b/8 mpu 0b overhead 0b cburst 1880b/8 mpu 0b overhead 0b level 0 
 Sent 449824 bytes 2745 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 2976bit 2pps backlog 0b 0p requeues 0 
lended: 2177 borrowed: 568 giants: 0
 tokens: 53386 ctokens: 24763

class htb 1:4 parent 1:1 leaf 4: prio 5 quantum 1500 rate 120000bit ceil 560000bit burst 1659b/8 mpu 0b overhead 0b cburst 1880b/8 mpu 0b overhead 0b level 0 
 Sent 109299 bytes 245 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 11568bit 3pps backlog 0b 0p requeues 0 
 lended: 237 borrowed: 8 giants: 0
 tokens: 101172 ctokens: 24763


Example 2:
(with longer txqueue)

qdisc htb 1: root r2q 10 default 4 direct_packets_stat 0 ver 3.17
 Sent 17205588 bytes 211080 pkt (dropped 0, overlimits 199620 requeues 5) 
 rate 0bit 0pps backlog 0b 0p requeues 5 
qdisc sfq 2: parent 1:2 limit 127p quantum 1514b flows 127/1024 
 Sent 11256846 bytes 179165 pkt (dropped 1200, overlimits 0 requeues 5) 
 rate 0bit 0pps backlog 0b 0p requeues 5 
qdisc sfq 3: parent 1:3 limit 127p quantum 1514b flows 127/1024 
 Sent 5225274 bytes 30009 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
qdisc sfq 4: parent 1:4 limit 127p quantum 1514b flows 127/1024 
 Sent 723468 bytes 1906 pkt (dropped 8, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
class htb 1:1 root rate 624000bit ceil 624000bit burst 1912b/8 mpu 0b overhead 0b cburst 1912b/8 mpu 0b overhead 0b level 7 
 Sent 17207118 bytes 211085 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 41968bit 42pps backlog 0b 0p requeues 0 
 lended: 85962 borrowed: 0 giants: 0
 tokens: 12267 ctokens: 12267

class htb 1:2 parent 1:1 leaf 2: prio 3 quantum 1500 rate 120000bit ceil 160000bit burst 1659b/8 mpu 0b overhead 0b cburst 1679b/8 mpu 0b overhead 0b level 0 
 Sent 11256846 bytes 179165 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 16496bit 37pps backlog 0b 0p requeues 0 
 lended: 95202 borrowed: 83968 giants: 0
 tokens: 101172 ctokens: 79297

class htb 1:3 parent 1:1 leaf 3: prio 4 quantum 3000 rate 240000bit ceil 560000bit burst 1719b/8 mpu 0b overhead 0b cburst 1880b/8 mpu 0b overhead 0b level 0 
 Sent 5225274 bytes 30009 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 1576bit 1pps backlog 0b 0p requeues 0 
 lended: 28163 borrowed: 1846 giants: 0
 tokens: 510 ctokens: 24763

class htb 1:4 parent 1:1 leaf 4: prio 5 quantum 1500 rate 120000bit ceil 560000bit burst 1659b/8 mpu 0b overhead 0b cburst 1880b/8 mpu 0b overhead 0b level 0 
 Sent 723468 bytes 1906 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 23880bit 4pps backlog 0b 0p requeues 0 
 lended: 1758 borrowed: 148 giants: 0
 tokens: 3049 ctokens: 7974


Krzysiek

----------------------------------------------------------------------
Wymysl wierszyk, wygraj cyfrowke!
Sprawdz >>> http://link.interia.pl/f1f5a

