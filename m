From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2] tc: add support for vlan tc action
Date: Tue, 18 Nov 2014 21:48:37 +0100
Message-ID: <20141118204837.GB1874@nanopsycho.orion>
References: <1415803950-9838-4-git-send-email-jiri@resnulli.us>
 <1415804134-9895-1-git-send-email-jiri@resnulli.us>
 <546906D6.7040400@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, pshelar@nicira.com,
	therbert@google.com, edumazet@google.com, willemb@google.com,
	dborkman@redhat.com, mst@redhat.com, fw@strlen.de,
	Paul.Durrant@citrix.com, tgraf@suug.ch
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:53603 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754933AbaKRUsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 15:48:39 -0500
Received: by mail-wg0-f46.google.com with SMTP id x12so934704wgg.5
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 12:48:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <546906D6.7040400@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Nov 16, 2014 at 09:19:34PM CET, jhs@mojatatu.com wrote:
>On 11/12/14 09:55, Jiri Pirko wrote:
>>Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>
>
>Latest patches work great. If you want you can
>include these notes in the iproute2 commit log.
>
>There is only one small doubt when i add two vlan
>tags(Q followed by QandQ). Look at the very end
>of the text i have below...

I fixed that. Trouble was that tc action finds skb->data in different
state so I have to push and pull. Sending v3 shortly.

