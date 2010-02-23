From: Reinaldo Carvalho <reinaldow@gmail.com>
Subject: u32 classifier port range calculation error
Date: Tue, 23 Feb 2010 18:22:28 -0300
Message-ID: <ec36785a1002231322q5da33c2fk158d5c9b3be9c31d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f219.google.com ([209.85.220.219]:51464 "EHLO
	mail-fx0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753755Ab0BWVWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 16:22:30 -0500
Received: by fxm19 with SMTP id 19so4312056fxm.21
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2010 13:22:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

== I'am not in netdev, please cc my addresss. ==

U32 classifier have a problem (?) on mask calculation of IP port range value.

To reproduce the problem:

##### MASK CALCULATION FOR PORT RANGE 6880->6911

echo "obase=16;(2^13)-32" | bc
1FE0

Example:

###### TC SAMPLE RULES
tc qdisc del dev eth0 root >/dev/null 2>&1

tc qdisc  add dev eth0 root handle 1: htb default 1100
tc class  add dev eth0 root classid 1:1000 htb rate 1000Mbit ceil 1000Mbit
tc class  add dev eth0 classid 1:1100 parent 1:1000 htb prio 0 rate 999Mbit
ceil 999Mbit
tc class  add dev eth0 classid 1:1200 parent 1:1000 htb prio 0 rate 1Mbit
ceil 1Mbit

tc filter add dev eth0 protocol ip prio 1 parent 1: u32 flowid 1:1200 match ip
dport 6880 0x1FE0

###### STATS CLEAN ** success 0
tc -s filter show dev eth0
filter parent 1: protocol ip pref 1 u32
filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1
filter parent 1: protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0
flowid 1:1200  (rule hit 116 success 0)
  match 00001ae0/00001fe0 at 20 (success 0 )

###### SENDING PACKETS I
# nmap example.ufpa.br -p 1-10000

###### STATS I ** success 32 (OK)
# tc -s filter show dev eth0
filter parent 1: protocol ip pref 1 u32
filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1
filter parent 1: protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0
flowid 1:1200  (rule hit 12676 success 32)
  match 00001ae0/00001fe0 at 20 (success 32 )

###### SENDING PACKETS II
# nmap example.ufpa.br -p 10000-20000

###### STATS II ** success 64 (ERROR) - should not match

# tc -s filter show dev eth0
filter parent 1: protocol ip pref 1 u32
filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1
filter parent 1: protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0
flowid 1:1200  (rule hit 25172 success 64)
  match 00001ae0/00001fe0 at 20 (success 64 )

###### SENDING PACKETS III
# nmap example.ufpa.br -p 20000-30000

###### STATS III ** success 96 (ERROR) - should not match

# tc -s filter show dev eth0
filter parent 1: protocol ip pref 1 u32
filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1
filter parent 1: protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0
flowid 1:1200  (rule hit 43131 success 96)
  match 00001ae0/00001fe0 at 20 (success 96 )

### End

Thanks

[]s

-- 
Reinaldo Carvalho
