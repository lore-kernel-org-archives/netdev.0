From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH v2 net-next] tcp: TSO packets automatic sizing
Date: Mon, 26 Aug 2013 15:31:39 -0700
Message-ID: <CAK6E8=eJi0FtbVp5Oc3uxHNXnU_Cd_1qUF9QeBJKQprJ+J+Lgw@mail.gmail.com>
References: <1377304192.8828.43.camel@edumazet-glaptop> <1377491162.8828.116.camel@edumazet-glaptop>
 <CAK6E8=dkp2soUUrv_gP5soBCqe7mf7KNY-iO-FoS0J4Pi4zXpg@mail.gmail.com> <1377548889.8828.130.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Van Jacobson <vanj@google.com>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:47155 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076Ab3HZWb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 18:31:59 -0400
Received: by mail-oa0-f45.google.com with SMTP id m1so1500978oag.32
        for <netdev@vger.kernel.org>; Mon, 26 Aug 2013 15:31:59 -0700 (PDT)
In-Reply-To: <1377548889.8828.130.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 26, 2013 at 1:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2013-08-26 at 12:09 -0700, Yuchung Cheng wrote:
>
>> init write of 10MSS now looks good, but the delay still shows up if 9
>> < write-size < 10 MSS...
>>
>> I use packetdrill to do write(14599) bytes of MSS 1460
>>
>> 0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
>> 0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
>> 0.000 bind(3, ..., ...) = 0
>> 0.000 listen(3, 1) = 0
>>
>> 0.100 < S 299245565:299245565(0) win 32792 <mss
>> 1460,sackOK,nop,nop,nop,wscale 7>
>> 0.100 > S. 0:0(0) ack 299245566 <mss 1460,nop,nop,sackOK,nop,wscale 6>
>> 0.200 < . 1:1(0) ack 1 win 257
>> 0.200 accept(3, ..., ...) = 4
>> +.000 write(4, ..., 13141) = 13141
>> +3 %{ print "done" }%
>>
>> and tcpdump shows
>>
>> 31.819958 IP cli > srv: S 299245565:299245565(0) win 32792 <mss 1460,sackOK,nop,
>> nop,nop,wscale 7>
>> 000034 IP srv > cli: S 203810874:203810874(0) ack 299245566 win 29200
>> <mss 1460,nop,nop,sackOK,nop,wscale 6>
>> 099966 IP cli > srv: . ack 1 win 257
>> 000079 IP srv > cli: . 1:2921(2920) ack 1 win 457
>> 000010 IP srv > cli: . 2921:5841(2920) ack 1 win 457
>> 000005 IP srv > cli: . 5841:8761(2920) ack 1 win 457
>> 000004 IP srv > cli: . 8761:11681(2920) ack 1 win 457
>> 199659 IP srv > cli: . 11681:13141(1460) ack 1 win 457
>> ...
>
> It works correctly here, I wonder what's happening on your host.
Sorry! I was testing the wrong patch so ignore my bogus report. I have
to run but will take another look of the new patch later today or
tomorrow.

>
> lpq83:~# tcpdump -p -n -s 0 -i any port 8080 -ttt
> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
> listening on any, link-type LINUX_SLL (Linux cooked), capture size 65535 bytes
> 000000 IP 192.0.2.1.42148 > 192.168.0.1.8080: S 299245565:299245565(0) win 32792 <mss 1460,sackOK,nop,nop,nop,wscale 7>
> 000042 IP 192.168.0.1.8080 > 192.0.2.1.42148: S 223873324:223873324(0) ack 299245566 win 29200 <mss 1460,nop,nop,sackOK,nop,wscale 6>
> 099946 IP 192.0.2.1.42148 > 192.168.0.1.8080: . ack 1 win 257
> 000087 IP 192.168.0.1.8080 > 192.0.2.1.42148: . 1:2921(2920) ack 1 win 457
> 000006 IP 192.168.0.1.8080 > 192.0.2.1.42148: . 2921:5841(2920) ack 1 win 457
> 000004 IP 192.168.0.1.8080 > 192.0.2.1.42148: . 5841:8761(2920) ack 1 win 457
> 000004 IP 192.168.0.1.8080 > 192.0.2.1.42148: . 8761:11681(2920) ack 1 win 457
> 000005 IP 192.168.0.1.8080 > 192.0.2.1.42148: . 11681:13141(1460) ack 1 win 457
> 000002 IP 192.168.0.1.8080 > 192.0.2.1.42148: P 13141:13142(1) ack 1 win 457
>
>
