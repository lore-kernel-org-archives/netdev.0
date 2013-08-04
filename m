From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v6 3/8] vxlan: Add vxlan recv demux.
Date: Sun, 4 Aug 2013 14:45:26 -0700
Message-ID: <20130804144526.4b2e189c@nehalam.linuxnetplumber.net>
References: <1375382689-3218-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:41244 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753939Ab3HDVp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Aug 2013 17:45:29 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so2521461pde.37
        for <netdev@vger.kernel.org>; Sun, 04 Aug 2013 14:45:29 -0700 (PDT)
In-Reply-To: <1375382689-3218-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  1 Aug 2013 11:44:49 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> +static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
> +					 vxlan_rcv_t *rcv)
>  {
>  	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
>  	struct vxlan_sock *vs;
>  
> -	vxlan_socket_create(net, port);
> +	vxlan_socket_create(net, port, rcv);
>  
>  	spin_lock(&vn->sock_lock);
>  	vs = vxlan_find_sock(net, port);
> -	if (vs)
> -		atomic_inc(&vs->refcnt);
> -	else
> +	if (vs) {
> +		if (vs->rcv == rcv)
> +			atomic_inc(&vs->refcnt);
> +		else
> +			vs = ERR_PTR(-EBUSY);
> +	}
> +	spin_unlock(&vn->sock_lock);
> +

I think the ref counting needs to be the same for the
kernel and OVS handling of a VXLAN. 
