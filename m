From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [RFC net] netconf: set mulitcast family for multicast forwarding
 messages
Date: Fri, 28 Jun 2013 09:13:38 -0700
Message-ID: <20130628091338.547bd88d@nehalam.linuxnetplumber.net>
References: <1372376687.21767.10.camel@imac-linux.luckyscavenger.com>
	<20130628082617.42a802a4@nehalam.linuxnetplumber.net>
	<51CDB1AD.1020202@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sven-Thorsten Dietrich <sven@vyatta.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Mike Davison <Mike.Davison@vyatta.com>
To: nicolas.dichtel@6wind.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51CDB1AD.1020202@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Revised version of Sven's patch. The idea is that multicast forwarding
should be under the multicast address family like other multicast netlink
messages.

This version generates each family under separate headers when
doing dump all.

Compile tested only, this is to show some of the issues that need
to be covered.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/ipv4/devinet.c	2013-06-11 09:50:21.550918636 -0700
+++ b/net/ipv4/devinet.c	2013-06-28 09:07:18.147829543 -0700
@@ -1685,6 +1685,11 @@ static int inet_netconf_msgsize_devconf(
 		size += nla_total_size(4);
 	if (type == -1 || type == NETCONFA_RP_FILTER)
 		size += nla_total_size(4);
+
+	/* additional header for MC family */
+	if (type == -1)
+		size += NLMSG_ALIGN(sizeof(struct netconfmsg))
+		   + nla_total_size(4);
 	if (type == -1 || type == NETCONFA_MC_FORWARDING)
 		size += nla_total_size(4);
 
@@ -1694,7 +1699,7 @@ static int inet_netconf_msgsize_devconf(
 static int inet_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 				     struct ipv4_devconf *devconf, u32 portid,
 				     u32 seq, int event, unsigned int flags,
-				     int type)
+				     u8 family, int type)
 {
 	struct nlmsghdr  *nlh;
 	struct netconfmsg *ncm;
@@ -1705,21 +1710,24 @@ static int inet_netconf_fill_devconf(str
 		return -EMSGSIZE;
 
 	ncm = nlmsg_data(nlh);
-	ncm->ncm_family = AF_INET;
+	ncm->ncm_family = family;
 
 	if (nla_put_s32(skb, NETCONFA_IFINDEX, ifindex) < 0)
 		goto nla_put_failure;
 
 	/* type -1 is used for ALL */
-	if ((type == -1 || type == NETCONFA_FORWARDING) &&
+	if (((type == -1 && family == AF_INET) ||
+	     type == NETCONFA_FORWARDING)  &&
 	    nla_put_s32(skb, NETCONFA_FORWARDING,
 			IPV4_DEVCONF(*devconf, FORWARDING)) < 0)
 		goto nla_put_failure;
-	if ((type == -1 || type == NETCONFA_RP_FILTER) &&
+	if (((type == -1 && family == AF_INET) ||
+	     type == NETCONFA_RP_FILTER) &&
 	    nla_put_s32(skb, NETCONFA_RP_FILTER,
 			IPV4_DEVCONF(*devconf, RP_FILTER)) < 0)
 		goto nla_put_failure;
-	if ((type == -1 || type == NETCONFA_MC_FORWARDING) &&
+	if (((type == -1 || family == RTNL_FAMILY_IPMR) ||
+	     type == NETCONFA_MC_FORWARDING) &&
 	    nla_put_s32(skb, NETCONFA_MC_FORWARDING,
 			IPV4_DEVCONF(*devconf, MC_FORWARDING)) < 0)
 		goto nla_put_failure;
@@ -1737,12 +1745,17 @@ void inet_netconf_notify_devconf(struct
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 
+	BUG_ON(type == -1); /* ALL is not valid for notification */
+
 	skb = nlmsg_new(inet_netconf_msgsize_devconf(type), GFP_ATOMIC);
 	if (skb == NULL)
 		goto errout;
 
 	err = inet_netconf_fill_devconf(skb, ifindex, devconf, 0, 0,
-					RTM_NEWNETCONF, 0, type);
+					RTM_NEWNETCONF, 0,
+					(type == NETCONFA_MC_FORWARDING) ?
+					RTNL_FAMILY_IPMR : AF_INET,
+					type);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in inet_netconf_msgsize_devconf() */
 		WARN_ON(err == -EMSGSIZE);
@@ -1811,13 +1824,23 @@ static int inet_netconf_get_devconf(stru
 	err = inet_netconf_fill_devconf(skb, ifindex, devconf,
 					NETLINK_CB(in_skb).portid,
 					nlh->nlmsg_seq, RTM_NEWNETCONF, 0,
-					-1);
+					AF_INET, -1);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in inet_netconf_msgsize_devconf() */
 		WARN_ON(err == -EMSGSIZE);
 		kfree_skb(skb);
 		goto errout;
 	}
+
+	err = inet_netconf_fill_devconf(skb, ifindex, devconf,
+					NETLINK_CB(in_skb).portid,
+					nlh->nlmsg_seq, RTM_NEWNETCONF, 0,
+					RTNL_FAMILY_IPMR, -1);
+	if (err < 0) {
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
 	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
 errout:
 	return err;
@@ -1855,10 +1878,23 @@ static int inet_netconf_dump_devconf(str
 						      cb->nlh->nlmsg_seq,
 						      RTM_NEWNETCONF,
 						      NLM_F_MULTI,
+						      AF_INET,
+						      -1) <= 0) {
+				rcu_read_unlock();
+				goto done;
+			}
+			if (inet_netconf_fill_devconf(skb, dev->ifindex,
+						      &in_dev->cnf,
+						      NETLINK_CB(cb->skb).portid,
+						      cb->nlh->nlmsg_seq,
+						      RTM_NEWNETCONF,
+						      NLM_F_MULTI,
+						      RTNL_FAMILY_IPMR,
 						      -1) <= 0) {
 				rcu_read_unlock();
 				goto done;
 			}
+
 			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
 cont:
 			idx++;
@@ -1871,10 +1907,18 @@ cont:
 					      NETLINK_CB(cb->skb).portid,
 					      cb->nlh->nlmsg_seq,
 					      RTM_NEWNETCONF, NLM_F_MULTI,
-					      -1) <= 0)
+					      AF_INET, -1) <= 0)
+			goto done;
+
+		if (inet_netconf_fill_devconf(skb, NETCONFA_IFINDEX_ALL,
+					      net->ipv4.devconf_all,
+					      NETLINK_CB(cb->skb).portid,
+					      cb->nlh->nlmsg_seq,
+					      RTM_NEWNETCONF, NLM_F_MULTI,
+					      RTNL_FAMILY_IPMR, -1) <= 0)
 			goto done;
