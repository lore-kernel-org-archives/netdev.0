From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net] dccp/tcp: fix ireq->opt races
Date: Sat, 21 Oct 2017 02:34:13 +0800
Message-ID: <201710210245.IOHWtezJ%fengguang.wu@intel.com>
References: <1508269854.31614.114.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, edumazet@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:13740 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752101AbdJTSe3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Oct 2017 14:34:29 -0400
Content-Disposition: inline
In-Reply-To: <1508269854.31614.114.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

[auto build test WARNING on net/master]

url:    https://github.com/0day-ci/linux/commits/Eric-Dumazet/dccp-tcp-fix-ireq-opt-races/20171021-001234
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)


vim +1954 net/ipv4/cipso_ipv4.c

446fda4f2 Paul Moore       2006-08-03  1898  
446fda4f2 Paul Moore       2006-08-03  1899  /**
389fb800a Paul Moore       2009-03-27  1900   * cipso_v4_req_setattr - Add a CIPSO option to a connection request socket
389fb800a Paul Moore       2009-03-27  1901   * @req: the connection request socket
389fb800a Paul Moore       2009-03-27  1902   * @doi_def: the CIPSO DOI to use
389fb800a Paul Moore       2009-03-27  1903   * @secattr: the specific security attributes of the socket
014ab19a6 Paul Moore       2008-10-10  1904   *
014ab19a6 Paul Moore       2008-10-10  1905   * Description:
389fb800a Paul Moore       2009-03-27  1906   * Set the CIPSO option on the given socket using the DOI definition and
389fb800a Paul Moore       2009-03-27  1907   * security attributes passed to the function.  Returns zero on success and
389fb800a Paul Moore       2009-03-27  1908   * negative values on failure.
014ab19a6 Paul Moore       2008-10-10  1909   *
014ab19a6 Paul Moore       2008-10-10  1910   */
389fb800a Paul Moore       2009-03-27  1911  int cipso_v4_req_setattr(struct request_sock *req,
389fb800a Paul Moore       2009-03-27  1912  			 const struct cipso_v4_doi *doi_def,
389fb800a Paul Moore       2009-03-27  1913  			 const struct netlbl_lsm_secattr *secattr)
014ab19a6 Paul Moore       2008-10-10  1914  {
389fb800a Paul Moore       2009-03-27  1915  	int ret_val = -EPERM;
389fb800a Paul Moore       2009-03-27  1916  	unsigned char *buf = NULL;
389fb800a Paul Moore       2009-03-27  1917  	u32 buf_len;
389fb800a Paul Moore       2009-03-27  1918  	u32 opt_len;
f6d8bd051 Eric Dumazet     2011-04-21  1919  	struct ip_options_rcu *opt = NULL;
389fb800a Paul Moore       2009-03-27  1920  	struct inet_request_sock *req_inet;
014ab19a6 Paul Moore       2008-10-10  1921  
389fb800a Paul Moore       2009-03-27  1922  	/* We allocate the maximum CIPSO option size here so we are probably
389fb800a Paul Moore       2009-03-27  1923  	 * being a little wasteful, but it makes our life _much_ easier later
389fb800a Paul Moore       2009-03-27  1924  	 * on and after all we are only talking about 40 bytes. */
389fb800a Paul Moore       2009-03-27  1925  	buf_len = CIPSO_V4_OPT_LEN_MAX;
389fb800a Paul Moore       2009-03-27  1926  	buf = kmalloc(buf_len, GFP_ATOMIC);
51456b291 Ian Morris       2015-04-03  1927  	if (!buf) {
389fb800a Paul Moore       2009-03-27  1928  		ret_val = -ENOMEM;
389fb800a Paul Moore       2009-03-27  1929  		goto req_setattr_failure;
389fb800a Paul Moore       2009-03-27  1930  	}
389fb800a Paul Moore       2009-03-27  1931  
389fb800a Paul Moore       2009-03-27  1932  	ret_val = cipso_v4_genopt(buf, buf_len, doi_def, secattr);
389fb800a Paul Moore       2009-03-27  1933  	if (ret_val < 0)
389fb800a Paul Moore       2009-03-27  1934  		goto req_setattr_failure;
389fb800a Paul Moore       2009-03-27  1935  	buf_len = ret_val;
389fb800a Paul Moore       2009-03-27  1936  
389fb800a Paul Moore       2009-03-27  1937  	/* We can't use ip_options_get() directly because it makes a call to
389fb800a Paul Moore       2009-03-27  1938  	 * ip_options_get_alloc() which allocates memory with GFP_KERNEL and
389fb800a Paul Moore       2009-03-27  1939  	 * we won't always have CAP_NET_RAW even though we _always_ want to
389fb800a Paul Moore       2009-03-27  1940  	 * set the IPOPT_CIPSO option. */
389fb800a Paul Moore       2009-03-27  1941  	opt_len = (buf_len + 3) & ~3;
389fb800a Paul Moore       2009-03-27  1942  	opt = kzalloc(sizeof(*opt) + opt_len, GFP_ATOMIC);
51456b291 Ian Morris       2015-04-03  1943  	if (!opt) {
389fb800a Paul Moore       2009-03-27  1944  		ret_val = -ENOMEM;
389fb800a Paul Moore       2009-03-27  1945  		goto req_setattr_failure;
389fb800a Paul Moore       2009-03-27  1946  	}
f6d8bd051 Eric Dumazet     2011-04-21  1947  	memcpy(opt->opt.__data, buf, buf_len);
f6d8bd051 Eric Dumazet     2011-04-21  1948  	opt->opt.optlen = opt_len;
f6d8bd051 Eric Dumazet     2011-04-21  1949  	opt->opt.cipso = sizeof(struct iphdr);
389fb800a Paul Moore       2009-03-27  1950  	kfree(buf);
389fb800a Paul Moore       2009-03-27  1951  	buf = NULL;
389fb800a Paul Moore       2009-03-27  1952  
389fb800a Paul Moore       2009-03-27  1953  	req_inet = inet_rsk(req);
389fb800a Paul Moore       2009-03-27 @1954  	opt = xchg(&req_inet->opt, opt);
f6d8bd051 Eric Dumazet     2011-04-21  1955  	if (opt)
4f9c8c1b0 Paul E. McKenney 2012-01-06  1956  		kfree_rcu(opt, rcu);
389fb800a Paul Moore       2009-03-27  1957  
389fb800a Paul Moore       2009-03-27  1958  	return 0;
389fb800a Paul Moore       2009-03-27  1959  
389fb800a Paul Moore       2009-03-27  1960  req_setattr_failure:
389fb800a Paul Moore       2009-03-27  1961  	kfree(buf);
389fb800a Paul Moore       2009-03-27  1962  	kfree(opt);
389fb800a Paul Moore       2009-03-27  1963  	return ret_val;
389fb800a Paul Moore       2009-03-27  1964  }
389fb800a Paul Moore       2009-03-27  1965  

:::::: The code at line 1954 was first introduced by commit
:::::: 389fb800ac8be2832efedd19978a2b8ced37eb61 netlabel: Label incoming TCP connections correctly in SELinux

:::::: TO: Paul Moore <paul.moore@hp.com>
:::::: CC: James Morris <jmorris@namei.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
