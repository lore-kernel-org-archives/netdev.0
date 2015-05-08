From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH 5/5] geneve: add initial netdev driver for GENEVE tunnels
Date: Fri, 8 May 2015 13:55:15 -0700
Message-ID: <CAHA+R7MqO2te-OR7mZqdy=TDkrcgyGhb-A4DvbQ07JAaKu49-Q@mail.gmail.com>
References: <1431105657-25492-1-git-send-email-linville@tuxdriver.com>
	<1431105657-25492-6-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:34211 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbbEHUzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 16:55:17 -0400
Received: by wgic8 with SMTP id c8so56297819wgi.1
        for <netdev@vger.kernel.org>; Fri, 08 May 2015 13:55:16 -0700 (PDT)
In-Reply-To: <1431105657-25492-6-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 8, 2015 at 10:20 AM, John W. Linville
<linville@tuxdriver.com> wrote:
> +
> +/* Setup stats when device is created */
> +static int geneve_init(struct net_device *dev)
> +{
> +       struct geneve_dev *geneve = netdev_priv(dev);
> +
> +       dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
> +       if (!dev->tstats)
> +               return -ENOMEM;
> +
> +       /* make new socket outside of RTNL */
> +       dev_hold(dev);
> +       queue_work(geneve_wq, &geneve->sock_work);
> +


Any reason to create socket in this init() rather than in ndo_open()?


> +       return 0;
> +}
> +
> +static void geneve_uninit(struct net_device *dev)
> +{
> +       struct geneve_dev *geneve = netdev_priv(dev);
> +       struct geneve_sock *gs = geneve->sock;
> +
> +       if (gs)
> +               geneve_sock_release(gs);
> +       free_percpu(dev->tstats);
> +}


Ditto, ndo_stop().


> +
> +static int geneve_newlink(struct net *net, struct net_device *dev,
> +                        struct nlattr *tb[], struct nlattr *data[])
> +{
...
> +
> +       if (data[IFLA_GENEVE_REMOTE])
> +               geneve->remote.sin_addr.s_addr =
> +                       nla_get_be32(data[IFLA_GENEVE_REMOTE]);


nla_get_in_addr()
