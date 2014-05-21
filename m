From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2.57] datapath: Add basic MPLS support to
	kernel
Date: Tue, 20 May 2014 19:30:38 -0700
Message-ID: <CAEP_g=8ZEbx0NzCaXOc=ywiBAtejpmO4K-UzVk5uwBmEfUwZ7w@mail.gmail.com>
References: <1400195227-21265-1-git-send-email-horms@verge.net.au>
 <1400195227-21265-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1400195227-21265-2-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Thu, May 15, 2014 at 4:07 PM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> diff --git a/datapath/linux/compat/gso.c b/datapath/linux/compat/gso.c
> index 9ded17c..d9b4485 100644
> --- a/datapath/linux/compat/gso.c
> +++ b/datapath/linux/compat/gso.c
> -#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,37)
> +#if LINUX_VERSION_CODE < KERNEL_VERSION(3,11,0)
>  static bool dev_supports_vlan_tx(struct net_device *dev)
>  {
> -#if defined(HAVE_VLAN_BUG_WORKAROUND)
> +#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,37)
> +       return true;

Should this be greater than 2.6.37 instead of less than?

> diff --git a/datapath/linux/compat/include/linux/netdevice.h b/datapath/linux/compat/include/linux/netdevice.h
> index d726390..0381002 100644
> --- a/datapath/linux/compat/include/linux/netdevice.h
> +++ b/datapath/linux/compat/include/linux/netdevice.h
> +#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,38)
>  #define netif_skb_features rpl_netif_skb_features
>  netdev_features_t rpl_netif_skb_features(struct sk_buff *skb);

Currently this function doesn't look at mpls_features. Should it for
things other than TSO?

> diff --git a/datapath/linux/compat/netdevice.c b/datapath/linux/compat/netdevice.c
> index 1dc5abf..d22fced 100644
> --- a/datapath/linux/compat/netdevice.c
> +++ b/datapath/linux/compat/netdevice.c
> @@ -78,6 +83,9 @@ struct sk_buff *rpl_skb_gso_segment(struct sk_buff *skb,
>         __be16 skb_proto;
>         struct sk_buff *skb_gso;
>
> +       if (eth_p_mpls(skb->protocol))
> +               type = ovs_skb_get_inner_protocol(skb);
> +
>         while (type == htons(ETH_P_8021Q)) {
>                 struct vlan_hdr *vh;

Is the ordering on this backwards given that we expect that VLANs can
be on the outside but not the other way around?
