From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] vxlan: fix missing options_len update on RX with
 collect metadata
Date: Wed, 2 Mar 2016 17:21:13 -0800
Message-ID: <CAM_iQpWurWR6c2tvi1fGmNvt-6J=mE05CeKKJkLAEob3stLtZg@mail.gmail.com>
References: <ea834e5ecd014f50f9d979ee869f96e5508f8d9c.1456880721.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>, jesse@kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:35662 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754937AbcCCBVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 20:21:14 -0500
Received: by mail-yw0-f175.google.com with SMTP id g127so6172027ywf.2
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 17:21:13 -0800 (PST)
In-Reply-To: <ea834e5ecd014f50f9d979ee869f96e5508f8d9c.1456880721.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2016 at 5:32 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> When signalling to metadata consumers that the metadata_dst entry
> carries additional GBP extension data for vxlan (TUNNEL_VXLAN_OPT),
> the dst's vxlan_metadata information is populated, but options_len
> is left to zero. F.e. in ovs, ovs_flow_key_extract() checks for
> options_len before extracting the data through ip_tunnel_info_opts_get().
>
> Geneve uses ip_tunnel_info_opts_set() helper in receive path, which
> sets options_len internally, vxlan however uses ip_tunnel_info_opts(),
> so when filling vxlan_metadata, we do need to update options_len.
>
> Fixes: 4c22279848c5 ("ip-tunnel: Use API to access tunnel metadata options.")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  drivers/net/vxlan.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index b601139..1c32bd1 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1308,8 +1308,10 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
>                 gbp = (struct vxlanhdr_gbp *)vxh;
>                 md->gbp = ntohs(gbp->policy_id);
>
> -               if (tun_dst)
> +               if (tun_dst) {
>                         tun_dst->u.tun_info.key.tun_flags |= TUNNEL_VXLAN_OPT;
> +                       tun_dst->u.tun_info.options_len = sizeof(*md);
> +               }
>

Why not set it in tun_rx_dst() where it is allocated?
