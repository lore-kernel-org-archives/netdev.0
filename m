From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: [net-next PATCH v0 3/5] net: add fdb generic dump routine
Date: Sun, 25 Mar 2012 06:09:31 -0700
Message-ID: <CB94671B.49E3F%roprabhu@cisco.com>
References: <20120319065202.10959.53491.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <mst@redhat.com>, <chrisw@redhat.com>,
	<gregory.v.rose@intel.com>, <kvm@vger.kernel.org>,
	<sri@us.ibm.com>, <chealy@imsco-us.com>
To: John Fastabend <john.r.fastabend@intel.com>, <jhs@mojatatu.com>,
	<shemminger@vyatta.com>, <bhutchings@solarflare.com>,
	<davem@davemloft.net>, <jeffrey.t.kirsher@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120319065202.10959.53491.stgit@jf-dev1-dcblab>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org




On 3/18/12 11:52 PM, "John Fastabend" <john.r.fastabend@intel.com> wrote:

> This adds a generic dump routine drivers can call. It
> should be sufficient to handle any bridging model that
> uses the unicast address list. This should be most SR-IOV
> enabled NICs.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> 
>  net/core/rtnetlink.c |   56
> ++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 56 insertions(+), 0 deletions(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 8c3278a..35ee2d6 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2082,6 +2082,62 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct
> nlmsghdr *nlh, void *arg)
> return err;
>  }
>  
> +/**
> + * ndo_dflt_fdb_dump: default netdevice operation to dump an FDB table.
> + * @nlh: netlink message header
> + * @dev: netdevice
> + *
> + * Default netdevice operation to dump the existing unicast address list.
> + * Returns zero on success.
> + */
> +int ndo_dflt_fdb_dump(struct sk_buff *skb,
> +        struct netlink_callback *cb,
> +        struct net_device *dev,
> +        int idx)
> +{
> + struct netdev_hw_addr *ha;
> + struct nlmsghdr *nlh;
> + struct ndmsg *ndm;
> + u32 pid, seq;
> +
> + pid = NETLINK_CB(cb->skb).pid;
> + seq = cb->nlh->nlmsg_seq;
> +
> + netif_addr_lock_bh(dev);
> + list_for_each_entry(ha, &dev->uc.list, list) {
> +  if (idx < cb->args[0])
> +   goto skip;

Any reason why its only uc ?. What about mc ?

> +
> +  nlh = nlmsg_put(skb, pid, seq,
> +    RTM_NEWNEIGH, sizeof(*ndm), NLM_F_MULTI);
> +  if (!nlh)
> +   break;
> +
> +  ndm = nlmsg_data(nlh);
> +  ndm->ndm_family  = AF_BRIDGE;
> +  ndm->ndm_pad1  = 0;
> +  ndm->ndm_pad2    = 0;
> +  ndm->ndm_flags  = NTF_LOWERDEV;
> +  ndm->ndm_type  = 0;
> +  ndm->ndm_ifindex = dev->ifindex;
> +  ndm->ndm_state   = NUD_PERMANENT;
> +
> +  NLA_PUT(skb, NDA_LLADDR, ETH_ALEN, ha->addr);
> +
> +  nlmsg_end(skb, nlh);
> +skip:
> +  ++idx;
> + }
> + netif_addr_unlock_bh(dev);
> +
> + return idx;
> +nla_put_failure:
> + netif_addr_unlock_bh(dev);
> + nlmsg_cancel(skb, nlh);
> + return idx;
> +}
> +EXPORT_SYMBOL(ndo_dflt_fdb_dump);
> +
>  static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
>  {
> int idx = 0;
> 

