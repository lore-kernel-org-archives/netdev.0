From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH 2.5.70+] tun using alloc_netdev
Date: Wed, 11 Jun 2003 12:21:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20030611121155.0b659e20@unixmail.qualcomm.com>
References: <20030609115857.38bb31d6.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>,
   "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030609115857.38bb31d6.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 11:58 AM 6/9/2003, Stephen Hemminger wrote:


>-               if ((err = dev_alloc_name(&tun->dev, name)) < 0)
>-                       goto failed;
>-               if ((err = register_netdevice(&tun->dev)))
>+               dev = alloc_netdev(sizeof(struct tun_struct), name,
>+                                  tun_setup);
>+               if (!dev)
>+                       return -ENOMEM;
>+
>+               tun = dev->priv;
>+               tun->flags = flags;
>+
>+               if ((err = register_netdevice(tun->dev))) {
>+                       kfree(dev);
>                        goto failed;
>+               }


This is wrong. register_netdevice() does not expand name (ie %d stuff).
So dev_alloc_name() is still needed. i.e.

                dev = alloc_netdev(sizeof(struct tun_struct), name, tun_setup);
                if (!dev)
                        return -ENOMEM;

                err = dev_alloc_name(dev, name);
                if (err < 0) {
                        kfree(dev);
                        return err;
                }

Max
