From: Jonathan Toppins <jtoppins@redhat.com>
Subject: Re: [PATCH net-next 2/5] vxlan: support fdb and learning in
 COLLECT_METADATA mode
Date: Tue, 31 Jan 2017 18:37:20 -0500
Message-ID: <7e4844ec-df5e-6140-c2f7-281619616416@redhat.com>
References: <1485842235-32343-1-git-send-email-roopa@cumulusnetworks.com>
 <1485842235-32343-3-git-send-email-roopa@cumulusnetworks.com>
Reply-To: jtoppins@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40038 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750796AbdAaXhb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Jan 2017 18:37:31 -0500
In-Reply-To: <1485842235-32343-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/2017 12:57 AM, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Vxlan COLLECT_METADATA mode today solves the per-vni netdev
> scalability problem in l3 networks. It expects all forwarding
> information to be present in dst_metadata. This patch series
> enhances collect metadata mode to include the case where only
> vni is present in dst_metadata, and the vxlan driver can then use
> the rest of the forwarding information datbase to make forwarding
> decisions. There is no change to default COLLECT_METADATA
> behaviour. These changes only apply to COLLECT_METADATA when
> used with the bridging use-case with a special dst_metadata
> tunnel info flag (eg: where vxlan device is part of a bridge).
> For all this to work, the vxlan driver will need to now support a
> single fdb table hashed by mac + vni. This series essentially makes
> this happen.
> 
> use-case and workflow:
> vxlan collect metadata device participates in bridging vlan
> to vn-segments. Bridge driver above the vxlan device,
> sends the vni corresponding to the vlan in the dst_metadata.
> vxlan driver will lookup forwarding database with (mac + vni)
> for the required remote destination information to forward the
> packet.
> 
> Changes introduced by this patch:
>     - allow learning and forwarding database state in vxlan netdev in
>       COLLECT_METADATA mode. Current behaviour is not changed
>       by default. tunnel info flag IP_TUNNEL_INFO_BRIDGE is used
>       to support the new bridge friendly mode.
>     - A single fdb table hashed by (mac, vni) to allow fdb entries with
>       multiple vnis in the same fdb table
>     - rx path already has the vni
>     - tx path expects a vni in the packet with dst_metadata
>     - prior to this series, fdb remote_dsts carried remote vni and
>       the vxlan device carrying the fdb table represented the
>       source vni. With the vxlan device now representing multiple vnis,
>       this patch adds a src vni attribute to the fdb entry. The remote
>       vni already uses NDA_VNI attribute. This patch introduces
>       NDA_SRC_VNI netlink attribute to represent the src vni in a multi
>       vni fdb table.
> 
> iproute2 example (patched and pruned iproute2 output to just show
> relevant fdb entries):
> example shows same host mac learnt on two vni's.
> 
> before (netdev per vni):
> $bridge fdb show | grep "00:02:00:00:00:03"
> 00:02:00:00:00:03 dev vxlan1001 dst 12.0.0.8 self
> 00:02:00:00:00:03 dev vxlan1000 dst 12.0.0.8 self
> 
> after this patch with collect metadata in bridged mode (single netdev):
> $bridge fdb show | grep "00:02:00:00:00:03"
> 00:02:00:00:00:03 dev vxlan0 src_vni 1001 dst 12.0.0.8 self
> 00:02:00:00:00:03 dev vxlan0 src_vni 1000 dst 12.0.0.8 self
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  drivers/net/vxlan.c            |  211 +++++++++++++++++++++++++---------------
>  include/uapi/linux/neighbour.h |    1 +
>  2 files changed, 136 insertions(+), 76 deletions(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 19b1653..b80c405 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -57,6 +57,8 @@
>  
>  static const u8 all_zeros_mac[ETH_ALEN + 2];
>  
> +static u32 fdb_salt __read_mostly;
> +
>  static int vxlan_sock_add(struct vxlan_dev *vxlan);
>  
>  /* per-network namespace private data for this module */
> @@ -75,6 +77,7 @@ struct vxlan_fdb {
>  	struct list_head  remotes;
>  	u8		  eth_addr[ETH_ALEN];
>  	u16		  state;	/* see ndm_state */
> +	__be32		  vni;
>  	u8		  flags;	/* see ndm_flags */
>  };
>  
> @@ -302,6 +305,10 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
>  	if (rdst->remote_vni != vxlan->default_dst.remote_vni &&
>  	    nla_put_u32(skb, NDA_VNI, be32_to_cpu(rdst->remote_vni)))
>  		goto nla_put_failure;
> +	if ((vxlan->flags & VXLAN_F_COLLECT_METADATA) && fdb->vni &&
> +	    nla_put_u32(skb, NDA_SRC_VNI,
> +			be32_to_cpu(fdb->vni)))
> +		goto nla_put_failure;
>  	if (rdst->remote_ifindex &&
>  	    nla_put_u32(skb, NDA_IFINDEX, rdst->remote_ifindex))
>  		goto nla_put_failure;
> @@ -400,34 +407,51 @@ static u32 eth_hash(const unsigned char *addr)
>  	return hash_64(value, FDB_HASH_BITS);
>  }
>  
> +static u32 eth_vni_hash(const unsigned char *addr, __be32 vni)
> +{
> +	/* use 1 byte of OUI and 3 bytes of NIC */
> +	u32 key = get_unaligned((u32 *)(addr + 2));
> +
> +	return jhash_2words(key, vni, fdb_salt) & (FDB_HASH_SIZE - 1);

Not seeing where fdb_salt gets set to anything, why not just use a
constant zero here?

> +}
> +
>  /* Hash chain to use given mac address */
>  static inline struct hlist_head *vxlan_fdb_head(struct vxlan_dev *vxlan,
> -						const u8 *mac)
> +						const u8 *mac, __be32 vni)
>  {
> -	return &vxlan->fdb_head[eth_hash(mac)];
> +	if (vxlan->flags & VXLAN_F_COLLECT_METADATA)
> +		return &vxlan->fdb_head[eth_vni_hash(mac, vni)];
> +	else
> +		return &vxlan->fdb_head[eth_hash(mac)];
>  }
>  
