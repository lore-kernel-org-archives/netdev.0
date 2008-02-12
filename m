From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2][AX25] af_ax25: remove sock lock in ax25_info_show()
Date: Mon, 11 Feb 2008 21:25:50 -0800 (PST)
Message-ID: <20080211.212550.45678043.davem@davemloft.net>
References: <20071218135202.GA2023@ff.dom.local>
	<47ADF4A2.6070705@free.fr>
	<20080210131051.GA7750@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f6bvp@free.fr, ralf@linux-mips.org, jann@gmx.de,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44838
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752077AbYBLFZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 00:25:19 -0500
In-Reply-To: <20080210131051.GA7750@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 10 Feb 2008 14:10:51 +0100

> [AX25] af_ax25: remove sock lock in ax25_info_show()
>  
> This lockdep warning:
> 
> > =======================================================
> > [ INFO: possible circular locking dependency detected ]
> > 2.6.24 #3
> > -------------------------------------------------------
> > swapper/0 is trying to acquire lock:
> >  (ax25_list_lock){-+..}, at: [<f91dd3b1>] ax25_destroy_socket+0x171/0x1f0 [ax25]
> > 
> > but task is already holding lock:
> >  (slock-AF_AX25){-+..}, at: [<f91dbabc>] ax25_std_heartbeat_expiry+0x1c/0xe0 [ax25]
> > 
> > which lock already depends on the new lock.
> ...
> 
> shows that ax25_list_lock and slock-AF_AX25 are taken in different
> order: ax25_info_show() takes slock (bh_lock_sock(ax25->sk)) while
> ax25_list_lock is held, so reversely to other functions. To fix this
> the sock lock should be moved to ax25_info_start(), and there would
> be still problem with breaking ax25_list_lock (it seems this "proper"
> order isn't optimal yet). But, since it's only for reading proc info
> it seems this is not necessary (e.g.  ax25_send_to_raw() does similar
> reading without this lock too).
> 
> So, this patch removes sock lock to avoid deadlock possibility; there
> is also used sock_i_ino() function, which reads sk_socket under proper
> read lock. Additionally printf format of this i_ino is changed to %lu.
> 
> Reported-by: Bernard Pidoux F6BVP <f6bvp@free.fr>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks Jarek.

> +			   sock_i_ino(ax25->sk));

Note that this taks the sk callback lock, it should be OK but
let's keep a watch out for any new lockdep warnings this
ends up causing :-)
