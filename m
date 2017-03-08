From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: Re: [PATCH v3] {net,IB}/{rxe,usnic}: Utilize generic mac to eui32
 function
Date: Wed, 8 Mar 2017 15:48:57 +0200
Message-ID: <20170308134856.GA4828@yuval-lap>
References: <1488915118-23331-1-git-send-email-yuval.shaia@oracle.com>
 <20170308074041.GW14379@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: benve@cisco.com, dgoodell@cisco.com, dledford@redhat.com,
        sean.hefty@intel.com, hal.rosenstock@gmail.com, monis@mellanox.com,
        davem@davemloft.net, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:48293 "EHLO
        aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751994AbdCHQVH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:21:07 -0500
Content-Disposition: inline
In-Reply-To: <20170308074041.GW14379@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 08, 2017 at 09:40:41AM +0200, Leon Romanovsky wrote:
> On Tue, Mar 07, 2017 at 09:31:58PM +0200, Yuval Shaia wrote:
> > This logic seems to be duplicated in (at least) three separate files.
> > Move it to one place so code can be re-use.
> >
> > Signed-off-by: Yuval Shaia <yuval.shaia@oracle.com>
> > ---
> > v0 -> v1:
> > 	* Add missing #include
> > 	* Rename to genaddrconf_ifid_eui48
> > v1 -> v2:
> > 	* Reset eui[0] to default if dev_id is used
> > v2 -> v3:
> > 	* Add helper function to avoid re-setting eui[0] to default if
> > 	  dev_id is used
> > ---
> >  drivers/infiniband/hw/usnic/usnic_common_util.h | 11 +++--------
> >  drivers/infiniband/sw/rxe/rxe_net.c             | 11 ++---------
> >  include/net/addrconf.h                          | 25 +++++++++++++++++++------
> >  3 files changed, 24 insertions(+), 23 deletions(-)
> 
> Not promising statistics :)

It is not fair, i also added 4 new blank lines :)

