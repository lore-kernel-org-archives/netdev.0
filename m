From: pravin shelar <pshelar@ovn.org>
Subject: Re: [net-next,v3] openvswitch: Add packet len info to upcall.
Date: Sun, 19 Jun 2016 11:08:51 -0700
Message-ID: <CAOrHB_ASYp9b_ibzAfg+3dorOer12j0MbB9eYTExVmOLzC3q_g@mail.gmail.com>
References: <1466193177-7656-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:45263 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbcFSSKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 14:10:23 -0400
Received: from mfilter13-d.gandi.net (mfilter13-d.gandi.net [217.70.178.141])
	by relay4-d.mail.gandi.net (Postfix) with ESMTP id C56CD1720A9
	for <netdev@vger.kernel.org>; Sun, 19 Jun 2016 20:08:54 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
	by mfilter13-d.gandi.net (mfilter13-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id F07-xaHxYzJm for <netdev@vger.kernel.org>;
	Sun, 19 Jun 2016 20:08:53 +0200 (CEST)
Received: from mail-it0-f53.google.com (mail-it0-f53.google.com [209.85.214.53])
	(Authenticated sender: pshelar@ovn.org)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 2EF99172097
	for <netdev@vger.kernel.org>; Sun, 19 Jun 2016 20:08:53 +0200 (CEST)
Received: by mail-it0-f53.google.com with SMTP id a5so30771399ita.1
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2016 11:08:53 -0700 (PDT)
In-Reply-To: <1466193177-7656-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 17, 2016 at 12:52 PM, William Tu <u9012063@gmail.com> wrote:
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
> ---
> v2->v3:
> - remove platform specific name.
> - fix issue when receiving GSO packet
> - remove skblen in struct dp_upcall_info
> v1->v2:
> - pass skb->len to userspace instead of cutlen
> ---
>  include/uapi/linux/openvswitch.h |  2 ++
>  net/openvswitch/datapath.c       | 11 ++++++++++-
>  2 files changed, 12 insertions(+), 1 deletion(-)
>

Patch looks good, I just have one minor comment.

> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 6739342..623fc04 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -387,7 +387,8 @@ static size_t upcall_msg_size(const struct dp_upcall_info *upcall_info,
>  {
>         size_t size = NLMSG_ALIGN(sizeof(struct ovs_header))
>                 + nla_total_size(hdrlen) /* OVS_PACKET_ATTR_PACKET */
> -               + nla_total_size(ovs_key_attr_size()); /* OVS_PACKET_ATTR_KEY */
> +               + nla_total_size(ovs_key_attr_size()) /* OVS_PACKET_ATTR_KEY */
> +               + nla_total_size(sizeof(unsigned int)); /* OVS_PACKET_ATTR_LEN */
>
>         /* OVS_PACKET_ATTR_USERDATA */
>         if (upcall_info->userdata)
> @@ -514,6 +515,14 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
>                 pad_packet(dp, user_skb);
>         }
>
> +       /* Add OVS_PACKET_ATTR_LEN */
> +       if (nla_put_u32(user_skb, OVS_PACKET_ATTR_LEN,
> +                       skb->len)) {
> +               err = -ENOBUFS;
> +               goto out;
> +       }
> +       pad_packet(dp, user_skb);
> +
We should only send packet length in case of truncated packet. This
would avoid sending this extra attribute in miss flow handling case.
