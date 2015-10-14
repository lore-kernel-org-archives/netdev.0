From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 3/3] tcp/dccp: fix race at listener dismantle
 phase
Date: Thu, 15 Oct 2015 03:27:48 +0800
Message-ID: <201510150300.H1hV4P1L%fengguang.wu@intel.com>
References: <1444845519-20064-4-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58017 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753357AbbJNT23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 15:28:29 -0400
Content-Disposition: inline
In-Reply-To: <1444845519-20064-4-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

[auto build test WARNING on net-next/master -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Eric-Dumazet/tcp-dccp-make-our-listener-code-more-robust/20151015-020006
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> net/ipv4/tcp_input.c:6238:17: sparse: context imbalance in 'tcp_conn_request' - unexpected unlock

vim +/tcp_conn_request +6238 net/ipv4/tcp_input.c

f7b3bec6 Florian Westphal 2014-11-03  6222  
f7b3bec6 Florian Westphal 2014-11-03  6223  	if (want_cookie) {
f7b3bec6 Florian Westphal 2014-11-03  6224  		isn = cookie_init_sequence(af_ops, sk, skb, &req->mss);
f7b3bec6 Florian Westphal 2014-11-03  6225  		req->cookie_ts = tmp_opt.tstamp_ok;
f7b3bec6 Florian Westphal 2014-11-03  6226  		if (!tmp_opt.tstamp_ok)
f7b3bec6 Florian Westphal 2014-11-03  6227  			inet_rsk(req)->ecn_ok = 0;
f7b3bec6 Florian Westphal 2014-11-03  6228  	}
f7b3bec6 Florian Westphal 2014-11-03  6229  
1fb6f159 Octavian Purdila 2014-06-25  6230  	tcp_rsk(req)->snt_isn = isn;
58d607d3 Eric Dumazet     2015-09-15  6231  	tcp_rsk(req)->txhash = net_tx_rndhash();
1fb6f159 Octavian Purdila 2014-06-25  6232  	tcp_openreq_init_rwin(req, sk, dst);
ca6fb065 Eric Dumazet     2015-10-02  6233  	if (!want_cookie) {
ca6fb065 Eric Dumazet     2015-10-02  6234  		tcp_reqsk_record_syn(sk, req, skb);
7656d842 Eric Dumazet     2015-10-04  6235  		fastopen_sk = tcp_try_fastopen(sk, skb, req, &foc, dst);
ca6fb065 Eric Dumazet     2015-10-02  6236  	}
7c85af88 Eric Dumazet     2015-09-24  6237  	if (fastopen_sk) {
ca6fb065 Eric Dumazet     2015-10-02 @6238  		af_ops->send_synack(fastopen_sk, dst, &fl, req,
ca6fb065 Eric Dumazet     2015-10-02  6239  				    skb_get_queue_mapping(skb), &foc, false);
7656d842 Eric Dumazet     2015-10-04  6240  		/* Add the child socket directly into the accept queue */
7656d842 Eric Dumazet     2015-10-04  6241  		inet_csk_reqsk_queue_add(sk, req, fastopen_sk);
7656d842 Eric Dumazet     2015-10-04  6242  		sk->sk_data_ready(sk);
7656d842 Eric Dumazet     2015-10-04  6243  		bh_unlock_sock(fastopen_sk);
7c85af88 Eric Dumazet     2015-09-24  6244  		sock_put(fastopen_sk);
7c85af88 Eric Dumazet     2015-09-24  6245  	} else {
9439ce00 Eric Dumazet     2015-03-17  6246  		tcp_rsk(req)->tfo_listener = false;

:::::: The code at line 6238 was first introduced by commit
:::::: ca6fb06518836ef9b65dc0aac02ff97704d52a05 tcp: attach SYNACK messages to request sockets instead of listener

:::::: TO: Eric Dumazet <edumazet@google.com>
:::::: CC: David S. Miller <davem@davemloft.net>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
