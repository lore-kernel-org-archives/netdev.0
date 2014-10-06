From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: refactor out tcf_exts
Date: Mon, 06 Oct 2014 07:20:41 -0400
Message-ID: <54327B09.9070204@mojatatu.com>
References: <1412376709-25564-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060408020607080800010709"
Cc: John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:52805 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbaJFLUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 07:20:45 -0400
Received: by mail-ie0-f169.google.com with SMTP id tp5so3115403ieb.28
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 04:20:45 -0700 (PDT)
In-Reply-To: <1412376709-25564-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060408020607080800010709
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

Sorry for being annoying.
Cong - here's a simple test that will test for both .police and .action
for one classifier. If you have time please run it when updating your
patch.

cheers,
jamal



--------------060408020607080800010709
Content-Type: text/plain; charset=us-ascii;
 name="rsvp-test1"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rsvp-test1"

export TC=/path/to/updatedtc

sudo $TC qdisc del dev eth0 root handle 1:0 prio 
sudo $TC qdisc add dev eth0 root handle 1:0 prio 

sudo $TC filter add dev eth0 pref 10 proto ip parent 1:0 rsvp session 10.0.0.1 ipproto icmp classid 1:1  police rate 1kbit burst 90k conform-exceed drop/ok

#display stats
$TC -s filter show dev eth0 parent 1:0
filter protocol ip pref 10 rsvp 
filter protocol ip pref 10 rsvp fh 0x0001100a flowid 1:1 session 10.0.0.1 ipproto icmp 
 Sent 0 bytes 0 pkts (dropped 0, overlimits 0) 


sudo ping -f 10.0.0.1 -c 10000

#display stats again..
$TC -s filter show dev eth0 parent 1:0

#
#
#lets redo with action semantics (two actions in the graph)
sudo $TC qdisc del dev eth0 root handle 1:0 prio
sudo $TC qdisc add dev eth0 root handle 1:0 prio

sudo $TC filter add dev eth0 pref 10 proto ip parent 1:0 \
rsvp session 10.0.0.1 ipproto icmp \
classid 1:1  \
action police rate 1kbit burst 90k pipe \
action ok

sudo ping -f 10.0.0.1 -c 1000
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
 
--- 10.0.0.1 ping statistics ---
1000 packets transmitted, 1000 received, 0% packet loss, time 377ms
rtt min/avg/max/mdev = 0.282/0.332/0.933/0.042 ms, ipg/ewma 0.378/0.333 ms

#display stats
$TC -s filter show dev eth0 parent 1:0
filter protocol ip pref 10 rsvp 
filter protocol ip pref 10 rsvp fh 0x0001100a flowid 1:1 session 10.0.0.1 ipproto icmp 
	action order 1:  police 0x5 rate 1Kbit burst 23440b mtu 2Kb action pipe overhead 0b 
ref 1 bind 1
	Action statistics:
	Sent 98000 bytes 1000 pkt (dropped 0, overlimits 761 requeues 0) 
	backlog 0b 0p requeues 0 

	action order 2: gact action pass
	 random type none pass val 0
	 index 2 ref 1 bind 1 installed 60 sec used 3 sec
 	Action statistics:
	Sent 74578 bytes 761 pkt (dropped 0, overlimits 0 requeues 0) 
	backlog 0b 0p requeues 0 


--------------060408020607080800010709--
