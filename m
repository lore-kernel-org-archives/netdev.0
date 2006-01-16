From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: 32 bit (socket layer) ioctl emulation for 64 bit kernels
Date: Mon, 16 Jan 2006 15:41:06 +0900 (JST)
Message-ID: <20060116.154106.64415709.yoshfuji@linux-ipv6.org>
References: <1137122079.5589.34.camel@spereira05.tusc.com.au>
	<200601131146.48128.arnd@arndb.de>
	<1137391160.5588.32.camel@spereira05.tusc.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, acme@ghostprotocols.net, ak@muc.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pereira.shaun@gmail.com, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751062AbWAPGkT@vger.kernel.org>
To: spereira@tusc.com.au
In-Reply-To: <1137391160.5588.32.camel@spereira05.tusc.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <1137391160.5588.32.camel@spereira05.tusc.com.au> (at Mon, 16 Jan 2006 16:59:20 +1100), Shaun Pereira <spereira@tusc.com.au> says:

> If I understand correctly from your comments (thanks for that, they are
> helpful)
> copy_to_user acts like a memcopy for an 'array' of bytes and should not
> be used to copy the timeval struct to userspace. 
> Rather put_user / __put_user macros should be used which allows transfer
> of single element values of the structure. 

> +int compat_sock_get_timestamp(struct sock *sk, struct timeval __user
> *userstamp)
> +{
> +	struct compat_timeval __user *ctv
> +		= (struct compat_timeval __user*) userstamp;
> +	int err = -ENOENT;
> +	if(!sock_flag(sk, SOCK_TIMESTAMP))
> +		sock_enable_timestamp(sk);
> +	if(sk->sk_stamp.tv_sec == -1)
> +		return err;
> +	if(sk->sk_stamp.tv_sec == 0)
> +		do_gettimeofday(&sk->sk_stamp);
> +	err = -EFAULT;
> +	if(access_ok(VERIFTY_WRITE, ctv, sizeof(*ctv))) {
> +		err = __put_user(sk->sk_stamp.tv_sec, &ctv->tv_sec);
> +		err != __put_user(sk->sk_stamp.tv_usec, &ctv->tv_usec);
> +	}
> +	return err;
> +}
> +

Hmm, you will copy 32bit of MSB in big-endian.
You should do something like this:

        strtuct compat_timeval tvtmp;
        :
	tvtmp.tv_sec = sk->sk_stamp.tv_sec;
	tvtmp.tv_usec = sk->sk_stemp.tv_usec;
	return copy_to_user(ctv, &tvtmp, sizeof(tvtmp));

Or, am I miss something?

--yoshfuji
