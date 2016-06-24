From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 24 Jun 2016 11:24:43 +1000
Message-ID: <20160624112443.3ab82788@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chris Packham <chris.packham@alliedtelesis.co.nz>,
	David Ahern <dsa@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/vrf.c

between commit:

  52fe705b493d ("net: vrf: replace hard tab with space in assignment")

from the net tree and commits:

  671cd19ade97 ("net: vrf: ipv4 support for local traffic to local addresses")
  625b47b50732 ("net: vrf: ipv6 support for local traffic to local addresses")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/vrf.c
index 8bd8c7e1ee87,b3762822b653..000000000000
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@@ -304,8 -437,26 +437,26 @@@ static int vrf_rt6_create(struct net_de
  	dst_hold(&rt6->dst);
  
  	rt6->rt6i_table = rt6i_table;
 -	rt6->dst.output	= vrf_output6;
 +	rt6->dst.output = vrf_output6;
+ 
+ 	/* create a dst for local routing - packets sent locally
+ 	 * to local address via the VRF device as a loopback
+ 	 */
+ 	rt6_local = ip6_dst_alloc(net, dev, flags);
+ 	if (!rt6_local) {
+ 		dst_release(&rt6->dst);
+ 		goto out;
+ 	}
+ 
+ 	dst_hold(&rt6_local->dst);
+ 
+ 	rt6_local->rt6i_idev  = in6_dev_get(dev);
+ 	rt6_local->rt6i_flags = RTF_UP | RTF_NONEXTHOP | RTF_LOCAL;
+ 	rt6_local->rt6i_table = rt6i_table;
+ 	rt6_local->dst.input  = ip6_input;
+ 
  	rcu_assign_pointer(vrf->rt6, rt6);
+ 	rcu_assign_pointer(vrf->rt6_local, rt6_local);
  
  	rc = 0;
  out:
@@@ -403,10 -576,22 +576,22 @@@ static int vrf_rtable_create(struct net
  	if (!rth)
  		return -ENOMEM;
  
+ 	/* create a dst for local ingress routing - packets sent locally
+ 	 * to local address via the VRF device as a loopback
+ 	 */
+ 	rth_local = rt_dst_alloc(dev, RTCF_LOCAL, RTN_LOCAL, 1, 1, 0);
+ 	if (!rth_local) {
+ 		dst_release(&rth->dst);
+ 		return -ENOMEM;
+ 	}
+ 
 -	rth->dst.output	= vrf_output;
 +	rth->dst.output = vrf_output;
  	rth->rt_table_id = vrf->tb_id;
  
+ 	rth_local->rt_table_id = vrf->tb_id;
+ 
  	rcu_assign_pointer(vrf->rth, rth);
+ 	rcu_assign_pointer(vrf->rth_local, rth_local);
  
  	return 0;
  }
