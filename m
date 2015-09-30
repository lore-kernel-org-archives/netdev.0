From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 1/3] net/rds: Use a single TCP socket for both
 send and receive.
Date: Wed, 30 Sep 2015 22:45:27 +0800
Message-ID: <201509302258.lJKbyxRW%fengguang.wu@intel.com>
References: <603874beb1dedd0a989d84740d22565bfc568c97.1443569239.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	rds-devel@oss.oracle.com, ajaykumar.hotchandani@oracle.com,
	igor.maximov@oracle.com, sowmini.varadhan@oracle.com,
	santosh.shilimkar@oracle.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <603874beb1dedd0a989d84740d22565bfc568c97.1443569239.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sowmini,

[auto build test results on v4.3-rc3 -- if it's inappropriate base, please ignore]

reproduce:
  # apt-get install sparse
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> net/rds/tcp_listen.c:118:35: sparse: restricted __be32 degrades to integer
   net/rds/tcp_listen.c:118:56: sparse: restricted __be32 degrades to integer
   net/rds/tcp_listen.c:187:29: sparse: incorrect type in assignment (different base types)
   net/rds/tcp_listen.c:187:29:    expected restricted __be32 [assigned] [usertype] s_addr
   net/rds/tcp_listen.c:187:29:    got unsigned int [unsigned] [usertype] <noident>
   net/rds/tcp_listen.c:188:22: sparse: incorrect type in assignment (different base types)
   net/rds/tcp_listen.c:188:22:    expected restricted __be16 [assigned] [usertype] sin_port
   net/rds/tcp_listen.c:188:22:    got unsigned short [unsigned] [usertype] <noident>

vim +118 net/rds/tcp_listen.c

   102			 &inet->inet_saddr, ntohs(inet->inet_sport),
   103			 &inet->inet_daddr, ntohs(inet->inet_dport));
   104	
   105		conn = rds_conn_create(sock_net(sock->sk),
   106				       inet->inet_saddr, inet->inet_daddr,
   107				       &rds_tcp_transport, GFP_KERNEL);
   108		if (IS_ERR(conn)) {
   109			ret = PTR_ERR(conn);
   110			goto out;
   111		}
   112		/* An incoming SYN request came in, and TCP just accepted it.
   113		 *
   114		 * If the client reboots, this conn will need to be cleaned up.
   115		 * rds_tcp_state_change() will do that cleanup
   116		 */
   117		rs_tcp = (struct rds_tcp_connection *)conn->c_transport_data;
 > 118		if (rs_tcp->t_sock && inet->inet_saddr < inet->inet_daddr) {
   119			struct sock *nsk = new_sock->sk;
   120	
   121			nsk->sk_user_data = NULL;
   122			nsk->sk_prot->disconnect(nsk, 0);
   123			tcp_done(nsk);
   124			new_sock = NULL;
   125			ret = 0;
   126			goto out;

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
