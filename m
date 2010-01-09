From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: query: tcp_sock tcp_header_len calculations
Date: Sat, 09 Jan 2010 09:03:35 -0500
Message-ID: <4B488CB7.8070900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.211.176]:64311 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594Ab0AIODi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2010 09:03:38 -0500
Received: by ywh6 with SMTP id 6so20284764ywh.4
        for <netdev@vger.kernel.org>; Sat, 09 Jan 2010 06:03:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm re-writing TCPCT part 3 waiting for comments on part 2, and have
stumbled upon a completely undocumented and incomprehensible usage for
tcp_header_len.  Is whomever wrote this still around?

linux/tcp.h documents this as:
...
	u16	tcp_header_len;	/* Bytes of tcp header to send		*/
...

So far, so good.  But it's clearly *not* correct in tcp_output.c:

tcp_connect_init()
...
	tp->tcp_header_len = sizeof(struct tcphdr) +
		(sysctl_tcp_timestamps ? TCPOLEN_TSTAMP_ALIGNED : 0);

#ifdef CONFIG_TCP_MD5SIG
	if (tp->af_specific->md5_lookup(sk, sk) != NULL)
		tp->tcp_header_len += TCPOLEN_MD5SIG_ALIGNED;
#endif
...

This combination is actually *impossible* -- current options code
*never* allows both authentication and timestamps, doing SACK instead:

tcp_syn_options()
...
	if (likely(sysctl_tcp_timestamps && *md5 == NULL)) {
		opts->options |= OPTION_TS;
...

tcp_synack_options()
...
		/* We can't fit any SACK blocks in a packet with MD5 + TS
		 * options. There was discussion about disabling SACK
		 * rather than TS in order to fit in better with old,
		 * buggy kernels, but that was deemed to be unnecessary.
		 */
		doing_ts &= !ireq->sack_ok;
...

Thus, tcp_header_len has the wrong value, resulting in underestimation
for MSS.  But even worse usage in minisocks.c:

tcp_create_openreq_child()
...
		if (newtp->rx_opt.tstamp_ok) {
			newtp->rx_opt.ts_recent = req->ts_recent;
			newtp->rx_opt.ts_recent_stamp = get_seconds();
			newtp->tcp_header_len = sizeof(struct tcphdr) + TCPOLEN_TSTAMP_ALIGNED;
		} else {
			newtp->rx_opt.ts_recent_stamp = 0;
			newtp->tcp_header_len = sizeof(struct tcphdr);
		}
#ifdef CONFIG_TCP_MD5SIG
		newtp->md5sig_info = NULL;	/*XXX*/
#endif
		if (skb->len >= TCP_MSS_DEFAULT + newtp->tcp_header_len)
			newicsk->icsk_ack.last_seg_size = skb->len - newtp->tcp_header_len;
...

This takes an *output* estimation, and then compares it to (and subtracts
from) skb->len, which is *input* length.  What's supposed to happen here?

Shouldn't this simply use the real input tcp_hdrlen()?
