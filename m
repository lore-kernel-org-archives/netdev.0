From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/3] strparser: Stream parser for messages
Date: Thu, 28 Jul 2016 08:02:17 -0600
Message-ID: <8ed2ab5d-6d30-7cc6-fb85-829f338847ee@cumulusnetworks.com>
References: <1469653391-3443235-1-git-send-email-tom@herbertland.com>
 <1469653391-3443235-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com, lancerchao@fb.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33899 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758283AbcG1OCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 10:02:20 -0400
Received: by mail-pa0-f51.google.com with SMTP id fi15so21465636pac.1
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2016 07:02:19 -0700 (PDT)
In-Reply-To: <1469653391-3443235-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/27/16 3:03 PM, Tom Herbert wrote:
> diff --git a/net/strparser/strparser.c b/net/strparser/strparser.c
> new file mode 100644
> index 0000000..d7aec13
> --- /dev/null
> +++ b/net/strparser/strparser.c
> @@ -0,0 +1,492 @@

missing copyright header?

> +#include <linux/bpf.h>
> +#include <linux/errno.h>
> +#include <linux/errqueue.h>
> +#include <linux/file.h>
> +#include <linux/in.h>
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/net.h>
> +#include <linux/netdevice.h>
> +#include <linux/poll.h>
> +#include <linux/rculist.h>
> +#include <linux/skbuff.h>
> +#include <linux/socket.h>
> +#include <linux/uaccess.h>
> +#include <linux/workqueue.h>
> +#include <net/strparser.h>
> +#include <net/netns/generic.h>
> +#include <net/sock.h>
> +#include <net/tcp.h>

-----8<-----


> +/* Lower sock lock held */
> +void strp_tcp_data_ready(struct sock *sk)
> +{
> +	struct strparser *strp;
> +
> +	read_lock_bh(&sk->sk_callback_lock);
> +
> +	strp = (struct strparser *)sk->sk_user_data;
> +	if (unlikely(!strp || strp->rx_stopped))
> +		goto out;
> +
> +	if (strp->rx_paused)
> +		goto out;
> +
> +	if (strp->rx_need_bytes) {
> +		if (tcp_inq(sk) >= strp->rx_need_bytes)
> +			strp->rx_need_bytes = 0;
> +		else
> +			goto out;
> +	}
> +
> +	if (strp_tcp_read_sock(strp) == -ENOMEM)
> +		queue_delayed_work(strp_wq, &strp->rx_delayed_work, 0);
> +
> +out:
> +	read_unlock_bh(&sk->sk_callback_lock);
> +}
> +EXPORT_SYMBOL(strp_tcp_data_ready);

The module is GPL; did you want the symbol exports to be GPL as well?
