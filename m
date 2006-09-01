From: "Matthias Urlichs" <matthias@urlichs.de>
Subject: TCP send/ack lockstep problem
Date: Fri, 1 Sep 2006 21:48:57 +0000 (UTC)
Message-ID: <eda9s9$bgq$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:65221 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1751102AbWIAWZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 18:25:05 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1GJHRd-0002Gp-L1
	for netdev@vger.kernel.org; Sat, 02 Sep 2006 00:25:01 +0200
Received: from smurf.noris.de ([192.109.102.42])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2006 00:25:01 +0200
Received: from matthias by smurf.noris.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2006 00:25:01 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I have a problem with a TCP connection here which just doesn't
want to have multiple packets on the wire.

I have verified that the sender has enough buffered data (netstat -t
shows 8..10k send buffer). There's no packet loss. The tcpdump
(attached) shows that the receiver increases its window correctly --
the sender just seems to ignore that.

Any ideas? Is the sending program doing something stupid? If so, what?

tcpdump (on the sender's interface; Ubuntu kernel 2.6.15-23):
11:00:02.101523 IP (tos 0x34, ttl  53, id 19121, offset 0, flags [DF], proto: TCP (6), length: 60) 62.193.238.120.33126 > 192.109.102.42.3306: S, cksum 0x130b (correct), 3222543538:3222543538(0) win 5840 <mss 1460,sackOK,timestamp 1550801950,nop,wscale 2>
11:00:02.101566 IP (tos 0x34, ttl  64, id 0, offset 0, flags [DF], proto: TCP (6), length: 60) 192.109.102.42.3306 > 62.193.238.120.33126: S, cksum 0xcff6 (correct), 1482874191:1482874191(0) ack 3222543539 win 5696 <mss 1100,sackOK,timestamp 150079063 155080195,nop,wscale 2>
11:00:02.149295 IP (tos 0x34, ttl  53, id 50966, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.33115 > 192.109.102.42.3306: ., cksum 0x2703 (correct), 86:86(0) ack 99 win 1460 <nop,nop,timestamp 155080241 150079062>
11:00:02.153222 IP (tos 0x34, ttl  53, id 19122, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.33126 > 192.109.102.42.3306: ., cksum 0x0daf (correct), 1:1(0) ack 1 win 1460 <nop,nop,timestamp 155080246 150079063>
11:00:02.153504 IP (tos 0x38, ttl  64, id 56076, offset 0, flags [DF], proto: TCP (6), length: 127) 192.109.102.42.3306 > 62.193.238.120.33126: P 1:76(75) ack 1 win 1424 <nop,nop,timestamp 150079068 155080246>
11:00:02.166282 IP (tos 0x38, ttl  64, id 27087, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.33821: P 1015273:1016689(1416) ack 0 win 1424 <nop,nop,timestamp 150079070 155079804>
11:00:02.190953 IP (tos 0x34, ttl  53, id 19123, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.33126 > 192.109.102.42.3306: ., cksum 0x0d39 (correct), 1:1(0) ack 76 win 1460 <nop,nop,timestamp 155080284 150079068>
11:00:02.194676 IP (tos 0x0, ttl  53, id 19124, offset 0, flags [DF], proto: TCP (6), length: 116) 62.193.238.120.33126 > 192.109.102.42.3306: P 1:65(64) ack 76 win 1460 <nop,nop,timestamp 155080288 150079068>
11:00:02.194727 IP (tos 0x34, ttl  64, id 56077, offset 0, flags [DF], proto: TCP (6), length: 52) 192.109.102.42.3306 > 62.193.238.120.33126: ., cksum 0x0d15 (correct), 76:76(0) ack 65 win 1424 <nop,nop,timestamp 150079072 155080288>
11:00:02.194835 IP (tos 0x34, ttl  64, id 56078, offset 0, flags [DF], proto: TCP (6), length: 63) 192.109.102.42.3306 > 62.193.238.120.33126: P, cksum 0x05fe (correct), 76:87(11) ack 65 win 1424 <nop,nop,timestamp 150079072 155080288>
11:00:02.223927 IP (tos 0x34, ttl  53, id 64017, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.33821 > 192.109.102.42.3306: ., cksum 0xd02b (correct), 0:0(0) ack 1016689 win 16022 <nop,nop,timestamp 155080317 150079070>
11:00:02.223961 IP (tos 0x38, ttl  64, id 27088, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.33821: P 1016689:1018105(1416) ack 0 win 1424 <nop,nop,timestamp 150079075 155080317>
11:00:02.236030 IP (tos 0x0, ttl  53, id 19125, offset 0, flags [DF], proto: TCP (6), length: 73) 62.193.238.120.33126 > 192.109.102.42.3306: P, cksum 0xcf80 (correct), 65:86(21) ack 87 win 1460 <nop,nop,timestamp 155080329 150079072>
11:00:02.240355 IP (tos 0x38, ttl  64, id 56079, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.33126: . 87:1503(1416) ack 86 win 1424 <nop,nop,timestamp 150079077 155080329>
11:00:02.281126 IP (tos 0x34, ttl  53, id 64018, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.33821 > 192.109.102.42.3306: ., cksum 0xca65 (correct), 0:0(0) ack 1018105 win 16022 <nop,nop,timestamp 155080374 150079075>
11:00:02.375243 IP (tos 0x34, ttl  53, id 19126, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.33126 > 192.109.102.42.3306: ., cksum 0x03bb (correct), 86:86(0) ack 1503 win 2184 <nop,nop,timestamp 155080469 150079077>
11:00:02.385427 IP (tos 0x38, ttl  64, id 56080, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.33126: . 1503:2919(1416) ack 86 win 1424 <nop,nop,timestamp 150079077 155080329>
11:00:02.444747 IP (tos 0x34, ttl  53, id 19127, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.33126 > 192.109.102.42.3306: ., cksum 0xfb19 (correct), 86:86(0) ack 2919 win 2908 <nop,nop,timestamp 155080538 150079077>
11:00:02.444787 IP (tos 0x38, ttl  64, id 56082, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.33126: P 2919:4335(1416) ack 86 win 1424 <nop,nop,timestamp 150079097 155080538>
11:00:02.530953 IP (tos 0x34, ttl  53, id 19128, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.33126 > 192.109.102.42.3306: ., cksum 0xf253 (correct), 86:86(0) ack 4335 win 3632 <nop,nop,timestamp 155080624 150079097>
11:00:02.626367 IP (tos 0x38, ttl  64, id 56083, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.33126: . 4335:5751(1416) ack 86 win 1424 <nop,nop,timestamp 150079106 155080624>
11:00:02.685415 IP (tos 0x34, ttl  53, id 19129, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.33126 > 192.109.102.42.3306: ., cksum 0xe953 (correct), 86:86(0) ack 5751 win 4356 <nop,nop,timestamp 155080779 150079106>
11:00:02.685459 IP (tos 0x38, ttl  64, id 56084, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.33126: . 5751:7167(1416) ack 86 win 1424 <nop,nop,timestamp 150079122 155080779>
11:00:02.741868 IP (tos 0x34, ttl  53, id 19130, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.33126 > 192.109.102.42.3306: ., cksum 0xe0af (correct), 86:86(0) ack 7167 win 5080 <nop,nop,timestamp 155080835 150079122>
11:00:02.866481 IP (tos 0x38, ttl  64, id 56085, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.33126: P 7167:8583(1416) ack 86 win 1424 <nop,nop,timestamp 150079122 155080779>
11:00:02.950319 IP (tos 0x34, ttl  53, id 19131, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.33126 > 192.109.102.42.3306: ., cksum 0xd783 (correct), 86:86(0) ack 8583 win 5804 <nop,nop,timestamp 155081043 150079122>
11:00:02.950357 IP (tos 0x38, ttl  64, id 56087, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.33126: . 8583:9999(1416) ack 86 win 1424 <nop,nop,timestamp 150079148 155081043>
11:00:03.007704 IP (tos 0x34, ttl  53, id 19132, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.33126 > 192.109.102.42.3306: ., cksum 0xced4 (correct), 86:86(0) ack 9999 win 6528 <nop,nop,timestamp 155081100 150079148>
11:00:03.116542 IP (tos 0x38, ttl  64, id 56088, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.33126: P 9999:11415(1416) ack 86 win 1424 <nop,nop,timestamp 150079154 155081100>
11:00:03.176137 IP (tos 0x34, ttl  53, id 19133, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.33126 > 192.109.102.42.3306: ., cksum 0xc5cb (correct), 86:86(0) ack 11415 win 7252 <nop,nop,timestamp 155081267 150079154>
11:00:03.176199 IP (tos 0x38, ttl  64, id 56089, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.33126: . 11415:12831(1416) ack 86 win 1424 <nop,nop,timestamp 150079171 155081267>
11:00:03.237363 IP (tos 0x34, ttl  53, id 19134, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.33126 > 192.109.102.42.3306: ., cksum 0xbd1f (correct), 86:86(0) ack 12831 win 7976 <nop,nop,timestamp 155081330 150079171>
11:00:03.346605 IP (tos 0x38, ttl  64, id 56090, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.33126: . 12831:14247(1416) ack 86 win 1424 <nop,nop,timestamp 150079171 155081267>
11:00:03.409507 IP (tos 0x34, ttl  53, id 19135, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.33126 > 192.109.102.42.3306: ., cksum 0xb416 (correct), 86:86(0) ack 14247 win 8700 <nop,nop,timestamp 155081503 150079171>
11:00:03.409541 IP (tos 0x38, ttl  64, id 56093, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.33126: P 14247:15663(1416) ack 86 win 1424 <nop,nop,timestamp 150079194 155081503>
11:00:03.469395 IP (tos 0x34, ttl  53, id 19136, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.33126 > 192.109.102.42.3306: ., cksum 0xab6a (correct), 86:86(0) ack 15663 win 9424 <nop,nop,timestamp 155081560 150079194>
11:00:03.586735 IP (tos 0x38, ttl  64, id 56094, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.33126: . 15663:17079(1416) ack 86 win 1424 <nop,nop,timestamp 150079200 155081560>


-- 
Matthias Urlichs


-- 
VGER BF report: U 0.5
