From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V6 net-next 2/2] smc: introduce socket family AF_SMC
Date: Mon, 21 Sep 2015 11:44:25 -0700 (PDT)
Message-ID: <20150921.114425.119948328742744162.davem@davemloft.net>
References: <1442227366-79236-1-git-send-email-ubraun@linux.vnet.ibm.com>
	<1442227366-79236-3-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: utz.bacher@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, ursula.braun@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54269 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140AbbIUSo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 14:44:29 -0400
In-Reply-To: <1442227366-79236-3-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Mon, 14 Sep 2015 12:42:46 +0200

> +#ifdef CONFIG_S390
> +#include <asm/ebcdic.h>
> +#endif

Please keep s390'isms out of this code.

> +void smc_link_up(struct smc_link_group *lgr)
> +{
> +	struct smc_roce_defs rocdefs;
> +	struct smc_link *link = NULL;
> +	int i;
> +	u8 p1, p2;

Please order local variable declarations from longest to shortest
line (aka: "reverse christimas tree").

Please fix this up for your entire submission, as I'm not going to
point out all of the instances explicitly.

> +
> +	/* determine working link */
> +	for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
> +		if (atomic_read(&lgr->lnk[i].state) == SMC_LINK_UP) {
> +			link = &lgr->lnk[i];
> +			break;
> +		}
> +	}

Using an atomic_t type and then only performing 'set' and 'read'
operations on that variable is pointless and doesn't provide you
with any real "atomicity".

Please use a plain int, or provide a complete and suitable
justification for using atomic_t in this situation.

> +	for (i = 0; i < 2; i++) {

Please change this '2' constant in all of these loops to some
suitable mnenomic.  Likewise in the declaration of the 'port_err'
struct member et al.

> +		get_random_bytes_arch(&local_peerid[0], 2);

I really don't see any justification for using get_random_bytes_arch()
vs. plain get_random_bytes().

> +void smc_sock_wake_tx(struct sock *sk)
> +{
> +	struct smc_sock *smc = smc_sk(sk);
> +	struct socket_wq *wq;
> +	struct socket *sock = sk->sk_socket;
> +
> +/* similar to sk_stream_write_space */

This comment is imporperly indented.

> +		/* cancel close waiting */
> +		atomic64_set(&conn->tx_curs_prep.s.acurs,
> +			     conn->tx_curs_sent.s.lcurs);
> +		atomic64_set(&conn->tx_curs_fin.s.acurs,
> +			     conn->tx_curs_sent.s.lcurs);

Another case of atomic types being used inappropriately.  You only use
'set' and 'read' operations on these values, and that makes using
atomic types entirely pointless.

This is a huge and complex submission and I'm already burnt out
reading the changes thus far.

You have a lot to fix up and you can expect many revisions to be
necessary before these changes are ready for integration upstream.
And that's if you are lucky and someone actually continues to review
this work.
