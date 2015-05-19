From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next 3/4] rocker: do not make neighbour entry changes
 when preparing transactions
Date: Tue, 19 May 2015 17:32:15 +0900
Message-ID: <555AF50F.1090402@lab.ntt.co.jp>
References: <1432016657-24231-1-git-send-email-simon.horman@netronome.com> <1432016657-24231-4-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:35273 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbbESIcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 04:32:36 -0400
In-Reply-To: <1432016657-24231-4-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/05/19 15:24, Simon Horman wrote:
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

Hi Simon,

I encountered oops by this bug without abort.
Adding a route by ip command and pinging to the gateway triggers oops.

The scenario I guess is below:
In the PREPARE phase, a new entry is allocated and added to the hash
table. In the COMMIT phase, the allocated entry is the same object as
that in the hash table. As "adding" is not true in the COMMIT phase, the
entry is freed in rocker_port_ipv4_nh() while it is still in the hash
table. This causes use-after-free and maybe corrupts pointers in the entry.

This seems to fix that problem.

Thanks,
Toshiaki Makita
