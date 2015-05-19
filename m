From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 3/4] rocker: do not make neighbour entry changes
 when preparing transactions
Date: Tue, 19 May 2015 09:11:29 -0700
Message-ID: <CAE4R7bBZTPeD4PM8xfxvEn0FSwCnWNwPt4FLAf38=7KdQn=s+Q@mail.gmail.com>
References: <1432016657-24231-1-git-send-email-simon.horman@netronome.com>
	<1432016657-24231-4-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:35657 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753169AbbESQLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 12:11:30 -0400
Received: by qkdn188 with SMTP id n188so8201591qkd.2
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 09:11:29 -0700 (PDT)
In-Reply-To: <1432016657-24231-4-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2015 at 11:24 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> rocker_port_ipv4_nh() and in turn rocker_port_ipv4_neigh() may be
> be called with trans == SWITCHDEV_TRANS_PREPARE and then
> trans == SWITCHDEV_TRANS_COMMIT from switchdev_port_obj_set() via
> fib_table_insert().
>
> Although I have been unable to find a scenario where a bug manifests
> I do see some incorrect behaviour when adding a fib entry with a gateway.
>
> The first time that rocker_port_ipv4_nh() is called, with
> trans == SWITCHDEV_TRANS_PREPARE, _rocker_neigh_add()
> adds a new entry to the neigh table.
>
> And the second time  rocker_port_ipv4_nh() is called, with
> trans == SWITCHDEV_TRANS_COMMIT, that entry is found and
> _rocker_neigh_update() is called.
>
> Assuming the transaction runs to completion this appears to be harmless.
> I suspect it would be not correct if the transaction was aborted.
>
> This problem does not appear to affect deletion as my analysis is
> that deletion is always performed with trans == SWITCHDEV_TRANS_NONE.
>
> For completeness _rocker_neigh_{add,del,prepare} are updated not
> to manipulate fib table entries if trans == SWITCHDEV_TRANS_PREPARE.
>
> Fixes: c4f20321d968 ("rocker: support prepare-commit transaction model")
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
>  drivers/net/ethernet/rocker/rocker.c | 16 ++++++++++++----
>  1 file changed, 12 insertions(+), 4 deletions(-)
>

[cut]

> @@ -2928,8 +2933,11 @@ static void _rocker_neigh_del(struct rocker_port *rocker_port,
>  }
>
>  static void _rocker_neigh_update(struct rocker_neigh_tbl_entry *entry,
> +                                enum switchdev_trans trans,
>                                  u8 *eth_dst, bool ttl_check)
>  {
> +       if (trans == SWITCHDEV_TRANS_PREPARE)
> +               return;

On this one, let move the trans==PREPARE test to the else branch, in
case someone down the line is dependent on eth_dst and ttl_check being
copied over.

Everything else in the patch looks good.
