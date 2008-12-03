From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [PATCH] net: fix /proc/net/ip_mr_cache display
Date: Wed, 03 Dec 2008 14:48:19 +0100
Message-ID: <49368E23.6070406@bull.net>
References: <493415B4.7020600@bull.net>	<20081201093341.537bf03d@extreme>	<20081201211702.a8cjo5p08wscwcwg@intran0x.frec.bull.fr> <20081202.150330.157587697.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:46755 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859AbYLCNsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 08:48:22 -0500
In-Reply-To: <20081202.150330.157587697.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Benjamin Thery " <Benjamin.Thery@bull.net>
> Date: Mon, 01 Dec 2008 21:17:02 +0100
> 
>> The right way to fix it, IMHO, is to print 0 (zero) in the columns
>> that have no meaning for the unresolved entries. That way we don't
>> break the ABI: the userspace expects to get at least 6 numbers for
>> each entries, it gets 6 numbers. It's easy to figure what zeros
>> represent and this prevent people from wasting time trying to figure
>> what to do with these "random" numbers on the unresolved entries, no?
> 
> Probably, this is correct.
> 
> However, we could run into problems if userland parsers expect
> 6 entries and then expect an immediate newline.  We'd break that.
> 
> The only thing that really works for extending files like this
> is if they are already exporting a "key: value" interface, then
> you can add new lines safely.
> 
> Doing this horizontal expansion as you are proposing here is,
> on the other hand, very risky and dangerous.
 >
 > I really don't think it's worth it.
 >
 > Fix the garbage values, or flush them to zero if we can't
 > represent them properly.  But don't add new stuff horizontally
 > to "fill in the gaps", as I don't think it can be done %100
 > safely.

I won't do any horizontal expansion.
Maybe my explanations where not very clear (due to my bad english I
guess). Let's try to reformulate :)

Today, /proc/net/ip_mr_cache output looks like this:

[root@qemu tests]# cat /proc/net/ip_mr_cache
Group    Origin   Iif     Pkts    Bytes    Wrong Oifs
014C00EF 010014AC 1         10    10050        0  2:1    3:1
024C00EF 010014AC 65535      514        2 -559067475

It displays resolved and unresolved mfc_caches.
Both type of entries have at least 6 fields printed (resolved have
more).
1st line is a resolved cache entry.
2nd line is an unresolved cache entry.

In the case of unresolved entries, columns Pkts, Bytes and Wrong
displays garbage data (due to the union in struct mfc_cache).

My first patch was completely wrong as it suppressed these fields
for the unresolved lines, but my proposal now is _only_ to replace the
garbage values with zeros. Like this:

[root@qemu tests]# cat /proc/net/ip_mr_cache
Group    Origin   Iif     Pkts    Bytes    Wrong Oifs
014C00EF 010014AC 1          8     8040        0  2:1    3:1
024C00EF 010014AC 65535      0        0        0

It shouldn't break the ABI.
I will send an updated patch for this.



Also, there is another bug.
Today, iproute2 already fails to show unresolved entries because it
expects to see -1 in 'Iif' column to identify unresolved entries but the
kernel output 65535. It's a signed/unsigned issue:

'Iif', the source interface, is retrieved from member mfc_parent in
struct mfc_cache. mfc_parent is a vifi_t: unsigned short, but is
displayed in ipmr_mfc_seq_show() as "%-3d", signed integer.

In unresolevd entries, the 65535 value (0xFFFF) comes from this define:
#define ALL_VIFS	((vifi_t)(-1))

That may explains why the guy who added support for this in iproute2
thought a -1 should be expected.

I don't know if this must be fixed in kernel or in iproute2. Who is
right?

I will send another patch for this one, which fix 'Iif' display
and let you or Stephen decide if it should be merged in kernel
or fixed in iproute2.

Regards,
Benjamin

-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