>
>cheers,
>jamal
>
>---
>export TC=/media/MT1/other-gits/iproute2-jiri/tc/tc
>export ETH=eth0
>#index supplied by kernel
>sudo $TC actions add action vlan pop
>#explicit add with our index
>sudo $TC actions add action vlan pop index 10
>sudo $TC actions add action vlan push id 123
>sudo $TC actions add action vlan push id 456 protocol 802.1Q
>sudo $TC actions add action vlan push id 789 protocol 802.1ad
>
>sudo $TC actions ls action vlan
>------ expect something like ----
>        action order 0:  vlan pop
>         index 1 ref 1 bind 0
>
>        action order 1:  vlan push id 123 protocol 802.1Q
>         index 2 ref 1 bind 0
>
>        action order 2:  vlan push id 456 protocol 802.1Q
>         index 3 ref 1 bind 0
>
>        action order 3:  vlan push id 789 protocol 802.1ad
>         index 4 ref 1 bind 0
>
>        action order 4:  vlan pop
>         index 10 ref 1 bind 0
>-------
>#show stats
>sudo $TC -s actions ls action vlan
>
>-------
>        action order 0:  vlan pop
>         index 1 ref 1 bind 0 installed 78 sec used 78 sec
>        Action statistics:
>        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>        backlog 0b 0p requeues 0
>
>        action order 1:  vlan push id 123 protocol 802.1Q
>         index 2 ref 1 bind 0 installed 44 sec used 44 sec
>        Action statistics:
>        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>        backlog 0b 0p requeues 0
>
>        action order 2:  vlan push id 456 protocol 802.1Q
>         index 3 ref 1 bind 0 installed 42 sec used 42 sec
>        Action statistics:
>        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>        backlog 0b 0p requeues 0
>
>        action order 3:  vlan push id 789 protocol 802.1ad
>         index 4 ref 1 bind 0 installed 39 sec used 39 sec
>        Action statistics:
>        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>        backlog 0b 0p requeues 0
>
>        action order 4:  vlan pop
>         index 10 ref 1 bind 0 installed 47 sec used 47 sec
>        Action statistics:
>        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>        backlog 0b 0p requeues 0
>-----
>
>sudo $TC actions flush action vlan
>#expect all actions to be gone..
>sudo $TC actions ls action vlan
>
>#lets bind actions to filters...
>sudo ip li add dev dummy0 type dummy
>sudo ifconfig dummy0 up
>#
>sudo tc qdisc del dev $ETH ingress
>sudo tc qdisc add dev $ETH ingress
>#
>sudo $TC filter add dev $ETH parent ffff: pref 11 protocol ip \
>u32 match ip src 10.0.0.1 flowid 1:1 \
>action  vlan  push id 123 \
>action mirred egress redirect dev dummy0
>
>window 1> sudo tcpdump -n -i dummy0 -e -X
>window 2> ping -c 1 10.0.0.1
>
>Expect something like:
>52:54:00:c3:4b:c5 > 02:00:00:22:01:01, ethertype 802.1Q (0x8100), length 102:
>vlan 123, p 0, ethertype IPv4, ...
>#now look at the stats..
>sudo $TC -s filter ls dev $ETH parent ffff: protocol ip
>#
>sudo $TC filter add dev $ETH parent ffff: pref 12 protocol ip \
>u32 match ip src 10.0.0.2 flowid 1:2 \
>action vlan push id 456 protocol 802.1Q \
>action mirred egress redirect dev dummy0
>
>sudo tcpdump -n -i dummy0 -X -e
>ping -c 1 10.0.0.2
>#look at the stats..
>sudo $TC -s filter ls dev $ETH parent ffff: protocol ip
>#
>sudo $TC filter add dev $ETH parent ffff: pref 13 protocol ip \
>u32 match ip src 10.0.0.13 flowid 1:13 \
>action vlan push id 789 protocol 802.1ad \
>action mirred egress redirect dev dummy0
>ping -c 1 10.0.0.2
>
>sudo tcpdump -n -i dummy0 -X -e
>Expect ...
>52:54:00:c3:4b:c5 > 02:00:00:22:01:01, ethertype 802.1Q-QinQ (0x88a8), length
>102: vlan 789, p 0, ethertype IPv4,,,
>#
>sudo $TC -s filter ls dev $ETH parent 1: protocol ip
>#
># Speaking in New Brunswickian:
>#             For shits and giggles lets add two vlans ...
># match all pings this time...
>#
>sudo $TC filter add dev $ETH parent ffff: pref 11 protocol ip u32 \
>match ip protocol 1 0xff flowid 1:1 \
>action  vlan  push id 123 \
>action vlan push id 789 protocol 802.1ad \
>action mirred egress redirect dev dummy0
>
>sudo $TC -s filter ls dev $ETH parent ffff: protocol ip
>------
>filter pref 11 u32
>filter pref 11 u32 fh 800: ht divisor 1
>filter pref 11 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:1 (rule
>hit 2 success 0)
>  match 00010000/00ff0000 at 8 (success 0 )
>        action order 1:  vlan push id 123 protocol 802.1Q
>         index 13 ref 1 bind 1 installed 6 sec used 6 sec
>        Action statistics:
>        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>        backlog 0b 0p requeues 0
>
>        action order 2:  vlan push id 789 protocol 802.1ad
>         index 14 ref 1 bind 1 installed 6 sec used 6 sec
>        Action statistics:
>        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>        backlog 0b 0p requeues 0
>
>        action order 3: mirred (Egress Redirect to device dummy0) stolen
>        index 9 ref 1 bind 1 installed 6 sec used 6 sec
>        Action statistics:
>        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>        backlog 0b 0p requeues 0
>----
>
>Send 10 pings to 192.168.100.1
>ping 192.168.100.1 -c 10
>
>sudo $TC -s filter ls dev $ETH parent ffff: protocol ip
>------
>filter pref 11 u32
>filter pref 11 u32 fh 800: ht divisor 1
>filter pref 11 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:1 (rule
>hit 24 success 10)
>  match 00010000/00ff0000 at 8 (success 10 )
>        action order 1:  vlan push id 123 protocol 802.1Q
>         index 13 ref 1 bind 1 installed 143 sec used 60 sec
>        Action statistics:
>        Sent 840 bytes 10 pkt (dropped 0, overlimits 0 requeues 0)
>        backlog 0b 0p requeues 0
>
>        action order 2:  vlan push id 789 protocol 802.1ad
>         index 14 ref 1 bind 1 installed 143 sec used 60 sec
>        Action statistics:
>        Sent 840 bytes 10 pkt (dropped 0, overlimits 0 requeues 0)
>        backlog 0b 0p requeues 0
>
>        action order 3: mirred (Egress Redirect to device dummy0) stolen
>        index 9 ref 1 bind 1 installed 143 sec used 60 sec
>        Action statistics:
>        Sent 840 bytes 10 pkt (dropped 0, overlimits 0 requeues 0)
>        backlog 0b 0p requeues 0
>--------
>
>As can be seen, the two vlan tags were supposedly added. I am
>not sure how well it worked. I see 4 more bytes added. tcpdump doesnt do
>a good job telling me if it worked...
>
>17:58:31.636816 00:22:01:01:52:54 > 00:00:00:00:02:00, ethertype 802.1Q-QinQ
>(0x88a8), length 106: vlan 789, p 0, LLC, dsap Unknown (0x44) Group, ssap
>Null (0x00) Command, ctrl 0x5400: Information, send seq 0, rcv seq 42, Flags
>[Command], length 88
>        0x0000:  0000 0000 0200 0022 0101 5254 88a8 0315
>        0x0010:  00c3 4500 0054 c06b 0000 4001 704c 8100
>        0x0020:  007b c0a8 6401 c0a8 649f 0000 24b8 027c
>        0x0030:  000a c7e5 6854 0000 0000 e0b4 0900 0000
>        0x0040:  0000 1011 1213 1415 1617 1819 1a1b 1c1d
>        0x0050:  1e1f 2021 2223 2425 2627 2829 2a2b 2c2d
>        0x0060:  2e2f 3031 3233 3435 3637
>
>Here it is with just 802.1q tag...
>17:53:38.198323 52:54:00:c3:4b:c5 > 02:00:00:22:01:01, ethertype 802.1Q
>(0x8100), length 102: vlan 456, p 0, ethertype IPv4, 192.168.100.1 >
>192.168.100.159: ICMP echo reply, id 620, seq 1, length 64
>        0x0000:  0200 0022 0101 5254 00c3 4bc5 8100 01c8
>        0x0010:  0800 4500 0054 c052 0000 4001 7065 c0a8
>        0x0020:  6401 c0a8 649f 0000 6482 026c 0001 a2e4
>        0x0030:  6854 0000 0000 cc04 0300 0000 0000 1011
>        0x0040:  1213 1415 1617 1819 1a1b 1c1d 1e1f 2021
>        0x0050:  2223 2425 2627 2829 2a2b 2c2d 2e2f 3031
>        0x0060:  3233 3435 3637
>
>------------
>
>
