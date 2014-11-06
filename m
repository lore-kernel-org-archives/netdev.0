From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: netfilter: nf_conntrack: there maybe a bug in
 __nf_conntrack_confirm, when it race against get_next_corpse
Date: Thu, 6 Nov 2014 14:00:13 +0100
Message-ID: <20141106140013.5110dd6e@redhat.com>
References: <012601cff7d1$7ce2d620$76a88260$@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <fw@strlen.de>, <linux-kernel@vger.kernel.org>,
	"Pablo Neira Ayuso" <pablo@netfilter.org>,
	"Patrick McHardy" <kaber@trash.net>, <kadlec@blackhole.kfki.hu>,
	<davem@davemloft.net>, "Changli Gao" <xiaosuo@gmail.com>,
	"Andrey Vagin" <avagin@openvz.org>, brouer@redhat.com,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "billbonaparte" <programme110@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <012601cff7d1$7ce2d620$76a88260$@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 4 Nov 2014 09:48:32 +0800
"billbonaparte" <programme110@gmail.com> wrote:

> (sorry to send this e-mail again, last mail is rejected by server due to
> non-acceptable content)

There is several issues with your submission.  I'll take care of
resubmitting a patch in your name (so you will get credit in the git
log).

If you care to know, issues are:
 1. you are not sending to the appropriate mailing lists,
 2. patch is as an attachment (should be inlined),
 3. the patch have style and white-space issues.


> Florian Westphal [mailto:fw@strlen.de] wrote:
> >Correct.  This is broken since the central spin lock removal, since 
> >nf_conntrack_lock no longer protects both get_next_corpse and 
> >conntrack_confirm.
> > 
> >Please send a patch, moving dying check after removal of conntrack from 
> >the percpu list,
>
> Since unconfirmed conntrack is stored in unconfirmed-list which is per-cpu
> list and protected by per-cpu spin-lock, we can remove it from
> uncomfirmed-list and insert it into ct-hash-table separately. that is to
> say, we can remove it from uncomfirmed-list without holding corresponding
> hash-lock, then check if it is dying.
> if it is dying, we add it to the dying-list, then quit
> __nf_conntrack_confirm. we do this to follow the rules that the conntrack
> must alternatively at unconfirmed-list or dying-list when it is abort to be
> destroyed.

In the resubmit. I'll take a slightly more conservative approach, by
keeping the DYING check under the hash-lock, as it is currently.  I
guess we could do it without holding the hash-lock, but I want to keep
the fix as simple as possible.


> >> 	2. operation on ct->status should be atomic, because it race aginst 
> >> get_next_corpse.
[...]
> if there is a race at operating ct->status, there will be in alternative
> case:
> 1) IPS_DYING bit which set in get_next_corpse override other bits (e.g.
> IPS_SRC_NAT_DONE_BIT), or
> 2) other bits (e.g. IPS_SRC_NAT_DONE_BIT) which set in nf_nat_setup_info
> override IPS_DYING bit.

Notice the set_bit() is atomic, so we don't have these issues (of bits
getting overridden).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
