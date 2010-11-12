From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/10] Fix leaking of kernel heap addresses in net/
Date: Thu, 11 Nov 2010 17:17:54 -0800
Message-ID: <20101111171754.0198e151@nehalam>
References: <1289524019.5167.66.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	James Morris <jmorris@namei.org>,
	Remi Denis-Courmont <remi.denis-courmont@nokia.com>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Tejun Heo <tj@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Li Zefan <lizf@cn.fujitsu.com>, Joe Perches <joe@perches.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Pavel Emelyanov <xemul@openvz.org>,
	socketcan-core@l
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52656 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757366Ab0KLBR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Nov 2010 20:17:58 -0500
In-Reply-To: <1289524019.5167.66.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Nov 2010 20:06:59 -0500
Dan Rosenberg <drosenberg@vsecurity.com> wrote:

> diff --git a/net/can/bcm.c b/net/can/bcm.c
> index 08ffe9e..5960ad7 100644
> --- a/net/can/bcm.c
> +++ b/net/can/bcm.c
> @@ -165,9 +165,16 @@ static int bcm_proc_show(struct seq_file *m, void *v)
>  	struct bcm_sock *bo = bcm_sk(sk);
>  	struct bcm_op *op;
>  
> -	seq_printf(m, ">>> socket %p", sk->sk_socket);
> -	seq_printf(m, " / sk %p", sk);
> -	seq_printf(m, " / bo %p", bo);
> +	/* Only expose kernel addresses to privileged readers */
> +	if (capable(CAP_NET_ADMIN))
> +		seq_printf(m, ">>> socket %p", sk->sk_socket);
> +		seq_printf(m, " / sk %p", sk);
> +		seq_printf(m, " / bo %p", bo);
> +	else
> +		seq_printf(m, ">>> socket %lu", sock_i_ino(sk));
> +		seq_printf(m, " / sk %d", 0);
> +		seq_printf(m, " / bo %d", 0);
> +

Printing different data based on security state seems like an ABI
nightmare.


-- 
