From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH v2 net-next 3/4] rocker: do not make neighbour entry
 changes when preparing transactions
Date: Tue, 19 May 2015 20:16:04 -0700
Message-ID: <CAE4R7bAxCvO7bfO8TEnj6r8XUhMLERs2ZNXvjkKjKuQS4s9ZhQ@mail.gmail.com>
References: <1432087212-29612-1-git-send-email-simon.horman@netronome.com>
	<1432087212-29612-4-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:35466 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbbETDQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 23:16:05 -0400
Received: by qceb3 with SMTP id b3so16196476qce.2
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 20:16:04 -0700 (PDT)
In-Reply-To: <1432087212-29612-4-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2015 at 7:00 PM, Simon Horman
<simon.horman@netronome.com> wrote:
>
> rocker_port_ipv4_nh() and in turn rocker_port_ipv4_neigh() may be
> be called with trans == SWITCHDEV_TRANS_PREPARE and then
> trans == SWITCHDEV_TRANS_COMMIT from switchdev_port_obj_set() via
> fib_table_insert().
>
> The first time that rocker_port_ipv4_nh() is called, with
> trans == SWITCHDEV_TRANS_PREPARE, _rocker_neigh_add() adds a new entry to
> the neigh table.
>
> And the second time  rocker_port_ipv4_nh() is called, with
> trans == SWITCHDEV_TRANS_COMMIT, that entry is found. This causes
> rocker_port_ipv4_nh() to believe it is not adding an entry and thus it
> frees "entry", which is still present in rocker driver's neigh table.
>
> This problem does not appear to affect deletion as my analysis is that
> deletion is always performed with trans == SWITCHDEV_TRANS_NONE.
>
> For completeness _rocker_neigh_{add,del,prepare} are updated not to
> manipulate fib table entries if trans == SWITCHDEV_TRANS_PREPARE.
>
> Fixes: c4f20321d968 ("rocker: support prepare-commit transaction model")
> Reported-by: oshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
>
> ---
> v2
> * As suggested by Scott Feldman, only guard ref_count adjustment
>   with (trans == SWITCHDEV_TRANS_PREPARE) in _rocker_neigh_update.
> * Updated changelog to note that an entry is freed but left
>   in the neigh table. Thanks to Toshiaki Makita.
> ---
>  drivers/net/ethernet/rocker/rocker.c | 16 +++++++++++-----
>  1 file changed, 11 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index 89d22bdcbdc4..b836dd315e8a 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -2909,8 +2909,11 @@ static struct rocker_neigh_tbl_entry *
>  }
>
>  static void _rocker_neigh_add(struct rocker *rocker,
> +                             enum switchdev_trans trans,
>                               struct rocker_neigh_tbl_entry *entry)
>  {
> +       if (trans == SWITCHDEV_TRANS_PREPARE)
> +               return;
>         entry->index = rocker->neigh_tbl_next_index++;
>         entry->ref_count++;
>         hash_add(rocker->neigh_tbl, &entry->entry,
> @@ -2921,6 +2924,8 @@ static void _rocker_neigh_del(struct rocker_port *rocker_port,
>                               enum switchdev_trans trans,
>                               struct rocker_neigh_tbl_entry *entry)
>  {
> +       if (trans == SWITCHDEV_TRANS_PREPARE)
> +               return;
>         if (--entry->ref_count == 0) {
>                 hash_del(&entry->entry);
>                 rocker_port_kfree(rocker_port, trans, entry);
> @@ -2928,12 +2933,13 @@ static void _rocker_neigh_del(struct rocker_port *rocker_port,
>  }
>
>  static void _rocker_neigh_update(struct rocker_neigh_tbl_entry *entry,
> +                                enum switchdev_trans trans,
>                                  u8 *eth_dst, bool ttl_check)
>  {
>         if (eth_dst) {
>                 ether_addr_copy(entry->eth_dst, eth_dst);
>                 entry->ttl_check = ttl_check;
> -       } else {
> +       } else if (trans == SWITCHDEV_TRANS_PREPARE) {
>                 entry->ref_count++;
>         }


hmmm...should that be else if (trans != SWITCHDEV_TRANS_PREPARE)?

If so, please send v3 and add my Acked-by.
