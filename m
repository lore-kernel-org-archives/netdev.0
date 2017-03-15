From: wenxu <wenxu@ucloud.cn>
Subject: Re: openvswitch conntrack and nat problem in first packet reply with
 RST
Date: Wed, 15 Mar 2017 12:19:41 +0800
Message-ID: <d6ce5a4d-c7ac-2b1e-3de8-8ea4e528a87e@ucloud.cn>
References: <5e19d70b-baab-0f52-744f-82758e399c47@ucloud.cn>
 <CAPWQB7GdCeA1Jev-UFS4jEM+9NJOtHt_Mr08bqUqfrfDELuQiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jarno Rajahalme <jarno@ovn.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50211.mail.qiye.163.com ([123.125.50.211]:19694 "EHLO
        m50211.mail.qiye.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751242AbdCOE1b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 00:27:31 -0400
In-Reply-To: <CAPWQB7GdCeA1Jev-UFS4jEM+9NJOtHt_Mr08bqUqfrfDELuQiA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


you are correct! Thanks very much.

It's works  set a new example as following.

ip,in_port=2 actions=ct(table=1,zone=1,nat)
ip,in_port=3 actions=ct(table=1,zone=1,nat)

table=1, ct_state=+new+trk,tcp,in_port=2,tp_dst=123 actions=ct(commit,zone=1,nat(src=2.2.1.7)),output:3
table=1, ct_state=+new+trk,icmp,in_port=2 actions=ct(commit,zone=1,nat(src=2.2.1.7)),output:3
table=1, ct_state=+new+trk,ip,in_port=3 actions=ct(commit,zone=1,nat(dst=192.168.0.7)),output:2
table=1, ct_state=+new+trk, priority=100, tcp,in_port=3,tp_dst=123 actions=drop
table=1, ct_state=+est+trk,ip,in_port=3 actions=output:2
table=1, ct_state=+est+trk,ip,in_port=2 actions=output:3





> On 13 March 2017 at 20:18, wenxu <wenxu@ucloud.cn> wrote:
>> Hi all,
>>
>> There is a simple test for conntrack and nat in openvswitch.  I want to do stateful
>> firewall with conntrack then do nat
>>
>> netns1 port1 with ip 10.0.0.7
>> netns2 port2 with ip 1.1.1.7
>>
>> netns1 10.0.0.7 src -nat to 2.2.1.7 access netns2 1.1.1.7
>>
>> 1. # ovs-ofctl add-flow br0  'ip,in_port=1 actions=ct(table=1,zone=1)'
>> 2. # ovs-ofctl add-flow br0  'ip,in_port=2 actions=ct(table=1,zone=1)'
>> 3. # ovs-ofctl add-flow br0  'table=1, ct_state=+new+trk,tcp,in_port=1,tp_dst=123 actions=ct(commit,zone=1,nat(src=2.2.1.7)),output:2'
>> 4. # ovs-ofctl add-flow br0  'table=1, ct_state=+est+trk,ip,in_port=2 actions=ct(commit,zone=1,nat(dst=10.0.0.7)),output:1'
>> 5. # ovs-ofctl add-flow br0  'table=1, ct_state=+est+trk,ip,in_port=1  actions=ct(commit,zone=1,nat(src=2.2.1.7)),output:2'
>>
>>
>> I  found that  netns1 can access 1.1.1.7:123  when there is 123-port listen on 1.1.1.7  in netns2
>>
>> But if there is no listen 123 port, The first RST packet reply by 1.1.1.7
>> (no datapath kernel rule) can't do dst-nat back to 10.0.0.7.  The second RST packet is ok (there is datapath kernel rule which comes from first RST packet)
>>
>> # tcpdump -i eth0 -nnn
>> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
>> listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
>> 14:44:13.575200 IP 10.0.0.7.39891 > 1.1.1.7.123: Flags [S], seq 935877775, win 29200, options [mss 1460,sackOK,TS val 584707316 ecr 0,nop,wscale 7], length 0
>> 14:44:13.576036 IP 1.1.1.7.123 > 2.2.1.7.39891: Flags [R.], seq 0, ack 935877776, win 0, length 0
>>
>> But the datapath flow is correct
>> # ovs-dpctl dump-flows
>> recirc_id(0),in_port(7),eth_type(0x0800),ipv4(frag=no), packets:0, bytes:0, used:never, actions:ct(zone=1),recirc(0x5a)
>> recirc_id(0x5a),in_port(7),ct_state(+new+trk),eth_type(0x0800),ipv4(proto=6,frag=no),tcp(dst=123),
>>  packets:0, bytes:0, used:never,
>> actions:ct(commit,zone=1,nat(src=2.2.1.7)),8
>> recirc_id(0),in_port(8),eth_type(0x0800),ipv4(frag=no), packets:0, bytes:0, used:never, actions:ct(zone=1),recirc(0x5b)
>> recirc_id(0x5b),in_port(8),ct_state(-new+est+trk),eth_type(0x0800),ipv4(frag=no),
>>  packets:0, bytes:0, used:never,
>> actions:ct(commit,zone=1,nat(dst=10.0.0.7)),7
>>
>>
>> I think It's a matter with the PACKET-OUT and RST packet
>>
>> There are two packet-out for rule2 and rul4. Rule2 go through connect track and find it is an RST packet then delete the conntrack . It leads the second packet(come from rule4) can't find the conntack to do dst-nat.
>>
>> In "netfilter/nf_conntrack_proto_tcp.c file
>>  if (!test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
>>                 /* If only reply is a RST, we can consider ourselves not to
>>                    have an established connection: this is a fairly common
>>                    problem case, so we can delete the conntrack
>>                    immediately.  --RR */
>>                 if (th->rst ) {
>>                         nf_ct_kill_acct(ct, ctinfo, skb);
>>                         return NF_ACCEPT;
>>                 }
>>         }
>>
>>
>> It should add a switch to avoid this conntrack  be deleted.
>>
>> if (!test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
>>                 /* If only reply is a RST, we can consider ourselves not to
>>                    have an established connection: this is a fairly common
>>                    problem case, so we can delete the conntrack
>>                    immediately.  --RR */
>> -                if (th->rst ) {
>> +                if (th->rst && !nf_ct_tcp_rst_no_kill) {
>>                         nf_ct_kill_acct(ct, ctinfo, skb);
>>                         return NF_ACCEPT;
>>                 }
> How would you know to not kill the entry? How would you ensure it's
> properly cleaned up later? I'm not sure if there's a way to implement
> this without some fairly serious plumbing.
>
> If you look at the examples in the OVS testsuite[0], it is suggested
> to use "ct(nat)" with no options early in your rules. This ensures
> that the connection is looked up, and if necessary, NAT is applied at
> the same time - meaning that the RST can be NATed back AND the
> connection is deleted. In the later table you need to differentiate
> the connections based on whether they were already statefully NATed or
> not. For new connections, it would be handled by your rule #3 (which
> would then perform the nat as part of that rule's actions). For
> existing connections, the packet is already NATed by the time it
> reaches table 1, and your rules 4-5 shouldn't need to apply the nat.
> If you still need access to the original tuple for matching purposes,
> the new fields 'ct_nw_src', 'ct_nw_dst', etc. fields will provide the
> original ct 5tuple. Note however those are only available on OVS
> master, should be part of OVS 2.8.
>
> [0] https://github.com/openvswitch/ovs/blob/branch-2.7/tests/system-traffic.at#L2331
> [1] http://openvswitch.org/support/dist-docs/ovs-fields.7.html
