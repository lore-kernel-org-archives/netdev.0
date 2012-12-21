From: Zhiyun Qian <zhiyunq@umich.edu>
Subject: TCP sequence number inference attack on Linux
Date: Fri, 21 Dec 2012 12:58:57 -0500
Message-ID: <CALvgte86miv450KnOcFRR-oEm_f=qRXarDfQkyU7T3OLqq816A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:56999 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014Ab2LUSFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 13:05:21 -0500
Received: by mail-wg0-f46.google.com with SMTP id dr13so2205691wgb.13
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 10:05:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear sir or madam,

My name is Zhiyun Qian, a recent PhD graduate from University of
Michigan. As our recent research effort, along with my colleagues, we
identified a vulnerability related to Linux. Details described in our
paper published at this year's ACM Conference on Computer and
Communications Security (CCS): Collaborative TCP Sequence Number
Inference Attack available
http://web.eecs.umich.edu/~zhiyunq/pub/ccs12_TCP_sequence_number_inference.pdf

Keywords: TCP, sequence number inference, DelayedAckLost counter,
privilege-escalation attack

The vulnerability would allow an local malicious program to gain write
access to TCP connections of other applications. An example attack
scenario (on android) would be "an attacker uploads a seemingly benign
app to the google play, when run at the background, it can inject
malicious HTML payload into a webpage open by the browser".

The problem is caused by the common TCP stats counters (the specific
counter I found is DelayedACKLost) maintained by the kernel (but
exposed to user space). By reading and reporting such counters to an
external attacker (colluded), the aforementioned attack can be
accomplished.

It is essentially a side-channel attack (using TCP stats counters to
infer TCP sequence numbers), but it is so real and easy to carry out
that I believe it should be considered a vulnerability. From a
difference perspective, this attack can be considered as a privilege
escalation attack since it allows a local non-privileged program to
gain write access to TCP connections made by other processes.

The lines of code in kernel impacted by the attack is:
net/ipv4/tcp_input.c at line 4166 (as in the latest kernel v3.7.1)

4160 static void tcp_send_dupack(struct sock *sk, const struct sk_buff *skb)
4161 {
4162        struct tcp_sock *tp = tcp_sk(sk);
4163
4164        if (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq &&
4165            before(TCP_SKB_CB(skb)->seq, tp->rcv_nxt)) {
4166                NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKLOST);
4167                tcp_enter_quickack_mode(sk);
4168
4169                if (tcp_is_sack(tp) && sysctl_tcp_dsack) {
4170                        u32 end_seq = TCP_SKB_CB(skb)->end_seq;
4171
4172                        if (after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt))
4173                                end_seq = tp->rcv_nxt;
4174                        tcp_dsack_set(sk, TCP_SKB_CB(skb)->seq, end_seq);
4175                }
4176        }
4177
4178        tcp_send_ack(sk);
4179 }


IMHO, an easy fix to the problem is to disallow unprivileged access to
counters such as DelayedAckLost. However, this solution may not be
ideal. A better way is to always enforce both acknowledgement number
and sequence number check on each incoming TCP packet instead of
checking one at a time. Currently, Linux TCP stack first only
validates the SEQ number and then subsequently the ACK number. If the
sequence number is invalid, the delayedAckLost counter will be
incremented (information about sequence number leaked already
regardless of the ACK number). To make attacker's job much harder (we
should require the attacker to guess both the valid sequence number
and ACK number at the same time). For instance, following RFC 5961:
(SND.UNA - MAX.SND.WND) <= SEG.ACK <= SND.NXT, this would require the
attacker to send many times (on the order of 10000) more packets to
conduct the same attack.

Please feel free to ask me any questions regarding this vulnerability.

Best,
-Zhiyun