-		else
-			h++;
+
+		h++;
 	}
 	if (h == NETDEV_HASHENTRIES + 1) {
 		if (inet_netconf_fill_devconf(skb, NETCONFA_IFINDEX_DEFAULT,
@@ -1882,10 +1926,18 @@ cont:
 					      NETLINK_CB(cb->skb).portid,
 					      cb->nlh->nlmsg_seq,
 					      RTM_NEWNETCONF, NLM_F_MULTI,
-					      -1) <= 0)
+					      AF_INET, -1) <= 0)
 			goto done;
-		else
-			h++;
+
+		if (inet_netconf_fill_devconf(skb, NETCONFA_IFINDEX_DEFAULT,
+					      net->ipv4.devconf_dflt,
+					      NETLINK_CB(cb->skb).portid,
+					      cb->nlh->nlmsg_seq,
+					      RTM_NEWNETCONF, NLM_F_MULTI,
+					      RTNL_FAMILY_IPMR, -1) <= 0)
+			goto done;
+
+		h++;
 	}
 done:
 	cb->args[0] = h;
--- a/net/ipv6/addrconf.c	2013-06-28 08:17:16.424664740 -0700
+++ b/net/ipv6/addrconf.c	2013-06-28 09:10:32.336959806 -0700
@@ -471,6 +471,9 @@ static int inet6_netconf_msgsize_devconf
 	if (type == -1 || type == NETCONFA_FORWARDING)
 		size += nla_total_size(4);
 #ifdef CONFIG_IPV6_MROUTE
+	if (type == -1)
+		size += NLMSG_ALIGN(sizeof(struct netconfmsg))
+			+ nla_total_size(4);
 	if (type == -1 || type == NETCONFA_MC_FORWARDING)
 		size += nla_total_size(4);
 #endif
@@ -481,7 +484,7 @@ static int inet6_netconf_msgsize_devconf
 static int inet6_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 				      struct ipv6_devconf *devconf, u32 portid,
 				      u32 seq, int event, unsigned int flags,
