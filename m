From: Rick Jones <rick.jones2@hp.com>
Subject: Is veth in net-next reordering traffic?
Date: Wed, 06 May 2015 19:04:47 -0700
Message-ID: <554AC83F.7070609@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t5008.houston.hp.com ([15.240.92.66]:56034 "EHLO
	g9t5008.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015AbbEGCEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 22:04:48 -0400
Received: from g9t2301.houston.hp.com (g9t2301.houston.hp.com [16.216.185.78])
	by g9t5008.houston.hp.com (Postfix) with ESMTP id 18B6313E
	for <netdev@vger.kernel.org>; Thu,  7 May 2015 02:04:48 +0000 (UTC)
Received: from [16.103.148.51] (tardy.usa.hp.com [16.103.148.51])
	by g9t2301.houston.hp.com (Postfix) with ESMTP id CD86170
	for <netdev@vger.kernel.org>; Thu,  7 May 2015 02:04:47 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been messing about with a setup approximating what an OpenStack 
Nova Compute node creates for the private networking plumbing when using 
OVX+VxLAN.  Just without the VM.  So, I have a linux bridge (named qbr), 
a veth pair (named qvb and qvo) joining that to an OVS switch (called 
br-int) which then has a patch pair joining that OVS bridge to another 
OVS bridge (br-tun) which has a vxlan tunnel defined.

I've assigned an IP address to the bare interface (an ixgbe-driven Intel 
83599ES - HP 560FLR), to each of the OVS switches and the Linux bridge.

A second system is setup the same way.

The kernel is 4.1.0-rc1+ out of a davem net-next tree from within the 
last two days.

I've set hostnames for the second system on the first as:

10.14.12.22	bareinterface
192.168.2.22	through-br-tun-vxlan
192.168.1.22	through-br-int
192.168.0.22	through-nearfull-stack

So for bareinterface, the traffic is just through the bare interface on 
each side.  through-nearfull-stack goes through the linux bridge and ovs 
switches and then the bare interface and up the corresponding path on 
the receiver:

And then run netperf:

root@qu-stbaz1-perf0000:~# netstat -s > before;HDR="-P 1"; for i in 
bareinterface through-br-tun-vxlan through-br-int 
through-nearfull-stack; do netperf $HDR -c -H $i -t TCP_stream -B $i -- 
-O 
result_brand,throughput,throughput_units,elapsed_time,local_transport_retrans; 
netstat -s > after; ~raj/beforeafter before after | grep -i reord; mv 
after before; HDR="-P 1"; done
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
bareinterface () port 0 AF_INET : demo
Result           Throughput Throughput  Elapsed Local
Tag                         Units       Time    Transport
                                         (sec)   Retransmissions

"bareinterface"  8311.99    10^6bits/s  10.00   66
     Detected reordering 1 times using FACK
     Detected reordering 0 times using SACK
     Detected reordering 0 times using time stamp
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
through-br-tun-vxlan () port 0 AF_INET : demo
Result                  Throughput Throughput  Elapsed Local
Tag                                Units       Time    Transport
                                                (sec)   Retransmissions

"through-br-tun-vxlan"  2845.10    10^6bits/s  10.07   32799
     Detected reordering 0 times using FACK
     Detected reordering 0 times using SACK
     Detected reordering 0 times using time stamp
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
through-br-int () port 0 AF_INET : demo
Result            Throughput Throughput  Elapsed Local
Tag                          Units       Time    Transport
                                          (sec)   Retransmissions

"through-br-int"  3412.14    10^6bits/s  10.01   30141
     Detected reordering 0 times using FACK
     Detected reordering 0 times using SACK
     Detected reordering 0 times using time stamp
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
through-nearfull-stack () port 0 AF_INET : demo
Result                    Throughput Throughput  Elapsed Local
Tag                                  Units       Time    Transport
                                                  (sec)   Retransmissions

"through-nearfull-stack"  2515.64    10^6bits/s  10.01   15339
     Detected reordering 0 times using FACK
     Detected reordering 310608 times using SACK
     Detected reordering 21621 times using time stamp

Once the traffic is through the "nearfull" stack a boatload of 
reordering is detected.

To see if it was on the sending side or the receiving side I gave br-tun 
on the receiving side the ip associated with "through-nearfull-stack" 
and ran that netperf again:

root@qu-stbaz1-perf0000:~# netstat -s > beforestat; netperf -H 
192.168.0.22 -l 10 -- -O throughput,local_transport_retrans; netstat -s 
 > afterstat;~raj/beforeafter beforestat afterstat | grep -i reord
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
192.168.0.22 () port 0 AF_INET : demo
Throughput Local
            Transport
            Retransmissions

2697.98    6208
     Detected reordering 0 times using FACK
     Detected reordering 166519 times using SACK
     Detected reordering 8457 times using time stamp

which makes it seem like the reordering is on the sending side though I 
suppose it is not entirely conclusive.  I have pcaps of a netperf 
through the "nearfull" stack on both sender and receiver, for the 
physical interface (which will be VxLAN encapsulated), the qvo, qvb and 
qvb (i've not yet learned how to get a trace off the OVS patch 
interfaces).  I've put them on netperf.org. for anonymous FTP - the file 
is veth_reordering.tgz and when unpacked will create a veth_reordering/ 
with all six captures in it.

Looking at the send_qvb trace in tcptrace/xplot looks "clean" as far as 
out of order is concerned.  looking at the send_qvo trace suggests out 
of order but is a little confusing.  There may be some packets in the 
trace out of timestamp order.  Can't really look at the physical 
interface trace with tcptrace because it doesn't know about VxLAN.  When 
I looked briefly with stone knives and bear skins at the sending side 
physical interface trace it did seem to show reordering though.

happy benchmarking,

rick jones
