From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: iproute2/nstat: Bug in displaying icmp stats
Date: Fri, 5 Dec 2014 15:35:10 -0800
Message-ID: <CAGK4HS_ty2=f0PNU-w8QPP9BoP67E+4MaDxLTLV4G22dx_7A-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:36665 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbaLEXfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 18:35:11 -0500
Received: by mail-wg0-f51.google.com with SMTP id k14so2093744wgh.38
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 15:35:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I noticed nstat is displaying icmp stats incorrectly.

$ cat /proc/net/snmp | grep Icmp | head -2 | awk '{print $1 " " $2 " "
$3 " " $4}'
Icmp: InMsgs InErrors InCsumErrors
Icmp: 215 0 0

$ nstat  -az | grep IcmpIn  | head -3
IcmpInMsgs                      0                  0.0
IcmpInErrors                    215                0.0
IcmpInCsumErrors                0                  0.0

For example, as seen in /proc/net/snmp, IcmpInMsgs should be 215 but
that value is assigned to IcmpInErrors.

The issue seems to be the way the values are populated.

$vim +209 misc/nstat.c
-----x----

                       /* Trick to skip "dummy" trailing ICMP MIB in 2.4 */

                        if (strcmp(idbuf, "IcmpOutAddrMaskReps") == 0)

                                idbuf[5] = 0;

                        else

                                n = n->next;

-----x------

It seems "IcmpOutAddrMaskReps" is processed twice and values assigned
are off by one.

Any idea what the code is doing for 2.4 kernel and how to fix this?

vijay
