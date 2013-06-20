From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 8/8] openvswitch: Add vxlan tunneling support.
Date: Thu, 20 Jun 2013 11:14:10 -0700
Message-ID: <CAEP_g=-2PT7qLeN2TfBG8=arEaj56f-7pcVsoP-GeYSgT1k9+A@mail.gmail.com>
References: <1371713222-8349-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:49981 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758557Ab3FTSOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 14:14:35 -0400
Received: by mail-ie0-f176.google.com with SMTP id ar20so17217596iec.35
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 11:14:30 -0700 (PDT)
In-Reply-To: <1371713222-8349-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 20, 2013 at 12:27 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
> diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
> new file mode 100644
> index 0000000..be22134
> --- /dev/null
> +++ b/net/openvswitch/vport-vxlan.c
> @@ -0,0 +1,220 @@
> +/*
> + * Copyright (c) 2013 Nicira, Inc.

The version in the out of tree module has a Cisco copyright notice as
well. I think it would be polite to keep it here as well.

> +/* Called with rcu_read_lock and BH disabled. */
> +static int vxlan_rcv(struct vxlan_handler *vh, struct sk_buff *skb, __be32 vx_vni)
> +{
> +       struct vport *vport = vh->data;
> +       struct iphdr *iph;
> +       struct ovs_key_ipv4_tunnel tun_key;
> +       __be64 key;
> +
> +       if (unlikely(!vport))
> +               return PACKET_REJECT;

Can this ever be NULL if we've found out handler?

> +static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
> +{
> +       struct net *net = ovs_dp_get_net(parms->dp);
> +       struct nlattr *options = parms->options;
> +       struct vxlan_port *vxlan_port;
> +       struct vxlan_handler *vh;
> +       struct vport *vport;
> +       struct nlattr *a;
> +       int err;
> +       u16 dst_port;
> +
> +       if (!options) {
> +               err = -EINVAL;
> +               goto error;
> +       }
> +       a = nla_find_nested(options, OVS_TUNNEL_ATTR_DST_PORT);
> +       if (a && nla_len(a) == sizeof(u16)) {
> +               dst_port = nla_get_u16(a);
> +       } else {
> +               /* Require destination port from userspace. */
> +               err = -EINVAL;
> +               goto error;
> +       }
> +
> +       vport = ovs_vport_alloc(sizeof(struct vxlan_port),
> +                               &ovs_vxlan_vport_ops, parms);
> +       if (IS_ERR(vport))
> +               return vport;
> +
> +       rtnl_lock();
> +       vh = vxlan_add_handler(net, htons(dst_port), vxlan_rcv,
> +                              vport, OVS_VXLAN_RCV_PRIORITY);
> +       rtnl_unlock();
> +       if (IS_ERR(vh)) {
> +               ovs_vport_free(vport);
> +               return (void *)vh;
> +       }
> +
> +       vxlan_port = vxlan_vport(vport);
> +       strncpy(vxlan_port->name, parms->name, IFNAMSIZ);
> +       vxlan_port->vh = vh;
> +       vxlan_port->dst_port = htons(dst_port);

I'm somewhat concerned about setting these after we call
vxlan_add_handler(), which is the code that has the RCU barriers. We
don't access them on receive (where is the only place it matters) but
it makes the reasoning a little more complicated than necessary.
