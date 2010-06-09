From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH v3] netfilter: Xtables: idletimer target implementation
Date: Wed, 09 Jun 2010 21:42:19 +0300
Message-ID: <1276108939.11199.23.camel@powerslave>
References: <1275592445-15555-1-git-send-email-luciano.coelho@nokia.com>
	 <4C0F9B17.10504@trash.net> <1276096275.31892.117.camel@chilepepper>
	 <alpine.LSU.2.01.1006091716170.30265@obet.zrqbmnf.qr>
	 <1276105707.11199.12.camel@powerslave>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ext Patrick McHardy <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Timo Teras <timo.teras@iki.fi>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1276105707.11199.12.camel@powerslave>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-06-09 at 19:48 +0200, Coelho Luciano (Nokia-D/Helsinki)
wrote:
> On Wed, 2010-06-09 at 17:18 +0200, ext Jan Engelhardt wrote:
> > >> > +	timer = __idletimer_tg_find_by_label(info->label);
> > >> > +	if (!timer) {
> > >> > +		spin_unlock(&list_lock);
> > >> > +		timer = idletimer_tg_create(info);
> > >> >   
> > >> 
> > >> How does this prevent creating the same timer twice?
> > >
> > >The timer will only be created if __idletimer_tg_find_by_label() returns
> > >NULL, which means that no timer with that label has been found.  "info"
> > >won't be the same if info->label is different, right? Or can it change
> > >on the fly?
> > 
> > One thing to be generally aware about is that things could potentially
> > be instantiated by another entity between the time a label was looked up
> > with negative result and the time one tries to add it.
> > It may thus be required to extend keeping the lock until after
> > idletimer_tg_create, in other words, lookup and create must be atomic
> > to the rest of the world.
> 
> Ahh, sure! I missed the actual point of Patrick's question.  I had the
> idletimer_tg_create() inside the lock, but when I added the
> sysfs_create_file() there (which can sleep), I screwed up with the
> locking.
> 
> I'll move the sysfs file creation to outside that function so I can keep
> the lock until after the timer is added to the list.  Thanks for
> clarifying!

Hmmm... after struggling with this for a while, I think it's not really
possible to simply create the sysfs file outside of the lock, because if
the sysfs creation fails, we will again risk a race condition.

I think the only way is to delay the sysfs file creation and do it in a
workqueue.


-- 
Cheers,
Luca.

