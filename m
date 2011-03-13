From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 3/3] vhost-net: use lock_sock_fast() in peek_head_len()
Date: Sun, 13 Mar 2011 17:06:47 +0200
Message-ID: <20110313150646.GA30494@redhat.com>
References: <20110117081058.18900.67456.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
 <20110117081117.18900.48672.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110117081117.18900.48672.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 17, 2011 at 04:11:17PM +0800, Jason Wang wrote:
> We can use lock_sock_fast() instead of lock_sock() in order to get
> speedup in peek_head_len().
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/vhost/net.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index c32a2e4..50b622a 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -211,12 +211,12 @@ static int peek_head_len(struct sock *sk)
>  {
>  	struct sk_buff *head;
>  	int len = 0;
> +	bool slow = lock_sock_fast(sk);
>  
> -	lock_sock(sk);
>  	head = skb_peek(&sk->sk_receive_queue);
>  	if (head)
>  		len = head->len;
> -	release_sock(sk);
> +	unlock_sock_fast(sk, slow);
>  	return len;
>  }
>  

Wanted to apply this, but looking at the code I think the lock_sock here
is wrong. What we really need is to handle the case where the skb is
pulled from the receive queue after skb_peek.  However this is not the
right lock to use for that, sk_receive_queue.lock is.
So I expect the following is the right way to handle this.
Comments?

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 0329c41..5720301 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -213,12 +213,13 @@ static int peek_head_len(struct sock *sk)
 {
 	struct sk_buff *head;
 	int len = 0;
+	unsigned long flags;
 
-	lock_sock(sk);
+	spin_lock_irqsave(&sk->sk_receive_queue.lock, flags);
 	head = skb_peek(&sk->sk_receive_queue);
-	if (head)
+	if (likely(head))
 		len = head->len;
-	release_sock(sk);
+	spin_unlock_irqrestore(&sk->sk_receive_queue.lock, flags);
 	return len;
 }
 
