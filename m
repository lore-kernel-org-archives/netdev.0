From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv6: double free in ipip6_dev_free
Date: Wed, 8 Feb 2017 09:11:11 -0800
Message-ID: <CAM_iQpXpRc9qVQQ2SkULTzvfNEeQHG-CVbS6SCvB=cj+EFVhWg@mail.gmail.com>
References: <CACT4Y+Yu2mdo7w13nskZCnNwfcOaPY_SS5KDoLciGRg0E=u57A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+Yu2mdo7w13nskZCnNwfcOaPY_SS5KDoLciGRg0E=u57A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 8, 2017 at 5:56 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> First dev->tstats was freed here:
>
> 1376 static int ipip6_tunnel_init(struct net_device *dev)
> 1377 {
> 1378         struct ip_tunnel *tunnel = netdev_priv(dev);
> 1379         int err;
> 1380
> 1381         tunnel->dev = dev;
> 1382         tunnel->net = dev_net(dev);
> 1383         strcpy(tunnel->parms.name, dev->name);
> 1384
> 1385         ipip6_tunnel_bind_dev(dev);
> 1386         dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
> 1387         if (!dev->tstats)
> 1388                 return -ENOMEM;
> 1389
> 1390         err = dst_cache_init(&tunnel->dst_cache, GFP_KERNEL);
> 1391         if (err) {
> 1392                 free_percpu(dev->tstats);
> 1393                 return err;
> 1394         }
> 1395
> 1396         return 0;
> 1397 }
>
> And then again here:
>
> 1342 static void ipip6_dev_free(struct net_device *dev)
> 1343 {
> 1344         struct ip_tunnel *tunnel = netdev_priv(dev);
> 1345
> 1346         dst_cache_destroy(&tunnel->dst_cache);
> 1347         free_percpu(dev->tstats);
> 1348         free_netdev(dev);
> 1349 }

Probably we need to NULL dev->tstats in the ndo_init(),
and ipip6 tunnel seems not the only one missing it.
