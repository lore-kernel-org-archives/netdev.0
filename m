From: Jesse Gross <jesse@nicira.com>
Subject: Re: [ovs-dev] [PATCH net-next 12/12] openvswitch: Add gre tunnel support.
Date: Fri, 14 Jun 2013 17:31:23 -0700
Message-ID: <CAEP_g=8cDsUptKbLX_2qmgLWhmXSyzL5+uaipGWWfh0jj3VfsQ@mail.gmail.com>
References: <1371147917-9559-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:53224 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752497Ab3FOAbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 20:31:44 -0400
Received: by mail-ie0-f175.google.com with SMTP id a13so2805881iee.34
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 17:31:44 -0700 (PDT)
In-Reply-To: <1371147917-9559-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 13, 2013 at 11:25 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
> diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
> new file mode 100644
> index 0000000..0420237
> --- /dev/null
> +++ b/net/openvswitch/vport-gre.c
> +/* Called with rcu_read_lock and BH disabled. */
> +static int gre_rcv(struct sk_buff *skb,
> +                  const struct tnl_ptk_info *tpi)
> +{
> +       struct ovs_key_ipv4_tunnel tun_key;
> +       struct ovs_net *ovs_net;
> +       struct vport *vport;
> +       __be64 key;
> +
> +       ovs_net = net_generic(dev_net(skb->dev), ovs_net_id);
> +       vport = rcu_dereference(ovs_net->vport_net.gre_vport);
> +       if (unlikely(!vport))
> +               return PACKET_REJECT;
> +
> +       key = key_to_tunnel_id(tpi->key, tpi->seq);
> +       ovs_flow_tun_key_init(&tun_key, ip_hdr(skb), key, tpi->flags);

I would probably filter the flags coming in, just in case another
module adds a new flag that we're not expecting.

> +static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
> +{
[...]
> +       /* Allow our local IP stack to fragment the outer packet even
> +        * if the DF bit is set as a last resort.  We also need to
> +        * force selection of an IP ID here because Linux will
> +        * otherwise leave it at 0 if the packet originally had DF set.
> +        */
> +
> +       skb->local_df = 1;

Are we actually doing the IP ID selection here that the comment is referring to?

> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
> index ef0bb5f..286c12a 100644
> --- a/net/openvswitch/vport.c
> +++ b/net/openvswitch/vport.c
> @@ -38,6 +38,7 @@
>  static const struct vport_ops *vport_ops_list[] = {
>         &ovs_netdev_vport_ops,
>         &ovs_internal_vport_ops,
> +       &ovs_gre_vport_ops,
>  };

I think we need some config guards to check that the GRE and IP tunnel
modules are available in the current kernel.
