From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]: New SO_BINDTODEVICE fix.
Date: Tue, 18 Sep 2007 10:13:16 -0700
Message-ID: <46F0072C.1080507@candelatech.com>
References: <20070914.164243.41634621.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:34893 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760586AbXIRRSY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 13:18:24 -0400
In-Reply-To: <20070914.164243.41634621.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Ok, I changed my mind and decided to retain the optlen==0
> intended behavior.  It fell out of fixing the small
> string length case.
> 
> This is likely what I'll push to Linus and later -stable
> as a fix for this stuff.

I manually patched this into 2.6.20 and ran some tests.

My test program is here:
http://www.candelatech.com/oss/bind_test.c

First, I could not detect any packets routed in-correctly with the
old code that did not release the route.  I'm not sure if my
test is bogus or if the old code somehow managed to trigger
a new route lookup anyway.

On failure, I expected the first un-bind to not actually work
and that I would continue to see the second set of 5 packets on
the previously bound interface.  I did not see these packets, so
the un-bind worked.

I did test that the new code works with passing "" and 0 length
argument to the un-bind.  As far as I can tell, it now matches
the man page and all is well.

Since I could not reproduce a functional error, and you can work around
the man-page mismatch by passing a 4+ byte string of /0 to un-bind, this
may not be required for stable, but it should not hurt.

Thanks,
Ben

> 
> Thanks.
> 
> commit 4878809f711981a602cc562eb47994fc81ea0155
> Author: David S. Miller <davem@sunset.davemloft.net>
> Date:   Fri Sep 14 16:41:03 2007 -0700
> 
>     [NET]: Fix two issues wrt. SO_BINDTODEVICE.
>     
>     1) Comments suggest that setting optlen to zero will unbind
>        the socket from whatever device it might be attached to.  This
>        hasn't been the case since at least 2.2.x because the first thing
>        this function does is return -EINVAL if 'optlen' is less than
>        sizeof(int).
>     
>        This check also means that passing in a two byte string doesn't
>        work so well.  It's almost as if this code was testing with "eth?"
>        patterned strings and nothing else :-)
>     
>        Fix this by breaking the logic of this facility out into a
>        seperate function which validates optlen more appropriately.
>     
>        The optlen==0 and small string cases now work properly.
>     
>     2) We should reset the cached route of the socket after we have made
>        the device binding changes, not before.
>     
>     Reported by Ben Greear.
>     
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index cfed7d4..190de61 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -362,6 +362,61 @@ struct dst_entry *sk_dst_check(struct sock *sk, u32 cookie)
>  }
>  EXPORT_SYMBOL(sk_dst_check);
>  
> +static int sock_bindtodevice(struct sock *sk, char __user *optval, int optlen)
> +{
> +	int ret = -ENOPROTOOPT;
> +#ifdef CONFIG_NETDEVICES
> +	char devname[IFNAMSIZ];
> +	int index;
> +
> +	/* Sorry... */
> +	ret = -EPERM;
> +	if (!capable(CAP_NET_RAW))
> +		goto out;
> +
> +	ret = -EINVAL;
> +	if (optlen < 0)
> +		goto out;
> +
> +	/* Bind this socket to a particular device like "eth0",
> +	 * as specified in the passed interface name. If the
> +	 * name is "" or the option length is zero the socket
> +	 * is not bound.
> +	 */
> +	if (optlen > IFNAMSIZ - 1)
> +		optlen = IFNAMSIZ - 1;
> +	memset(devname, 0, sizeof(devname));
> +
> +	ret = -EFAULT;
> +	if (copy_from_user(devname, optval, optlen))
> +		goto out;
> +
> +	if (devname[0] == '\0') {
> +		index = 0;
> +	} else {
> +		struct net_device *dev = dev_get_by_name(devname);
> +
> +		ret = -ENODEV;
> +		if (!dev)
> +			goto out;
> +
> +		index = dev->ifindex;
> +		dev_put(dev);
> +	}
> +
> +	lock_sock(sk);
> +	sk->sk_bound_dev_if = index;
> +	sk_dst_reset(sk);
> +	release_sock(sk);
> +
> +	ret = 0;
> +
> +out:
> +#endif
> +
> +	return ret;
> +}
> +
>  /*
>   *	This is meant for all protocols to use and covers goings on
>   *	at the socket level. Everything here is generic.
> @@ -390,6 +445,9 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
>  	}
>  #endif
>  
> +	if (optname == SO_BINDTODEVICE)
> +		return sock_bindtodevice(sk, optval, optlen);
> +
>  	if (optlen < sizeof(int))
>  		return -EINVAL;
>  
> @@ -578,54 +636,6 @@ set_rcvbuf:
>  		ret = sock_set_timeout(&sk->sk_sndtimeo, optval, optlen);
>  		break;
>  
> -#ifdef CONFIG_NETDEVICES
> -	case SO_BINDTODEVICE:
> -	{
> -		char devname[IFNAMSIZ];
> -
> -		/* Sorry... */
> -		if (!capable(CAP_NET_RAW)) {
> -			ret = -EPERM;
> -			break;
> -		}
> -
> -		/* Bind this socket to a particular device like "eth0",
> -		 * as specified in the passed interface name. If the
> -		 * name is "" or the option length is zero the socket
> -		 * is not bound.
> -		 */
> -
> -		if (!valbool) {
> -			sk->sk_bound_dev_if = 0;
> -		} else {
> -			if (optlen > IFNAMSIZ - 1)
> -				optlen = IFNAMSIZ - 1;
> -			memset(devname, 0, sizeof(devname));
> -			if (copy_from_user(devname, optval, optlen)) {
> -				ret = -EFAULT;
> -				break;
> -			}
> -
> -			/* Remove any cached route for this socket. */
> -			sk_dst_reset(sk);
> -
> -			if (devname[0] == '\0') {
> -				sk->sk_bound_dev_if = 0;
> -			} else {
> -				struct net_device *dev = dev_get_by_name(devname);
> -				if (!dev) {
> -					ret = -ENODEV;
> -					break;
> -				}
> -				sk->sk_bound_dev_if = dev->ifindex;
> -				dev_put(dev);
> -			}
> -		}
> -		break;
> -	}
> -#endif
> -
> -
>  	case SO_ATTACH_FILTER:
>  		ret = -EINVAL;
>  		if (optlen == sizeof(struct sock_fprog)) {
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

