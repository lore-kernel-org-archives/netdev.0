From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v4 0/5] net-timestamp: additional sw tstamps and
Date: Wed, 30 Jul 2014 11:48:43 -0400
Message-ID: <1406735328-7520-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f73.google.com ([209.85.213.73]:48477 "EHLO
	mail-yh0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753755AbaG3Psu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 11:48:50 -0400
Received: by mail-yh0-f73.google.com with SMTP id f73so173144yha.0
        for <netdev@vger.kernel.org>; Wed, 30 Jul 2014 08:48:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend socket tx timestamping:
- allow multiple types of software timestamps aside from send (1)
- add software timestamp on tc enqueue (3)
- add software timestamp for TCP (4)
- add software timestamp for TCP on ACK (5)

The sk_flags option space is nearly exhausted. Also move the
many timestamp options to a new sk->sk_tstamps (2).

The patchset extends Linux tx timestamping to monitoring of latency
incurred within the kernel stack and to protocols embedded in TCP.
Complex kernel setups may have multiple layers of queueing, including
multiple instances of traffic shaping, and many classes per layer.
Many applications embed discrete payloads into TCP bytestreams for
reliability, flow control, etcetera. Detecting application tail
latency in such scenarios relies on identifying the exact queue
responsible if on the host, or the network latency if otherwise.

Changelog:
v3->v4
  - (v3 review comment) removed skb->mark packet identification (*A)
  - (v3 review comment) fixed indentation
  - tcp: fixed poll() to return POLLERR on non-zero queue
  - rebased to work without syststamp
  - comments: removed all traces of MSG_TSTAMP_.. (*B)

v2->v3
  - extend the SO_TIMESTAMPING API, instead of defining a new one.
  - add protocol independent support to correlate tstamps with data,
    based on returning skb->mark.
  - removed no-payload optimization and documentation (for now):

    I have a follow-on patch that reintroduces MSG_TSTAMP along with a
    new socket option SOF_TIMESTAMPING_OPT_ONFLAG. This is equivalent
    to sequence setsockopt(<enable>); send(..); setsockopt(<disable>),
    but avoids the need to define a MSG_TSTAMP_<TYPE> for each type.

    I will leave these three patches as follow-on, as this patchset is
    large enough as is.

v1->2
  - expand timestamping (existing and new) to SOCK_RAW and ping sockets
  - rename sock_errqueue_timestamping to scm_timestamping
  - change timestamp data format: do not add fields to scm_timestamping.
      Doing so could break legacy applications. Instead, communicate
      through an existing, but unused, field in the error message.
  - rename SOF_.._OPT_TX_NO_PAYLOAD to shorter SOF_.._OPT_TSONLY
  - move msg_tstamp test app out of patchset and to github
      git://github.com/wdebruij/kerneltools.git

v4 comments:

A: unique correlation of payload and timestamp when multiple payloads
   are in flight requires more extensive changes if we do not use
   skb->mark. That is better left to a follow-up patch.
B: similarly, I intend to submit the MSG_TSTAMP short-hand for
   setsockopt(<enable>); send; setsockopt(<disable>); as follow-up
   for review.

-- 
2.0.0.526.g5318336
