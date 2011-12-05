From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: ipv4: Perform peer validation on cached route lookup.
Date: Mon, 5 Dec 2011 16:27:14 +0300
Message-ID: <20111205132714.GA27452@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:53318 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932309Ab1LEN1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 08:27:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David S. Miller,

This is a semi-automatic email about new static checker warnings.

The patch efbc368dcc64: "ipv4: Perform peer validation on cached 
route lookup." from Dec 1, 2011, leads to the following Smatch 
complaint:

net/ipv4/route.c +2369 ip_route_input_common()
	 error: we previously assumed 'rth' could be null (see line 2378)

net/ipv4/route.c
  2368		for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
  2369		     rth = rcu_dereference(rth->dst.rt_next)) {
                                           ^^^^^^^^^^^^^^^^
The dereference here will oops

  2370			if ((((__force u32)rth->rt_key_dst ^ (__force u32)daddr) |
  2371			     ((__force u32)rth->rt_key_src ^ (__force u32)saddr) |
  2372			     (rth->rt_route_iif ^ iif) |
  2373			     (rth->rt_key_tos ^ tos)) == 0 &&
  2374			    rth->rt_mark == skb->mark &&
  2375			    net_eq(dev_net(rth->dst.dev), net) &&
  2376			    !rt_is_expired(rth)) {
  2377				rth = ipv4_validate_peer(rth);
  2378				if (!rth)
  2379					continue;

if we hit this new continue statement.

  2380				if (noref) {

regards,
dan carpenter
