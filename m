From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 1/1] netfilter: h323: avoid potential attack
Date: Wed, 27 Jan 2016 23:06:27 +0800
Message-ID: <201601272338.CDMcH7dg%fengguang.wu@intel.com>
References: <1453905646-6446-1-git-send-email-zhouzhouyi@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="pWyiEgJYm5f9v55/"
Cc: kbuild-all@01.org, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zhouyi Zhou <yizhouzhou@ict.ac.cn>,
	Zhouyi Zhou <zhouzhouyi@gmail.com>
To: Zhouyi Zhou <zhouzhouyi@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1453905646-6446-1-git-send-email-zhouzhouyi@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--pWyiEgJYm5f9v55/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Zhouyi,

[auto build test ERROR on nf-next/master]
[also build test ERROR on v4.5-rc1 next-20160127]
[if your patch is applied to the wrong git tree, please drop us a note to help improving the system]

url:    https://github.com/0day-ci/linux/commits/Zhouyi-Zhou/netfilter-h323-avoid-potential-attack/20160127-225253
base:   https://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next master
config: x86_64-randconfig-x016-01270835 (attached as .config)
reproduce:
        # save the attached .config to linux build tree
        make ARCH=x86_64 

All error/warnings (new ones prefixed by >>):

   net/netfilter/nf_conntrack_h323_main.c: In function 'get_h245_addr':
>> net/netfilter/nf_conntrack_h323_main.c:114:11: error: invalid operands to binary - (have 'const unsigned char *' and 'char *')
      if (((p - h323_buffer) + n) > 65536)  \
              ^
>> net/netfilter/nf_conntrack_h323_main.c:254:2: note: in expansion of macro 'CHECK_BOUND'
     CHECK_BOUND(p, len);
     ^
   net/netfilter/nf_conntrack_h323_main.c: In function 'get_h225_addr':
>> net/netfilter/nf_conntrack_h323_main.c:114:11: error: invalid operands to binary - (have 'const unsigned char *' and 'char *')
      if (((p - h323_buffer) + n) > 65536)  \
              ^
   net/netfilter/nf_conntrack_h323_main.c:678:2: note: in expansion of macro 'CHECK_BOUND'
     CHECK_BOUND(p, len);
     ^

