From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: iproute u32 filter - server hang
Date: Wed, 31 Mar 2010 11:42:32 +0200
Message-ID: <4BB31908.5090601@itcare.pl>
References: <4BB3116F.803@itcare.pl> <4BB31731.9060104@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:48975 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755936Ab0CaJmi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 05:42:38 -0400
In-Reply-To: <4BB31731.9060104@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2010-03-31 11:34, Patrick McHardy pisze:
> Pawe=C5=82 Staszewski wrote:
>   =20
>> I find some problem with iproute2 and u32 filters
>>
>> To reproduce the problem (need to make one mistake in filter parent
>> declaration 1:101):
>>
>> ...
>> tc filter add dev eth0 protocol ip parent 1:101 u32 match ip protoco=
l 1
>> 0xff flowid 1:101
>>
>> ping 212.77.100.101
>> And after this server will stop responding to anything - without any
>> error (hang).
>>     =20
> This is caused by hfsc_classify() looping endlessly since the filter
> points to the originating class. hfsc_bind_tcf() is actually supposed
> to prevent this, but it only prevents resolving the filter immediatel=
y
> and we still run into the loop at runtime.
>
> This patch (based on how CBQ handles this) should abort classificatio=
n
> and fall back to the default class. It would be better to simply catc=
h
> this at configuration time, but that looks a bit more involved. I'll =
try
> to look into it this weekend.
>
>
>   =20
I check this also with htb and the same problem like with hfsc.
This rules also hang my server.

tc qdisc del dev eth4 root
tc qdisc add dev eth4 root handle 1: htb default 63
tc class add dev eth4 parent 1: classid 1:1 htb rate 100mbit ceil 100mb=
it
tc class add dev eth4 parent 1:1 classid 1:2 htb rate 1mbit ceil 1mbit
tc class add dev eth4 parent 1:1 classid 1:63 htb rate 99mbit ceil 99mb=
it
tc class add dev eth4 parent 1:1 classid 1:101 htb rate 8kbit ceil 1mbi=
t
tc class add dev eth4 parent 1:101 classid 1:102 htb rate 8kbit ceil 1m=
bit
tc filter add dev eth4 protocol ip parent 1: u32 match ip dst=20
212.77.100.101 flowid 1:101
tc filter add dev eth4 protocol ip parent 1:101 u32 match ip protocol 1=
=20
0xff flowid 1:101




