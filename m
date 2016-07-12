From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2] ip route: restore route entries in correct order
Date: Tue, 12 Jul 2016 15:55:59 +0200
Message-ID: <20160712135559.GB15034@orbyte.nwl.cc>
References: <db0478737a916791e56b8a5f4c6307143ea44c25.1468330678.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, stephen@networkplumber.org
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37697 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750936AbcGLN4C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 09:56:02 -0400
Content-Disposition: inline
In-Reply-To: <db0478737a916791e56b8a5f4c6307143ea44c25.1468330678.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2016 at 09:37:58PM +0800, Xin Long wrote:
> Sometimes we cannot restore route entries, because in kernel
>   [1] fib_check_nh()
>   [2] fib_valid_prefsrc()
> cause some routes to depend on existence of others while adding.
> 
> For example, we saved all the routes, and flushed all tables
>   [a] default via 192.168.122.1 dev eth0
>   [b] 192.168.122.0/24 dev eth0 src 192.168.122.21
>   [c] broadcast 127.0.0.0 dev lo table local src 127.0.0.1
>   [d] local 127.0.0.0/8 dev lo table local  src 127.0.0.1
>   [e] local 127.0.0.1 dev lo table local src 127.0.0.1
>   [f] broadcast 127.255.255.255 dev lo table local src 127.0.0.1
>   [g] broadcast 192.168.122.0 dev eth0 table local src 192.168.122.21
>   [h] local 192.168.122.21 dev eth0 table local src 192.168.122.21
>   [i] broadcast 192.168.122.255 dev eth0 table local src 192.168.122.21
> 
>   Now start to restore them:
>     If we want to add [a], we have to add [b] first, as [1] and
>     'via 192.168.122.1' in [a].
>     If we want to add [b], we have to add [h] first, as [2] and
>     'src 192.168.122.21' in [b].
> 
>   So the correct order to restore should be like:
>     [e][h] -> [b][c][d][f][g][i] -> [a]
> 
> This patch fixes it by traversing the file 3 times, it only restores
> part of them in each run according to the following conditions, to
> make sure every entry can be restored successfully.
>   1. !gw && (!fib_prefsrc || fib_prefsrc == cfg->fc_dst)
>   2. !gw && (fib_prefsrc != cfg->fc_dst)
>   3. gw
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Phil Sutter <phil@nwl.cc>
