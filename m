From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] cipso: don't follow a NULL pointer when setsockopt() is called
Date: Tue, 17 Jul 2012 17:24:50 -0400
Message-ID: <16005876.GSA3ToWriD@sifl>
References: <20120717210738.22790.23522.stgit@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51377 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756737Ab2GQVYx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 17:24:53 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q6HLOrCA010459
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 17:24:53 -0400
Received: from sifl.localnet (vpn-10-24.rdu.redhat.com [10.11.10.24])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q6HLOqD5014473
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 17:24:53 -0400
In-Reply-To: <20120717210738.22790.23522.stgit@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, July 17, 2012 05:07:47 PM Paul Moore wrote:
> As reported by Alan Cox, and verified by Lin Ming, when a user
> attempts to add a CIPSO option to a socket using the CIPSO_V4_TAG_LOCAL
> tag the kernel dies a terrible death when it attempts to follow a NULL
> pointer (the skb argument to cipso_v4_validate() is NULL when called via
> the setsockopt() syscall).
> 
> This patch fixes this by first checking to ensure that the skb is
> non-NULL before using it to find the incoming network interface.  In
> the unlikely case where the skb is NULL and the user attempts to add
> a CIPSO option with the _TAG_LOCAL tag we return an error as this is
> not something we want to allow.

...

> CC: Lin Ming <mlin@ss.pku.edu.cn>
> Reported-by: Alan Cox <alan@lxorguk.ukuu.org.uk>
> Signed-off-by: Paul Moore <pmoore@redhat.com>

Argh, I just realized I forgot to CC the stable folks.

David, if you don't queue this up for them, let me know and I'll resend it to 
stable once it hits Linus' tree.

> ---
>  net/ipv4/cipso_ipv4.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
> index c48adc5..667c1d4 100644
> --- a/net/ipv4/cipso_ipv4.c
> +++ b/net/ipv4/cipso_ipv4.c
> @@ -1725,8 +1725,10 @@ int cipso_v4_validate(const struct sk_buff *skb,
> unsigned char **option) case CIPSO_V4_TAG_LOCAL:
>  			/* This is a non-standard tag that we only allow for
>  			 * local connections, so if the incoming interface is
> -			 * not the loopback device drop the packet. */
> -			if (!(skb->dev->flags & IFF_LOOPBACK)) {
> +			 * not the loopback device drop the packet. Further,
> +			 * there is no legitimate reason for setting this from
> +			 * userspace so reject it if skb is NULL. */
> +			if (skb == NULL || !(skb->dev->flags & IFF_LOOPBACK)) {
>  				err_offset = opt_iter;
>  				goto validate_return_locked;
>  			}
-- 
paul moore
security and virtualization @ redhat
