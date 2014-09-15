From: Yuchung Cheng <ycheng@google.com>
Subject: Re: TCP connection will hang in FIN_WAIT1 after closing if zero
 window is advertised
Date: Mon, 15 Sep 2014 16:37:09 -0700
Message-ID: <CAK6E8=fQOA7Mav=a0NJxozAv-AHUV8vcsy+uMJVcH+6zcOE5=A@mail.gmail.com>
References: <54170FC0.6020907@oktetlabs.ru> <1410822949.5018.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>,
	netdev <netdev@vger.kernel.org>,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>,
	Konstantin Ushakov <kostik@oktetlabs.ru>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:52686 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754225AbaIOXht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 19:37:49 -0400
Received: by mail-ig0-f177.google.com with SMTP id h15so4895226igd.10
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 16:37:49 -0700 (PDT)
In-Reply-To: <1410822949.5018.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 4:15 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Mo, 2014-09-15 at 20:11 +0400, Andrey Dmitrov wrote:
>> Greetings,
>>
>> there is possible vulnerability in the TCP stack. Closing a socket after
>> the TCP zero window advertising by peer leads to the socket stuck in
>> FIN_WAIT1 state. FIN-ACK packet is not sent and not retransmitted. So
>> the connection remains alive and without relation to any socket while
>> the peer sends replies to the zero probe packets. It is possible to
>> create a lot of connections in the same manner which will be in
>> FIN_WAIT1 state forever.
>>
>> Linux version 3.13-1-amd64 (debian-kernel@lists.debian.org) (gcc version
>> 4.8.2 (Debian 4.8.2-16) ) #1 SMP Debian 3.13.10-1 (2014-04-15)
>>
>> I've written a script on Lua to reproduce this issue, find it in
>> attachment please. I've used it with two hosts host_A (victim) and
>> host_B (attacker), which are directly connected to each other. host_A
>> has lighttpd installed and runned. Actually host_A can have any opened
>> TCP listener socket to be attacked. If it closes any established with
>> attacker connection it will stuck in the FIN_WAIT1 state. The script
>> creates a number of TCP connections with the victim and sends replies
>> for the zero window probe packets.
>>
>> The test requires lua, tcpdump and nemesis on the host_B:
>> aptitude install lua5.1 lua5.1-posix nemesis tcpdump
>>
>> How to run the test:
>> 1. Run a httpd daemon on the host_A (I've used lighttpd).
>> 2. Copy the test script attack.lua to the host_B.
>> 3. Fill in the tested interfaces configuration (source, destination IP
>> and MAC addresses) in the beginning of the file attack.lua. You can set
>> maximum connections number in the variable *limit*, by default it is 500.
>> 4. Set a fake MAC address for victim interface in host_B ARP table. It
>> is to prevent host_B system replies (RST) receiving by the host_A:
>>      sudo arp -s <host_A IP addr> <any MAC address>
>> 5. Run the test script on the host_B:
>>      sudo ./attack.lua
>>
>> After ~10 minutes you will see 500 connections in the FIN_WAIT1 state on
>> the host_A:
>> netstat | grep FIN_WAIT1 | wc -l
>> 500
>>
>> Even if you close the http daemon the connections still will be alive.
>
> Also thanks for the report.
>
> Do you see any tcp window repair messages in dmesg? Can you send some
> output of ss -oemit state FIN-WAIT-1 from the target host?
>
> I thought they should timeout after RTO_MAX (~2 minutes).
I think the vulnerability comes from the peer/attacker actually
responds to the probes to evade the orphan counts or memory checks in
tcp_probe_timer(). This is a gray area of being legit but suspiciously
mis-behaving?
maybe have socket option TCP_USER_TIMEOUT for apps to cover conditions
like these.

>
> Thanks,
> Hannes
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