-				      int type)
+				      u8 family, int type)
 {
 	struct nlmsghdr  *nlh;
 	struct netconfmsg *ncm;
@@ -492,17 +495,19 @@ static int inet6_netconf_fill_devconf(st
 		return -EMSGSIZE;
 
 	ncm = nlmsg_data(nlh);
-	ncm->ncm_family = AF_INET6;
+	ncm->ncm_family = family;
 
 	if (nla_put_s32(skb, NETCONFA_IFINDEX, ifindex) < 0)
 		goto nla_put_failure;
 
 	/* type -1 is used for ALL */
-	if ((type == -1 || type == NETCONFA_FORWARDING) &&
+	if (((type == -1 && family == AF_INET6) ||
+	     type == NETCONFA_FORWARDING) &&
 	    nla_put_s32(skb, NETCONFA_FORWARDING, devconf->forwarding) < 0)
 		goto nla_put_failure;
 #ifdef CONFIG_IPV6_MROUTE
-	if ((type == -1 || type == NETCONFA_MC_FORWARDING) &&
+	if (((type == -1 && family == RTNL_FAMILY_IP6MR) ||
+	     type == NETCONFA_MC_FORWARDING) &&
 	    nla_put_s32(skb, NETCONFA_MC_FORWARDING,
 			devconf->mc_forwarding) < 0)
 		goto nla_put_failure;
@@ -520,12 +525,23 @@ void inet6_netconf_notify_devconf(struct
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 
+	BUG_ON(type == -1);
+
 	skb = nlmsg_new(inet6_netconf_msgsize_devconf(type), GFP_ATOMIC);
 	if (skb == NULL)
 		goto errout;
 
+#ifdef CONFIG_IPV6_MROUTE
+	if (type == NETCONFA_MC_FORWARDING)
+		err = inet6_netconf_fill_devconf(skb, ifindex, devconf, 0, 0,
+						 RTM_NEWNETCONF, 0,
+						 RTNL_FAMILY_IP6MR, type);
+	else
+#endif
 	err = inet6_netconf_fill_devconf(skb, ifindex, devconf, 0, 0,
-					 RTM_NEWNETCONF, 0, type);
+					 RTM_NEWNETCONF, 0,
+					 AF_INET6, type);
+#endif
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in inet6_netconf_msgsize_devconf() */
 		WARN_ON(err == -EMSGSIZE);
@@ -592,13 +608,25 @@ static int inet6_netconf_get_devconf(str
 	err = inet6_netconf_fill_devconf(skb, ifindex, devconf,
 					 NETLINK_CB(in_skb).portid,
 					 nlh->nlmsg_seq, RTM_NEWNETCONF, 0,
-					 -1);
+					 AF_INET6, -1);
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in inet6_netconf_msgsize_devconf() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
+#ifdef CONFIG_IPV6_MROUTE
+	err = inet6_netconf_fill_devconf(skb, ifindex, devconf,
+					 NETLINK_CB(in_skb).portid,
+					 nlh->nlmsg_seq, RTM_NEWNETCONF, 0,
+					 RTNL_FAMILY_IP6MR, -1);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in inet6_netconf_msgsize_devconf() */
 		WARN_ON(err == -EMSGSIZE);
 		kfree_skb(skb);
 		goto errout;
 	}
+#endif
 	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
 errout:
 	return err;
@@ -636,10 +664,23 @@ static int inet6_netconf_dump_devconf(st
 						       cb->nlh->nlmsg_seq,
 						       RTM_NEWNETCONF,
 						       NLM_F_MULTI,
+						       AF_INET6, -1) <= 0) {
+				rcu_read_unlock();
+				goto done;
+			}
+#ifdef CONFIG_IPV6_MROUTE
+			if (inet6_netconf_fill_devconf(skb, dev->ifindex,
+						       &idev->cnf,
+						       NETLINK_CB(cb->skb).portid,
+						       cb->nlh->nlmsg_seq,
+						       RTM_NEWNETCONF,
+						       NLM_F_MULTI,
+						       RTNL_FAMILY_IP6MR,
 						       -1) <= 0) {
 				rcu_read_unlock();
 				goto done;
 			}
+#endif
 			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
 cont:
 			idx++;
@@ -652,10 +693,18 @@ cont:
 					       NETLINK_CB(cb->skb).portid,
 					       cb->nlh->nlmsg_seq,
 					       RTM_NEWNETCONF, NLM_F_MULTI,
-					       -1) <= 0)
+					       AF_INET6, -1) <= 0)
 			goto done;
-		else
-			h++;
+#ifdef CONFIG_IPV6_MROUTE
+		if (inet6_netconf_fill_devconf(skb, NETCONFA_IFINDEX_ALL,
+					       net->ipv6.devconf_all,
+					       NETLINK_CB(cb->skb).portid,
+					       cb->nlh->nlmsg_seq,
+					       RTM_NEWNETCONF, NLM_F_MULTI,
+					       RTNL_FAMILY_IP6MR, -1) <= 0)
+			goto done;
+#endif
+		h++;
 	}
 	if (h == NETDEV_HASHENTRIES + 1) {
 		if (inet6_netconf_fill_devconf(skb, NETCONFA_IFINDEX_DEFAULT,
@@ -663,9 +712,17 @@ cont:
 					       NETLINK_CB(cb->skb).portid,
 					       cb->nlh->nlmsg_seq,
 					       RTM_NEWNETCONF, NLM_F_MULTI,
-					       -1) <= 0)
+					       AF_INET6, -1) <= 0)
+			goto done;
+#ifdef CONFIG_IPV6_MROUTE
+		if (inet6_netconf_fill_devconf(skb, NETCONFA_IFINDEX_DEFAULT,
+					       net->ipv6.devconf_dflt,
+					       NETLINK_CB(cb->skb).portid,
+					       cb->nlh->nlmsg_seq,
+					       RTM_NEWNETCONF, NLM_F_MULTI,
+					       RTNL_FAMILY_IP6MR, -1) <= 0)
 			goto done;
-		else
+#endif
 			h++;
 	}
 done:
