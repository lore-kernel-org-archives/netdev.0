From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 2/6] vxlan: Group Policy extension
Date: Mon, 12 Jan 2015 11:23:28 -0800
Message-ID: <CAEP_g=8TqGnftZa_scKODa2ra7gsV6ov_5J+Lbfq+4bFDZjiBw@mail.gmail.com>
References: <cover.1421064100.git.tgraf@suug.ch> <014606bb741d017675f7728a0bccc4cbed42af4b.1421064100.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:45618 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932266AbbALTXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 14:23:49 -0500
Received: by mail-qc0-f174.google.com with SMTP id c9so19708862qcz.5
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 11:23:49 -0800 (PST)
In-Reply-To: <014606bb741d017675f7728a0bccc4cbed42af4b.1421064100.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2015 at 4:26 AM, Thomas Graf <tgraf@suug.ch> wrote:
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 4d52aa9..b148739 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -568,7 +569,8 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head, struct sk_buff
>                         continue;
>
>                 vh2 = (struct vxlanhdr *)(p->data + off_vx);
> -               if (vh->vx_vni != vh2->vx_vni) {
> +               if (vh->vx_flags != vh2->vx_flags ||
> +                   vh->vx_vni != vh2->vx_vni) {

It's probably better to do a memcmp over the entire header. There's no
guarantee that new fields will be entirely represented by flags.

> diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
> index d7c46b3..dd68c97 100644
> --- a/net/openvswitch/vport-vxlan.c
> +++ b/net/openvswitch/vport-vxlan.c
> @@ -146,6 +147,7 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
>         struct vxlan_port *vxlan_port = vxlan_vport(vport);
>         __be16 dst_port = inet_sk(vxlan_port->vs->sock->sk)->inet_sport;
>         struct ovs_key_ipv4_tunnel *tun_key;
> +       struct vxlan_metadata md;

It might be a good idea to zero out 'md', even if not strictly required.
