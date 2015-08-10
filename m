From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: [FWD] PROBLEM: there exists a wrong return value of function mkiss_open()
Date: Mon, 10 Aug 2015 09:42:03 -0700
Message-ID: <CA+55aFy1af43uxH1r=_CxTCgPNN802YA+H26Vbbkb=rknqZuXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:35608 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754273AbbHJQmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 12:42:04 -0400
Received: by igbjg10 with SMTP id jg10so4610030igb.0
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 09:42:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't know how many people care about hamradio, but the report that
mkiss_open() returns success even when register_netdev() fails seems
entirely true. The email was just not sent to the right people..

                   Linus

On Sun, Aug 9, 2015 at 5:08 PM, RUC_Soft_Sec <zy900702@163.com> wrote:
> Summary:
>     there exists a wrong return value of function mkiss_open(). It's a
> theoretical problem. we use static analysis method to detect this bug.
> Bug Description:
>
> In function mkiss_open() at drivers/net/hamradio/mkiss.c:726, the call to
> register_netdev() in line 765 may return a negative error code, and thus
> function mkiss_open() will return the value of variable err. And, the
> function mkiss_open() will return 0 at last when it runs well. However, when
> the call to register_netdev() in line 765 return a negative error code, the
> value of err is 0. So the function mkiss_open() will return 0 to its caller
> functions when it runs error because of the failing call to
> register_netdev(), leading to a wrong return value of function mkiss_open().
> The related code snippets in mkiss_open() is as following.
> mkiss_open @@ drivers/net/hamradio/mkiss.c:726
>  726static int mkiss_open(struct tty_struct *tty)
>  727{
>             ...
>  761        if ((err = ax_open(ax->dev))) {
>  762                goto out_free_netdev;
>  763        }
>  764
>  765        if (register_netdev(dev))
>  766                goto out_free_buffers;
>             ...
>  800out_free_buffers:
>  801        kfree(ax->rbuff);
>  802        kfree(ax->xbuff);
>  803
>  804out_free_netdev:
>  805        free_netdev(dev);
>  806
>  807out:
>  808        return err;
>  809}
>
> Generally, when the call to register_netdev() fails, the return value of
> caller functions should be different from another return value set when the
> call to register_netdev() succeeds, like the following codes in another
> file.
> com90io_found @@ drivers/net/arcnet/com90io.c:234
>  234static int __init com90io_found(struct net_device *dev)
>  235{
>             ...
>  268        err = register_netdev(dev);
>  269        if (err) {
>  270                outb((inb(_CONFIG) & ~IOMAPflag), _CONFIG);
>  271                free_irq(dev->irq, dev);
>  272                release_region(dev->base_addr, ARCNET_TOTAL_SIZE);
>  273                return err;
>  274        }
>  275
>  276        BUGMSG(D_NORMAL, "COM90IO: station %02Xh found at %03lXh, IRQ
> %d.\n",
>  277               dev->dev_addr[0], dev->base_addr, dev->irq);
>  278
>  279        return 0;
>  280}
>
> Kernel version:
>     3.19.1
>
>
>
>
