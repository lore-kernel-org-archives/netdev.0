From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [Patch net] igmp: acquire pmc lock for ip_mc_clear_src()
Date: Tue, 13 Jun 2017 02:30:16 +0800
Message-ID: <CADvbK_f=NePnrAvARnOMvg_o8G2bj-p1i1e_CXMZ6BooW3yhHA@mail.gmail.com>
References: <1497286346-26888-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:36368 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752050AbdFLSaT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 14:30:19 -0400
Received: by mail-qt0-f194.google.com with SMTP id s33so28443734qtg.3
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 11:30:18 -0700 (PDT)
In-Reply-To: <1497286346-26888-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 13, 2017 at 12:52 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> Andrey reported a use-after-free in add_grec():
>
>         for (psf = *psf_list; psf; psf = psf_next) {
>                 ...
>                 psf_next = psf->sf_next;
>
> where the struct ip_sf_list's were already freed by:
>
>  kfree+0xe8/0x2b0 mm/slub.c:3882
>  ip_mc_clear_src+0x69/0x1c0 net/ipv4/igmp.c:2078
>  ip_mc_dec_group+0x19a/0x470 net/ipv4/igmp.c:1618
>  ip_mc_drop_socket+0x145/0x230 net/ipv4/igmp.c:2609
>  inet_release+0x4e/0x1c0 net/ipv4/af_inet.c:411
>  sock_release+0x8d/0x1e0 net/socket.c:597
>  sock_close+0x16/0x20 net/socket.c:1072
>
> This happens because we don't hold pmc->lock in ip_mc_clear_src()
> and a parallel mr_ifc_timer timer could jump in and access them.
>
> The RCU lock is there but it is merely for pmc itself, this
> spinlock could actually ensure we don't access them in parallel.
>
> Thanks to Eric and Long for discussion on this bug.
>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Xin Long <lucien.xin@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/ipv4/igmp.c | 21 +++++++++++++--------
>  1 file changed, 13 insertions(+), 8 deletions(-)
>
> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index 44fd86d..8f6b5bb 100644
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
> @@ -2071,21 +2071,26 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
>
>  static void ip_mc_clear_src(struct ip_mc_list *pmc)
>  {
> -       struct ip_sf_list *psf, *nextpsf;
> +       struct ip_sf_list *psf, *nextpsf, *tomb, *sources;
>
> -       for (psf = pmc->tomb; psf; psf = nextpsf) {
> +       spin_lock_bh(&pmc->lock);
> +       tomb = pmc->tomb;
> +       pmc->tomb = NULL;
> +       sources = pmc->sources;
> +       pmc->sources = NULL;
> +       pmc->sfmode = MCAST_EXCLUDE;
> +       pmc->sfcount[MCAST_INCLUDE] = 0;
> +       pmc->sfcount[MCAST_EXCLUDE] = 1;
> +       spin_unlock_bh(&pmc->lock);
> +
> +       for (psf = tomb; psf; psf = nextpsf) {
>                 nextpsf = psf->sf_next;
>                 kfree(psf);
>         }
> -       pmc->tomb = NULL;
> -       for (psf = pmc->sources; psf; psf = nextpsf) {
> +       for (psf = sources; psf; psf = nextpsf) {
>                 nextpsf = psf->sf_next;
>                 kfree(psf);
>         }
Hi, Cong.

how about in ip_check_mc_rcu():
        for (psf = im->sources; psf; psf = psf->sf_next) {
               if (psf->sf_inaddr == src_addr)
                           break;
         }

I didn't see spinlock for it, is it safe to access them in parallel ?
or these two places would never be in parallel ?

I've already checked elsewhere, all other places where it accesses
or traverses im->sources are protected by this spinlock.

> -       pmc->sources = NULL;
> -       pmc->sfmode = MCAST_EXCLUDE;
> -       pmc->sfcount[MCAST_INCLUDE] = 0;
> -       pmc->sfcount[MCAST_EXCLUDE] = 1;
>  }
>
>  /* Join a multicast group
> --
> 2.5.5
>
