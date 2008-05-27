From: Patrick McHardy <kaber@trash.net>
Subject: Re: DNAT sporadically doesn't replace destination IP address
Date: Tue, 27 May 2008 16:44:15 +0200
Message-ID: <483C1E3F.4030802@trash.net>
References: <4835A03D.B932.00FE.0@newtec.eu> <483589C0.4080006@trash.net> <4835ABD2.B932.00FE.0@newtec.eu> <4835913A.4020909@trash.net> <4835AE9B.B932.00FE.0@newtec.eu> <48359F66.50503@trash.net> <4836EDCE.B932.00FE.0@newtec.eu> <483AC787.6030902@trash.net> <483C365A.B932.00FE.0@newtec.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ulrik De Bie <ulrik.debie@newtec.eu>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Kris Op de Beeck <kris.op.de.beeck@newtec.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55639 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754797AbYE0OoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 10:44:18 -0400
In-Reply-To: <483C365A.B932.00FE.0@newtec.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kris Op de Beeck wrote:
>> What does "grep <srcport from above> /proc/net/nf_conntrack" show
>> when the problem occurs?
>>
> [ 1976.495472] nf_ct_tcp: invalid packet ignored IN= OUT= SRC=192.168.1.29 DST=10.9.9.28 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=58096 DF PROTO=TCP SPT=41675 DPT=80 SEQ=3967333855 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A00065A1E0000000001030305) UID=1000
> 
>  sudo grep 41675 /proc/net/nf_conntrack
> ipv4     2 tcp      6 43 SYN_RECV src=192.168.1.29 dst=10.9.9.28 sport=41675 dport=80 packets=1 bytes=60 src=192.168.1.1 dst=192.168.1.29 sport=80 dport=41675 packets=3 bytes=180 mark=0 secmark=0 use=1

That looks like the client send a SYN, the server sent three
SYN/ACKs that never reached the client and the client retransmits
its SYN. The SYN should still be NATed, but conntrack thinks
its out of sync because its already in SYN_RECV state, while the
client is apparently still in SYN_SENT state.

Looking back at your first mail:

>     print "iptables -t mangle -A VLAN$vlan -j MARK --set-mark $vlan\n";
>     print "iptables -t mangle -A OUTPUT -o eth2.$vlan -j VLAN$vlan\n";
>     print "ip ro add table $vlan default dev eth2.$vlan\n";
>     print "ip ru add fwmark $vlan table $vlan\n";

This looks like a chicken-and-egg problem. You mark packets based
on the output device, but use the mark to direct them to the output
device.

I guess if you use the source IP for routing table selection it
will work. Not sure why it works at all currently.
