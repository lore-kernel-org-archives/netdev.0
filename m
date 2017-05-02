From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net v3] driver: veth: Fix one possbile memleak when fail
 to register_netdevice
Date: Tue, 2 May 2017 15:55:36 +0800
Message-ID: <CADvbK_cEHXTSXx5Qa17TfeUXnYiBq8ptR+=5e-fbzPF0r4DNhQ@mail.gmail.com>
References: <1493437911-27167-1-git-send-email-gfree.wind@foxmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem <davem@davemloft.net>, jarod@redhat.com,
        Stephen Hemminger <stephen@networkplumber.org>,
        dsa@cumulusnetworks.com, network dev <netdev@vger.kernel.org>
To: gfree.wind@foxmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:32846 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750886AbdEBHzi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 03:55:38 -0400
Received: by mail-qt0-f194.google.com with SMTP id c45so19207585qtb.0
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 00:55:37 -0700 (PDT)
In-Reply-To: <1493437911-27167-1-git-send-email-gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 29, 2017 at 11:51 AM,  <gfree.wind@foxmail.com> wrote:
> From: Gao Feng <gfree.wind@foxmail.com>
>
> The veth driver allocates some resources in its ndo_init func, and
> free them in its destructor func. Then there is one memleak that some
> errors happen after register_netdevice invokes the ndo_init callback.
> Because the destructor would not be invoked to free the resources.
>
> Now create one new func veth_destructor_free to free the mem in the
> destructor, and add ndo_uninit func also invokes it when fail to register
> the veth device.
>
> It's not only free all resources, but also follow the original desgin
> that the resources are freed in the destructor normally after
> register the device successfully.
>
> Signed-off-by: Gao Feng <gfree.wind@foxmail.com>
> ---
>  v3: Split one patch to multiple commits, per David Ahern
>  v2: Move the free in ndo_uninit when fail to register, per Herbert Xu
>  v1: initial version
>
>  drivers/net/veth.c | 15 ++++++++++++++-
>  1 file changed, 14 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index 8c39d6d..418376a 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -224,9 +224,21 @@ static int veth_dev_init(struct net_device *dev)
>         return 0;
>  }
>
> -static void veth_dev_free(struct net_device *dev)
> +static void veth_destructor_free(struct net_device *dev)
>  {
>         free_percpu(dev->vstats);
> +}
not sure why you needed to add this function.
to use free_percpu() directly may be clearer.

> +
> +static void veth_dev_uninit(struct net_device *dev)
> +{
call free_percpu() here, no need to check dev->reg_state.
free_percpu will just return if dev->vstats is NULL.

> +       /* dev is not registered, perform the free instead of destructor */
> +       if (dev->reg_state == NETREG_UNINITIALIZED)
> +               veth_destructor_free(dev);
> +}
> +
> +static void veth_dev_free(struct net_device *dev)
> +{
> +       veth_destructor_free(dev);
use free_percpu here as well.

>         free_netdev(dev);
>  }
>
> @@ -284,6 +296,7 @@ static void veth_set_rx_headroom(struct net_device *dev, int new_hr)
>
>  static const struct net_device_ops veth_netdev_ops = {
>         .ndo_init            = veth_dev_init,
> +       .ndo_uninit          = veth_dev_uninit,
>         .ndo_open            = veth_open,
>         .ndo_stop            = veth_close,
>         .ndo_start_xmit      = veth_xmit,
> --
> 2.7.4
>
