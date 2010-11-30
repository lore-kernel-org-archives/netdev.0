From: Rui <wirelesser@gmail.com>
Subject: multi bpf filter will impact performance?
Date: Tue, 30 Nov 2010 17:22:50 +0800
Message-ID: <AANLkTikx68M43+vv+Rav_HCJMJnuc15TtuBgmbv2xP=U@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:58694 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752623Ab0K3JWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 04:22:51 -0500
Received: by pwj3 with SMTP id 3so893980pwj.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 01:22:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi

I did a test with an intel X520 10Gnic, HP DL380 G6,  to see how the
bpf filter will impact the performance.

kernel .2.6.32 SLES11+SP1, original ixgbe driver

step 0:
launch 4 tcpdump processes,each applied a filter to filter out some
GTP-U packets. seen with 'tcpdump -d', the bpf code has about 100
lines.

#!/bin/sh
PCAP_FRAMES=32000 ./tcpdump_MMAP -i eth4 'udp dst port 2152 and (
(((ether[48:1]&0x07)>0) and
(((ether[66:1]+ether[67:1]+ether[68:1]+ether[69:1]+ether[70:1]+ether[71:1]+ether[72:1]+ether[73:1])&0x03)==0))
or (((ether[48:1]&0x07)==0) and
(((ether[62:1]+ether[63:1]+ether[64:1]+ether[65:1]+ether[66:1]+ether[67:1]+ether[68:1]+ether[69:1])&0x03)==0))
) ' -w /dev/null -s 4096 2>f1.log &
PCAP_FRAMES=32000 ./tcpdump_MMAP -i eth4 'udp dst port 2152 and (
(((ether[48:1]&0x07)>0) and
(((ether[66:1]+ether[67:1]+ether[68:1]+ether[69:1]+ether[70:1]+ether[71:1]+ether[72:1]+ether[73:1])&0x03)==1))
or (((ether[48:1]&0x07)==0) and
(((ether[62:1]+ether[63:1]+ether[64:1]+ether[65:1]+ether[66:1]+ether[67:1]+ether[68:1]+ether[69:1])&0x03)==1))
) ' -w /dev/null -s 4096 2>f2.log &
PCAP_FRAMES=32000 ./tcpdump_MMAP -i eth4 'udp dst port 2152 and (
(((ether[48:1]&0x07)>0) and
(((ether[66:1]+ether[67:1]+ether[68:1]+ether[69:1]+ether[70:1]+ether[71:1]+ether[72:1]+ether[73:1])&0x03)==2))
or (((ether[48:1]&0x07)==0) and
(((ether[62:1]+ether[63:1]+ether[64:1]+ether[65:1]+ether[66:1]+ether[67:1]+ether[68:1]+ether[69:1])&0x03)==2))
) ' -w /dev/null -s 4096 2>f3.log &
PCAP_FRAMES=32000 ./tcpdump_MMAP -i eth4 'udp dst port 2152 and (
(((ether[48:1]&0x07)>0) and
(((ether[66:1]+ether[67:1]+ether[68:1]+ether[69:1]+ether[70:1]+ether[71:1]+ether[72:1]+ether[73:1])&0x03)==3))
or (((ether[48:1]&0x07)==0) and
(((ether[62:1]+ether[63:1]+ether[64:1]+ether[65:1]+ether[66:1]+ether[67:1]+ether[68:1]+ether[69:1])&0x03)==3))
) ' -w /dev/null -s 4096 2>f4.log &


step1:
use stress test equipment to generate traffic >1.2Gbps


step2:
type 'ifconfig eth4'
saw many packets dropped

step3:
type 'sar -n DEV 1', the incoming throughput limited at 800Mbps


my questions:

Q1. the bpf filter is run one by one? will only one filter be executed
for one sock? (so that the tcpdump corresponding kernel part will run
filter in parallel?)

Q2. performance is bad? any idea to improve it?

thanks a lot
rui
