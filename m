From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH RFC 2/3] kcm: Kernel Connection Multiplexor module
Date: Wed, 23 Sep 2015 11:36:56 +0200
Message-ID: <20150923093656.GE29680@pox.localdomain>
References: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
 <1442788161-2626305-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:37100 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753075AbbIWJmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 05:42:52 -0400
Received: by wicfx3 with SMTP id fx3so60551091wic.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 02:42:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1442788161-2626305-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/15 at 03:29pm, Tom Herbert wrote:
> This module implement the Kernel Connection Multiplexor.
> 
> Kernel Connection Multiplexor (KCM) is a facility that provides a
> message based interface over TCP for generic application protocols.
> With KCM an application can efficiently send and receive application
> protocol messages over TCP using datagram sockets.
> 
> For more information see the included Documentation/networking/kcm.txt
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

This looks great!

> +Cloning KCM sockets
> +-------------------
> +
> +After the first KCM socket is created using the socket call as described
> +above, additional sockets for the multiplexor can be created by cloning
> +a KCM socket. This is accomplished by calling accept on the KCM socket:
> +
> +   newkcmfd = accept(kcmfd, NULL, 0)

This looks a bit ugly.

> +  ioctl(kcmfd, SIOCKCMATTACH, &info);

Use setsockopt() instead?

> +/* Process a new message. If there is no KCM socket waiting for a message
> + * hold it in the psock. Returns true if message is held this way, false
> + * otherwise.
> + */
> +static bool new_rx_msg(struct kcm_psock *psock, struct sk_buff *head)
> +{
> +	struct kcm_mux *mux = psock->mux;
> +	struct kcm_sock *kcm = NULL;
> +	struct sock *sk;
> +
> +	spin_lock_bh(&mux->lock);
> +
> +	if (WARN_ON(psock->ready_rx_msg)) {
> +		spin_unlock_bh(&mux->lock);
> +		kfree_skb(head);
> +		return false;
> +	}
> +
> +	if (list_empty(&mux->kcm_rx_waiters)) {
> +		psock->ready_rx_msg = head;
> +
> +		list_add_tail(&psock->psock_ready_list,
> +			      &mux->psocks_ready);
> +
> +		spin_unlock_bh(&mux->lock);
> +		return true;
> +	}
> +
> +	kcm = list_first_entry(&mux->kcm_rx_waiters,
> +			       struct kcm_sock, wait_rx_list);

Per CPU list of waiting sockets?
