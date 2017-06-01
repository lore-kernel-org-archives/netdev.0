From: Yury Norov <ynorov@caviumnetworks.com>
Subject: Re: [PATCH v3] net: don't call strlen on non-terminated string in
 dev_set_alias()
Date: Thu, 1 Jun 2017 16:47:37 +0300
Message-ID: <20170601134737.7dp2pbnek26b6kqf@yury-thinkpad>
References: <20170601123829.51794-1-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        davem@davemloft.net, stephen@networkplumber.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexander Potapenko <glider@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170601123829.51794-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 01, 2017 at 02:38:29PM +0200, Alexander Potapenko wrote:
> KMSAN reported a use of uninitialized memory in dev_set_alias(),
> which was caused by calling strlcpy() (which in turn called strlen())
> on the user-supplied non-terminated string.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
> v3: removed the multi-line comment
> v2: fixed an off-by-one error spotted by Dmitry Vyukov
 
[...]

> ---
>  net/core/dev.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index fca407b4a6ea..3e3b29133cc9 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1254,7 +1254,9 @@ int dev_set_alias(struct net_device *dev, const char *alias, size_t len)
>  		return -ENOMEM;
>  	dev->ifalias = new_ifalias;
>  
> -	strlcpy(dev->ifalias, alias, len+1);
> +	/* alias comes from the userspace and may not be zero-terminated. */

So if the comment is correct, you'd use copy_from_user() instead.

> +	memcpy(dev->ifalias, alias, len);
> +	dev->ifalias[len] = 0;
>  	return len;
>  }
>  
> -- 
> 2.13.0.219.gdb65acc882-goog
