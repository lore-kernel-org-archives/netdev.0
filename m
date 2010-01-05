From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 14875] New: iproute2: problems with "tc filter
 replace" and u32 hashing filters
Date: Tue, 05 Jan 2010 05:46:56 +0100
Message-ID: <4B42C440.3070906@trash.net>
References: <bug-14875-10286@http.bugzilla.kernel.org/> <20100104123314.a8e1de57.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, stas@crypt.org.ru
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48200 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146Ab0AEErF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 23:47:05 -0500
In-Reply-To: <20100104123314.a8e1de57.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=14875
>>
>> I'm using u32 hashing filters and have some issues with "tc filter replace"
>> command.
>>
>> Issue 1: "tc filter replace" command does not replace filters inside u32 hash
>> tables and works like "tc filter add" command.
>>
>> Consider the following scenario:
>>
>> ...
>> 2. Add filter for IP-address 10.0.0.1
>>
>> tc class add dev eth1 parent 1: classid 1:3 htb rate 256kibit ceil 256kibit
>> tc qdisc add dev eth1 parent 1:3 handle 3:0 pfifo limit 50
>> tc filter add dev eth1 parent 1: pref 20 u32 ht 100:1: \
>>     match ip src 10.0.0.1 flowid 1:3
>>
>> 3. Try to replace filter for 10.0.0.1 with a new one for 10.0.0.2
>>
>> tc filter replace dev eth1 parent 1: pref 20 u32 ht 100:1: \
>>     match ip src 10.0.0.2 flowid 1:3
>>
>> I expect that filter for 10.0.0.1 in hash table 100:1: have been replaced by
>> new
>> rule for 10.0.0.2. But "tc -p filter show dev eth1" outputs two filters for
>> both 10.0.0.1 and 10.0.0.2:
>>
>> filter parent 1: protocol ip pref 10 u32 fh 100:1:800 order 2048 key ht 100
>>  bkt 1 flowid 1:3
>>   match IP src 10.0.0.1/32
>> filter parent 1: protocol ip pref 10 u32 fh 100:1:801 order 2049 key ht 100
>>  bkt 1 flowid 1:3
>>   match IP dst 10.0.0.2/32
>>
>> It means that "tc filter replace" command did not delete the filter 100:1:800, 
>> but attached a new one with handle 100:1:801, just like the "tc filter add" 
>> command. I think it is a wrong behaviour for "replace" command.

You need to specify a handle for the filters to get replaced.

tc filter add dev eth1 parent 1: pref 20 handle 100:1 u32 ht 100:1: \
    match ip src 10.0.0.1 flowid 1:3

tc filter replace dev eth1 parent 1: pref 20 handle 100:1 u32 ht 100:1: \
    match ip src 10.0.0.2 flowid 1:3

works fine.

>> Issue 2: It seems that tc does not provide any syntax to replace a single
>> filter
>> inside the hash table. The command with explicit handle number
>>
>> tc filter replace dev eth1 parent 1: pref 20 u32 ht 100:1:800 \
>>     match ip dst 10.0.0.3 flowid 1:3
>>
>> gives the error message: "ht" must be a hash table.
>>
>> The similar command with "handle 100:1:800" prints "What is "handle"?" and
>> usage information.

Handles consist of a major and minor number, not three numbers,
see above.
