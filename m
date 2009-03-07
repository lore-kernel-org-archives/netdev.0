From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: skbedit action chaining with other actions - will fail
Date: Sun, 8 Mar 2009 01:15:41 +0200
Message-ID: <200903080115.41617.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	alexander.h.duyck@intel.com, shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:60415 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbZCGXPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2009 18:15:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If i am chaining skbedit with other action, packets will not come in next (by 
order) action. Here is example:

Command
    echo "filter add dev $2 parent ffff: protocol ip prio 10 u32 \
match u32 0 0 flowid 1:1 \
action skbedit priority 0x${lowid} \
action mirred egress redirect dev ifb0"

and for ipt example
    echo "filter add dev $2 parent ffff: protocol ip prio 10 u32 \
match u32 0 0 flowid 1:1 \
action ipt -j MARK --set-mark ${id} \
action mirred egress redirect dev ifb0"


Here is skbedit (mirred will fail)

filter protocol ip pref 10 u32 fh 801::800 order 2048 key ht 801 bkt 0 flowid 
1:1  (rule hit 569 success 569)
  match 00000000/00000000 at 0 (success 569 )
        action order 1:  skbedit priority :7 installed 121 sec used 8 sec       
Action statistics:
        Sent 103528 bytes 569 pkt (dropped 0, overlimits 0 requeues 0)
        rate 0bit 0pps backlog 0b 0p requeues 0

        action order 2: mirred (Egress Redirect to device ifb0) stolen
        index 706 ref 1 bind 1 installed 121 sec used 121 sec
        Action statistics:
        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
        rate 0bit 0pps backlog 0b 0p requeues 0

But for example ipt works fine
filter protocol ip pref 10 u32 fh 801::800 order 2048 key ht 801 bkt 0 flowid 
1:1  (rule hit 5023 success 5023)
  match 00000000/00000000 at 0 (success 5023 )
        action order 1: tablename: mangle  hook: NF_IP_PRE_ROUTING
        target MARK xset 0x65/0xffffffff
        index 190508 ref 1 bind 1 installed 792 sec used 0 sec
        Action statistics:
        Sent 999442 bytes 5023 pkt (dropped 0, overlimits 0 requeues 0)
        rate 0bit 0pps backlog 0b 0p requeues 0

        action order 2: mirred (Egress Redirect to device ifb0) stolen
        index 190508 ref 1 bind 1 installed 792 sec used 0 sec
        Action statistics:
        Sent 999442 bytes 5023 pkt (dropped 0, overlimits 0 requeues 0)
        rate 0bit 0pps backlog 0b 0p requeues 0