vim +114 net/netfilter/nf_conntrack_h323_main.c

   108			      __be16 port, struct nf_conntrack_expect *exp)
   109			      __read_mostly;
   110	
   111	static DEFINE_SPINLOCK(nf_h323_lock);
   112	static char *h323_buffer;
   113	#define CHECK_BOUND(p, n) do {					\
 > 114			if (((p - h323_buffer) + n) > 65536)		\
   115				return 0;				\
   116	} while (0)
   117	
   118	static struct nf_conntrack_helper nf_conntrack_helper_h245;
   119	static struct nf_conntrack_helper nf_conntrack_helper_q931[];
   120	static struct nf_conntrack_helper nf_conntrack_helper_ras[];
   121	
   122	/****************************************************************************/
   123	static int get_tpkt_data(struct sk_buff *skb, unsigned int protoff,
   124				 struct nf_conn *ct, enum ip_conntrack_info ctinfo,
   125				 unsigned char **data, int *datalen, int *dataoff)
   126	{
   127		struct nf_ct_h323_master *info = nfct_help_data(ct);
   128		int dir = CTINFO2DIR(ctinfo);
   129		const struct tcphdr *th;
   130		struct tcphdr _tcph;
   131		int tcpdatalen;
   132		int tcpdataoff;
   133		unsigned char *tpkt;
   134		int tpktlen;
   135		int tpktoff;
   136	
   137		/* Get TCP header */
   138		th = skb_header_pointer(skb, protoff, sizeof(_tcph), &_tcph);
   139		if (th == NULL)
   140			return 0;
   141	
   142		/* Get TCP data offset */
   143		tcpdataoff = protoff + th->doff * 4;
   144	
   145		/* Get TCP data length */
   146		tcpdatalen = skb->len - tcpdataoff;
   147		if (tcpdatalen <= 0)	/* No TCP data */
   148			goto clear_out;
   149	
   150		if (*data == NULL) {	/* first TPKT */
   151			/* Get first TPKT pointer */
   152			tpkt = skb_header_pointer(skb, tcpdataoff, tcpdatalen,
   153						  h323_buffer);
   154			BUG_ON(tpkt == NULL);
   155	
   156			/* Validate TPKT identifier */
   157			if (tcpdatalen < 4 || tpkt[0] != 0x03 || tpkt[1] != 0) {
   158				/* Netmeeting sends TPKT header and data separately */
   159				if (info->tpkt_len[dir] > 0) {
   160					pr_debug("nf_ct_h323: previous packet "
   161						 "indicated separate TPKT data of %hu "
   162						 "bytes\n", info->tpkt_len[dir]);
   163					if (info->tpkt_len[dir] <= tcpdatalen) {
   164						/* Yes, there was a TPKT header
   165						 * received */
   166						*data = tpkt;
   167						*datalen = info->tpkt_len[dir];
   168						*dataoff = 0;
   169						goto out;
   170					}
   171	
   172					/* Fragmented TPKT */
   173					pr_debug("nf_ct_h323: fragmented TPKT\n");
   174					goto clear_out;
   175				}
   176	
   177				/* It is not even a TPKT */
   178				return 0;
   179			}
   180			tpktoff = 0;
   181		} else {		/* Next TPKT */
   182			tpktoff = *dataoff + *datalen;
   183			tcpdatalen -= tpktoff;
   184			if (tcpdatalen <= 4)	/* No more TPKT */
   185				goto clear_out;
   186			tpkt = *data + *datalen;
   187	
   188			/* Validate TPKT identifier */
   189			if (tpkt[0] != 0x03 || tpkt[1] != 0)
   190				goto clear_out;
   191		}
   192	
   193		/* Validate TPKT length */
   194		tpktlen = tpkt[2] * 256 + tpkt[3];
   195		if (tpktlen < 4)
   196			goto clear_out;
   197		if (tpktlen > tcpdatalen) {
   198			if (tcpdatalen == 4) {	/* Separate TPKT header */
   199				/* Netmeeting sends TPKT header and data separately */
   200				pr_debug("nf_ct_h323: separate TPKT header indicates "
   201					 "there will be TPKT data of %hu bytes\n",
   202					 tpktlen - 4);
   203				info->tpkt_len[dir] = tpktlen - 4;
   204				return 0;
   205			}
   206	
   207			pr_debug("nf_ct_h323: incomplete TPKT (fragmented?)\n");
   208			goto clear_out;
   209		}
   210	
   211		/* This is the encapsulated data */
   212		*data = tpkt + 4;
   213		*datalen = tpktlen - 4;
   214		*dataoff = tpktoff + 4;
   215	
   216	      out:
   217		/* Clear TPKT length */
   218		info->tpkt_len[dir] = 0;
   219		return 1;
   220	
   221	      clear_out:
   222		info->tpkt_len[dir] = 0;
   223		return 0;
   224	}
   225	
   226	/****************************************************************************/
   227	static int get_h245_addr(struct nf_conn *ct, const unsigned char *data,
   228				 H245_TransportAddress *taddr,
   229				 union nf_inet_addr *addr, __be16 *port)
   230	{
   231		const unsigned char *p;
   232		int len;
   233	
   234		if (taddr->choice != eH245_TransportAddress_unicastAddress)
   235			return 0;
   236	
   237		switch (taddr->unicastAddress.choice) {
   238		case eUnicastAddress_iPAddress:
   239			if (nf_ct_l3num(ct) != AF_INET)
   240				return 0;
   241			p = data + taddr->unicastAddress.iPAddress.network;
   242			len = 4;
   243			break;
   244		case eUnicastAddress_iP6Address:
   245			if (nf_ct_l3num(ct) != AF_INET6)
   246				return 0;
   247			p = data + taddr->unicastAddress.iP6Address.network;
   248			len = 16;
   249			break;
   250		default:
   251			return 0;
   252		}
   253	
 > 254		CHECK_BOUND(p, len);
   255	
   256		memcpy(addr, p, len);
   257		memset((void *)addr + len, 0, sizeof(*addr) - len);

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--pWyiEgJYm5f9v55/
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
oFidpun/Y5cJKDsXAQA=

--pWyiEgJYm5f9v55/--
