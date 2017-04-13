From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Wed, 12 Apr 2017 23:48:22 -0700
Message-ID: <CACKFLikqDDLDSywxTNJoktpO0ViggH=Lbzebw27RaUPSGp0knQ@mail.gmail.com>
References: <20170412.145415.1441440342830198148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:36426 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750811AbdDMGsZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 02:48:25 -0400
Received: by mail-lf0-f52.google.com with SMTP id s141so24866313lfe.3
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 23:48:24 -0700 (PDT)
In-Reply-To: <20170412.145415.1441440342830198148.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 12, 2017 at 11:54 AM, David Miller <davem@davemloft.net> wrote:
>
> +static struct static_key generic_xdp_needed __read_mostly;
> +
> +static int generic_xdp_install(struct net_device *dev, struct netdev_xdp *xdp)
> +{
> +       struct bpf_prog *new = xdp->prog;
> +       int ret = 0;
> +
> +       switch (xdp->command) {
> +       case XDP_SETUP_PROG: {
> +               struct bpf_prog *old = rtnl_dereference(dev->xdp_prog);
> +
> +               rcu_assign_pointer(dev->xdp_prog, new);
> +               if (old)
> +                       bpf_prog_put(old);
> +
> +               if (old && !new)
> +                       static_key_slow_dec(&generic_xdp_needed);
> +               else if (new && !old)
> +                       static_key_slow_inc(&generic_xdp_needed);

I think we need to call dev_disable_lro(dev) to disable LRO also when
a BPF program is installed.

> +               break;
> +       }
> +
> +       case XDP_QUERY_PROG:
> +               xdp->prog_attached = !!rcu_access_pointer(dev->xdp_prog);
> +               break;
> +
> +       default:
> +               ret = -EINVAL;
> +               break;
> +       }
> +
> +       return ret;
> +}
> +
