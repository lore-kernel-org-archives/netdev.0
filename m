From: =?UTF-8?B?5p2o56GV?= <shanqn@gmail.com>
Subject: why does the tcp_time_wait() call tcp_done(sk)?
Date: Thu, 25 Mar 2010 11:24:19 +0800
Message-ID: <ffe582101003242024o23ddbdc9w7aaffde382c3da8b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42443 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174Ab0CYDYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 23:24:21 -0400
Received: by wyb38 with SMTP id 38so3298970wyb.19
        for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 20:24:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

that means the connection has been closed?
Does kernel think like that???
we can use "STATE_TRACE" to see FIN_WAIT_2--->CLOSE rather than
FIN_WAIT_2-->TIME_WAIT-->CLOSE.

TIA.

void tcp_time_wait(struct sock *sk, int state, int timeo)
{
	struct inet_timewait_sock *tw = NULL;
	const struct inet_connection_sock *icsk = inet_csk(sk);
	const struct tcp_sock *tp = tcp_sk(sk);
	int recycle_ok = 0;

	if (tcp_death_row.sysctl_tw_recycle && tp->rx_opt.ts_recent_stamp)
		recycle_ok = icsk->icsk_af_ops->remember_stamp(sk);

	if (tcp_death_row.tw_count < tcp_death_row.sysctl_max_tw_buckets)
		tw = inet_twsk_alloc(sk, state);

	if (tw != NULL) {
		struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
		const int rto = (icsk->icsk_rto << 2) - (icsk->icsk_rto >> 1);

		tw->tw_rcv_wscale	= tp->rx_opt.rcv_wscale;
		tcptw->tw_rcv_nxt	= tp->rcv_nxt;
		tcptw->tw_snd_nxt	= tp->snd_nxt;
		tcptw->tw_rcv_wnd	= tcp_receive_window(tp);
		tcptw->tw_ts_recent	= tp->rx_opt.ts_recent;
		tcptw->tw_ts_recent_stamp = tp->rx_opt.ts_recent_stamp;

#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
		if (tw->tw_family == PF_INET6) {
			struct ipv6_pinfo *np = inet6_sk(sk);
			struct inet6_timewait_sock *tw6;

			tw->tw_ipv6_offset = inet6_tw_offset(sk->sk_prot);
			tw6 = inet6_twsk((struct sock *)tw);
			ipv6_addr_copy(&tw6->tw_v6_daddr, &np->daddr);
			ipv6_addr_copy(&tw6->tw_v6_rcv_saddr, &np->rcv_saddr);
			tw->tw_ipv6only = np->ipv6only;
		}
#endif

#ifdef CONFIG_TCP_MD5SIG
		/*
		 * The timewait bucket does not have the key DB from the
		 * sock structure. We just make a quick copy of the
		 * md5 key being used (if indeed we are using one)
		 * so the timewait ack generating code has the key.
		 */
		do {
			struct tcp_md5sig_key *key;
			memset(tcptw->tw_md5_key, 0, sizeof(tcptw->tw_md5_key));
			tcptw->tw_md5_keylen = 0;
			key = tp->af_specific->md5_lookup(sk, sk);
			if (key != NULL) {
				memcpy(&tcptw->tw_md5_key, key->key, key->keylen);
				tcptw->tw_md5_keylen = key->keylen;
				if (tcp_alloc_md5sig_pool() == NULL)
					BUG();
			}
		} while (0);
#endif

		/* Linkage updates. */
		__inet_twsk_hashdance(tw, sk, &tcp_hashinfo);

		/* Get the TIME_WAIT timeout firing. */
		if (timeo < rto)
			timeo = rto;

		if (recycle_ok) {
			tw->tw_timeout = rto;
		} else {
			tw->tw_timeout = TCP_TIMEWAIT_LEN;
			if (state == TCP_TIME_WAIT)
				timeo = TCP_TIMEWAIT_LEN;
		}

		inet_twsk_schedule(tw, &tcp_death_row, timeo,
				   TCP_TIMEWAIT_LEN);
		inet_twsk_put(tw);
	} else {
		/* Sorry, if we're out of memory, just CLOSE this
		 * socket up.  We've got bigger problems than
		 * non-graceful socket closings.
		 */
		LIMIT_NETDEBUG(KERN_INFO "TCP: time wait bucket table overflow\n");
	}

	tcp_update_metrics(sk);
	tcp_done(sk);
}
