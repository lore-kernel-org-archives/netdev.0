From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: crypto: deadlock between crypto_alg_sem/rtnl_mutex/genl_mutex
Date: Tue, 14 Mar 2017 11:31:05 +0100
Message-ID: <CACT4Y+bzAdkwKgNHZ2PXvJFvm0h2uFYtnjhwCWW1HNOki9=hEA@mail.gmail.com>
References: <CACT4Y+bLbNbf0T376JHvemuY+za0+qgrfOKWzvJg5vAkJTCRFg@mail.gmail.com>
 <20170314091649.GA711@gondor.apana.org.au> <CACT4Y+YT6EZFtMTNywd4BtKyzWrJ9vtDU96TUFi9WLpypkgWhg@mail.gmail.com>
 <20170314102557.GA1225@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, linux-crypto@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314102557.GA1225@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 14, 2017 at 11:25 AM, Herbert Xu
<herbert@gondor.apana.org.au> wrote:
> On Tue, Mar 14, 2017 at 10:44:10AM +0100, Dmitry Vyukov wrote:
>>
>> Yes, please.
>> Disregarding some reports is not a good way long term.
>
> Please try this patch.

Applied on bots. I should have a conclusion within a day.
Thanks!


> ---8<---
> Subject: netlink: Annotate nlk cb_mutex by protocol
>
> Currently all occurences of nlk->cb_mutex are annotated by lockdep
> as a single class.  This causes a false lcokdep cycle involving
> genl and crypto_user.
>
> This patch fixes it by dividing cb_mutex into individual classes
> based on the netlink protocol.  As genl and crypto_user do not
> use the same netlink protocol this breaks the false dependency
> loop.
>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 7b73c7c..596eaff 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -96,6 +96,44 @@ static inline int netlink_is_kernel(struct sock *sk)
>
>  static DECLARE_WAIT_QUEUE_HEAD(nl_table_wait);
>
> +static struct lock_class_key nlk_cb_mutex_keys[MAX_LINKS];
> +
> +static const char *const nlk_cb_mutex_key_strings[MAX_LINKS + 1] = {
> +       "nlk_cb_mutex-ROUTE",
> +       "nlk_cb_mutex-1",
> +       "nlk_cb_mutex-USERSOCK",
> +       "nlk_cb_mutex-FIREWALL",
> +       "nlk_cb_mutex-SOCK_DIAG",
> +       "nlk_cb_mutex-NFLOG",
> +       "nlk_cb_mutex-XFRM",
> +       "nlk_cb_mutex-SELINUX",
> +       "nlk_cb_mutex-ISCSI",
> +       "nlk_cb_mutex-AUDIT",
> +       "nlk_cb_mutex-FIB_LOOKUP",
> +       "nlk_cb_mutex-CONNECTOR",
> +       "nlk_cb_mutex-NETFILTER",
> +       "nlk_cb_mutex-IP6_FW",
> +       "nlk_cb_mutex-DNRTMSG",
> +       "nlk_cb_mutex-KOBJECT_UEVENT",
> +       "nlk_cb_mutex-GENERIC",
> +       "nlk_cb_mutex-17",
> +       "nlk_cb_mutex-SCSITRANSPORT",
> +       "nlk_cb_mutex-ECRYPTFS",
> +       "nlk_cb_mutex-RDMA",
> +       "nlk_cb_mutex-CRYPTO",
> +       "nlk_cb_mutex-SMC",
> +       "nlk_cb_mutex-23",
> +       "nlk_cb_mutex-24",
> +       "nlk_cb_mutex-25",
> +       "nlk_cb_mutex-26",
> +       "nlk_cb_mutex-27",
> +       "nlk_cb_mutex-28",
> +       "nlk_cb_mutex-29",
> +       "nlk_cb_mutex-30",
> +       "nlk_cb_mutex-31",
> +       "nlk_cb_mutex-MAX_LINKS"
> +};
> +
>  static int netlink_dump(struct sock *sk);
>  static void netlink_skb_destructor(struct sk_buff *skb);
>
> @@ -585,6 +623,9 @@ static int __netlink_create(struct net *net, struct socket *sock,
>         } else {
>                 nlk->cb_mutex = &nlk->cb_def_mutex;
>                 mutex_init(nlk->cb_mutex);
> +               lockdep_set_class_and_name(nlk->cb_mutex,
> +                                          nlk_cb_mutex_keys + protocol,
> +                                          nlk_cb_mutex_key_strings[protocol]);
>         }
>         init_waitqueue_head(&nlk->wait);
>
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
