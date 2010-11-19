From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Fri, 19 Nov 2010 11:17:03 +1100
Message-ID: <20101119111703.8e33c5fb.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thomas Graf <tgraf@infradead.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
net/ipv6/addrconf.c between commit
18a31e1e282f9ed563b131526a88162ccbe04ee3 ("ipv6: Expose reachable and
retrans timer values as msecs") from the net-current tree and commit
b382b191ea9e9ccefc437433d23befe91f4a8925 ("ipv6: AF_INET6 link address
family") from the net tree.

I fixed it up (I think - see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv6/addrconf.c
index 2fc35b3,470e7ac..0000000
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@@ -3896,6 -3894,69 +3899,68 @@@ static void snmp6_fill_stats(u64 *stats
  	}
  }
  
+ static int inet6_fill_ifla6_attrs(struct sk_buff *skb, struct inet6_dev *idev)
+ {
+ 	struct nlattr *nla;
+ 	struct ifla_cacheinfo ci;
+ 
+ 	NLA_PUT_U32(skb, IFLA_INET6_FLAGS, idev->if_flags);
+ 
+ 	ci.max_reasm_len = IPV6_MAXPLEN;
 -	ci.tstamp = (__u32)(TIME_DELTA(idev->tstamp, INITIAL_JIFFIES) / HZ * 100
 -		    + TIME_DELTA(idev->tstamp, INITIAL_JIFFIES) % HZ * 100 / HZ);
 -	ci.reachable_time = idev->nd_parms->reachable_time;
 -	ci.retrans_time = idev->nd_parms->retrans_time;
++	ci.tstamp = cstamp_delta(idev->tstamp);
++	ci.reachable_time = jiffies_to_msecs(idev->nd_parms->reachable_time);
++	ci.retrans_time = jiffies_to_msecs(idev->nd_parms->retrans_time);
+ 	NLA_PUT(skb, IFLA_INET6_CACHEINFO, sizeof(ci), &ci);
+ 
+ 	nla = nla_reserve(skb, IFLA_INET6_CONF, DEVCONF_MAX * sizeof(s32));
+ 	if (nla == NULL)
+ 		goto nla_put_failure;
+ 	ipv6_store_devconf(&idev->cnf, nla_data(nla), nla_len(nla));
+ 
+ 	/* XXX - MC not implemented */
+ 
+ 	nla = nla_reserve(skb, IFLA_INET6_STATS, IPSTATS_MIB_MAX * sizeof(u64));
+ 	if (nla == NULL)
+ 		goto nla_put_failure;
+ 	snmp6_fill_stats(nla_data(nla), idev, IFLA_INET6_STATS, nla_len(nla));
+ 
+ 	nla = nla_reserve(skb, IFLA_INET6_ICMP6STATS, ICMP6_MIB_MAX * sizeof(u64));
+ 	if (nla == NULL)
+ 		goto nla_put_failure;
+ 	snmp6_fill_stats(nla_data(nla), idev, IFLA_INET6_ICMP6STATS, nla_len(nla));
+ 
+ 	return 0;
+ 
+ nla_put_failure:
+ 	return -EMSGSIZE;
+ }
+ 
+ static size_t inet6_get_link_af_size(const struct net_device *dev)
+ {
+ 	if (!__in6_dev_get(dev))
+ 		return 0;
+ 
+ 	return inet6_ifla6_size();
+ }
+ 
+ static int inet6_fill_link_af(struct sk_buff *skb, const struct net_device *dev)
+ {
+ 	struct inet6_dev *idev = __in6_dev_get(dev);
+ 
+ 	if (!idev)
+ 		return -ENODATA;
+ 
+ 	if (inet6_fill_ifla6_attrs(skb, idev) < 0)
+ 		return -EMSGSIZE;
+ 
+ 	return 0;
+ }
+ 
+ static int inet6_parse_link_af(struct net_device *dev, const struct nlattr *nla)
+ {
+ 	return -EOPNOTSUPP;
+ }
+ 
  static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev,
  			     u32 pid, u32 seq, int event, unsigned int flags)
  {
