From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: net/unix: sk_socket can disappear when state is unlocked
Date: Fri, 22 May 2015 11:50:30 +0200
Message-ID: <1432288230.3364.23.camel@redhat.com>
References: <1432225541-28498-1-git-send-email-salyzyn@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	David Howells <dhowells@redhat.com>,
	Ying Xue <ying.xue@windriver.com>,
	Christoph Hellwig <hch@lst.de>, netdev@vger.kernel.org
To: Mark Salyzyn <salyzyn@android.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432225541-28498-1-git-send-email-salyzyn@android.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Do, 2015-05-21 at 09:25 -0700, Mark Salyzyn wrote:
> got a rare NULL pointer dereference in clear_bit
> 
> Signed-off-by: Mark Salyzyn <salyzyn@android.com>
> ---
>  net/unix/af_unix.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 5266ea7..37a8925 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1880,6 +1880,11 @@ static long unix_stream_data_wait(struct sock *sk, long timeo,
>  		unix_state_unlock(sk);
>  		timeo = freezable_schedule_timeout(timeo);
>  		unix_state_lock(sk);
> +
> +		/* sk_socket may have been killed while unlocked */
> +		if (!sk->sk_socket)
> +			break;
> +
>  		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
>  	}
>  

Canonical way is to test for sock_flag(sk, SOCK_DEAD). Also it does not
seem like we are returning an error to user space but are still looping
to try to dequeue skbs from sk_receive_queue, which is concurrently
emptied by unix_release (maybe, without holding unix_state_lock).

Bye,
Hannes
