From: Willem de Bruijn <willemb@google.com>
Subject: net-timestamp: MSG_TSTAMP flags and bytestream support
Date: Tue, 24 Jun 2014 11:43:45 -0400
Message-ID: <1403624632-17327-1-git-send-email-willemb@google.com>
Cc: eric.dumazet@gmail.com, richardcochran@gmail.com,
	davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:35913 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754391AbaFXPoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 11:44:00 -0400
Received: by mail-qa0-f74.google.com with SMTP id w8so41613qac.3
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 08:43:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset extends socket timestamping in a number of related ways.
Most notably:

2 MSG_TSTAMP: request a single tx timestamp by passing a flag on send
6 MSG_TSTAMP_ENQ: request a tx timestamp before traffic shaping.
5 MSG_TSTAMP_ACK: request a tx timestamp after acknowledgements (TCP)
4 TCP support for all three flags

Each individual patch commit message gives more detail about the
specific feature.

The other patches support the main feature:
1 explicitly define the timestamp response API
3 optionally avoid looping large packets onto the socket error queue.
7 documentation and an example test.

This initial patchset is mostly to request feedback. Though the
patches are somewhat interdependent, I can resubmit them independently
or drop optional features (most notably, patches 1 and 3).

While rebasing, I found a few possible improvements, myself. These are
debatable, so I will send the set first and optionally integrate these
in v2:

- The struct in patch 1 was informally called scm_timestamping in the
  documentation. I prefer that name over the long one I came up with.
- We can actually avoid extending that structure, because ts_type and
  ts_key can be passed in the currently unused sock_extended_err
  fields ee_info and ee_data
- the new functionality of MSG_TSTAMP_* should also be extended to
  the socket option interface SO_TIMESTAMPING

Tested:
  I ran the msg_tstamp binary for various settings:
  - IPv4 and IPv6
  - UDP and TCP
  - 1 B and 20 KB payload
  - GSO, TSO, neither
  - with and without the no-payload feature (patch 3)

  Example output from one IPv4/TCP/1B/payload run:
  (on a bonded machine, resulting in 2 ENQ timestamps per send)

proto INET
  test SND
      USR: 1400265321 s 167847 us (seq=0, len=0)
      SND: 1400265321 s 167854 us (seq=408779523, len=7)  (+7 us)
  test ENQ
      USR: 1400265321 s 768728 us (seq=0, len=7)
      ENQ: 1400265321 s 768732 us (seq=3113669987, len=7)  (+4 us)
      ENQ: 1400265321 s 768734 us (seq=3113669987, len=7)  (+2 us)
  test ENQ + SND
      USR: 1400265322 s 369747 us (seq=0, len=7)
      ENQ: 1400265322 s 369750 us (seq=2305548511, len=7)  (+3 us)
      ENQ: 1400265322 s 369751 us (seq=2305548511, len=7)  (+1 us)
      SND: 1400265322 s 369752 us (seq=2305548511, len=7)  (+1 us)
  test ACK
      USR: 1400265322 s 970717 us (seq=0, len=7)
      ACK: 1400265322 s 970752 us (seq=2324323855, len=7)  (+35 us)
  test SND + ACK
      USR: 1400265323 s 571662 us (seq=0, len=7)
      SND: 1400265323 s 571681 us (seq=872301729, len=7)  (+19 us)
      ACK: 1400265323 s 571708 us (seq=872301729, len=7)  (+27 us)
  test ENQ + SND + ACK
      USR: 1400265324 s 172558 us (seq=0, len=7)
      ENQ: 1400265324 s 172561 us (seq=2135092223, len=7)  (+3 us)
      ENQ: 1400265324 s 172565 us (seq=2135092223, len=7)  (+4 us)
      SND: 1400265324 s 172581 us (seq=2135092223, len=7)  (+16 us)
      ACK: 1400265324 s 172624 us (seq=2135092223, len=7)  (+43 us)


Signed-off-by: Willem de Bruijn <willemb@google.com>
