From: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [net-next-2.6 PATCH] infiniband: convert to use
 netdev_for_each_mc_addr
Date: Sat, 27 Feb 2010 23:07:33 +0100
Message-ID: <20100227220731.GB6550@psychotron.redhat.com>
References: <20100224151108.GD2663@psychotron.lab.eng.brq.redhat.com>
 <4B862E07.7020002@Voltaire.com>
 <20100225084915.GA3171@psychotron.redhat.com>
 <20100227060146.GA13231@obsidianresearch.com>
 <20100227103835.GA2862@psychotron.redhat.com>
 <20100227184410.GB13231@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Moni Shoua <monis-smomgflXvOZWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100227184410.GB13231-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sat, Feb 27, 2010 at 07:44:10PM CET, jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org wrote:
>On Sat, Feb 27, 2010 at 11:38:37AM +0100, Jiri Pirko wrote:
>
>> >The problem this statement is trying to solve had to do with bonding
>> >creating multicast addresess for ethernet rather than infiniband in
>> >some cases. This happens because bonding makes a device that switches
>> >from ethernet to infiniband during its lifetime. I'm not quite
>> >sure what kind of life cycle those addresses go through, but if they
>> >somehow stay on the mc_list then ipoib_mcast_addr_is_valid will still
>> >need to have the check.
>
>> Ok I see your point now. But in this case, the length check should be in all
>> drivers because if for example bonding device changes from infiniband back to
>> eth, the addresses stored would be "cut" to 6 bytes and would make no sense.
>
>Ideally, but the other wrinkle is due to other problems in the ipoib
>driver one bad multicast address blocks further addresses from being
>processed - effectively rendering the interface useless for
>multicast. Ethernet drivers will just subscribe to a bogus address, no
>real harm done.
>
>I would prefer to see the check remain in ipoib until we can see
>through testing that it is no longer triggering.

Fair enough.

Subject: [net-next-2.6 PATCH] ipoib: returned back addrle check for mc addresses

Apparently bogus mc address can brake IPOIB multicast processing. Therefore
returning the check for addrlen back until this is resolved in bonding (I don't
see any other point from where mc address with non-dev->addr_len length can came
from).

Signed-off-by: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index 19eba3c..d41ea27 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -767,8 +767,11 @@ void ipoib_mcast_dev_flush(struct net_device *dev)
 	}
 }
 
-static int ipoib_mcast_addr_is_valid(const u8 *addr, const u8 *broadcast)
+static int ipoib_mcast_addr_is_valid(const u8 *addr, unsigned int addrlen,
+				     const u8 *broadcast)
 {
+	if (addrlen != INFINIBAND_ALEN)
+		return 0;
 	/* reserved QPN, prefix, scope */
 	if (memcmp(addr, broadcast, 6))
 		return 0;
@@ -812,6 +815,7 @@ void ipoib_mcast_restart_task(struct work_struct *work)
 		union ib_gid mgid;
 
 		if (!ipoib_mcast_addr_is_valid(mclist->dmi_addr,
+					       mclist->dmi_addrlen,
 					       dev->broadcast))
 			continue;
 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
