From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH] tun: Persistent devices can get stuck in xoff state
Date: Wed, 9 Jul 2008 17:15:25 +0200
Message-ID: <200807091715.25464.borntraeger@de.ibm.com>
References: <1215584648-13444-1-git-send-email-maxk@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Max Krasnyansky <maxk@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:31024 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758574AbYGIPP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 11:15:28 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m69FFRxW633022
	for <netdev@vger.kernel.org>; Wed, 9 Jul 2008 15:15:27 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m69FFQg84354240
	for <netdev@vger.kernel.org>; Wed, 9 Jul 2008 17:15:26 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m69FFQE4028575
	for <netdev@vger.kernel.org>; Wed, 9 Jul 2008 17:15:26 +0200
In-Reply-To: <1215584648-13444-1-git-send-email-maxk@qualcomm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 9. Juli 2008 schrieb Max Krasnyansky:
> The scenario goes like this. App stops reading from tun/tap.
> TX queue gets full and driver does netif_stop_queue().
> App closes fd and TX queue gets flushed as part of the cleanup.
> Next time the app opens tun/tap and starts reading from it but
> the xoff state is not cleared. We're stuck.
> Normally xoff state is cleared when netdev is brought up. But
> in the case of persistent devices this happens only during
> initial setup.

Thats interesting. I believe we have seen exactly this behaviour
with KVM and lots of preallocated tap devices. 
[...]
> +++ b/drivers/net/tun.c
> @@ -576,6 +576,11 @@ static int tun_set_iff(struct file *file, struct ifreq 
*ifr)
>  	file->private_data = tun;
>  	tun->attached = 1;
> 
> +	/* Make sure persistent devices do not get stuck in
> +	 * xoff state */
> +	if (netif_running(tun->dev))
> +		netif_wake_queue(tun->dev);
> +
>  	strcpy(ifr->ifr_name, tun->dev->name);
>  	return 0;

I think that patch looks ok, but I am curious why you dont clear the xoff 
state on application close at the same time when the TX queue gets flushed?

Christian
