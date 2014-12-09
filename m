From: Timo Teras <timo.teras@iki.fi>
Subject: Re: Possible regression: "gre: Use inner mac length when computing
 tunnel length"
Date: Tue, 9 Dec 2014 08:26:45 +0200
Message-ID: <20141209082645.5cf70f55@vostro>
References: <20141204141616.185b88c4@vostro>
	<CA+mtBx-se+u4j8WHzZ+AXeiFN2uevrvcTb6xFpeNrhjOv=EVng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:48738 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339AbaLIG0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 01:26:55 -0500
Received: by mail-lb0-f177.google.com with SMTP id b6so4732812lbj.8
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2014 22:26:53 -0800 (PST)
In-Reply-To: <CA+mtBx-se+u4j8WHzZ+AXeiFN2uevrvcTb6xFpeNrhjOv=EVng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Dec 2014 08:00:19 -0800
Tom Herbert <therbert@google.com> wrote:

> A fix is pending for net. Please try if you can.

Finally got to testing this. Unfortunately, this does not seem to fix
the issue I am experiencing.

Any suggestions?

> 
> Tom
> 
> diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
> index bb5947b..51973dd 100644
> --- a/net/ipv4/gre_offload.c
> +++ b/net/ipv4/gre_offload.c
> @@ -247,6 +247,9 @@ static int gre_gro_complete(struct sk_buff *skb,
> int nhoff) err = ptype->callbacks.gro_complete(skb, nhoff + grehlen);
> 
>         rcu_read_unlock();
> +
> +       skb_set_inner_mac_header(skb, nhoff + grehlen);
> +
>         return err;
>  }
> 
> On Thu, Dec 4, 2014 at 4:16 AM, Timo Teras <timo.teras@iki.fi> wrote:
> > Hi,
> >
> > After upgrading to latest 3.14.24 or newer, I noticed a weird TSO
> > bug in the "dmvpn" setup I use. And seems 3.14.23 works just fine.
> > So the commit 14051f0452a2c26a "gre: Use inner mac length when
> > computing tunnel length" would appear to be the related commit (but
> > have not yet tested this).
> >
> > In practice what happens is that forwarding path between ethX (or
> > vlanX) and gre1 gets broken.
> >
> > There's probably two differences to the "regular" gre tunnel case:
> > - it's nbma mode, meaning the gre header is inserted via slightly
> >   different code path
> > - the gre1 packets are IPsec encrypted in transport mode
> >
> > As additional detail, doing "ethtool -K gre1 tso off" will
> > workaround the issue, so it is clearly tso issue pointing even
> > further to the commit in question.
> >
> > Is this something the suspected patch could cause? Any suggestions
> > what to test more?
> >
> > Thanks,
> > Timo
> >
