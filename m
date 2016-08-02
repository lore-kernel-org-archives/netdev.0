From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net-next] net/multicast: should not send source list
 records when have filter mode change
Date: Tue, 2 Aug 2016 18:10:56 +0800
Message-ID: <CAPwn2JQiCea4w7hhssa370kKG_xc0dXX5qCg6JqxBBX2k304iA@mail.gmail.com>
References: <1470132177-22984-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>,
	Hangbin Liu <liuhangbin@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:34992 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965729AbcHBOEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 10:04:20 -0400
Received: by mail-oi0-f43.google.com with SMTP id 4so27569320oih.2
        for <netdev@vger.kernel.org>; Tue, 02 Aug 2016 07:02:41 -0700 (PDT)
In-Reply-To: <1470132177-22984-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Here are some tests with this patch. It's hard to test all scenarios. So I just
did a part. And all looks good so far.

Please tell me if there is anything unclear.

Thanks
Hangbin


Group: 239.1.1.1
A: 192.168.1.1
B: 192.168.1.2
C: 192.168.1.3
------------------------------------------------------------------------
# Section 1: diff before/after patch
## Test 1: EX{A} -> IN{A}

Before patch:
15:24:00.451637 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 56, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 2 group record(s)
[gaddr 239.1.1.1 block { 192.168.1.1 }] [gaddr 239.1.1.1 to_in {
192.168.1.1 }]
After patch:
15:22:50.398652 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 44, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_in { 192.168.1.1 }]

## Test 2: IN{A} -> EX{A}

Before patch:
15:24:10.239734 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 56, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 2 group record(s)
[gaddr 239.1.1.1 block { 192.168.1.1 }] [gaddr 239.1.1.1 to_ex {
192.168.1.1 }]
After patch:
15:22:59.754639 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 44, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_ex { 192.168.1.1 }]


------------------------------------------------------------------------
# Section 2: Functional test with this patch
## Test 1: IN{ } ->
Case-1 IN{ } -> IN{ }
    Do nothing
Case-2 IN{ } -> IN{A}
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_in { 192.168.1.1 }]
Case-3 IN{ } -> EX{ }
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_ex { }]
Case-4 IN{} -> EX{A}
    Not supported

## Test 2: EX{ } ->
Case-1 EX{ } -> EX{ }
    Do nothing
Case-2 EX{ } -> EX{A}
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 block { 192.168.1.1 }]
Case-3 EX{ } -> IN{ }
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_in { }]
Case-4 EX{ } -> IN{A}
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_in { 192.168.1.1 }]

## Test 3: IN{A} ->
Case-1 IN{A} -> IN{ }
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 block { 192.168.1.1 }]
Case-2 IN{A} -> IN{A}
    Do nothing
Case-3 IN{A} -> IN{B}
    192.168.1.100 > 224.0.0.22: igmp v3 report, 2 group record(s)
[gaddr 239.1.1.1 allow { 192.168.1.2 }] [gaddr 239.1.1.1 block {
192.168.1.1 }]
Case-4 IN{A} -> EX{ }
Case-5 IN{A} -> EX{A}
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_ex { 192.168.1.1 }]
Case-6 IN{A} -> EX{B}
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_ex { 192.168.1.2 }]

## Test 4: EX{A} ->
Case-1 EX{A} -> EX{ }
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 allow { 192.168.1.1 }]
Case-2 EX{A} -> EX{A}
    Do nothing
Case-3 EX{A} -> EX{B}
    192.168.1.100 > 224.0.0.22: igmp v3 report, 2 group record(s)
[gaddr 239.1.1.1 block { 192.168.1.2 }] [gaddr 239.1.1.1 allow {
192.168.1.1 }]
Case-4 EX{A} -> IN{ }
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_in { }]
Case-5 EX{A} -> IN{A}
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_in { 192.168.1.1 }]
Case-6 EX{A} -> IN{B}
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_in { 192.168.1.2 }]


------------------------------------------------------------------------
# Section 3: New change record during change record.
Case-1:
IN{A} -> IN{AB} -> sleep 1 -> IN{AC}
EX{AB} -> EX{AC} -> sleep 1 -> IN{}

23:32:14.602458 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 40, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_ex { }]
23:32:21.230500 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 40, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_ex { }]
23:32:24.610438 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 44, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_in { 192.168.1.1 }]
23:32:25.978493 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 44, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_in { 192.168.1.1 }]
23:32:34.621459 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 44, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 allow { 192.168.1.2 }]
23:32:35.630439 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 56, options (RA))
    ^^ we can see only send 1 allow{B} record, and then start send
allow{C}, block{b}
    192.168.1.100 > 224.0.0.22: igmp v3 report, 2 group record(s)
[gaddr 239.1.1.1 allow { 192.168.1.3 }] [gaddr 239.1.1.1 block {
192.168.1.2 }]
23:32:39.566551 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 56, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 2 group record(s)
[gaddr 239.1.1.1 allow { 192.168.1.3 }] [gaddr 239.1.1.1 block {
192.168.1.2 }]
23:32:50.641450 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 48, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_ex { 192.168.1.1 192.168.1.2 }]
23:32:51.650439 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 48, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_ex { 192.168.1.1 192.168.1.3 }]
23:32:51.850474 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 56, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 2 group record(s)
[gaddr 239.1.1.1 block { 192.168.1.3 }] [gaddr 239.1.1.1 allow {
192.168.1.2 }]
    ^^ Here EX{AB} -> EX{AC}, we can see the BLOCK{C}, ALLOW{B} only
send once and start TO_IN{ }
23:33:06.663455 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 40, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_in { }]
23:33:08.086493 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 40, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_in { }]

Case-2: IN{A} -> IN{ABC} -> sleep 1 -> EX{AB} -> sleep 1 -> IN{BC}

02:18:27.216445 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 40, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_ex { }]
02:18:28.354479 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 40, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_ex { }]
02:18:37.226445 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 44, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_in { 192.168.1.1 }]
02:18:39.510496 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 44, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_in { 192.168.1.1 }]
02:18:47.236445 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 48, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 allow { 192.168.1.2 192.168.1.3 }]
    ^^ ALLOW{BC} once and start TO_EX{AB}
02:18:48.246448 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 48, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_ex { 192.168.1.1 192.168.1.2 }]
    ^^ TO_EX{AB} once and start TO_IN{BC}
02:18:49.256450 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 48, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_in { 192.168.1.2 192.168.1.3 }]
02:18:58.558556 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 48, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_in { 192.168.1.2 192.168.1.3 }]
02:19:04.268441 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 48, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 block { 192.168.1.3 192.168.1.2 }]
02:19:12.510502 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 48, options (RA))
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 block { 192.168.1.3 192.168.1.2 }]


------------------------------------------------------------------------
# Section 3: Multi sockets
Case-1:

S1 EX{ }
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_ex { }]
S1 EX{A}
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 block { 192.168.1.1 }]
S2 EX{ }
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 allow { 192.168.1.1 }]
S2 IN{B}
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 block { 192.168.1.1 }]
S1 IN{ }
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_in { 192.168.1.2 }]
S2 IN{ }
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 block { 192.168.1.2 }]

Case-2:

S1 EX{ }
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_ex { }]
S2 EX{ }
    Do Nothing
S1 IN{A}
    Do Nothing
S2 IN{A}
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 to_in { 192.168.1.1 192.168.1.2 }]
S1 IN{ }
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 block { 192.168.1.1 }]
S2 IN{ }
    192.168.1.100 > 224.0.0.22: igmp v3 report, 1 group record(s)
[gaddr 239.1.1.1 block { 192.168.1.2 }]
