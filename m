From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15379] New: u32 classifier port range
 calculation error
Date: Wed, 24 Feb 2010 14:52:20 -0800
Message-ID: <20100224145220.da5ec0b0.akpm@linux-foundation.org>
References: <bug-15379-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, reinaldoc@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51251 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758042Ab0BXWxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 17:53:04 -0500
In-Reply-To: <bug-15379-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 23 Feb 2010 20:56:09 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=15379
> 
>            Summary: u32 classifier port range calculation error
>            Product: Networking
>            Version: 2.5
>     Kernel Version: All (2.6.32 tested)
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: reinaldoc@gmail.com
>         Regression: No
> 
> 
> U32 classifier have a problem on mask calculation of IP port range value.
> 
> To reproduce the problem:
> 
> ##### MASK CALCULATION FOR PORT RANGE 6880->6911
> 
> echo "obase=16;(2^13)-32" | bc
> 1FE0
> 
> Example:
> 
> ###### TC SAMPLE RULES
> tc qdisc del dev eth0 root >/dev/null 2>&1
> 
> tc qdisc  add dev eth0 root handle 1: htb default 1100
> tc class  add dev eth0 root classid 1:1000 htb rate 1000Mbit ceil 1000Mbit
> tc class  add dev eth0 classid 1:1100 parent 1:1000 htb prio 0 rate 999Mbit
> ceil 999Mbit
> tc class  add dev eth0 classid 1:1200 parent 1:1000 htb prio 0 rate 1Mbit  
> ceil 1Mbit
> 
> tc filter add dev eth0 protocol ip prio 1 parent 1: u32 flowid 1:1200 match ip
> dport 6880 0x1FE0
> 
> ###### STATS CLEAN ** success 0
> tc -s filter show dev eth0
> filter parent 1: protocol ip pref 1 u32
> filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1
> filter parent 1: protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0
> flowid 1:1200  (rule hit 116 success 0)
>   match 00001ae0/00001fe0 at 20 (success 0 )
> 
> ###### SENDING PACKETS I
> # nmap example.ufpa.br -p 1-10000
> 
> ###### STATS I ** success 32 (OK)
> # tc -s filter show dev eth0
> filter parent 1: protocol ip pref 1 u32
> filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1
> filter parent 1: protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0
> flowid 1:1200  (rule hit 12676 success 32)
>   match 00001ae0/00001fe0 at 20 (success 32 )
> 
> ###### SENDING PACKETS II
> # nmap example.ufpa.br -p 10000-20000
> 
> ###### STATS II ** success 64 (ERROR) - should not match
> 
> # tc -s filter show dev eth0
> filter parent 1: protocol ip pref 1 u32
> filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1
> filter parent 1: protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0
> flowid 1:1200  (rule hit 25172 success 64)
>   match 00001ae0/00001fe0 at 20 (success 64 )
> 
> ###### SENDING PACKETS III
> # nmap example.ufpa.br -p 20000-30000
> 
> ###### STATS III ** success 96 (ERROR) - should not match
> 
> # tc -s filter show dev eth0
> filter parent 1: protocol ip pref 1 u32
> filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1
> filter parent 1: protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0
> flowid 1:1200  (rule hit 43131 success 96)
>   match 00001ae0/00001fe0 at 20 (success 96 )
> 
> ### End

