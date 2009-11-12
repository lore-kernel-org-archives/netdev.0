From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [RACE] net: in process_backlog
Date: Fri, 13 Nov 2009 07:54:14 +0800
Message-ID: <412e6f7f0911121554n22a6f975h1fb5df59bd4b84a2@mail.gmail.com>
References: <412e6f7f0911120050w740377c7j2cdf24ef9fd2ca59@mail.gmail.com>
	 <20091112085739.1137f690@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:45612 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755624AbZKLXyI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 18:54:08 -0500
Received: by pzk1 with SMTP id 1so906713pzk.33
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 15:54:14 -0800 (PST)
In-Reply-To: <20091112085739.1137f690@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 12:57 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Thu, 12 Nov 2009 16:50:53 +0800
> Changli Gao <xiaosuo@gmail.com> wrote:
>
>
> There is are a couple of issues here, but it is not what you thought
> you saw.
>
> The receive process is always done in soft IRQ context. The backlog q=
ueue's
> are per-cpu. When a device is deleted an IPI is sent to all cpu's to
> scan there backlog queue. =C2=A0What should protect the skb is the fa=
ct that
> the network device destruction process waits for an RCU grace period.
> So skb->dev points to valid data.

Yea, if the process waits for a RCU grace period, there will be no
race. But think about another case:
1. flush_backlog().
2. dev_hold(skb->dev); netif_rx(). dev_put(skb->dev);
3. wait_for_refs();
4. free(dev);
5. netif_receive_skb(); //skb->dev doesn't present.
flush_backlog() can't prevent new skbs are added to backlog. If we
swap the flush_backlog() and wait_for_refs(), this case will be OK
too.

>
> BUT the flush_backlog is run too late in the device destruction proce=
ss.
> It should be moved out of netdev_run_todo, to right after dev_shutdow=
n().
> Also adding a check for skb->dev->reg_state in netif_receive_skb woul=
d
> be wise to drop packets.
>
>
> --
>



--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
