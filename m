From: Cong Wang <cwang@twopensource.com>
Subject: igb driver randomly truncates packets
Date: Mon, 27 Apr 2015 12:09:15 -0700
Message-ID: <CAHA+R7OhiJVNDMLOeQZEZ8u0gKu7X=31kLXXv=wkW3cMdysvug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev <netdev@vger.kernel.org>, intel-wired-lan@lists.osuosl.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33896 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753040AbbD0TJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 15:09:17 -0400
Received: by wicmx19 with SMTP id mx19so91301431wic.1
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 12:09:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, all


We saw some packet corruptions with igb driver after upgrading to 3.14
kernel, but we have no idea how to reproduce it. Below are my
observations for debugging:

1) This is probably a regression from 3.10 to 3.14 as we don't see any
issue with 3.10 kernel. Someone else reported similar regression too:

https://www.mail-archive.com/e1000-devel%40lists.sourceforge.net/msg10105.html

# ethtool -i eth0
driver: igb
version: 5.0.5-k
firmware-version: 1.4.3
bus-info: 0000:01:00.0

2) It seems the interface needs to be in some status to trigger this
bug: before this, there was no bug; after this, the bug always happens
randomly on every 3 packets or so.

3) It doesn't always truncate packets, sometimes it fills in more
(garbage) data than expect, see below:

17:31:45.719107 IP (tos 0x0, ttl  56, id 62032, offset 0, flags
[none], proto: ICMP (1), length: 91) 172.25.141.57 > 10.40.73.112:
ICMP echo request, id 14715, seq 3, length 71
0x0000:  008c fa00 8934 0001 e882 3f42 0800 4500
0x0010:  005b f250 0000 3801 0367 ac19 8d39 0a28
0x0020:  4970 0800 30e3 397b 0003 553e 728e 0001
0x0030:  ee1b 0809 0a0b 0c0d 0e0f 1011 1213 1415
0x0040:  1617 1819 1a1b 1c1d 1e1f 2021 2223 2425
0x0050:  2627 2829 2a2b 2c2d 2e2f 3031 3233 3435
0x0060:  3637 3839 3a3b 3c3d 3e61 e06c

(the last "61 e06c" bytes are garbage.)

17:31:46.717448 IP truncated-ip - 3 bytes missing! (tos 0x0, ttl  56,
id 37686, offset 0, flags [none], proto: ICMP (1), length: 91)
172.25.141.57 > 10.40.73.112: ICMP echo request, id 14715, seq 4,
length 71
0x0000:  008c fa00 8934 0001 e882 3f42 0800 4500
0x0010:  005b 9336 0000 3801 6281 ac19 8d39 0a28
0x0020:  4970 0800 2d2e 397b 0004 553e 728f 0001
0x0030:  f1ce 0809 0a0b 0c0d 0e0f 1011 1213 1415
0x0040:  1617 1819 1a1b 1c1d 1e1f 2021 2223 2425
0x0050:  2627 2829 2a2b 2c2d 2e2f 3031 3233 3435
0x0060:  3637 3839 3a3b

("3c3d 3e" bytes are truncated.)

Checking the trace events on napi, I don't see anything wrong with
regarding to skb fields etc, this is why I suspect it is related to
igb hardware (e.g. registers, rx rings), which is beyond my knowledge.

Again, given that we don't know how to reproduce this issue, we can't
check if the latest upstream has the same issue or not, nor we can do
any bisect.

But I am very happy to provide any other information if you need, as
long as I can. ;)

Thanks!
