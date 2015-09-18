From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/1] macvtap: Fix regression for macvtap ioctls
Date: Fri, 18 Sep 2015 13:39:19 +0300
Message-ID: <20150918132119-mutt-send-email-mst@redhat.com>
References: <1442562884-27310-1-git-send-email-borntraeger@de.ibm.com>
 <1442562884-27310-2-git-send-email-borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@vger.kernel.org, netdev@vger.kernel.org,
	Matthew Rosato <mjrosato@linux.vnet.ibm.com>,
	kvm@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1442562884-27310-2-git-send-email-borntraeger@de.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 18, 2015 at 09:54:44AM +0200, Christian Borntraeger wrote:
> To avoid overwriting the upper bits of the flags, commit
> 39ec7de7092b ("macvtap: fix uninitialized access on
> TUNSETIFF") changed the variable u from unsigned int to
> unsigned short and added some ORing logic for the flags.
> This introduced at least one regression:
> - TUNSETSNDBUF supports int as its size and also uses the now
>   short u as buffer - this breaks any sendbuf size > 64k
> 
> Let's change u back to unsigned int, keep the ORing and
> handle the overwrite issue with casts and masking.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: David S. Miller <davem@davemloft.net>
> Reported-by: Mark A. Peloquin
> Bisected-by: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Fixes: 39ec7de7092b ("macvtap: fix uninitialized access on TUNSETIFF")
> Cc: stable@vger.kernel.org
> ---
>  drivers/net/macvtap.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index edd7734..c33fe41 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -1060,7 +1060,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
>  	void __user *argp = (void __user *)arg;
>  	struct ifreq __user *ifr = argp;
>  	unsigned int __user *up = argp;
> -	unsigned short u;
> +	unsigned int u;
>  	int __user *sp = argp;
>  	struct sockaddr sa;
>  	int s;
> @@ -1076,7 +1076,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
>  		if ((u & ~MACVTAP_FEATURES) != (IFF_NO_PI | IFF_TAP))
>  			ret = -EINVAL;
>  		else
> -			q->flags = (q->flags & ~MACVTAP_FEATURES) | u;
> +			q->flags = (q->flags & ~MACVTAP_FEATURES) | (short) u;
>  
>  		return ret;
>  
> @@ -1089,9 +1089,8 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
>  		}
>  
>  		ret = 0;
> -		u = q->flags;
>  		if (copy_to_user(&ifr->ifr_name, vlan->dev->name, IFNAMSIZ) ||
> -		    put_user(u, &ifr->ifr_flags))
> +		    put_user((short) q->flags, &ifr->ifr_flags))
>  			ret = -EFAULT;
>  		macvtap_put_vlan(vlan);
>  		rtnl_unlock();

I agree it's a bug, but I don't think it's reasonable to
read 32 bit from the flags field.
I'll send a patch shortly.

> -- 
> 2.3.0
