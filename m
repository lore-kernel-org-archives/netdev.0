From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next-2.6 v2 08/12] net-caif: add CAIF socket
 implementation
Date: Tue, 16 Feb 2010 07:57:56 -0800
Message-ID: <1266335876.8849.11.camel@localhost.localdomain>
References: <1266328017-28406-1-git-send-email-sjur.brandeland@stericsson.com>
	 <1266328017-28406-2-git-send-email-sjur.brandeland@stericsson.com>
	 <1266328017-28406-3-git-send-email-sjur.brandeland@stericsson.com>
	 <1266328017-28406-4-git-send-email-sjur.brandeland@stericsson.com>
	 <1266328017-28406-5-git-send-email-sjur.brandeland@stericsson.com>
	 <1266328017-28406-6-git-send-email-sjur.brandeland@stericsson.com>
	 <1266328017-28406-7-git-send-email-sjur.brandeland@stericsson.com>
	 <1266328017-28406-8-git-send-email-sjur.brandeland@stericsson.com>
	 <1266328017-28406-9-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	daniel.martensson@stericsson.com, kaber@trash.net
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37085 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757129Ab0BPP7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 10:59:17 -0500
In-Reply-To: <1266328017-28406-9-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sjur,

> +static int setsockopt(struct socket *sock,
> +			int lvl, int opt, char __user *ov, unsigned int ol)
> +{
> +	struct sock *sk = sock->sk;
> +	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
> +	int prio, linksel;
> +	struct ifreq ifreq;
> +	struct caif_param caif_param;
> +	if (lvl != SOL_CAIF) {
> +		pr_debug("CAIF: %s(): setsockopt bad level\n", __func__);
> +		return -ENOPROTOOPT;
> +	}
> +	if (STATE_IS_OPEN(cf_sk)) {
> +		pr_debug("CAIF: %s(): setsockopt "
> +			 "cannot be done on a connected socket\n",
> +			 __func__);
> +		return -ENOPROTOOPT;
> +	}
> +	switch (opt) {
> +	case CAIFSO_LINK_SELECT:
> +		if (ol < sizeof(int)) {
> +			pr_debug("CAIF: %s(): setsockopt"
> +				 " CAIFSO_CHANNEL_CONFIG bad size\n", __func__);
> +			return -EINVAL;
> +		}
> +		if (copy_from_user(&linksel, ov, sizeof(int)))
> +			return -EINVAL;
> +		lock_sock(&(cf_sk->sk));
> +		cf_sk->config.phy_pref = linksel;
> +		pr_debug("CAIF: %s(): Setting sockopt pref=%dn", __func__,
> +			cf_sk->config.phy_pref);
> +		release_sock(&cf_sk->sk);
> +		return 0;
> +
> +	case SO_PRIORITY:
> +		if (ol < sizeof(int)) {
> +			pr_debug("CAIF: %s(): setsockopt"
> +				 " SO_PRIORITY bad size\n", __func__);
> +			return -EINVAL;
> +		}
> +		if (copy_from_user(&prio, ov, sizeof(int)))
> +			return -EINVAL;
> +		lock_sock(&(cf_sk->sk));
> +		cf_sk->config.phy_pref = prio;
> +		pr_debug("CAIF: %s(): Setting sockopt pref=%dn", __func__,
> +			cf_sk->config.phy_pref);
> +		release_sock(&cf_sk->sk);
> +		return 0;
> +
> +	case SO_BINDTODEVICE:
> +		if (ol < sizeof(struct ifreq)) {
> +			pr_debug("CAIF: %s(): setsockopt"
> +				 " SO_PRIORITY bad size\n", __func__);
> +			return -EINVAL;
> +		}
> +		if (copy_from_user(&ifreq, ov, sizeof(ifreq)))
> +			return -EFAULT;
> +		lock_sock(&(cf_sk->sk));
> +		strncpy(cf_sk->config.phy_name, ifreq.ifr_name,
> +			sizeof(cf_sk->config.phy_name));
> +		cf_sk->config.phy_name[sizeof(cf_sk->config.phy_name)-1] = 0;
> +
> +		release_sock(&cf_sk->sk);
> +		return 0;

I would have implemented SO_PRIORITY and SO_BINDTODEVICE on SOL_SOCKET
level. Having them on SOL_CAIF level is not really useful.

Regards

Marcel


