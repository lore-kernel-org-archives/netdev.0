From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Fri, 18 Jul 2008 20:07:47 +0400
Message-ID: <20080718160746.GC29740@2ka.mipt.ru>
References: <20080717214222.GA29449@elte.hu> <20080718054626.GA3338@2ka.mipt.ru> <84144f020807180202l6c703234ic3a2b57e73a1d89a@mail.gmail.com> <20080718101624.GA7107@2ka.mipt.ru> <84144f020807180744w40677f6dm790d2caee3ca0d15@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Vegard Nossum <vegard.nossum@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Christoph Lameter <cl@linux-foundation.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:38881 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753795AbYGRQIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 12:08:36 -0400
Content-Disposition: inline
In-Reply-To: <84144f020807180744w40677f6dm790d2caee3ca0d15@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pekka.

On Fri, Jul 18, 2008 at 05:44:44PM +0300, Pekka Enberg (penberg@cs.helsinki.fi) wrote:
> Yeah. See the free_debug_processing() function in mm/slub.c for
> details (the on_freelist() part). However, if you look at slab_free()
> you can see that in the SLUB fast-path we don't do any of these
> debugging checks. So you can end up with slab corruption without a
> nice error message.

Yup, I see.

Actually with the network there will be no duuble free as long as uses
use kfree_skb(), since first freeing (with skb->users being equal to 1,
so user owns this skb) will fill skb with 0x6b, so any subsequent
kfree_skb() will try to decrement particulary huge reference counter
(0x6b6b6b6b) and actually will never reach 1 again, so things will look
quite clear, but if the same slub area will be reused for the next skb
before it is freed second time, very hard-to-debug data corruption will
happen, so I belive this kind of checks should be done into kfree_skb()
(of course under special debug compile option). I posted that patch just
for the reference and that Ingo would be able to detect where skb is
used after already being freed.

-- 
	Evgeniy Polyakov
