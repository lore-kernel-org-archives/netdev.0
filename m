From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Re : Re : Re : Bug in using inet_lookup ()
Date: Thu, 15 Nov 2007 19:45:27 +0300
Message-ID: <20071115164525.GA12632@2ka.mipt.ru>
References: <910163.76878.qm@web26108.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net
To: Nj A <nj_a83@yahoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:40466 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751881AbXKOQpl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 11:45:41 -0500
Content-Disposition: inline
In-Reply-To: <910163.76878.qm@web26108.mail.ukl.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 15, 2007 at 05:29:52PM +0100, Nj A (nj_a83@yahoo.fr) wrote:
> Hello all,
> No bugs are due to the inet_lookup call now using the following:
>       if ((s_skb = alloc_skb (MAX_TCP_HEADER + 15, GFP_ATOMIC)) == NULL)
>       {
>          printk ("%s: Unable to allocate memory \n", __FUNCTION__);
>          err = -ENOMEM;
>       }
>       dev = s_skb->dev;
> 
>       if (!dev)
>          printk ("%s: no device attached to s_skb\n", __FUNCTION__);
>          goto process_dev;
> 
>       sk = inet_lookup (&tcp_hashinfo, src, p_src, dst, p_dst, inet_iif (s_skb));
> 
>       bh_lock_sock (sk);
>     process_dev:
>       spin_lock (&tmp_lock);
>       new_dev = list_entry (&tmp, struct net_device, todo_list);
>       spin_unlock (&tmp_lock);
>       if (!new_dev)
>          printk ("%s: no device attached to new_dev \n", __FUNCTION__);
>       s_skb->dev = new_dev;
> 
>   ...
>   bh_unlock_sock (sk);
>   ...
> 
> However, I am not having the right results. I checked with an established socket and expected to see that the socket is established (which is the case) but got the wrong state when testing on (sk->sk_state) and the socket seems in the TIME_WAIT / CLOSE state.
> 
> May be I am corrupting the search by manually attaching a device to the skb?
> Any idea please?

Well, your code will oops just like before - you provide empty skb to
the inet_iif(), which is wrong. Actually you will not even reach that
point, since your code will exit after skb->dev check.

Try simple inet_lookup(&tcp_hashinfo, src, p_src, dst, p_dst, 0).
It does work.

-- 
	Evgeniy Polyakov
