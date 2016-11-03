From: "De Schepper, Koen (Nokia - BE)"
        <koen.de_schepper@nokia-bell-labs.com>
Subject: Is there a maximum bytes in flight limitation in the tcp stack?
Date: Thu, 3 Nov 2016 16:37:48 +0000
Message-ID: <BF6B00CC65FD2D45A326E74492B2C19FB77853E9@FR711WXCHMBA05.zeu.alcatel-lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fr-hpida-esg-02.alcatel-lucent.com ([135.245.210.21]:50246 "EHLO
        smtp-fr.alcatel-lucent.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752138AbcKCQhw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 12:37:52 -0400
Received: from fr712umx4.dmz.alcatel-lucent.com (unknown [135.245.210.45])
        by Websense Email Security Gateway with ESMTPS id D2E8A90DC791A
        for <netdev@vger.kernel.org>; Thu,  3 Nov 2016 16:37:46 +0000 (GMT)
Received: from fr712usmtp2.zeu.alcatel-lucent.com (fr712usmtp2.zeu.alcatel-lucent.com [135.239.2.42])
        by fr712umx4.dmz.alcatel-lucent.com (GMO-o) with ESMTP id uA3Gbnqd031831
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Thu, 3 Nov 2016 16:37:50 GMT
Received: from FR711WXCHHUB01.zeu.alcatel-lucent.com (fr711wxchhub01.zeu.alcatel-lucent.com [135.239.2.111])
        by fr712usmtp2.zeu.alcatel-lucent.com (GMO) with ESMTP id uA3GbmM9027062
        (version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=FAIL)
        for <netdev@vger.kernel.org>; Thu, 3 Nov 2016 17:37:49 +0100
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We experience some limit on the maximum packets in flight which seem not to be related with the receive or write buffers. Does somebody know if there is an issue with a maximum of around 1MByte (or sometimes 2Mbyte) of data in flight per TCP flow?

It seems to be a strict and stable limit independent from the CC (tested with Cubic, Reno and DCTCP). On a link of 200Mbps and 200ms RTT our link is only 20% (sometimes 40%, see conditions below) utilized for a single TCP flow with no drop experienced at all (no bottleneck in the AQM or RTT emulation, as it supports more throughput if multiple flows are active).

Some configuration changes we already tried on both client and server (kernel 3.18.9):

net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_rmem = 4096 87380 6291456
net.ipv4.tcp_wmem = 4096 16384 4194304

SERVER# ss -i
tcp    ESTAB      0      1049728  10.187.255.211:46642     10.187.16.194:ssh
	 dctcp wscale:7,7 rto:408 rtt:204.333/0.741 ato:40 mss:1448 cwnd:1466 send 83.1Mbps unacked:728 rcv_rtt:212 rcv_space:29200
CLIENT# ss -i
tcp    ESTAB      0      288      10.187.16.194:ssh      10.187.255.211:46642
	 dctcp wscale:7,7 rto:404 rtt:203.389/0.213 ato:40 mss:1448 cwnd:78 send 4.4Mbps unacked:8 rcv_rtt:204 rcv_space:1074844

When increasing the write and receive mem further (they were already way above 1 or 2 MB) it steps to double (40%; 2Mbytes in flight):
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_rmem = 4096 8000000 16291456
net.ipv4.tcp_wmem = 4096 8000000 16291456

SERVER # ss -i
tcp    ESTAB      0      2068976  10.187.255.212:54637     10.187.16.112:ssh
	 cubic wscale:8,8 rto:404 rtt:202.622/0.061 ato:40 mss:1448 cwnd:1849 ssthresh:1140 send 105.7Mbps unacked:1457 rcv_rtt:217.5 rcv_space:29200
CLIENT# ss -i
tcp    ESTAB      0      648      10.187.16.112:ssh      10.187.255.212:54637
	 cubic wscale:8,8 rto:404 rtt:201.956/0.038 ato:40 mss:1448 cwnd:132 send 7.6Mbps unacked:18 rcv_rtt:204 rcv_space:2093044

Further increasing (x10) does not help anymore...
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_rmem = 4096 80000000 162914560
net.ipv4.tcp_wmem = 4096 80000000 162914560

As all these parameters autotune, it is hard to find out which one is limiting... In the examples, above unacked does not want to go higher, while congestion window in the server is big enough... rcv_space could be limiting, but it tunes up if I change the server with the higher buffers (switching to 2MByte in flight).

We also tried tcp_limit_output_bytes, setting it bigger (x10) and smaller(/10), without effect. We've put it in /etc/sysctl.conf and rebooted, to make sure that it is effective.

Some more detailed tests that had an effect on the 1 or 2MByte:
- It seems that with TSO off, if we configure a bigger wmem buffer, an ongoing flow suddenly is able to immediately double its bytes in flight limit. We configured further up to more than 10x the buffer, but no further increase helps, and the limits we saw are only 1MByte and 2Mbyte (no intermediate values depending on any parameter). When setting tcp_wmem smaller again, the 2MByte limit stays on the ongoing flow. We have to restart the flow to make the buffer reduction to 1MByte effective.
- With TSO on, only the 2MByte limit is effective, independent from the wmem buffer. We have to restart the flow to make a tso change effective.

Koen.
