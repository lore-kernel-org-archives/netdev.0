From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: Fix a big endian bug in sctp_for_each_transport()
Date: Sat, 23 Sep 2017 19:37:48 +0800
Message-ID: <CADvbK_dCT6Z6JwD+VtjNg6UUkQneU2OLeme9JVqrXjnJJ63cGg@mail.gmail.com>
References: <20170923102537.wra55nqyqsfoduxo@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, network dev <netdev@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170923102537.wra55nqyqsfoduxo@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 23, 2017 at 6:25 PM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> Fundamentally, the "pos" pointer points to "cb->args[2]" which is a long.
> In the current code, we only use the high 32 bits and cast it as an
> int.  That works on little endian systems but will fail on big endian
> systems.
>
> Fixes: d25adbeb0cdb ("sctp: fix an use-after-free issue in sctp_sock_dump")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index d7d8cba01469..7d87439f299a 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -121,14 +121,14 @@ void sctp_transport_walk_stop(struct rhashtable_iter *iter);
>  struct sctp_transport *sctp_transport_get_next(struct net *net,
>                         struct rhashtable_iter *iter);
>  struct sctp_transport *sctp_transport_get_idx(struct net *net,
> -                       struct rhashtable_iter *iter, int pos);
> +                       struct rhashtable_iter *iter, long pos);
>  int sctp_transport_lookup_process(int (*cb)(struct sctp_transport *, void *),
>                                   struct net *net,
>                                   const union sctp_addr *laddr,
>                                   const union sctp_addr *paddr, void *p);
>  int sctp_for_each_transport(int (*cb)(struct sctp_transport *, void *),
>                             int (*cb_done)(struct sctp_transport *, void *),
> -                           struct net *net, int *pos, void *p);
> +                           struct net *net, long *pos, void *p);
>  int sctp_for_each_endpoint(int (*cb)(struct sctp_endpoint *, void *), void *p);
>  int sctp_get_sctp_info(struct sock *sk, struct sctp_association *asoc,
>                        struct sctp_info *info);
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index d4730ada7f32..0222743b3aa8 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -4603,7 +4603,7 @@ struct sctp_transport *sctp_transport_get_next(struct net *net,
>
>  struct sctp_transport *sctp_transport_get_idx(struct net *net,
>                                               struct rhashtable_iter *iter,
> -                                             int pos)
> +                                             long pos)
>  {
>         void *obj = SEQ_START_TOKEN;
>
> @@ -4659,7 +4659,7 @@ EXPORT_SYMBOL_GPL(sctp_transport_lookup_process);
>
>  int sctp_for_each_transport(int (*cb)(struct sctp_transport *, void *),
>                             int (*cb_done)(struct sctp_transport *, void *),
> -                           struct net *net, int *pos, void *p) {
> +                           struct net *net, long *pos, void *p) {
>         struct rhashtable_iter hti;
>         struct sctp_transport *tsp;
>         int ret;
> diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
> index 22ed01a76b19..e9d5405aa6ac 100644
> --- a/net/sctp/sctp_diag.c
> +++ b/net/sctp/sctp_diag.c
> @@ -493,7 +493,7 @@ static void sctp_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
>                 goto done;
>
>         sctp_for_each_transport(sctp_sock_filter, sctp_sock_dump,
> -                               net, (int *)&cb->args[2], &commp);
> +                               net, &cb->args[2], &commp);
>
>  done:
>         cb->args[1] = cb->args[4];
Better not to touch sctp_for_each_transport and sctp_transport_get_idx
which are supposed to be also used elsewhere as common apis.

Can you pls try to fix this in sctp_diag_dump(), like:
@@ -463,6 +463,7 @@ static void sctp_diag_dump(struct sk_buff *skb,
struct netlink_callback *cb,
                .r = r,
                .net_admin = netlink_net_capable(cb->skb, CAP_NET_ADMIN),
        };
+       int pos = cb->args[2];

        /* eps hashtable dumps
         * args:
@@ -493,7 +494,8 @@ static void sctp_diag_dump(struct sk_buff *skb,
struct netlink_callback *cb,
                goto done;

        sctp_for_each_transport(sctp_sock_filter, sctp_sock_dump,
-                               net, (int *)&cb->args[2], &commp);
+                               net, &pos, &commp);
+       cb->args[2] = pos;
