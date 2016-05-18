From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PATCH net-next 1/4] scsi_tcp: block BH in TCP callbacks
Date: Wed, 18 May 2016 12:21:03 -0500
Message-ID: <573CA47F.10304@cs.wisc.edu>
References: <1463532249-20850-1-git-send-email-edumazet@google.com>
 <1463532249-20850-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Venkatesh Srinivas <venkateshs@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:34768 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752008AbcERSAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2016 14:00:00 -0400
In-Reply-To: <1463532249-20850-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/17/2016 07:44 PM, Eric Dumazet wrote:
> iscsi_sw_tcp_data_ready() and iscsi_sw_tcp_state_change() were
> using read_lock(&sk->sk_callback_lock) which is fine if caller
> disabled BH.
> 
> TCP stack no longer has this requirement and can run from
> process context.
> 
> Use read_lock_bh() variant to restore previous assumption.
> 
> Ideally this code could use RCU instead...
> 
> Fixes: 5413d1babe8f ("net: do not block BH while processing socket backlog")
> Fixes: d41a69f1d390 ("tcp: make tcp_sendmsg() aware of socket backlog")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Mike Christie <michaelc@cs.wisc.edu>
> Cc: Venkatesh Srinivas <venkateshs@google.com>
> ---
>  drivers/scsi/iscsi_tcp.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
> index 2e4c82f8329c..ace4f1f41b8e 100644
> --- a/drivers/scsi/iscsi_tcp.c
> +++ b/drivers/scsi/iscsi_tcp.c
> @@ -131,10 +131,10 @@ static void iscsi_sw_tcp_data_ready(struct sock *sk)
>  	struct iscsi_tcp_conn *tcp_conn;
>  	read_descriptor_t rd_desc;
>  
> -	read_lock(&sk->sk_callback_lock);
> +	read_lock_bh(&sk->sk_callback_lock);
>  	conn = sk->sk_user_data;
>  	if (!conn) {
> -		read_unlock(&sk->sk_callback_lock);
> +		read_unlock_bh(&sk->sk_callback_lock);
>  		return;
>  	}
>  	tcp_conn = conn->dd_data;
> @@ -154,7 +154,7 @@ static void iscsi_sw_tcp_data_ready(struct sock *sk)
>  	/* If we had to (atomically) map a highmem page,
>  	 * unmap it now. */
>  	iscsi_tcp_segment_unmap(&tcp_conn->in.segment);
> -	read_unlock(&sk->sk_callback_lock);
> +	read_unlock_bh(&sk->sk_callback_lock);
>  }
>  
>  static void iscsi_sw_tcp_state_change(struct sock *sk)
> @@ -165,10 +165,10 @@ static void iscsi_sw_tcp_state_change(struct sock *sk)
>  	struct iscsi_session *session;
>  	void (*old_state_change)(struct sock *);
>  
> -	read_lock(&sk->sk_callback_lock);
> +	read_lock_bh(&sk->sk_callback_lock);
>  	conn = sk->sk_user_data;
>  	if (!conn) {
> -		read_unlock(&sk->sk_callback_lock);
> +		read_unlock_bh(&sk->sk_callback_lock);
>  		return;
>  	}
>  	session = conn->session;
> @@ -179,7 +179,7 @@ static void iscsi_sw_tcp_state_change(struct sock *sk)
>  	tcp_sw_conn = tcp_conn->dd_data;
>  	old_state_change = tcp_sw_conn->old_state_change;
>  
> -	read_unlock(&sk->sk_callback_lock);
> +	read_unlock_bh(&sk->sk_callback_lock);
>  
>  	old_state_change(sk);
>  }

Can I just confirm that nested bh lock calls like:

spin_lock_bh(lock1);
spin_lock_bh(lock2);

do something

spin_unlock_bh(lock2);
spin_unlock_bh(lock1);

is ok? It seems smatch sometimes warns about this.

I found this thread

https://lkml.org/lkml/2011/1/25/232

which says it is ok.
