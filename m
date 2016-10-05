From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH] netdevice: add netdev_pub helper function
Date: Wed, 5 Oct 2016 02:52:23 +0200
Message-ID: <CAHmME9rYOYUy94ETHro7NFy9Q09PQuXDGcgsdAi577wquobZAg@mail.gmail.com>
References: <1434115829-22804-1-git-send-email-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "David S. Miller" <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434115829-22804-1-git-send-email-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey David,

The use of this function is going from the private member to the
public netdev struct. The usage is desired from the following coding
pattern.

You're implementing a netdevice. You've got ndo_init, ndo_uninit,
ndo_open, ndo_stop, ndo_start_xmit, and maybe even ndo_do_ioctl. All
of these functions basically follow the flow: get some information out
of struct netdev, then call netdev_priv(), and pass that specific
pointer onto the rest of the driver. The rest of the driver, 99% of
the time, only deals with your private member. Very very occasionally
it might want to check into how some piece of public data is doing.
For example, is the interface up? In this case, it's very convenient
to have the netdev_pub function, as in this patch.

    if (netdev_pub(priv)->flags & IFF_UP) {
        ...
    }

Then, after shortly using the public members, the driver gets on its
way dealing again exclusively with the private part.

I posted this patch a year ago, and let it languish after your initial
comment, because I wasn't confident that this was necessarily
something everybody could benefit from. 18 months later, after reading
quite a few netdevice-based drivers, it seems like this is indeed a
very useful code pattern, that makes things a bit more clear, a bit
less verbose, and helps maintain type safety throughout a driver.

So, I resubmit this to you for inclusion.

Regards,
Jason


On Fri, Jun 12, 2015 at 3:30 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> Being able to utilize this makes much code a lot simpler and cleaner.
> It's a nice convenience function.
>
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> ---
>  include/linux/netdevice.h | 11 +++++++++++
>  1 file changed, 11 insertions(+)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 05b9a69..f85be18 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1871,6 +1871,17 @@ static inline void *netdev_priv(const struct net_device *dev)
>         return (char *)dev + ALIGN(sizeof(struct net_device), NETDEV_ALIGN);
>  }
>
> +/**
> + *     netdev_pub - access network device from private pointer
> + *     @priv: private data pointer of network device
> + *
> + * Get network device from a network device private data pointer
> + */
> +static inline struct net_device *netdev_pub(void *priv)
> +{
> +       return (struct net_device *)((char *)priv - ALIGN(sizeof(struct net_device), NETDEV_ALIGN));
> +}
> +
>  /* Set the sysfs physical device reference for the network logical device
>   * if set prior to registration will cause a symlink during initialization.
>   */
> --
> 2.4.2
>
