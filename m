From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net_sched: prio: rollback allocations if
 prio_init() fails
Date: Mon, 13 Jun 2016 10:13:24 -0700
Message-ID: <1465838004.7945.167.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465773707.7945.133.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpXY0Ce5hbXYGOcd-N1tb9BH33JYXFQdmWEbsc5SWYsV8A@mail.gmail.com>
	 <1465792157.7945.145.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1465794231.7945.150.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpWWLTMRUNUeS9=6B3KqA6Tyu0qaUYSRw_PFYFK_mo7Urw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36575 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933027AbcFMRN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 13:13:26 -0400
Received: by mail-pa0-f41.google.com with SMTP id b5so47476034pas.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 10:13:26 -0700 (PDT)
In-Reply-To: <CAM_iQpWWLTMRUNUeS9=6B3KqA6Tyu0qaUYSRw_PFYFK_mo7Urw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-06-13 at 09:28 -0700, Cong Wang wrote:
> On Sun, Jun 12, 2016 at 10:03 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > Now prio_init() can return -ENOMEM, it also has to make sure
> > any allocated qdisc are freed, since the caller (qdisc_create()) wont
> > call ->destroy() handler for us.
> 
> 
> But prio_tune() is called by ->change() too, so just call prio_destroy()
> inside prio_tune() ?

Because the following should work :

tc qdisc replace dev eth0 root prio bands 3

(later...)

tc qdisc change dev eth0 root prio bands 5 // memory allocation failure

We must not destroy the qdisc on a change operation if it fails.

Only the init should clean the qdisc state/memory/children since qdisc
wont be created for real.

Presumably we should commit changes on qdisc only if the whole
->change() succeeded, but I guess lot of qdisc are buggy in this
respect.
