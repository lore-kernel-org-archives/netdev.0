From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next v2] rocker: move netevent neigh update to
 processes context
Date: Fri, 5 Jun 2015 07:54:28 +0900
Message-ID: <20150604225425.GA7465@verge.net.au>
References: <1433303008-32656-1-git-send-email-sfeldma@gmail.com>
 <20150603.233829.1362177764562847830.davem@davemloft.net>
 <20150604082045.GA7709@vergenet.net>
 <CAE4R7bD1EmYm4TNrWWskTeKA6NfNsasVRTP4KxhOYvZt_9n3Ow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <simon.horman@netronome.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	=?utf-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:52946 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753799AbbFDWyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 18:54:31 -0400
Content-Disposition: inline
In-Reply-To: <CAE4R7bD1EmYm4TNrWWskTeKA6NfNsasVRTP4KxhOYvZt_9n3Ow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Scott,

> Simon, just focusing on this rocker->neigh_tbl_next_index++ issue at
> the moment, I think the change below would make _rocker_neigh_add()
> safe to call without needing to put neigh_update into process context.
> It works because entry is stored between PREPARE and COMMIT, so once
> entry->index is assigned in PREPARE (under neigh_tbl_lock), it'll be
> re-used in COMMIT, even if the NONE thread also claims it's
> entry->index (also under neigh_tbl_lock).
> 
> I know there are other issues you and Toshiaki Makita have pointed
> out, but let's see if we can peel the onion one layer at a time.
> 
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -2904,10 +2904,10 @@ static void _rocker_neigh_add(struct rocker *rocker,
>                               enum switchdev_trans trans,
>                               struct rocker_neigh_tbl_entry *entry)
>  {
> -       entry->index = rocker->neigh_tbl_next_index;
> +       if (trans != SWITCHDEV_TRANS_COMMIT)
> +               entry->index = rocker->neigh_tbl_next_index++;
>         if (trans == SWITCHDEV_TRANS_PREPARE)
>                 return;
> -       rocker->neigh_tbl_next_index++;
>         entry->ref_count++;
>         hash_add(rocker->neigh_tbl, &entry->entry,
>                  be32_to_cpu(entry->ip_addr));

I agree that should work.
