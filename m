From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC] tun: Support VIRTIO_NET_HDR_F_DATA_VALID in tun_get_user
Date: Mon, 27 Jun 2016 16:41:25 -0700
Message-ID: <CALx6S36i5tjUjY42AJOnFMdc+KAhdmQLEQcAr4+KWe=BZR5rgw@mail.gmail.com>
References: <1466821262-11176-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lorenzo Colitti <lorenzo@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33468 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888AbcF0Xl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 19:41:26 -0400
Received: by mail-io0-f196.google.com with SMTP id t74so402878ioi.0
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 16:41:26 -0700 (PDT)
In-Reply-To: <1466821262-11176-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 24, 2016 at 7:21 PM, Subash Abhinov Kasiviswanathan
<subashab@codeaurora.org> wrote:
> Userspace applications might sometimes process packets from hardware
> which has already validated checksum, perform trivial operations and
> then queue them back to the network stack. By not recomputing the
> checksum here, we can see significant improvement in performance.
>
> Sample application here is CLAT which does IPv6 to IPv4 translation.
> IPv6 packets for which checksum is validated in hardware are captured
> in CLAT and then translated to IPv4 and then queued back to network
> stack. In this case, it is expected that the application would not
> corrupt the packet and recomputing the checksum would be redundant.
>
> Pass the hint to kernel to skip checksum validation if
> VIRTIO_NET_HDR_F_DATA_VALID is set from userspace.
>
CHECKSUM_UNNECESSARY is not a hint, the interface is very specific. It
means that a checksum(s) has been verified to be correct. There is no
way here to validate that the userspace code is doing the right thing.
virtionet interface really should also pass checksum-complete values
to be up with the times, this would be more robust and harder to
silently get wrong.

Tom

> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> ---
>  drivers/net/tun.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index e16487c..a5828a5 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1263,6 +1263,9 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>                 }
>         }
>
> +       if (gso.flags & VIRTIO_NET_HDR_F_DATA_VALID)
> +               skb->ip_summed = CHECKSUM_UNNECESSARY;
> +
>         switch (tun->flags & TUN_TYPE_MASK) {
>         case IFF_TUN:
>                 if (tun->flags & IFF_NO_PI) {
> --
> 1.9.1
>
