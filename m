From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: query: tcp_sock tcp_header_len calculations (re-sent)
Date: Sun, 10 Jan 2010 07:06:40 -0500
Message-ID: <4B49C2D0.1070704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752474Ab0AJMGq@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Apparently, nobody on the network developers list knows about this.  I've
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
