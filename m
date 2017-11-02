From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next V2 2/3] tun: introduce ioctls to set and get
 steering policies
Date: Thu, 2 Nov 2017 10:15:28 +0900
Message-ID: <CAF=yD-++5q7f5Cvao4j5GPj8koEQ-RA0_OkuxsOWf0xwJaRx9Q@mail.gmail.com>
References: <1509445938-4345-1-git-send-email-jasowang@redhat.com> <1509445938-4345-3-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Tom Herbert <tom@herbertland.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1509445938-4345-3-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 31, 2017 at 7:32 PM, Jason Wang <jasowang@redhat.com> wrote:
> This patch introduces new ioctl for change packet steering policy for
> tun. Only automatic flow steering is supported, more policies will
> come.
>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/tun.c           | 35 ++++++++++++++++++++++++++++++++++-
>  include/uapi/linux/if_tun.h |  7 +++++++
>  2 files changed, 41 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index bff6259..ab109ff 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -122,7 +122,8 @@ do {                                                                \
>  #define TUN_VNET_BE     0x40000000
>
>  #define TUN_FEATURES (IFF_NO_PI | IFF_ONE_QUEUE | IFF_VNET_HDR | \
> -                     IFF_MULTI_QUEUE | IFF_NAPI | IFF_NAPI_FRAGS)
> +                     IFF_MULTI_QUEUE | IFF_NAPI | IFF_NAPI_FRAGS | \
> +                     IFF_MULTI_STEERING)
>
>  #define GOODCOPY_LEN 128
>
> @@ -2516,6 +2517,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>         unsigned int ifindex;
>         int le;
>         int ret;
> +       unsigned int steering;
>
>         if (cmd == TUNSETIFF || cmd == TUNSETQUEUE || _IOC_TYPE(cmd) == SOCK_IOC_TYPE) {
>                 if (copy_from_user(&ifr, argp, ifreq_len))
> @@ -2774,6 +2776,37 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>                 ret = 0;
>                 break;
>
> +       case TUNSETSTEERING:
> +               ret = -EFAULT;
> +               if (copy_from_user(&steering, argp, sizeof(steering)))
> +                       break;
> +               ret = 0;
> +               switch (steering) {
> +               case TUN_STEERING_AUTOMQ:
> +                       tun->steering_ops = &tun_automq_ops;
> +                       break;
> +               default:
> +                       ret = -EFAULT;
> +               }
> +               break;
> +
> +       case TUNGETSTEERING:
> +               ret = 0;
> +               if (tun->steering_ops == &tun_automq_ops)
> +                       steering = TUN_STEERING_AUTOMQ;
> +               else
> +                       BUG();
> +               if (copy_to_user(argp, &steering, sizeof(steering)))
> +                       ret = -EFAULT;
> +               break;
> +
> +       case TUNGETSTEERINGFEATURES:
> +               ret = 0;
> +               steering = TUN_STEERING_AUTOMQ;
> +               if (copy_to_user(argp, &steering, sizeof(steering)))
> +                       ret = -EFAULT;
> +               break;
> +


Similar to my comment in patch 1/3: if only eBPF is used, these
calls can be avoided in favor of only TUNSETSTEERINGEBPF
from patch 3/3.
