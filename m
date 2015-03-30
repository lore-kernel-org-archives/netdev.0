From: Ilya Dmitrichenko <errordeveloper@gmail.com>
Subject: Multicast packets visible on different subnets in different namespaces
Date: Mon, 30 Mar 2015 13:05:05 +0100
Message-ID: <CAPhDKbGDCCs3xqLKVj2UE8Y-YFnyQ0dN_meLB0ULEeVy7tCECA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:34661 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbbC3MFG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 08:05:06 -0400
Received: by iedfl3 with SMTP id fl3so129983535ied.1
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 05:05:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello List,

We have recently discovered that namespaced processes in different
subnets can unexpectedly see each other=E2=80=99s multicast packets und=
er
certain condition described below.

We setup 3 network namespace, let's call those A, B and C; where
subnets are assigned like so:

A: 10.20.1.2/24
B: 10.20.1.4/24
C: 10.20.2.2/24

These namespaces are setup with a simple script using ip command [1].
The value of rp_filter is 1 (in all of
`/proc/sys/net/ipv4/conf/*/rp_filter`, except from `lo`).

=46irst, as a sanity check, A is unreachable from namespace C through
either ping, TCP or UDP, which is what=E2=80=99s expected.

However, when doing a multicast test with a commonly known program
[2], it turns out that -

1. sender from C cannot reach receiver in A at first
2. sender from B reaches receiver in A
3. unexpectedly, sender from C can reach receiver in A, after B has
reached it once

This is the exact sequence of commands we used to reproduce the issue:

shell1: sudo ip netns exec nsA mcreceive 224.2.2.4 5050
shell2: echo hi1 | sudo ip netns exec nsC mcsend 224.2.2.4 5050
shell2: echo h2 | sudo ip netns exec nsB mcsend 224.2.2.4 5050
shell2: echo hi3 | sudo ip netns exec nsC mcsend 224.2.2.4 5050

The kernel versions we have tested are:

3.18.7-100 from Fedora 20.
3.19.0 from CoreOS

[0]: https://github.com/errordeveloper/subleak/blob/master/test.sh
[1]: http://www.nmsl.cs.ucsb.edu/MulticastSocketsBook/c_send_receive.ta=
r.gz

Regards,
=E2=80=94
Ilya Dmitrichenko
