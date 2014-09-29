From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] tun: make sure interface usage can not overflow
Date: Mon, 29 Sep 2014 11:04:00 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1749FC70@AcuExch.aculab.com>
References: <20140928232753.GA31180@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Tom Herbert <therbert@google.com>,
	Masatake YAMATO <yamato@redhat.com>, Xi Wang <xii@google.com>,
	stephen hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Kees Cook' <keescook@chromium.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59698 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751695AbaI2LFq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 07:05:46 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 18780-02 for <netdev@vger.kernel.org>;
 Mon, 29 Sep 2014 12:05:44 +0100 (BST)
In-Reply-To: <20140928232753.GA31180@www.outflux.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees Cook
> This makes the size argument a const, since it is always populated by
> the caller.

There is almost no point making parameters 'const.
('const foo *' makes sense).

> Additionally double-checks to make sure the copy_from_user
> can never overflow, keeping CONFIG_DEBUG_STRICT_USER_COPY_CHECKS happy:
> 
>    In function 'copy_from_user',
>        inlined from '__tun_chr_ioctl' at drivers/net/tun.c:1871:7:
>        ... copy_from_user() buffer size is not provably correct

If 'ifreq_len' could be too big then you want to error the ioctl, not panic.
If it can't be too big you don't need the check.

	David

> Signed-off-by: Kees Cook <keescook@chromium.org>
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
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
