From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] tun: make sure interface usage can not overflow
Date: Mon, 29 Sep 2014 14:48:49 +0300
Message-ID: <20140929114849.GA913@redhat.com>
References: <20140928232753.GA31180@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	Tom Herbert <therbert@google.com>,
	Masatake YAMATO <yamato@redhat.com>, Xi Wang <xii@google.com>,
	stephen hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140928232753.GA31180@www.outflux.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 28, 2014 at 04:27:53PM -0700, Kees Cook wrote:
> This makes the size argument a const, since it is always populated by
> the caller. Additionally double-checks to make sure the copy_from_user
> can never overflow, keeping CONFIG_DEBUG_STRICT_USER_COPY_CHECKS happy:
> 
>    In function 'copy_from_user',
>        inlined from '__tun_chr_ioctl' at drivers/net/tun.c:1871:7:
>        ... copy_from_user() buffer size is not provably correct
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>

What exactly is the issue here?
__tun_chr_ioctl is called with sizeof(struct compat_ifreq)
or  sizeof (struct ifreq) as the last argument.

So this looks like a false positive, but
CONFIG_DEBUG_STRICT_USER_COPY_CHECKS machinery is supposed
to avoid false positives.

On which architecture is this?


> ---
>  drivers/net/tun.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index acaaf6784179..a1f317cba206 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1855,7 +1855,7 @@ unlock:
>  }
>  
>  static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
> -			    unsigned long arg, int ifreq_len)
> +			    unsigned long arg, const size_t ifreq_len)
>  {
>  	struct tun_file *tfile = file->private_data;
>  	struct tun_struct *tun;
> @@ -1869,6 +1869,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>  	int ret;
>  
>  	if (cmd == TUNSETIFF || cmd == TUNSETQUEUE || _IOC_TYPE(cmd) == 0x89) {
> +		BUG_ON(ifreq_len > sizeof(ifr));
>  		if (copy_from_user(&ifr, argp, ifreq_len))
>  			return -EFAULT;
>  	} else {
> -- 
> 1.9.1
> 
> 
> -- 
> Kees Cook
> Chrome OS Security
