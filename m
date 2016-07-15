From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip route: restore route entries in correct
 order
Date: Fri, 15 Jul 2016 11:35:38 -0700
Message-ID: <20160715113538.6cd8391b@xeon-e3>
References: <db0478737a916791e56b8a5f4c6307143ea44c25.1468330678.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, phil@nwl.cc
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35951 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518AbcGOSfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 14:35:22 -0400
Received: by mail-pa0-f47.google.com with SMTP id pp5so34851469pac.3
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 11:35:22 -0700 (PDT)
In-Reply-To: <db0478737a916791e56b8a5f4c6307143ea44c25.1468330678.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Jul 2016 21:37:58 +0800
Xin Long <lucien.xin@gmail.com> wrote:

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

Applied, then I changed rtattr_cmp() to have const args.
