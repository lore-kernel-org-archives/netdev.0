From: Stanislav Kruchinin <stas@crypt.org.ru>
Subject: Re: [Bugme-new] [Bug 14875] New: iproute2: problems with "tc filter
 replace" and u32 hashing filters
Date: Tue, 05 Jan 2010 19:00:42 +0300
Message-ID: <4B43622A.9010409@crypt.org.ru>
References: <bug-14875-10286@http.bugzilla.kernel.org/> <20100104123314.a8e1de57.akpm@linux-foundation.org> <4B42C440.3070906@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crypt.org.ru ([94.242.1.30]:3231 "EHLO crypt.org.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754852Ab0AEQK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jan 2010 11:10:57 -0500
In-Reply-To: <4B42C440.3070906@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05.01.2010 7:46, Patrick McHardy wrote:
>>> Issue 1: "tc filter replace" command does not replace filters inside u32 hash
>>> tables and works like "tc filter add" command.
> 
> You need to specify a handle for the filters to get replaced.
> 
> tc filter add dev eth1 parent 1: pref 20 handle 100:1 u32 ht 100:1: \
>     match ip src 10.0.0.1 flowid 1:3
> 
> tc filter replace dev eth1 parent 1: pref 20 handle 100:1 u32 ht 100:1: \
>     match ip src 10.0.0.2 flowid 1:3
> 
> works fine.

Thank you, this solves the first issue, but it's little odd that "replace"
command require both "handle" and "ht" parameters, whereas "tc filter del"
command takes only a "handle" parameter.

Me and some of my colleagues are going to write a "tc-u32" and "tc-flow"
manpages to document the tc syntax for u32 filter and for new "flow" filter.
These documents could be useful for other people, and I might want to publish
them. May I ask you, who is the current maintainer of iproute2 manpages?

>>> Issue 2: It seems that tc does not provide any syntax to replace a single
>>> filter inside the hash table. The command with explicit handle number
> 
> Handles consist of a major and minor number, not three numbers,
> see above.

Yes, but in case of u32 filters one can add a number of rules to a single hash
bucket. These filters will be numbered as follows: 100:1:800, 100:1:801, etc.
And "tc filter ..." commands accept a handles like 100:1:800 without any errors.
The problem is that there is no way to address these filters using "replace"
command, whereas "del/add" commands perform well.

After execution of the following commands
tc filter add dev eth1 parent 1: pref 20 handle 100:1 u32 ht 100:1: \
   match ip src 10.0.0.1 flowid 1:3
tc filter add dev eth1 parent 1: pref 20 handle 100:1 u32 ht 100:1: \
   match ip src 10.0.0.2 flowid 1:3

we will have 100:1:800 filter that matches 10.0.0.1, and 100:1:801 that matches
10.0.0.2.

The following command
tc filter replace dev eth1 parent 1: pref 20 handle 100:1:801 u32 ht 100:1: \
   match ip src 10.0.0.3 flowid 1:3

gives no error messages but does not replace the IP address in the filter
100:1:801, and adds one more filter with number 100:1:801 for IP 10.0.0.3. As I
wrote before, the sequence of "del" and "add" commands works OK with
three-number handles.

tc filter del dev eth1 parent 1: pref 20 handle 100:1:801 u32
tc filter add dev eth1 parent 1: pref 20 u32 ht 100:1: \
   match ip src 10.0.0.3 flowid 1:3

Once again, thanks for a quick reply.
