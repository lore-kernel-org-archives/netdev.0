From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3 2/2] sctp: fix ASCONF list handling
Date: Mon, 08 Jun 2015 22:09:50 +0200
Message-ID: <1433794190.4616.8.camel@stressinduktion.org>
References: <20150604142710.GD24585@hmsreliant.think-freely.org>
	 <b319ab74178e7f186081db90cc24c229127e42ad.1433524062.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Michio Honda <micchie@sfc.wide.ad.jp>
To: mleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:58226 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752720AbbFHUJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 16:09:54 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id D0C9320F1A
	for <netdev@vger.kernel.org>; Mon,  8 Jun 2015 16:09:53 -0400 (EDT)
In-Reply-To: <b319ab74178e7f186081db90cc24c229127e42ad.1433524062.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2015-06-05 at 14:08 -0300, mleitner@redhat.com wrote:
>       if (sp->do_auto_asconf) {
> +             spin_lock_bh(&sock_net(sk)->sctp.addr_wq_lock);
>               sp->do_auto_asconf = 0;
> -             list_del(&sp->auto_asconf_list);
> +             list_del_rcu(&sp->auto_asconf_list);
> +             spin_unlock_bh(&sock_net(sk)->sctp.addr_wq_lock);
>       }

This also looks a bit unsafe to me:

My proposal would be to sock_hold/sock_put the sockets when pushing them
onto the auto_asconf_list and defer the modifications on the list until
we don't need to hold socket lock anymore (in syscalls we do have a reference
anyway).

addr_wq_lock then is only used either without lock_sock at all or only
in order addr_wq_lock -> lock_sock, which does not cause any locking
ordering issues.

Bye,
Hannes
