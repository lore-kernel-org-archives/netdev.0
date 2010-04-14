From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6] fasync: RCU locking
Date: Wed, 14 Apr 2010 16:36:13 +0800
Message-ID: <4BC57E7D.9060706@cn.fujitsu.com>
References: <1271230961.16881.630.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55955 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753134Ab0DNIgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Apr 2010 04:36:45 -0400
In-Reply-To: <1271230961.16881.630.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> -void __kill_fasync(struct fasync_struct *fa, int sig, int band)
> +/*
> + * rcu_read_lock() is held
> + */
> +static void kill_fasync_rcu(struct fasync_struct *fa, int sig, int band)
>  {
>  	while (fa) {
>  		struct fown_struct * fown;
> @@ -719,22 +728,19 @@ void __kill_fasync(struct fasync_struct *fa, int sig, int band)
>  		   mechanism. */
>  		if (!(sig == SIGURG && fown->signum == 0))
>  			send_sigio(fown, fa->fa_fd, band);
> -		fa = fa->fa_next;
> +		fa = rcu_dereference(fa->fa_next);
>  	}
>  }
>  

Since rcu_read_lock() protects fasync_struct *fa for us, we can access
to @fa safely even fasync_remove_entry() is just called.

But this patch does not ensure 'fa->fa_file is not freed' nor
'fa->fa_fd is not released', so kill_fasync_rcu() may do wrong thing
if there is no other code ensure it.
