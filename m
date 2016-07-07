From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [RFC PATCH v2] net: sched: convert qdisc linked list to hashtable
Date: Thu, 7 Jul 2016 18:57:33 -0400
Message-ID: <CAEfhGizOVjafBpH8K0+57cyN_ySKqChYRw8jrfV=ODM5nmnvmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jiri Kosina <jikos@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34677 "EHLO
	mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753044AbcGGW5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 18:57:37 -0400
Received: by mail-lf0-f66.google.com with SMTP id a10so907175lfb.1
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 15:57:36 -0700 (PDT)
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com. [209.85.215.45])
        by smtp.gmail.com with ESMTPSA id 206sm7905675ljj.0.2016.07.07.15.57.34
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 15:57:34 -0700 (PDT)
Received: by mail-lf0-f45.google.com with SMTP id l188so20762615lfe.2
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 15:57:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 7, 2016 at 4:36 PM, Jiri Kosina <jikos@kernel.org> wrote:
> From: Jiri Kosina <jkosina@suse.cz>
>
> Convert the per-device linked list into a hashtable. The primary
> motivation for this change is that currently, we're not tracking all the
> qdiscs in hierarchy (e.g. excluding default qdiscs), as the lookup
> performed over the linked list by qdisc_match_from_root() is rather
> expensive.
>
> The ultimate goal is to get rid of hidden qdiscs completely, which will
> bring much more determinism in user experience.
>
> As we're adding hashtable.h include into generic netdevice.h, we have to make
> sure HASH_SIZE macro is now non-conflicting with local definitions.
>
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> ---
>
> v1 -> v2:       fix up RCU hastable usage wrt. rtnl
>                 fix compilation of .c files which define their own
>                  HASH_SIZE that now oncflicts with the one from
>                  hashtable.h (newly included via netdevice.h)
This sort of seems like it's just side-stepping the problem.  Given
that the size of this hash table is fixed, the lookup time of this
operation is still going to approach linear as the number of qdiscs
increases.  I took a quick pass at trying to use rhashtable for this
purpose a few weeks ago but dropped it when I realized many of the
table operations (which can trigger resize events) need to happen
while holding the rtnl lock.  I still think it would be possible to
use a dynamically sizable datastructure for this purpose, but it will
be a fair amount of work to change the current locking semantics to
make it work...
