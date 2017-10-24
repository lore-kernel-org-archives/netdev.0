From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH v2] sctp: full support for ipv6 ip_nonlocal_bind & IP_FREEBIND
Date: Tue, 24 Oct 2017 14:18:23 +0800
Message-ID: <CADvbK_ftZFLyA7p_3Dp8ChdVJoXi4zeWdkYz62Bzf9h2-Bez6Q@mail.gmail.com>
References: <20171023171933.GA4592@ubuntu-desk-vm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        linux-sctp@vger.kernel.org, network dev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Laszlo Toth <laszlth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:53978 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751623AbdJXGSY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 02:18:24 -0400
In-Reply-To: <20171023171933.GA4592@ubuntu-desk-vm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 24, 2017 at 1:19 AM, Laszlo Toth <laszlth@gmail.com> wrote:
> Commit 9b9742022888 ("sctp: support ipv6 nonlocal bind")
> introduced support for the above options as v4 sctp did,
> so patched sctp_v6_available().
>
> In the v4 implementation it's enough, because
> sctp_inet_bind_verify() just returns with sctp_v4_available().
> However sctp_inet6_bind_verify() has an extra check before that
> for link-local scope_id, which won't respect the above options.
>
> Added the checks before calling ipv6_chk_addr(), but
> not before the validation of scope_id.
>
> before (w/ both options):
>  ./v6test fe80::10 sctp
>  bind failed, errno: 99 (Cannot assign requested address)
>  ./v6test fe80::10 tcp
>  bind success, errno: 0 (Success)
>
> after (w/ both options):
>  ./v6test fe80::10 sctp
>  bind success, errno: 0 (Success)
>
> Signed-off-by: Laszlo Toth <laszlth@gmail.com>
> ---
> changed in v2:
>  - fixed indentation
>
>  net/sctp/ipv6.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index 51c4887..7fe9e1d1 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -882,8 +882,10 @@ static int sctp_inet6_bind_verify(struct sctp_sock *opt, union sctp_addr *addr)
>                         net = sock_net(&opt->inet.sk);
>                         rcu_read_lock();
>                         dev = dev_get_by_index_rcu(net, addr->v6.sin6_scope_id);
> -                       if (!dev ||
> -                           !ipv6_chk_addr(net, &addr->v6.sin6_addr, dev, 0)) {
> +                       if (!dev || !(opt->inet.freebind ||
> +                                     net->ipv6.sysctl.ip_nonlocal_bind ||
> +                                     ipv6_chk_addr(net, &addr->v6.sin6_addr,
> +                                                   dev, 0))) {
>                                 rcu_read_unlock();
>                                 return 0;
>                         }
> --
> 2.7.4
>
Reviewed-by: Xin Long <lucien.xin@gmail.com>

Thanks.
