From: =?UTF-8?B?5p2o56GV?= <shanqn@gmail.com>
Subject: why not use the tcp_set_state() in inet_csk_listen_start()?
Date: Wed, 24 Mar 2010 16:13:20 +0800
Message-ID: <ffe582101003240113i15c48ff2g850bb209c825b11c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:46152 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753953Ab0CXINW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 04:13:22 -0400
Received: by wwe15 with SMTP id 15so4806536wwe.19
        for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 01:13:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

why use "sk->sk_state = TCP_LISTEN" rather than "tcp_set_state(sk, TCP_LISTEN)"?

TIA :)

int inet_csk_listen_start(struct sock *sk, const int nr_table_entries)
{
	struct inet_sock *inet = inet_sk(sk);
	struct inet_connection_sock *icsk = inet_csk(sk);
	int rc = reqsk_queue_alloc(&icsk->icsk_accept_queue, nr_table_entries);

	if (rc != 0)
		return rc;

	sk->sk_max_ack_backlog = 0;
	sk->sk_ack_backlog = 0;
	inet_csk_delack_init(sk);

	/* There is race window here: we announce ourselves listening,
	 * but this transition is still not validated by get_port().
	 * It is OK, because this socket enters to hash table only
	 * after validation is complete.
	 */
	sk->sk_state = TCP_LISTEN;
	if (!sk->sk_prot->get_port(sk, inet->num)) {
		inet->sport = htons(inet->num);

		sk_dst_reset(sk);
		sk->sk_prot->hash(sk);

		return 0;
	}

	sk->sk_state = TCP_CLOSE;
	__reqsk_queue_destroy(&icsk->icsk_accept_queue);
	return -EADDRINUSE;
}
