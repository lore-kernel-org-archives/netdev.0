From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH v3] netfilter: Xtables: idletimer target implementation
Date: Wed, 9 Jun 2010 17:18:54 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1006091716170.30265@obet.zrqbmnf.qr>
References: <1275592445-15555-1-git-send-email-luciano.coelho@nokia.com>  <4C0F9B17.10504@trash.net> <1276096275.31892.117.camel@chilepepper>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ext Patrick McHardy <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Timo Teras <timo.teras@iki.fi>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1276096275.31892.117.camel@chilepepper>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2010-06-09 17:11, Luciano Coelho wrote:
>> 
>> How does this work with multiple namespaces? It seems every namespace
>> can bind to any timer.
>
>I was implementing this solution for multiple namespaces (see the
>previous versions of my patch), but the code started getting really
>complicated.  Then I found out that sysfs and multiple namespaces are
>not working very well together yet and decided to drop it for the time
>being.  Of course this doesn't matter anymore, since the timers belong
>to an independent class in sysfs, so I can easily add multiple namespace
>support by adding struct net *net as part of the list key together with
>the label.
>
>Do you think it's okay to leave it like this for now and extend it for
>multiple namespace support with a future patch?

Yes. Least thing we need is one humongous patch. :)


>> > +	timer = __idletimer_tg_find_by_label(info->label);
>> > +	if (!timer) {
>> > +		spin_unlock(&list_lock);
>> > +		timer = idletimer_tg_create(info);
>> >   
>> 
>> How does this prevent creating the same timer twice?
>
>The timer will only be created if __idletimer_tg_find_by_label() returns
>NULL, which means that no timer with that label has been found.  "info"
>won't be the same if info->label is different, right? Or can it change
>on the fly?

One thing to be generally aware about is that things could potentially
be instantiated by another entity between the time a label was looked up
with negative result and the time one tries to add it.
It may thus be required to extend keeping the lock until after
idletimer_tg_create, in other words, lookup and create must be atomic
to the rest of the world.
