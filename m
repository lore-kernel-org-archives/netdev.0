From: "Djalel Chefrour" <cdjalel@gmail.com>
Subject: Does HTB traffic shaping happen on leaf classes only or could it happen at root qdisc
Date: Tue, 18 Mar 2008 13:39:24 +0100
Message-ID: <4a9dfdec0803180539wb2f9dc7n18cac81a2fe92345@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:41525 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261AbYCRMj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2008 08:39:27 -0400
Received: by wf-out-1314.google.com with SMTP id 28so5947951wff.4
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2008 05:39:24 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

According to Traffic-Control-HOWTO
(http://tldp.org/HOWTO/Traffic-Control-HOWTO/classful-qdiscs.html),
with HTB scheduler, traffic is only throttled in leaf classes.
I wonder if this is true in recent implementations ?

In the log below, with kernel 2.6.12.6, "overlimits" increases only
for "root qdisc",
While uplink rate is 256kbs and I am sending 100kbps to high prio class 1:110
and doing ftp upload through class 1:20.

# tc -s -d qdisc show dev ppp0
qdisc htb 1: r2q 10 default 20 direct_packets_stat 2 ver 3.17
 Sent 8926254 bytes 23133 pkts (dropped 0, overlimits 37101 )
 backlog 82p
qdisc pfifo 110: parent 1:110 limit 50p
 Sent 3887561 bytes 19364 pkts (dropped 0, overlimits 0 )
qdisc pfifo 120: parent 1:120 limit 50p
 Sent 0 bytes 0 pkts (dropped 0, overlimits 0 )
qdisc sfq 20: parent 1:20 limit 128p quantum 1492b flows 128/1024 perturb 10sec
 Sent 5037436 bytes 3767 pkts (dropped 0, overlimits 0 )
 backlog 82p

# tc -s -d class show dev ppp0
class htb 1:110 parent 1:10 leaf 110: prio 0 quantum 1375 rate 110Kbit
ceil 220Kbit burst 323b/2 mpu 0b overhead 18b atm cburst 392b/2 mpu 0b
overhead 18b atm level 0
 Sent 3888361 bytes 19368 pkts (dropped 0, overlimits 0)
 rate 7160bit 35pps
 lended: 19348 borrowed: 20 giants: 50
 tokens: 2404 ctokens: 3813

class htb 1:1 root rate 256Kbit ceil 256Kbit burst 1760b/8 mpu 0b
overhead 18b atm cburst 1760b/8 mpu 0b overhead 18b atm level 7
 Sent 8806437 bytes 23055 pkts (dropped 0, overlimits 0)
 rate 26913bit 49pps
 lended: 2365 borrowed: 0 giants: 0
 tokens: -86236 ctokens: -86236

class htb 1:10 parent 1:1 rate 210Kbit ceil 256Kbit burst 1730b/8 mpu
0b overhead 18b atm cburst 1760b/8 mpu 0b overhead 18b atm level 6
 Sent 3888361 bytes 19368 pkts (dropped 0, overlimits 0)
 rate 7279bit 36pps
 lended: 20 borrowed: 0 giants: 0
 tokens: 45750 ctokens: 38273

class htb 1:20 parent 1:1 leaf 20: prio 7 quantum 1500 rate 46Kbit
ceil 256Kbit burst 1627b/8 mpu 0b overhead 18b atm cburst 1760b/8 mpu
0b overhead 18b atm level 0
 Sent 5038928 bytes 3768 pkts (dropped 0, overlimits 0)
 rate 160Kbit 13pps backlog 81p
 lended: 1322 borrowed: 2365 giants: 0
 tokens: -154108 ctokens: -41778

class htb 1:120 parent 1:10 leaf 120: prio 1 quantum 1250 rate 100Kbit
ceil 100Kbit burst 317b/2 mpu 0b overhead 18b atm cburst 317b/2 mpu 0b
overhead 18b atm level 0
 Sent 0 bytes 0 pkts (dropped 0, overlimits 0)
 lended: 0 borrowed: 0 giants: 0
 tokens: 20840 ctokens: 20840


Normally traffic sent to 1:110 should not be delayed, but I am
experiencing an important latency there,
also traffic going 1:20 should is not dropped as one would expect !!!

Does this mean traffic is shaped at the root qdisc before it is
classified and sent down ?

TIA
-- 
Dr Djalel Chefrour,
Software Consultant
