From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2.6 NET] Fixes slab corruption in cbq_destroy
Date: Thu, 16 Sep 2004 16:09:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916140943.GC27293@postel.suug.ch>
References: <20040916132856.GA27293@postel.suug.ch> <4149998C.6060501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4149998C.6060501@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <4149998C.6060501@trash.net> 2004-09-16 15:47
> Thomas Graf wrote:
> 
> >Fixes slab corruption in cbq_destroy. cbq_destroy_filters and
> >qdisc_put_rtab(q->link.R_tab) are already called in cbq_destroy_class.
> >The latter lead to a slab corruption due to repeated freeing of
> >q->link.R_tab because q->link is part of q->classes. Problem introduced
> >in 1.21.
> > 
> >
> I don't see how there can be slab corruption. qdisc_put_rtab only
> calls kfree if the table is found in qdisc_rtab_list, which only
> happens once. But the patch is still fine as cleanup :)

On second call to qdisc_put_rtab with tab pointing to an already
freed qdisc_rate_table:

sch_api.c:271:  if (!tab || --tab->refcnt)

Sep 16 01:52:51 axs kernel: Slab corruption: start=d8bd4f30, len=2048
Sep 16 01:52:51 axs kernel: Redzone: 0x5a2cf071/0x5a2cf071.
Sep 16 01:52:51 axs kernel: Last user: [<c036c9af>](cbq_destroy_class+0x36/0x60)
Sep 16 01:52:51 axs kernel: 410: 6a 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
                                 ^^
	I guess this is the --tab->refcnt

Sep 16 01:52:51 axs kernel: Prev obj: start=d8bd4724, len=2048
Sep 16 01:52:51 axs kernel: Redzone: 0x170fc2a5/0x170fc2a5.
Sep 16 01:52:51 axs kernel: Last user: [<c0364594>](qdisc_get_rtab+0x77/0xcd)
Sep 16 01:52:51 axs kernel: 000: 04 00 00 00 00 00 40 00 20 bc be 00 05 00 00 00
Sep 16 01:52:51 axs kernel: 010: 05 00 00 00 05 00 00 00 05 00 00 00 05 00 00 00
Sep 16 01:52:51 axs kernel: Next obj: start=d8bd573c, len=2048
Sep 16 01:52:51 axs kernel: Redzone: 0x170fc2a5/0x170fc2a5.
Sep 16 01:52:51 axs kernel: Last user: [<c03484ce>](alloc_skb+0x48/0xe1)
Sep 16 01:52:51 axs kernel: 000: 6c 04 00 00 28 00 05 06 d5 d5 48 41 00 00 00 00
Sep 16 01:52:51 axs kernel: 010: 00 00 00 00 04 00 00 00 12 00 10 00 00 00 10 00
