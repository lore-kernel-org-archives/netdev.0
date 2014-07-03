From: Willem de Bruijn <willemb@google.com>
Subject: net-timestamp: MSG_TSTAMP flags and bytestream support
Date: Thu,  3 Jul 2014 15:39:32 -0400
Message-ID: <1404416380-3545-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gomail.com, stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:49716 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753302AbaGCTju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 15:39:50 -0400
Received: by mail-pa0-f73.google.com with SMTP id kq14so133906pab.0
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2014 12:39:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset extends socket timestamping for continuous sampled
monitoring of a wider set of protocols, including discrete
messages layered over bytestreams.

Patches 5 and 6 add additional measurement points in the data
lifecycle, to be able to detect the cause of latency (e.g.,
which tc queue).

Patch 4 extends timestamping to bytestreams, because many
application protocols, including those with discrete payloads,
use TCP as a transport layer for reliability, flow control, etc.

Patch 2 adds a send() flag-based control interface to request a
timestamp for a payload. With bytestream-based timestamping, this
allows an application to communicate the boundaries of discrete
application payloads, which often span multiple send() calls.

A second use of this feature is in sampled background monitoring.
For high volume production server workloads, high sampling rates
may be the only feasible approach to 24/7 monitoring.

The other patches support these core features:

Patch 1 explicitly defines a previously implicitly defined struct
Patch 3 optionally conserves SO_SNDBUF by not looping payloads
        back onto the error queue
Patch 7 documents the new mechanisms
Patch 8 fixes SO_TIMESTAMPING for SOCK_RAW and ping sockets
        and adds support for the new MSG_TSTAMP interface.

The individual patch commit messages gives more detail about the
specific feature.

Changelog:
  v1->v2
  - expand timestamping (existing and new) to SOCK_RAW and ping sockets
  - rename sock_errqueue_timestamping to scm_timestamping
  - change timestamp data format: do not add fields to scm_timestamping.
      Doing so could break legacy applications. Instead, communicate
      through an existing, but unused, field in the error message.
  - rename SOF_.._OPT_TX_NO_PAYLOAD to shorter SOF_.._OPT_TSONLY
  - move msg_tstamp test app out of patchset and to github
      git://github.com/wdebruij/kerneltools.git
 
Tested:
  msg_tstamp with various settings:
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

  also regression tested existing SO_TIMESTAMP(NS|ING) interfaces
 
Comments:

# overloading SCM_TIMESTAMPING

This patchset reuses SCM_TIMESTAMPING to return new kinds of
timestamps. It is possible to create a new SCM_.. and struct,
but both socket option and flags-based interface can in principle
be equivalent feature-wise. In that case, it is preferable if
they return information in the same format.

# SO_TIMESTAMPING / MSG_TSTAMP feature parity

This patchset does not implement a fully equivalent feature set yet.
Not included is a draft patch that adds the functionality of
MSG_TSTAMP_ENQ and MSG_TSTAMP_ACK to SO_TIMESTAMPING. It is trivial,
save from the fact that these new options overflow sk_flags. The
patch introduces a separate timestamping sk_tsflags.
