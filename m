From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] openvswitch: Scrub skb between namespaces
Date: Wed, 14 Oct 2015 17:34:24 -0700
Message-ID: <CALnjE+qzLHVLXxrMSrP7R9cQp7jxh7p4y85AqpfkmgYos7rEVw@mail.gmail.com>
References: <1444846249-52053-1-git-send-email-joestringer@nicira.com>
	<1444846249-52053-2-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
	Hannes Sowa <hannes@redhat.com>, Jesse Gross <jesse@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:32814 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbbJOAeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 20:34:24 -0400
Received: by iodv82 with SMTP id v82so73727630iod.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 17:34:24 -0700 (PDT)
In-Reply-To: <1444846249-52053-2-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2015 at 11:10 AM, Joe Stringer <joestringer@nicira.com> wrote:
> If OVS receives a packet from another namespace, then the packet should
> be scrubbed. However, people have already begun to rely on the behaviour
> that skb->mark is preserved across namespaces, so retain this one field.
>
> This is mainly to address information leakage between namespaces when
> using OVS internal ports, but by placing it in ovs_vport_receive() it is
> more generally applicable, meaning it should not be overlooked if other
> port types are allowed to be moved into namespaces in future.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> I originally proposed this patch as part of the conntrack changes to OVS,
> and there was some discussion on that thread, culminating here:
> http://www.spinics.net/lists/netdev/msg338626.html
>
> We also discussed this a bit in Seattle, however I didn't follow up
> immediately so I don't exactly recall what the consensus was. Following
> Jesse's direction in the above thread, I'm proposing that we preserve the
> mark, but scrub the rest. Also fixed the use-after-free bug present in the
> previous version.
>
> I think this is relevant for 'net', because this is the first time that
> the metadata_dst and nfct are exposed (albeit indirectly) through OVS so it
> would be nice to get agreement on the expected behaviour.
> ---
>  net/openvswitch/vport.c | 7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
> index fc5c0b9ccfe9..70f19ea99b92 100644
> --- a/net/openvswitch/vport.c
> +++ b/net/openvswitch/vport.c
> @@ -440,10 +440,17 @@ int ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
>                       const struct ip_tunnel_info *tun_info)
>  {
>         struct sw_flow_key key;
> +       u32 mark = skb->mark;
>         int error;
>
>         OVS_CB(skb)->input_vport = vport;
>         OVS_CB(skb)->mru = 0;
> +       if (dev_net(skb->dev) != ovs_dp_get_net(vport->dp)) {
This should be marked as unlikely.

> +               skb_scrub_packet(skb, true);
> +               tun_info = NULL;
> +       }
> +       skb->mark = mark;
Lets move this to skb scrub block. in other cases this not required.

> +
>         /* Extract flow from 'skb' into 'key'. */
>         error = ovs_flow_key_extract(tun_info, skb, &key);
>         if (unlikely(error)) {
> --
> 2.1.4
>
