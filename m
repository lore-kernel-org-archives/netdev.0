From: Ben Greear <greearb@candelatech.com>
Subject: Adding multiple multicast routing tables.
Date: Mon, 26 May 2008 13:23:18 -0700
Message-ID: <483B1C36.50603@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:44161 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754997AbYEZUXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 16:23:19 -0400
Received: from [71.113.76.161] (pool-71-113-76-161.sttlwa.dsl-w.verizon.net [71.113.76.161])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id m4QKNIIr002097
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 26 May 2008 13:23:19 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am working on adding support for multiple multicast routing tables, and
would welcome some feedback if anyone has comments.

It looks like there are several globals currently.  I would plan to wrap 
those
in a 'mroute_table_entry struct and have the global be a hash of these
routing tables.

Inside this table, I'd add a hash of vifs (no more max limit for vifs),
the mroute_socket for this table, and 32-bit vif_index (routing-table id).

In the ip_mroute_setsockopt, add a 32-bit table-id to all of the
optnames.  This will increase the optlen by 4 for all options,
so we can know it's the new API.  For MRT_INIT, could pass
in something like this, for instance:

struct foo {
  uint32 mrt_table_idx;
  uint32 mrt_version;
}

Or, use entirely new MRT_* sockopts so there is no chance
of confusion.  I plan to update xorp to support this API, so I can be 
flexible on
the API.

User space will need a way to detect the new API.  I could probably
just try to INIT with a larger optlen.  2.6.25 (and probably many previous kernels) 

appears to error nicely if optlen != sizeof(int), so I can trigger on that.

The mcast table ID would be associated directly with the 'regular' routing
table index, so if the mcast is table-id 4444, then any routes 
associated with it
should be added to the unicast routing table 4444.  Or, it could be mapped,
but I am not sure there is much benefit for that added complexity.

getsockopt and the ioctl would need similar changes to the setsockopt.

ip_mr_input looks interesting...not sure how to decide which mroute_socket
it uses...maybe it doesn't matter?

And, for things like pim_rcv*, might need some sort of table lookup to
map a skb->dev into a mroute table so that it can handle the reg_vif_num
thing.  To make this really fast, a new member could be added to struct netdev.

A netdev may belong to no more that one mcast routing table.  If someone 
wants
to share NICS, they can use something like mac-vlans to multiplex the 
physical
device.

Suggestions are welcome.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


