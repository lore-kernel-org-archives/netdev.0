From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH 0/5] tracing/events: add tracepoint to TCP/IP stack and
 netdev layer
Date: Wed, 20 Jan 2010 09:52:00 +0800
Message-ID: <4B5661C0.9050309@cn.fujitsu.com>
References: <4B541B31.5090207@jp.fujitsu.com> <4B555C12.1060909@cn.fujitsu.com> <4B565786.9070503@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	izumi.taku@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53383 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751477Ab0ATBvO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jan 2010 20:51:14 -0500
In-Reply-To: <4B565786.9070503@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Koki Sanagi wrote:
> Thanks for your reply.
> 
> (2010/01/19 16:15), Yang Hongyang wrote:
>> Koki Sanagi wrote:
>>> These patch-set adds some tracepoints to the TCP/IP stack and netdev layer.
>> Your patch-set is mainly for IPv4,I think you'd better mantion that in your
>> title.^!^
>>
> Yeah, you're right.
> I'll change the title next time.

Next time,  all your mails that you send out to the maillist should using
UTF-8 encoding.

> 
> Best regards,
> Koki Sanagi
> 
>>> As described below,
>>> http://marc.info/?l=linux-netdev&m=126096487212459&w=2
>>> dev_hard_start_xmit and netif_receive_skb are important location to add
>>> tracepoints. Because driver depends on an machine environment, we usually
>>> check this point when solving network problem. But these two points are lack of
>>> infrotmation that what packets are passed, So I add other tracepoints to know
>>> what packets are passed and to give some merits.
>>>
>>> Added tracepoints are at transmit/receive entry of TCP, UDP, RAW, IPv4, driver
>>> and Qdisc. And tracepoints to output information to make connection
>>> between these entry tracepoints are also added.
>>>
>>> These tracepoints give some merits.
>>> For example, they enable us to measure packet latency.
>>> By using tcpdump, we can analyze what packets are passed, but we cannot analyze
>>> how long it takes to pass through network layer(In other words, latency of TCP
>>> layer, IP layer and Qdisc).
>>> Packet latency is very useful information to solve a network bad performance or
>>> bad reaction network application, packet latency is very useful information.
>>>
>>> As an other use case, unlike a tcpdump, they are recorded in ftrace buffer
>>> without IO burden. Only when you need, output recorded information.
>>> I mean, they are fit to run always.
>>>
>>> Details of added tracepoint are below.
>>>
>>> skb_clone               chase the cloned skb
>>> senddata_copy_skb       copy userdata to skb for transmit
>>>
>>> netdev_start_xmit       entry of driver's transmit function.
>>> netdev_receive_skb      entry of netstack(receive).
>>> dev_queue_xmit          entry of Qdisc.	
>>>
>>> ip_queue_xmit           entry of IP layer(TCP transmit)
>>> ip_push_pending_frames  entry of IP layer(UDP transmit)
>>> ip_output               entry of IP layer(RAW transmit)
>>> ip_frag_queue           aggregate fragmented packet
>>> ip_frag_reasm           reasemble fragmented packet
>>> ip_rcv                  entry of IP layer(receive)
>>>
>>> tcp_sendmsg             entry of TCP layer(transmit)
>>> tcp_sendpage            entry of TCP layer(transmit)
>>> tcp_push_pending_frames all data(tcp_sendmsg have) have copied to skb
>>> tcp_v4_rcv              entry of TCP layer(receive)
>>>
>>> udp_sendmsg             entry of UDP layer(transmit)
>>> udp_sendpage            entry of UDP layer(transmit)
>>> udp_push_pending_frames all data(udp_sendmsg have) have copied to skb
>>> udp_rcv                 entry of UDP layer(receive).
>>>
>>> raw_sendmsg             entry of RAW layer(transmit).
>>> raw_rcv                 entry of RAW layer(receive).
>>>
>>> Outputs are below.
>>>
>>> TCP send
>>>           netperf-2513  [000]  2603.586818: tcp_sendmsg: sk=f644eac0 len=5000
>>>           netperf-2513  [000]  2603.586818: senddata_copy_skb: sk=f644eac0 skbaddr=f7159800 len=1416
>>>           netperf-2513  [000]  2603.586820: senddata_copy_skb: sk=f644eac0 skbaddr=f7159500 len=1448
>>>           netperf-2513  [000]  2603.586821: senddata_copy_skb: sk=f644eac0 skbaddr=f7158d80 len=1448
>>>           netperf-2513  [000]  2603.586822: senddata_copy_skb: sk=f644eac0 skbaddr=f7159c80 len=688
>>>           netperf-2513  [000]  2603.586822: tcp_push_pending_frames: sk=f644eac0 sport=54875 dport=51707
>>>              tail-2514  [001]  2603.587577: skb_clone: original=f7159800 clone=f71598b4
>>>              tail-2514  [001]  2603.587578: ip_queue_xmit: skbaddr=f71598b4 saddr=192.168.100.5 daddr=192.168.100.2
>>>              tail-2514  [001]  2603.587579: ip_output: skbaddr=f71598b4 saddr=192.168.100.5 daddr=192.168.100.2
>>>              tail-2514  [001]  2603.587579: dev_queue_xmit: dev=eth10 skbaddr=f71598b4 len=1514
>>>              tail-2514  [001]  2603.587580: netdev_start_xmit: dev=eth10 skbaddr=f71598b4 len=1514
>>>              tail-2514  [001]  2603.587628: skb_clone: original=f7159500 clone=f71595b4
>>>              tail-2514  [001]  2603.587629: ip_queue_xmit: skbaddr=f71595b4 saddr=192.168.100.5 daddr=192.168.100.2
>>>              tail-2514  [001]  2603.587630: ip_output: skbaddr=f71595b4 saddr=192.168.100.5 daddr=192.168.100.2
>>>              tail-2514  [001]  2603.587631: dev_queue_xmit: dev=eth10 skbaddr=f71595b4 len=1514
>>>              tail-2514  [001]  2603.587632: netdev_start_xmit: dev=eth10 skbaddr=f71595b4 len=1514
>>>              tail-2514  [001]  2603.587632: skb_clone: original=f7158d80 clone=f7158e34
>>>              tail-2514  [001]  2603.587633: ip_queue_xmit: skbaddr=f7158e34 saddr=192.168.100.5 daddr=192.168.100.2
>>>              tail-2514  [001]  2603.587634: ip_output: skbaddr=f7158e34 saddr=192.168.100.5 daddr=192.168.100.2
>>>              tail-2514  [001]  2603.587635: dev_queue_xmit: dev=eth10 skbaddr=f7158e34 len=1514
>>>              tail-2514  [001]  2603.587635: netdev_start_xmit: dev=eth10 skbaddr=f7158e34 len=1514
>>>              tail-2514  [001]  2603.587685: skb_clone: original=f7159c80 clone=f7159d34
>>>              tail-2514  [001]  2603.587685: ip_queue_xmit: skbaddr=f7159d34 saddr=192.168.100.5 daddr=192.168.100.2
>>>              tail-2514  [001]  2603.587687: ip_output: skbaddr=f7159d34 saddr=192.168.100.5 daddr=192.168.100.2
>>>              tail-2514  [001]  2603.587687: dev_queue_xmit: dev=eth10 skbaddr=f7159d34 len=1514
>>>              tail-2514  [001]  2603.587688: netdev_start_xmit: dev=eth10 skbaddr=f7159d34 len=1514
>>>
>>> TCP recv
>>>            <idle>-0     [001]  3499.386601: netdev_receive_skb: dev=eth10 skbaddr=f4a88480 len=1500
>>>            <idle>-0     [001]  3499.386602: ip_rcv: skbaddr=f4a88480 saddr=192.168.100.2 daddr=192.168.100.5
>>>            <idle>-0     [001]  3499.386604: tcp_v4_rcv: skbaddr=f4a88480 sport=51035 dport=34474
>>>            <idle>-0     [000]  3499.386619: netdev_receive_skb: dev=eth10 skbaddr=f3c75300 len=1500
>>>            <idle>-0     [000]  3499.386619: ip_rcv: skbaddr=f3c75300 saddr=192.168.100.2 daddr=192.168.100.5
>>>            <idle>-0     [000]  3499.386622: tcp_v4_rcv: skbaddr=f3c75300 sport=51035 dport=34474
>>>         netserver-2519  [000]  3499.386626: skb_copy_datagram_iovec: skbaddr=f4a88480 len=1448
>>>         netserver-2519  [000]  3499.386628: skb_copy_datagram_iovec: skbaddr=f3c75300 len=1448
>>>
>>> UDP send
>>>           netperf-2506  [001]  2309.073460: udp_sendmsg: sk=f662e6c0 len=5000
>>>           netperf-2506  [001]  2309.073466: senddata_copy_skb: sk=f662e6c0 skbaddr=f5f65780 len=1472
>>>           netperf-2506  [001]  2309.073467: senddata_copy_skb: sk=f662e6c0 skbaddr=f5f65000 len=1480
>>>           netperf-2506  [001]  2309.073468: senddata_copy_skb: sk=f662e6c0 skbaddr=f3decf00 len=1480
>>>           netperf-2506  [001]  2309.073469: senddata_copy_skb: sk=f662e6c0 skbaddr=f4802840 len=568
>>>           netperf-2506  [001]  2309.073470: udp_push_pending_frames: sk=f662e6c0 sport=42679 dport=47640
>>>           netperf-2506  [001]  2309.073470: ip_push_pending_frames: skbaddr=f5f65780 saddr=192.168.100.5 daddr=192.168.100.2
>>>           netperf-2506  [001]  2309.073471: ip_output: skbaddr=f5f65780 saddr=192.168.100.5 daddr=192.168.100.2
>>>           netperf-2506  [001]  2309.073472: dev_queue_xmit: dev=eth10 skbaddr=f5f65780 len=1514
>>>           netperf-2506  [001]  2309.073473: dev_queue_xmit: dev=eth10 skbaddr=f5f65000 len=1514
>>>           netperf-2506  [001]  2309.073474: dev_queue_xmit: dev=eth10 skbaddr=f3decf00 len=1514
>>>           netperf-2506  [001]  2309.073474: dev_queue_xmit: dev=eth10 skbaddr=f4802840 len=602
>>>            <idle>-0     [001]  2309.073615: netdev_start_xmit: dev=eth10 skbaddr=f5f65780 len=1514
>>>            <idle>-0     [001]  2309.073616: netdev_start_xmit: dev=eth10 skbaddr=f5f65000 len=1514
>>>            <idle>-0     [000]  2309.073633: netdev_start_xmit: dev=eth10 skbaddr=f3decf00 len=1514
>>>            <idle>-0     [000]  2309.073633: netdev_start_xmit: dev=eth10 skbaddr=f4802840 len=602
>>>
>>> UDP recv
>>>            <idle>-0     [001]  3671.663678: netdev_receive_skb: dev=eth10 skbaddr=f5f72d80 len=1500
>>>            <idle>-0     [001]  3671.663678: ip_rcv: skbaddr=f5f72d80 saddr=192.168.100.2 daddr=192.168.100.5
>>>            <idle>-0     [001]  3671.663680: ip_frag_queue: skbaddr=f5f72d80 prev=(null)
>>>            <idle>-0     [001]  3671.663681: netdev_receive_skb: dev=eth10 skbaddr=f5f6aa80 len=1500
>>>            <idle>-0     [001]  3671.663681: ip_rcv: skbaddr=f5f6aa80 saddr=192.168.100.2 daddr=192.168.100.5
>>>            <idle>-0     [001]  3671.663681: ip_frag_queue: skbaddr=f5f6aa80 prev=f5f72d80
>>>            <idle>-0     [000]  3671.663702: netdev_receive_skb: dev=eth10 skbaddr=f4800840 len=1500
>>>            <idle>-0     [000]  3671.663703: ip_rcv: skbaddr=f4800840 saddr=192.168.100.2 daddr=192.168.100.5
>>>            <idle>-0     [000]  3671.663703: ip_frag_queue: skbaddr=f4800840 prev=f5f6aa80
>>>            <idle>-0     [000]  3671.663704: netdev_receive_skb: dev=eth10 skbaddr=f4a88b40 len=588
>>>            <idle>-0     [000]  3671.663705: ip_rcv: skbaddr=f4a88b40 saddr=192.168.100.2 daddr=192.168.100.5
>>>            <idle>-0     [000]  3671.663705: ip_frag_queue: skbaddr=f4a88b40 prev=f4800840
>>>            <idle>-0     [000]  3671.663706: skb_clone: original=f4a88b40 clone=f5fff480
>>>            <idle>-0     [000]  3671.663707: kfree_skb: skbaddr=f5f72d80 protocol=2048 location=c0715f1a
>>>            <idle>-0     [000]  3671.663707: ip_frag_reasm: head=f4a88b40 len=1480
>>>            <idle>-0     [000]  3671.663711: udp_rcv: skbaddr=f4a88b40 sport=57915 dport=37634
>>>         netserver-2525  [000]  3671.663718: skb_copy_datagram_iovec: skbaddr=f4a88b40 len=5000
>>>         netserver-2525  [000]  3671.663718: skb_copy_datagram_iovec: skbaddr=f5f6aa80 len=1480
>>>         netserver-2525  [000]  3671.663719: skb_copy_datagram_iovec: skbaddr=f4800840 len=1480
>>>         netserver-2525  [000]  3671.663719: skb_copy_datagram_iovec: skbaddr=f5fff480 len=568
>>>
>>> RAW send
>>>              send-2431  [001]  1813.799957: raw_sendmsg: sk=f4a37200 len=1500
>>>              send-2431  [001]  1813.799959: senddata_copy_skb: sk=f4a37200 skbaddr=f3dec180 len=1500
>>>              send-2431  [001]  1813.799960: ip_output: skbaddr=f3dec180 saddr=192.168.100.5 daddr=192.168.100.2
>>>              send-2431  [001]  1813.799960: dev_queue_xmit: dev=eth10 skbaddr=f3dec180 len=1514
>>>              send-2431  [001]  1813.799961: netdev_start_xmit: dev=eth10 skbaddr=f3dec180 len=1514
>>>
>>> RAW recv
>>>            <idle>-0     [000]  2052.858947: netdev_receive_skb: dev=eth1 skbaddr=f5f66000 len=1500
>>>            <idle>-0     [000]  2052.858947: ip_rcv: skbaddr=f5f66000 saddr=192.168.101.2 daddr=192.168.101.5
>>>            <idle>-0     [000]  2052.858951: skb_clone: original=f5f66000 clone=f3e43cc0
>>>            <idle>-0     [000]  2052.858952: raw_rcv: skbaddr=f3e43cc0 len=1476
>>>              recv-2499  [001]  2052.858970: skb_copy_datagram_iovec: skbaddr=f3e43cc0 len=1500
>>>
>>> Best Regards,
>>> Koki Sanagi<sanagi.koki@jp.fujitsu.com>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>>
>>
> 
> 
> 
> 


-- 
Regards
Yang Hongyang
