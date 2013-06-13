From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] skbuff: Update truesize in pskb_expand_head
Date: Wed, 12 Jun 2013 22:38:56 -0700
Message-ID: <1371101936.3252.92.camel@edumazet-glaptop>
References: <1371027934-1955-1-git-send-email-david.wiltshire@gmx.com>
	 <1371027934-1955-2-git-send-email-david.wiltshire@gmx.com>
	 <1371028618.3252.57.camel@edumazet-glaptop>
	 <20130612233503.GB10989@linux-rbgc.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
	eparis@redhat.com, edumazet@google.com
To: Dave Wiltshire <david.wiltshire@gmx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130612233503.GB10989@linux-rbgc.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-06-13 at 09:35 +1000, Dave Wiltshire wrote:

> Firstly, from my cover letter: "Perhaps I don't understand something,
> but I thought it best to generate the change and then ask. So is this
> correct?".

Sure I have no problems with that.

>  But secondly, I understand that the only reason for truesize
> is for memory accounting on sockets. Indeed that's why I thought this
> was incorrect. Something being complex is not a good reason not to do
> it.

OK but right now your patch adds many regressions, that will take weeks
for other dev to discover, understand and fix.

If you change skb->truesize not properly while skb is owned by a socket,
we can hold references forever and prevent sockets from being
dismantled/freed, or worse we'll free sockets while they are still in
use and panic the machine.

Some callers of pskb_expand_head() do not want skb->truesize to be
modified, because skb might be orphaned or not.

There are hundred of call sites.

Really, your patch is way too risky and will consume too much time for
very little gain. We cannot change conventions without a full audit.

There are some cases where truesize can not be exactly tracked.
For example, when we pull all data from a frag into skb->head, and the
frag can be release (put_page() on it), we do not know its original size
and can not reduce skb->truesize by this amount.
Thats fine, most of the time, because we pull network headers and they
are limited in size.

Your changelog used : "This is likely a memory audit leak", which is
weak considering the amount of time needed for us to validate such a big
change.
