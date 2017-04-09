From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next RFC] Generic XDP
Date: Sun, 09 Apr 2017 08:25:18 +0200
Message-ID: <1491719118.4309.1.camel@sipsolutions.net>
References: <20170408.200721.109499285021338999.davem@davemloft.net>
         (sfid-20170409_050731_027484_B256A547)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:48150 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751211AbdDIGZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 9 Apr 2017 02:25:28 -0400
In-Reply-To: <20170408.200721.109499285021338999.davem@davemloft.net> (sfid-20170409_050731_027484_B256A547)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-04-08 at 20:07 -0700, David Miller wrote:

> +static int generic_xdp_install(struct net_device *dev, struct
> netdev_xdp *xdp)
> +{
> +       struct bpf_prog *new = xdp->prog;
> +       int ret = 0;
> +
> +       switch (xdp->command) {
> +       case XDP_SETUP_PROG: {
> +               struct bpf_prog *old;
> +
> +               old = xchg(&dev->xdp_prog, new);
> +               if (old)
> +                       bpf_prog_put(old);

I don't really see why you need the xchg() here - just fetching the old
program and setting the new one should be sufficient since you're under
RTNL here.
That would also let you use rcu_assign_pointer() which seems like the
right thing to do here, along with marking the xdp_prog pointer as
__rcu? That'd also let you use rcu_dereference() instead of READ_ONCE()
which seems like the better annotation?

johannes
