From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14875] New: iproute2: problems with
 "tc filter replace" and u32 hashing filters
Date: Mon, 4 Jan 2010 12:33:14 -0800
Message-ID: <20100104123314.a8e1de57.akpm@linux-foundation.org>
References: <bug-14875-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, stas@crypt.org.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46451 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752260Ab0ADUdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 15:33:24 -0500
In-Reply-To: <bug-14875-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 25 Dec 2009 02:24:00 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14875
> 
>            Summary: iproute2: problems with "tc filter replace" and u32
>                     hashing filters
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.32
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: low
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: stas@crypt.org.ru
>         Regression: No
> 
> 
> I'm using u32 hashing filters and have some issues with "tc filter replace"
> command.
> 
> Issue 1: "tc filter replace" command does not replace filters inside u32 hash
> tables and works like "tc filter add" command.
> 
> Consider the following scenario:
> 
> 1. Create qdisc and hashing filters for 10.0.0.0/24 network
> 
> tc qdisc add dev eth1 root handle 1: htb
> tc filter add dev eth1 parent 1:0 pref 10 protocol ip u32
> tc filter add dev eth1 parent 1:0 pref 10 handle 100: protocol ip \
>     u32 divisor 256
> tc filter add dev eth1 parent 1:0 pref 10 protocol ip u32 ht 800:: \
>     match ip src 10.0.0.0/24 hashkey mask 0x000000ff at 12 link 100:
> tc filter add dev eth1 parent 1:0 protocol ip pref 30 u32 \
>     match u32 0x0 0x0 at 0 police mtu 1 action drop
> 
> 2. Add filter for IP-address 10.0.0.1
> 
> tc class add dev eth1 parent 1: classid 1:3 htb rate 256kibit ceil 256kibit
> tc qdisc add dev eth1 parent 1:3 handle 3:0 pfifo limit 50
> tc filter add dev eth1 parent 1: pref 20 u32 ht 100:1: \
>     match ip src 10.0.0.1 flowid 1:3
> 
> 3. Try to replace filter for 10.0.0.1 with a new one for 10.0.0.2
> 
> tc filter replace dev eth1 parent 1: pref 20 u32 ht 100:1: \
>     match ip src 10.0.0.2 flowid 1:3
> 
> I expect that filter for 10.0.0.1 in hash table 100:1: have been replaced by
> new
> rule for 10.0.0.2. But "tc -p filter show dev eth1" outputs two filters for
> both 10.0.0.1 and 10.0.0.2:
> 
> filter parent 1: protocol ip pref 10 u32 fh 100:1:800 order 2048 key ht 100
>  bkt 1 flowid 1:3
>   match IP src 10.0.0.1/32
> filter parent 1: protocol ip pref 10 u32 fh 100:1:801 order 2049 key ht 100
>  bkt 1 flowid 1:3
>   match IP dst 10.0.0.2/32
> 
> It means that "tc filter replace" command did not delete the filter 100:1:800, 
> but attached a new one with handle 100:1:801, just like the "tc filter add" 
> command. I think it is a wrong behaviour for "replace" command.
> 
> 
> Issue 2: It seems that tc does not provide any syntax to replace a single
> filter
> inside the hash table. The command with explicit handle number
> 
> tc filter replace dev eth1 parent 1: pref 20 u32 ht 100:1:800 \
>     match ip dst 10.0.0.3 flowid 1:3
> 
> gives the error message: "ht" must be a hash table.
> 
> The similar command with "handle 100:1:800" prints "What is "handle"?" and
> usage information.
> 
> The following sequence of "del" and "add" commands works:
> 
> tc filter del dev eth1 parent 1: pref 10 handle 100:1:800 u32
> tc filter add dev eth1 parent 1: pref 20 u32 ht 100:1: \
>     match ip src 10.0.0.1 flowid 1:3
> 
> Note, that "del" command works only when I use "pref 10" (preference value 
> for hashing filter 100:), but in "add" command I specified "pref 20"
> (preference for 100:1:800 filter). This is little counterintuitive, but not
> very important.
> 
> 
> My suggestions about fixing of "tc filter replace" behaviour.
> 
> 1. The "replace" command with "ht" argument
> 
> tc filter replace dev eth1 parent 1: pref 20 u32 ht 100:1: match ...
> 
> should empty the whole table 100:1: and add a new filter with handle 100:1:800.
> 
> 2. The command with "handle" argument
> 
> tc filter replace dev eth1 parent 1: pref 20 u32 handle 100:1:800 match ...
> 
> should replace only one filter with handle 100:1:800.
> 
> Thanks for attention.

