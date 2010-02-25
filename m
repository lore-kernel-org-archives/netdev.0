From: Reinaldo de Carvalho <reinaldoc@gmail.com>
Subject: Re: [Bugme-new] [Bug 15379] New: u32 classifier port range
	calculation error
Date: Thu, 25 Feb 2010 08:25:52 -0300
Message-ID: <4a5881461002250325o45965b2fu2855b712b73e00b9@mail.gmail.com>
References: <bug-15379-10286@http.bugzilla.kernel.org/>
	 <20100224145220.da5ec0b0.akpm@linux-foundation.org>
	 <1267068257.3973.865.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:51805 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759259Ab0BYL0Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 06:26:24 -0500
Received: by gwj16 with SMTP id 16so1624467gwj.19
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2010 03:26:23 -0800 (PST)
In-Reply-To: <1267068257.3973.865.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Then u32 mask is useless. Or exist a correct mask to match with especif=
ic range?

--=20
Reinaldo de Carvalho


On Thu, Feb 25, 2010 at 12:24 AM, jamal <hadi@cyberus.ca> wrote:
>
> This is expected.
> An incoming packet is masked with 0x1FE0 at offset 20 and the
> value is compared to 6880. If they match, success.
> So between 1-10000, you essentially have some starting at 6880.
> And then at a large number prolly around port 15000, you have
> a few more. and the pattern repeats etc.
>
> cheers,
> jamal
>
> On Wed, 2010-02-24 at 14:52 -0800, Andrew Morton wrote:
>> (switched to email. =A0Please respond via emailed reply-to-all, not =
via the
>> bugzilla web interface).
>>
>> On Tue, 23 Feb 2010 20:56:09 GMT bugzilla-daemon@bugzilla.kernel.org=
 wrote:
>>
>> > http://bugzilla.kernel.org/show_bug.cgi?id=3D15379
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0Summary: u32 classifier port range calculat=
ion error
>> > =A0 =A0 =A0 =A0 =A0 =A0Product: Networking
>> > =A0 =A0 =A0 =A0 =A0 =A0Version: 2.5
>> > =A0 =A0 Kernel Version: All (2.6.32 tested)
>> > =A0 =A0 =A0 =A0 =A0 Platform: All
>> > =A0 =A0 =A0 =A0 OS/Version: Linux
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 Tree: Mainline
>> > =A0 =A0 =A0 =A0 =A0 =A0 Status: NEW
>> > =A0 =A0 =A0 =A0 =A0 Severity: normal
>> > =A0 =A0 =A0 =A0 =A0 Priority: P1
>> > =A0 =A0 =A0 =A0 =A0Component: Other
>> > =A0 =A0 =A0 =A0 AssignedTo: acme@ghostprotocols.net
>> > =A0 =A0 =A0 =A0 ReportedBy: reinaldoc@gmail.com
>> > =A0 =A0 =A0 =A0 Regression: No
>> >
>> >
>> > U32 classifier have a problem on mask calculation of IP port range=
 value.
>> >
>> > To reproduce the problem:
>> >
>> > ##### MASK CALCULATION FOR PORT RANGE 6880->6911
>> >
>> > echo "obase=3D16;(2^13)-32" | bc
>> > 1FE0
>> >
>> > Example:
>> >
>> > ###### TC SAMPLE RULES
>> > tc qdisc del dev eth0 root >/dev/null 2>&1
>> >
>> > tc qdisc =A0add dev eth0 root handle 1: htb default 1100
>> > tc class =A0add dev eth0 root classid 1:1000 htb rate 1000Mbit cei=
l 1000Mbit
>> > tc class =A0add dev eth0 classid 1:1100 parent 1:1000 htb prio 0 r=
ate 999Mbit
>> > ceil 999Mbit
>> > tc class =A0add dev eth0 classid 1:1200 parent 1:1000 htb prio 0 r=
ate 1Mbit
>> > ceil 1Mbit
>> >
>> > tc filter add dev eth0 protocol ip prio 1 parent 1: u32 flowid 1:1=
200 match ip
>> > dport 6880 0x1FE0
>> >
>> > ###### STATS CLEAN ** success 0
>> > tc -s filter show dev eth0
>> > filter parent 1: protocol ip pref 1 u32
>> > filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1
>> > filter parent 1: protocol ip pref 1 u32 fh 800::800 order 2048 key=
 ht 800 bkt 0
>> > flowid 1:1200 =A0(rule hit 116 success 0)
>> > =A0 match 00001ae0/00001fe0 at 20 (success 0 )
>> >
>> > ###### SENDING PACKETS I
>> > # nmap example.ufpa.br -p 1-10000
>> >
>> > ###### STATS I ** success 32 (OK)
>> > # tc -s filter show dev eth0
>> > filter parent 1: protocol ip pref 1 u32
>> > filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1
>> > filter parent 1: protocol ip pref 1 u32 fh 800::800 order 2048 key=
 ht 800 bkt 0
>> > flowid 1:1200 =A0(rule hit 12676 success 32)
>> > =A0 match 00001ae0/00001fe0 at 20 (success 32 )
>> >
>> > ###### SENDING PACKETS II
>> > # nmap example.ufpa.br -p 10000-20000
>> >
>> > ###### STATS II ** success 64 (ERROR) - should not match
>> >
>> > # tc -s filter show dev eth0
>> > filter parent 1: protocol ip pref 1 u32
>> > filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1
>> > filter parent 1: protocol ip pref 1 u32 fh 800::800 order 2048 key=
 ht 800 bkt 0
>> > flowid 1:1200 =A0(rule hit 25172 success 64)
>> > =A0 match 00001ae0/00001fe0 at 20 (success 64 )
>> >
>> > ###### SENDING PACKETS III
>> > # nmap example.ufpa.br -p 20000-30000
>> >
>> > ###### STATS III ** success 96 (ERROR) - should not match
>> >
>> > # tc -s filter show dev eth0
>> > filter parent 1: protocol ip pref 1 u32
>> > filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1
>> > filter parent 1: protocol ip pref 1 u32 fh 800::800 order 2048 key=
 ht 800 bkt 0
>> > flowid 1:1200 =A0(rule hit 43131 success 96)
>> > =A0 match 00001ae0/00001fe0 at 20 (success 96 )
>> >
>> > ### End
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
>
