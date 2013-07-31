From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v5 1/7] vxlan: Restructure vxlan socket apis.
Date: Wed, 31 Jul 2013 16:45:21 -0700
Message-ID: <20130731164521.09c43fb8@nehalam.linuxnetplumber.net>
References: <1375312463-18574-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:47570 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808Ab3GaXpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 19:45:25 -0400
Received: by mail-pd0-f173.google.com with SMTP id p11so1326950pdj.18
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 16:45:25 -0700 (PDT)
In-Reply-To: <1375312463-18574-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Jul 2013 16:14:23 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

>  	/* Disable multicast loopback */
>  	inet_sk(sk)->mc_loop = 0;
> +	spin_lock(&vn->sock_lock);
> +	hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
> +	spin_unlock(&vn->sock_lock);
>  

This change could potentially put two of the sockets with the
same port in the list.

There is an existing check in vxlan_sock_work to handle this
now. It does:
  create new socket (no locks)

  spin_lock
  if (udp_socket with that port exists)
      drop new socket
  else
      add to list
  spin_unlock

Your code seems to immediately put it on the list which
will cause duplicates if race occurs.
