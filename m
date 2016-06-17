From: pravin shelar <pshelar@ovn.org>
Subject: Re: [net-next,v2] openvswitch: Add skb->len info to upcall.
Date: Thu, 16 Jun 2016 18:50:35 -0700
Message-ID: <CAOrHB_Bs-C78nCUvtQd5ubm_Bz5jdUrWLKt-jE7xdqymawm88Q@mail.gmail.com>
References: <1466101040-47741-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:49523 "EHLO
	relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755047AbcFQBuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 21:50:40 -0400
Received: from mfilter35-d.gandi.net (mfilter35-d.gandi.net [217.70.178.166])
	by relay6-d.mail.gandi.net (Postfix) with ESMTP id 20A0DFB887
	for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 03:50:39 +0200 (CEST)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
	by mfilter35-d.gandi.net (mfilter35-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id Xw5rZiWECU-H for <netdev@vger.kernel.org>;
	Fri, 17 Jun 2016 03:50:37 +0200 (CEST)
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	(Authenticated sender: pshelar@ovn.org)
	by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 8C190FB881
	for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 03:50:37 +0200 (CEST)
Received: by mail-io0-f176.google.com with SMTP id f30so57842464ioj.2
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 18:50:37 -0700 (PDT)
In-Reply-To: <1466101040-47741-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 16, 2016 at 11:17 AM, William Tu <u9012063@gmail.com> wrote:
> The commit f2a4d086ed4c ("openvswitch: Add packet truncation support.")
> introduces packet truncation before sending to userspace upcall receiver.
> This patch passes up the skb->len before truncation so that the upcall
> receiver knows the original packet size. Potentially this will be used
> by sFlow, where OVS translates sFlow config header=N to a sample action,
> truncating packet to N byte in kernel datapath. Thus, only N bytes instead
> of full-packet size is copied from kernel to userspace, saving the
> kernel-to-userspace bandwidth.
>
> Signed-off-by: William Tu <u9012063@gmail.com>
> Cc: Pravin Shelar <pshelar@nicira.com>
>
> ---
> v1->v2:
> - pass skb->len to userspace instead of cutlen
> ---
>  include/uapi/linux/openvswitch.h |  2 ++
>  net/openvswitch/actions.c        |  1 +
>  net/openvswitch/datapath.c       | 15 +++++++++++++++
>  net/openvswitch/datapath.h       |  2 ++
>  4 files changed, 20 insertions(+)
>
> diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
> index 8274675..f9e204e 100644
> --- a/include/uapi/linux/openvswitch.h
> +++ b/include/uapi/linux/openvswitch.h
> @@ -166,6 +166,7 @@ enum ovs_packet_cmd {
>   * output port is actually a tunnel port. Contains the output tunnel key
>   * extracted from the packet as nested %OVS_TUNNEL_KEY_ATTR_* attributes.
>   * @OVS_PACKET_ATTR_MRU: Present for an %OVS_PACKET_CMD_ACTION and
> + * @OVS_PACKET_ATTR_SKBLEN: Packet size before truncation.
>   * %OVS_PACKET_ATTR_USERSPACE action specify the Maximum received fragment
>   * size.
>   *
> @@ -185,6 +186,7 @@ enum ovs_packet_attr {
>         OVS_PACKET_ATTR_PROBE,      /* Packet operation is a feature probe,
>                                        error logging should be suppressed. */
>         OVS_PACKET_ATTR_MRU,        /* Maximum received IP fragment size. */
> +       OVS_PACKET_ATTR_SKBLEN,         /* Packet size before truncation. */
>         __OVS_PACKET_ATTR_MAX
>  };
>
skb is linux specific name. I do not think it should be used in OVS
datapath interface which is not platform specific.

> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 1ecbd77..bb18ca1 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -793,6 +793,7 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
>         memset(&upcall, 0, sizeof(upcall));
>         upcall.cmd = OVS_PACKET_CMD_ACTION;
>         upcall.mru = OVS_CB(skb)->mru;
> +       upcall.skblen = skb->len;
>
In case of GSO packet up call breaks the packet and sends multiple
upcall, therefore this packet length is not correct.

>         for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
>                  a = nla_next(a, &rem)) {
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 6739342..3866d87 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -277,6 +277,7 @@ void ovs_dp_process_packet(struct sk_buff *skb, struct sw_flow_key *key)
>                 upcall.cmd = OVS_PACKET_CMD_MISS;
>                 upcall.portid = ovs_vport_find_upcall_portid(p, skb);
>                 upcall.mru = OVS_CB(skb)->mru;
> +               upcall.skblen = skb->len;

same as output_userspace(), this could be gso packet.

...
...
> diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
> index ab85c1c..f87f526 100644
> --- a/net/openvswitch/datapath.h
> +++ b/net/openvswitch/datapath.h
> @@ -120,6 +120,7 @@ struct ovs_skb_cb {
>   * counter.
>   * @egress_tun_info: If nonnull, becomes %OVS_PACKET_ATTR_EGRESS_TUN_KEY.
>   * @mru: If not zero, Maximum received IP fragment size.
> + * @skblen: The packet size before truncation.
>   */
>  struct dp_upcall_info {
>         struct ip_tunnel_info *egress_tun_info;
> @@ -129,6 +130,7 @@ struct dp_upcall_info {
>         u32 portid;
>         u8 cmd;
>         u16 mru;
> +       u32 skblen;
>  };
>
There is no need to pass this as parameter, queue_userspace_packet()
has access to the packet length.
