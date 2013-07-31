From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/5] bonding: groundwork and initial conversion
 to RCU
Date: Wed, 31 Jul 2013 08:27:59 -0700
Message-ID: <1375284479.10515.106.camel@edumazet-glaptop>
References: <1375283553-32070-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net,
	fubar@us.ibm.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:51887 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803Ab3GaP2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 11:28:10 -0400
Received: by mail-pa0-f45.google.com with SMTP id bg4so988080pad.18
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 08:28:09 -0700 (PDT)
In-Reply-To: <1375283553-32070-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-31 at 17:12 +0200, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>
> 
> Hello,
>  This patchset aims to lay the groundwork, and do the initial conversion to
> RCUism. I decided that it'll be much better to make the bonding RCU
> conversion gradual, so patches can be reviewed and tested better rather
> than having one huge patch (which I did in the beginning, before this).
> The first patch is straightforward and it converts the bonding to the
> standard list API, simplifying a lot of code, removing unnecessary local
> variables and allowing to use the nice rculist API later. It also takes
> care of some minor styling issues (re-arranging local variables longest ->
> shortest, removing brackets for single statement if/else, leaving new line
> before return statement etc.).
>  The second patch simplifies the conversion by removing unnecessary
> read_lock(&bond->curr_slave_lock) in xmit paths that are to be converted
> later, because we only care if the pointer is NULL or a slave there, since
> we already have bond->lock the slave can't go away.
>  The third patch simplifies the broadcast xmit function by removing
> the use of curr_active_slave and converting to standard list API. Also this
> design of the broadcast xmit function avoids a subtle double packet tx race
> when converted to RCU.
>  The fourth patch factors out the code that transmits skb through a slave
> with given id (i.e. rr_tx_counter in rr mode, hashed value in xor mode) and
> simplifies the active-backup xmit path because bond_dev_queue_xmit always
> consumes the skb. The new bond_xmit_slave_id function is used in rr and xor
> modes currently, but the plans are to use it in 3ad mode as well thus it's
> made global. I've left the function prototype to be 81 chars so I wouldn't
> break it, if this is an issue I can always break it in more lines.
>  The fifth patch introduces RCU by converting attach/detach and release to
> RCU. It also converts dereferencing of curr_active_slave to rcu_dereference
> although it's not fully converted to RCU, that is needed for the converted
> xmit paths. And it converts roundrobin, broadcast, xor and active-backup
> xmit paths to RCU. The 3ad and ALB/TLB modes acquire read_lock(&bond->lock)
> to make sure that no slave will be removed and to sync properly with
> enslave and release as before.
>  This way for the price of a little complexity, we'll be able to convert
> individual parts of the bonding to RCU, and test them easier in the
> process. If this patchset is accepted in some form, I'll post followups
> in the next weeks that gradually convert the bonding to RCU and remove the
> need for the rwlocks.
>  For performance notes please refer to patch 5 (RCU conversion one).
> 
> Best regards,
>  Nikolay Aleksandrov
> 

This is awesome work, thanks Nikolay.
