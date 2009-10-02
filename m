From: Daniel Slot <slot.daniel@gmail.com>
Subject: [QUESTION] Packet Reordering detection and response with TCP in
	Reno-mode
Date: Fri, 2 Oct 2009 16:09:38 +0200
Message-ID: <bb6e06c00910020709y5af227d5i76b72ce8ff7f9158@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f199.google.com ([209.85.210.199]:52139 "EHLO
	mail-yx0-f199.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbZJBOJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 10:09:34 -0400
Received: by yxe37 with SMTP id 37so1203197yxe.33
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2009 07:09:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have some problems understanding Linux TCP's reordering detection
and response algorithms.
When the SACK option is used, the threshold adaption is understandable.
But in Reno-mode (without SACKs), reordering detection and response
are imho not clear.

Reordering detection:
How is it possible to determine the number of holes without SACK?
Simple DUPACKs do not provide enough information for such an estimation.

kernel 2.6.30.4 - net/ipv4/tcp_input.c -line 1934
static int tcp_limit_reno_sacked(struct tcp_sock *tp)
{
        u32 holes;

        holes = max(tp->lost_out, 1U);
        holes = min(holes, tp->packets_out);

        if ((tp->sacked_out + holes) > tp->packets_out) {
                tp->sacked_out = tp->packets_out - holes;
                return 1;
        }
        return 0;
}

Reordering response:
Reordering detection in Reno-mode is only possible in the disorder phase.
When packet reordering has been detected in Reno-mode,
linux's dupthresh (tp->reordering) is set to the number of packets in
flight (plus something else).
The question is, why choosing the number of packets in flight as new dupthresh?
And more important, why adapting the dupthresh when its old value is
still sufficient?
Detecting reordering in the disorder phase means that nothing has been
retransmitted yet.

kernel 2.6.30.4 - net/ipv4/tcp_input.c -line 1952
static void tcp_check_reno_reordering(struct sock *sk, const int addend)
{
        struct tcp_sock *tp = tcp_sk(sk);
        if (tcp_limit_reno_sacked(tp))
                tcp_update_reordering(sk, tp->packets_out + addend, 0);
}


29/09/2009 Daniel Slot (slot.daniel(at)gmail.com)
