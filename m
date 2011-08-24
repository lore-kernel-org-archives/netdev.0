From: Jerry Chu <hkchu@google.com>
Subject: Re: [BUG] tcp : how many times a frame can possibly be retransmitted ?
Date: Wed, 24 Aug 2011 12:39:38 -0700
Message-ID: <CAPshTCi_5uRXCJF96OV1ApcbcDcoKDeVwzCm432Rcf8DV3SaiQ@mail.gmail.com>
References: <1314202918.2296.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<3482698A-C35B-4BED-AEEF-EBA135991705@comsys.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Lukowski Damian <damian@tvk.rwth-aachen.de>,
	Hannemann Arnd <arnd@arndnet.de>
To: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f198.google.com ([209.85.213.198]:42046 "EHLO
	mail-yx0-f198.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617Ab1HXUFR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 16:05:17 -0400
Received: by yxj17 with SMTP id 17so1936563yxj.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2011 13:05:16 -0700 (PDT)
In-Reply-To: <3482698A-C35B-4BED-AEEF-EBA135991705@comsys.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexander,

On Wed, Aug 24, 2011 at 12:03 PM, Alexander Zimmermann
<alexander.zimmermann@comsys.rwth-aachen.de> wrote:
> Hi Eric,
>
> Am 24.08.2011 um 18:21 schrieb Eric Dumazet:
>
>> On one dev machine running net-next, I just found strange tcp sessio=
ns
>> that retransmit a frame forever (The other peer disappeared)
>
> not forever...
> If remember correctly you will stop after 120s.

Yup. It looks like this "feature" was introduced in the patch
"Revert Backoff [v3]: Calculate TCP's connection close threshold as a
time value"
by Damian as well to bound the abort timeout by time duration rather
than how many
retries (icsk_retransmits). But as pointed out if rto is small it
could mean a lot of
retransmissions before one gives up.

Jerry

>
>>
>> # ss -emoi dst 10.2.1.1
>> State =A0 =A0 =A0Recv-Q Send-Q =A0 =A0 =A0Local Address:Port =A0 =A0=
 =A0 =A0 =A0Peer Address:Port
>> ESTAB =A0 =A0 =A00 =A0 =A0 =A0816 =A0 =A0 =A0 =A0 =A0 =A0 =A010.2.1.=
2:37930 =A0 =A0 =A0 =A0 =A0 =A0 10.2.1.1:ssh =A0 =A0 =A0timer:(on,630ms=
,246) ino:60786 sk:ffff8801189aa400
>> =A0 =A0 =A0 =A0mem:(r0,w3776,f320,t0) ts sack ecn cubic wscale:8,6 r=
to:1680 rtt:16.25/7.5 ato:40 ssthresh:7 send 1.4Mbps rcv_rtt:10 rcv_spa=
ce:16632
>>
>>
>> You can see the retransmit count : 246
>>
>> What possibly can be going on ?
>>
>> What happened to backoff ?
>>
>> # grep . /proc/sys/net/ipv4/tcp_retries*
>> /proc/sys/net/ipv4/tcp_retries1:3
>> /proc/sys/net/ipv4/tcp_retries2:15
>>
>>
>>
>> extract of tcpdump :
>>
>> 12:01:02.074244 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16128024 59389>
>> 12:01:03.754243 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16128192 59389>
>> 12:01:05.434245 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16128360 59389>
>> 12:01:07.114243 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16128528 59389>
>> 12:01:08.794248 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16128696 59389>
>> 12:01:10.474242 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16128864 59389>
>> 12:01:12.154243 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16129032 59389>
>> 12:01:13.834241 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16129200 59389>
>> 12:01:15.514246 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16129368 59389>
>> 12:01:17.194244 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16129536 59389>
>> 12:01:18.874248 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16129704 59389>
>> 12:01:20.554243 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16129872 59389>
>> 12:01:22.234244 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16130040 59389>
>> 12:01:23.914244 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16130208 59389>
>> 12:01:25.594247 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16130376 59389>
>> 12:01:27.274242 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16130544 59389>
>> 12:01:28.954242 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16130712 59389>
>> 12:01:30.634248 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16130880 59389>
>> 12:01:32.314245 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16131048 59389>
>> 12:01:33.994243 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16131216 59389>
>> 12:01:35.674250 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16131384 59389>
>> 12:01:37.354244 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16131552 59389>
>> 12:01:39.034245 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16131720 59389>
>> 12:01:40.714245 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16131888 59389>
>> 12:01:42.394245 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16132056 59389>
>> 12:01:44.074242 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16132224 59389>
>> 12:01:45.754249 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16132392 59389>
>> 12:01:47.434242 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16132560 59389>
>> 12:01:49.114247 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16132728 59389>
>> 12:01:50.794250 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16132896 59389>
>> 12:01:52.474247 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16133064 59389>
>> 12:01:54.154242 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16133232 59389>
>> 12:01:55.834246 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16133400 59389>
>> 12:01:57.514243 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16133568 59389>
>> 12:01:59.194247 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16133736 59389>
>> 12:02:00.874250 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16133904 59389>
>> 12:02:02.554242 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16134072 59389>
>> 12:02:04.234243 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16134240 59389>
>> 12:02:05.914245 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16134408 59389>
>> 12:02:07.594244 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16134576 59389>
>> 12:02:09.274249 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16134744 59389>
>> 12:02:10.954241 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16134912 59389>
>> 12:02:12.634249 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack 1=
 win 1002 <nop,nop,timestamp 16135080 59389>
>>
>> tcp_retransmit_timer() does the exponential backoff, but something
>> resets icsk_rto to a low value ?
>>
>> Ah, it seems to be because of commit f1ecd5d9e7366609
>> (Revert Backoff [v3]: Revert RTO on ICMP destination unreachable)
>>
>> Since arp resolution (or routing, I dont know yet) fails, an
>> internal/loopback ICMP host/network unreachable message is
>> generated and handled in tcp_v4_err() :
>
> Yeah, you have a local connectivity disruption. This is one
> possible scenario.
>
>>
>> icsk_backoff-- and icsk_rto is reset.
>>
>> I am afraid this can generate a storm (cpu time at very least),
>> in case we have many tcp sessions in this state.
>
> Hmm, maybe. I don't know. Arnd or Damian what are you thing about thi=
s point?
>
>>
>> I guess its time for me to read RFC 6069
>
> If you find a bug. Let me know.
>
> Alex
>
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
> //
> // Dipl.-Inform. Alexander Zimmermann
> // Department of Computer Science, Informatik 4
> // RWTH Aachen University
> // Ahornstr. 55, 52056 Aachen, Germany
> // phone: (49-241) 80-21422, fax: (49-241) 80-22222
> // email: zimmermann@cs.rwth-aachen.de
> // web: http://www.umic-mesh.net
> //
>
>