> 
> >
> > diff --git a/drivers/infiniband/hw/usnic/usnic_common_util.h b/drivers/infiniband/hw/usnic/usnic_common_util.h
> > index b54986d..d91b035 100644
> > --- a/drivers/infiniband/hw/usnic/usnic_common_util.h
> > +++ b/drivers/infiniband/hw/usnic/usnic_common_util.h
> > @@ -34,6 +34,8 @@
> >  #ifndef USNIC_CMN_UTIL_H
> >  #define USNIC_CMN_UTIL_H
> >
> > +#include <net/addrconf.h>
> > +
> >  static inline void
> >  usnic_mac_to_gid(const char *const mac, char *raw_gid)
> >  {
> > @@ -57,14 +59,7 @@ usnic_mac_ip_to_gid(const char *const mac, const __be32 inaddr, char *raw_gid)
> >  	raw_gid[1] = 0x80;
> >  	memset(&raw_gid[2], 0, 2);
> >  	memcpy(&raw_gid[4], &inaddr, 4);
> > -	raw_gid[8] = mac[0]^2;
> > -	raw_gid[9] = mac[1];
> > -	raw_gid[10] = mac[2];
> > -	raw_gid[11] = 0xff;
> > -	raw_gid[12] = 0xfe;
> > -	raw_gid[13] = mac[3];
> > -	raw_gid[14] = mac[4];
> > -	raw_gid[15] = mac[5];
> > +	addrconf_addr_eui48(&raw_gid[8], mac);
> >  }
> >
> >  static inline void
> > diff --git a/drivers/infiniband/sw/rxe/rxe_net.c b/drivers/infiniband/sw/rxe/rxe_net.c
> > index d8610960..ab8ea23 100644
> > --- a/drivers/infiniband/sw/rxe/rxe_net.c
> > +++ b/drivers/infiniband/sw/rxe/rxe_net.c
> > @@ -38,6 +38,7 @@
> >  #include <linux/if_vlan.h>
> >  #include <net/udp_tunnel.h>
> >  #include <net/sch_generic.h>
> > +#include <net/addrconf.h>
> >  #include <linux/netfilter.h>
> >  #include <rdma/ib_addr.h>
> >
> > @@ -86,18 +87,10 @@ struct rxe_recv_sockets recv_sockets;
> >
> >  static __be64 rxe_mac_to_eui64(struct net_device *ndev)
> >  {
> 
> It is worth to drop this wrapper completely. The rxe_mac_to_eui64 is
> called twice in the same file.

hmmm, this is a classic wrapper to adapt an existing API signature to
usage. And in this case to return __be64 from existing function which
returns void.

What we can do is the opposite - get rid of rxe_node_guid and rxe_port_guid
and call directly to rxe_mac_to_eui64. This is based on the assumption that
node_guid and port_guid are the same in Soft RoCE.
What do you think?

> 
> > -	unsigned char *mac_addr = ndev->dev_addr;
> >  	__be64 eui64;
> >  	unsigned char *dst = (unsigned char *)&eui64;
> >
> > -	dst[0] = mac_addr[0] ^ 2;
> > -	dst[1] = mac_addr[1];
> > -	dst[2] = mac_addr[2];
> > -	dst[3] = 0xff;
> > -	dst[4] = 0xfe;
> > -	dst[5] = mac_addr[3];
> > -	dst[6] = mac_addr[4];
> > -	dst[7] = mac_addr[5];
> > +	addrconf_addr_eui48(dst, ndev->dev_addr);
> >
> >  	return eui64;
> >  }
> > diff --git a/include/net/addrconf.h b/include/net/addrconf.h
> > index 17c6fd8..28274ed 100644
> > --- a/include/net/addrconf.h
> > +++ b/include/net/addrconf.h
> > @@ -103,12 +103,25 @@ int addrconf_prefix_rcv_add_addr(struct net *net, struct net_device *dev,
> >  				 u32 addr_flags, bool sllao, bool tokenized,
> >  				 __u32 valid_lft, u32 prefered_lft);
> >
> > +static inline void addrconf_addr_eui48_xor(u8 *eui, const char *const addr, bool xor)
> > +{
> > +	memcpy(eui, addr, 3);
> > +	if (xor)
> > +		eui[0] ^= 2;
> > +	eui[3] = 0xFF;
> > +	eui[4] = 0xFE;
> > +	memcpy(eui + 5, addr + 3, 3);
> > +}
> > +
> > +static inline void addrconf_addr_eui48(u8 *eui, const char *const addr)
> > +{
> > +	addrconf_addr_eui48_xor(eui, addr, true);
> 
> Just put your "eui[0] ^= 2" here and remove redundant "if (xor)".
> > +}
> > +
> >  static inline int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
> >  {
> >  	if (dev->addr_len != ETH_ALEN)
> >  		return -1;
> > -	memcpy(eui, dev->dev_addr, 3);
> > -	memcpy(eui + 5, dev->dev_addr + 3, 3);
> >
> >  	/*
> >  	 * The zSeries OSA network cards can be shared among various
> > @@ -123,14 +136,14 @@ static inline int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
> >  	 * case.  Hence the resulting interface identifier has local
> >  	 * scope according to RFC2373.
> >  	 */
> > +
> > +	addrconf_addr_eui48_xor(eui, dev->dev_addr, !dev->dev_id);
> > +
> >  	if (dev->dev_id) {
> >  		eui[3] = (dev->dev_id >> 8) & 0xFF;
> >  		eui[4] = dev->dev_id & 0xFF;
> > -	} else {
> > -		eui[3] = 0xFF;
> > -		eui[4] = 0xFE;
> > -		eui[0] ^= 2;
> 
> Leave this line.

Along with the above comment - looks better, will do.

> Thanks
> 
> >  	}
> > +
> >  	return 0;
> >  }
> >
> > --
> > 2.7.4
> >
