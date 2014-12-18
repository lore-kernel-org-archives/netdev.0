From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH net] netlink: Don't reorder loads/stores before marking
 mmap netlink frame as available
Date: Thu, 18 Dec 2014 11:13:08 -0800
Message-ID: <CA+55aFyauxJFoK-ABmT+Zd3-oEV0d_FCXPLXrS_3yMG24Fe=8Q@mail.gmail.com>
References: <20141014.220908.123550384430402000.davem@davemloft.net>
	<543F6998.5090000@redhat.com>
	<20141016070753.GA16738@casper.infradead.org>
	<20141216.175817.576861457076632402.davem@davemloft.net>
	<1418774579.9773.69.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141218103026.GA16239@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Patrick McHardy <kaber@trash.net>,
	Network Development <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:47675 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162AbaLRTNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 14:13:09 -0500
Received: by mail-qg0-f51.google.com with SMTP id e89so1307155qgf.24
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2014 11:13:08 -0800 (PST)
In-Reply-To: <20141218103026.GA16239@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2014 at 2:30 AM, Thomas Graf <tgraf@suug.ch> wrote:
>
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index ef5f77b..2662821 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -550,9 +550,9 @@ static enum nl_mmap_status netlink_get_status(const struct nl_mmap_hdr *hdr)
>  static void netlink_set_status(struct nl_mmap_hdr *hdr,
>                                enum nl_mmap_status status)
>  {
> +       smp_mb();
>         hdr->nm_status = status;
>         flush_dcache_page(pgvec_to_page(hdr));
> -       smp_wmb();
>  }

If this is performance-critical code (I have no idea), then a better
idea might be to use

        smp_store_release(&hdr->nm_status, status);

instead of using explicit memory barriers. That's going to  generally
be much cheaper than a memory barrier.

                      Linus
