From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH v3 net-next 3/4] rocker: do not make neighbour entry changes
 when preparing transactions
Date: Wed, 20 May 2015 15:15:23 +0900
Message-ID: <555C267B.9070807@lab.ntt.co.jp>
References: <1432100902-10187-1-git-send-email-simon.horman@netronome.com> <1432100902-10187-4-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:45442 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631AbbETGPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 02:15:55 -0400
In-Reply-To: <1432100902-10187-4-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/05/20 14:48, Simon Horman wrote:
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

'T' is missing from my first name

> Acked-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> 
...
>  static void _rocker_neigh_add(struct rocker *rocker,
> +			      enum switchdev_trans trans,
>  			      struct rocker_neigh_tbl_entry *entry)
>  {
> +	if (trans == SWITCHDEV_TRANS_PREPARE)
> +		return;
>  	entry->index = rocker->neigh_tbl_next_index++;

Isn't index needed here? It looks to be used in later function call and
logging.
How about setting index like this?

	entry->index = rocker->neigh_tbl_next_index;
	if (trans == PREPARE)
		return;
	rocker->neigh_tbl_next_index++;
	...

Thanks,
Toshiaki Makita
