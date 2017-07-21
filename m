From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCHv2 net] ipv6: should not return rt->dst.error if it is
 prohibit or blk hole entry.
Date: Fri, 21 Jul 2017 23:29:34 +0800
Message-ID: <201707212326.7OKYJqTe%fengguang.wu@intel.com>
References: <1500608835-24845-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="xHFwDpU9dbj6ez1V"
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Hangbin Liu <liuhangbin@gmail.com>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:38913 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751464AbdGUPaB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Jul 2017 11:30:01 -0400
Content-Disposition: inline
In-Reply-To: <1500608835-24845-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Hangbin,

[auto build test ERROR on net/master]

url:    https://github.com/0day-ci/linux/commits/Hangbin-Liu/ipv6-should-not-return-rt-dst-error-if-it-is-prohibit-or-blk-hole-entry/20170721-204554
config: m68k-sun3_defconfig (attached as .config)
compiler: m68k-linux-gcc (GCC) 4.9.0
reproduce:
        wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=m68k 

All errors (new ones prefixed by >>):

   net//ipv6/route.c: In function 'inet6_rtm_getroute':
>> net//ipv6/route.c:3640:38: error: 'struct netns_ipv6' has no member named 'ip6_prohibit_entry'
     if (rt->dst.error && rt != net->ipv6.ip6_prohibit_entry &&
                                         ^
>> net//ipv6/route.c:3641:21: error: 'struct netns_ipv6' has no member named 'ip6_blk_hole_entry'
         rt != net->ipv6.ip6_blk_hole_entry) {
                        ^

vim +3640 net//ipv6/route.c

  3558	
  3559	static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
  3560				      struct netlink_ext_ack *extack)
  3561	{
  3562		struct net *net = sock_net(in_skb->sk);
  3563		struct nlattr *tb[RTA_MAX+1];
  3564		int err, iif = 0, oif = 0;
  3565		struct dst_entry *dst;
  3566		struct rt6_info *rt;
  3567		struct sk_buff *skb;
  3568		struct rtmsg *rtm;
  3569		struct flowi6 fl6;
  3570		bool fibmatch;
  3571	
  3572		err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv6_policy,
  3573				  extack);
  3574		if (err < 0)
  3575			goto errout;
  3576	
  3577		err = -EINVAL;
  3578		memset(&fl6, 0, sizeof(fl6));
  3579		rtm = nlmsg_data(nlh);
  3580		fl6.flowlabel = ip6_make_flowinfo(rtm->rtm_tos, 0);
  3581		fibmatch = !!(rtm->rtm_flags & RTM_F_FIB_MATCH);
  3582	
  3583		if (tb[RTA_SRC]) {
  3584			if (nla_len(tb[RTA_SRC]) < sizeof(struct in6_addr))
  3585				goto errout;
  3586	
  3587			fl6.saddr = *(struct in6_addr *)nla_data(tb[RTA_SRC]);
  3588		}
  3589	
  3590		if (tb[RTA_DST]) {
  3591			if (nla_len(tb[RTA_DST]) < sizeof(struct in6_addr))
  3592				goto errout;
  3593	
  3594			fl6.daddr = *(struct in6_addr *)nla_data(tb[RTA_DST]);
  3595		}
  3596	
  3597		if (tb[RTA_IIF])
  3598			iif = nla_get_u32(tb[RTA_IIF]);
  3599	
  3600		if (tb[RTA_OIF])
  3601			oif = nla_get_u32(tb[RTA_OIF]);
  3602	
  3603		if (tb[RTA_MARK])
  3604			fl6.flowi6_mark = nla_get_u32(tb[RTA_MARK]);
  3605	
  3606		if (tb[RTA_UID])
  3607			fl6.flowi6_uid = make_kuid(current_user_ns(),
  3608						   nla_get_u32(tb[RTA_UID]));
  3609		else
  3610			fl6.flowi6_uid = iif ? INVALID_UID : current_uid();
  3611	
  3612		if (iif) {
  3613			struct net_device *dev;
  3614			int flags = 0;
  3615	
  3616			dev = __dev_get_by_index(net, iif);
  3617			if (!dev) {
  3618				err = -ENODEV;
  3619				goto errout;
  3620			}
  3621	
  3622			fl6.flowi6_iif = iif;
  3623	
  3624			if (!ipv6_addr_any(&fl6.saddr))
  3625				flags |= RT6_LOOKUP_F_HAS_SADDR;
  3626	
  3627			if (!fibmatch)
  3628				dst = ip6_route_input_lookup(net, dev, &fl6, flags);
  3629		} else {
  3630			fl6.flowi6_oif = oif;
  3631	
  3632			if (!fibmatch)
  3633				dst = ip6_route_output(net, NULL, &fl6);
  3634		}
  3635	
  3636		if (fibmatch)
  3637			dst = ip6_route_lookup(net, &fl6, 0);
  3638	
  3639		rt = container_of(dst, struct rt6_info, dst);
> 3640		if (rt->dst.error && rt != net->ipv6.ip6_prohibit_entry &&
> 3641		    rt != net->ipv6.ip6_blk_hole_entry) {
  3642			err = rt->dst.error;
  3643			ip6_rt_put(rt);
  3644			goto errout;
  3645		}
  3646	
  3647		skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
  3648		if (!skb) {
  3649			ip6_rt_put(rt);
  3650			err = -ENOBUFS;
  3651			goto errout;
  3652		}
  3653	
  3654		skb_dst_set(skb, &rt->dst);
  3655		if (fibmatch)
  3656			err = rt6_fill_node(net, skb, rt, NULL, NULL, iif,
  3657					    RTM_NEWROUTE, NETLINK_CB(in_skb).portid,
  3658					    nlh->nlmsg_seq, 0);
  3659		else
  3660			err = rt6_fill_node(net, skb, rt, &fl6.daddr, &fl6.saddr, iif,
  3661					    RTM_NEWROUTE, NETLINK_CB(in_skb).portid,
  3662					    nlh->nlmsg_seq, 0);
  3663		if (err < 0) {
  3664			kfree_skb(skb);
  3665			goto errout;
  3666		}
  3667	
  3668		err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
  3669	errout:
  3670		return err;
  3671	}
  3672	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--xHFwDpU9dbj6ez1V
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
3GOttvbj//4LofsN/6i6AAA=

--xHFwDpU9dbj6ez1V--
