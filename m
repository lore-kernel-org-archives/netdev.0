From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next 0/4] tcp: mitigate TCP ACK loops due to out-of-window validation dupacks
Date: Fri,  6 Feb 2015 16:04:37 -0500
Message-ID: <1423256681-31716-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:54334 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755225AbbBFVEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 16:04:52 -0500
Received: by mail-yk0-f177.google.com with SMTP id 19so6981964ykq.8
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 13:04:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series mitigates "ack loop" DoS scenarios by rate-limiting
outgoing duplicate ACKs sent in response to incoming "out of window"
segments.

Background
-----------

There are several cases in which the TCP RFCs specify that a TCP
endpoint should send a pure duplicate ACK in response to a pure
duplicate ACK that appears to be invalid due to being "out of window":

(1) RFC 793 (section 3.9, page 69) specifies that endpoints should
    send a duplicate ACK in response to an ACK when the incoming
    sequence number is invalid due to being outside the receive
    window: "If an incoming segment is not acceptable, an
    acknowledgment should be sent in reply".

(2) RFC 793 (section 3.9, page 72) says: "If the ACK acknowledges
    something not yet sent (SEG.ACK > SND.NXT) then send an ACK".

(3) RFC 1323 (section 4.2.1, page 18) specifies that endpoints should
    send a duplicate ACK in response to an ACK when the PAWS check for
    the incoming timestamp value fails: "If .... SEG.TSval < TS.Recent
    and if TS.Recent is valid ... Send an acknowledgement in reply"

The problem
------------

Normally, this is not a problem. However, a buggy middlebox or
malicious man-in-the-middle can inject a few packets into the
conversation that advance each endpoint's notion of the current window
(sequence, ACK, or timestamp), without either side noticing. In this
case, from then on each side can think the other is sending invalid
segments. Thus an infinite feedback loop of duplicate ACKs can ensue,
as each endpoint receives a duplicate ACK, decides that it is invalid
(due to sequence number, ACK number, or timestamp), and then sends a
dupack in reply, which the other side decides is invalid, responding
with a dupack... ad infinitum. This ping-pong feedback loop can happen
at a very high rate.

This phenomenon can and does happen in practice. It has been seen in
datacenter and Internet contexts at Google, and has been documented by
Anil Agarwal in the Nov 2013 tcpm thread "TCP mismatched sequence
numbers issue", and Avery Fay in the Feb 2015 Linux netdev thread
"Invalid timestamp? causing tight ack loop (hundreds of thousands of
packets / sec)".

This patch series
------------------

This patch series mitigates such ack loops by rate-limiting outgoing
duplicate ACKs sent in response to incoming TCP packets that are for
an existing connection but that are invalid due to any of the reasons
mentioned above: sequence number (1), ACK field (2), or timestamp
value (3). The rate limit for such duplicate ACKs is specified by a
new sysctl, tcp_invalid_ratelimit, which specifies the minimal space
between such outbound duplicate ACKs, in milliseconds. The default is
500 (500ms), and 0 disables the mechanism.

We rate-limit these duplicate ACK responses rather than blocking them
entirely or resetting the connection, because legitimate connections
can rely on dupacks in response to some out-of-window segments. For
example, zero window probes are typically sent with a sequence number
that is below the current window, and ZWPs thus expect to thus elicit
a dupack in response.

Testing: this approach has been in use at Google for a while.

Neal Cardwell (4):
  tcp: helpers to mitigate ACK loops by rate-limiting out-of-window
    dupacks
  tcp: mitigate ACK loops for connections as tcp_request_sock
  tcp: mitigate ACK loops for connections as tcp_sock
  tcp: mitigate ACK loops for connections as tcp_timewait_sock

 Documentation/networking/ip-sysctl.txt | 22 +++++++++++++++++++++
 include/linux/tcp.h                    |  6 ++++++
 include/net/tcp.h                      | 33 +++++++++++++++++++++++++++++++
 include/uapi/linux/snmp.h              |  6 ++++++
 net/ipv4/proc.c                        |  6 ++++++
 net/ipv4/sysctl_net_ipv4.c             |  7 +++++++
 net/ipv4/tcp_input.c                   | 30 +++++++++++++++++++++-------
 net/ipv4/tcp_minisocks.c               | 36 ++++++++++++++++++++++++++++------
 8 files changed, 133 insertions(+), 13 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
