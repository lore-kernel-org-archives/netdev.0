From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] macvtap: fix recovery from gup errors
Date: Mon, 24 Jun 2013 11:23:15 +0800
Message-ID: <51C7BBA3.1050300@redhat.com>
References: <20130623142658.GA21141@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Brad Hubbard <bhubbard@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130623142658.GA21141@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/23/2013 10:26 PM, Michael S. Tsirkin wrote:
> get user pages might fail partially in macvtap zero copy
> mode. To recover we need to put all pages that we got,
> but code used a wrong index resulting in double-free
> errors.
>
> Reported-by: Brad Hubbard <bhubbard@redhat.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>
> Same as the tun patch really. Also stable material.

Acked-by: Jason Wang <jasowang@redhat.com>
>
>  drivers/net/macvtap.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 59e9605..4ddd108 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -524,8 +524,9 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
>  			return -EMSGSIZE;
>  		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
>  		if (num_pages != size) {
> -			for (i = 0; i < num_pages; i++)
> -				put_page(page[i]);
> +			int j;
> +			for (j = 0; j < num_pages; j++)
> +				put_page(page[i + j]);
>  			return -EFAULT;
>  		}
>  		truesize = size * PAGE_SIZE;
