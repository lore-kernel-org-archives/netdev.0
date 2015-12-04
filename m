From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Fri, 4 Dec 2015 19:34:28 -0200
Message-ID: <20151204213428.GH4164@mrl.redhat.com>
References: <CACT4Y+ZMshfGvb81VhCGuZzbSec2sCBaJUNFb1QQ-ccyH9BPkQ@mail.gmail.com>
 <fcceeb2a58ce2054cedb091f0e251393b36418ba.1449250981.git.marcelo.leitner@gmail.com>
 <CACT4Y+b66FHbFyERm804RDWh9oPC==K43TgDJfs52cQG1MDjcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	syzkaller <syzkaller@googlegroups.com>,
	linux-sctp@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60142 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754837AbbLDVec (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 16:34:32 -0500
Content-Disposition: inline
In-Reply-To: <CACT4Y+b66FHbFyERm804RDWh9oPC==K43TgDJfs52cQG1MDjcg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 04, 2015 at 09:25:35PM +0100, Dmitry Vyukov wrote:
> On Fri, Dec 4, 2015 at 6:48 PM, Marcelo Ricardo Leitner
> <marcelo.leitner@gmail.com> wrote:
> > Hi Dmitry,
> >
> > Can you please test this patch?
> > I'll re-post with proper subject if it works.
> 
> Still happening with the same stacks.

Then there may be another one, I'm afraid.

I'm using the testapp you shared in the first email, with that debug line
enabled and added a new one:
+       pr_debug("%p %d\n", asoc, asoc ? asoc->state : 0);
        debug_post_sfx();
(should have used %x, but ok)

Also enabled slub_debug=PUZ, and I get:

without the patch:
[   87.873640] sctp: ffff8800b71533d8 1
[   87.873647] sctp: sctp_do_sm[post-sfx]: error:0,
asoc:ffff8800b71533d8[STATE_CLOSED]
[   87.873739] sctp: ffff8800b71533d8 1
[   87.873742] sctp: sctp_do_sm[post-sfx]: error:0,
asoc:ffff8800b71533d8[STATE_CLOSED]
[   87.875149] sctp: ffff8800b71533d8 1802201963
[   87.875238] sctp: sctp_do_sm[post-sfx]: error:0,
asoc:ffff8800b71533d8[STATE_CLOSED]

1802201963 = 0x6b6b6b6b, poison

with the patch:
[   81.071265] sctp: ffff880137571148 1
[   81.071273] sctp: sctp_do_sm[post-sfx]: error:0,
asoc:ffff880137571148[STATE_CLOSED]
[   81.071372] sctp: ffff880137571148 1
[   81.071375] sctp: sctp_do_sm[post-sfx]: error:0,
asoc:ffff880137571148[STATE_CLOSED]
[   81.072423] sctp:           (null) 0
[   81.072427] sctp: sctp_do_sm[post-sfx]: error:0, asoc:
(null)[STATE_CLOSED]

This one, at least, is gone with this patch.

  Marcelo
