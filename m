From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [RFC] add rtnl semaphore to linux-atm
Date: Mon, 06 Oct 2003 10:46:25 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310061446.h96EkOkT029882@ginger.cmf.nrl.navy.mil>
References: <mitch@sfgoth.com>
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: Message from Mitchell Blank Jr <mitch@sfgoth.com>
   of "Mon, 06 Oct 2003 02:03:04 PDT." <20031006090304.GD4651@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20031006090304.GD4651@gaz.sfgoth.com>,Mitchell Blank Jr writes:
>There are no users inside the atm tools that need ATM_ITF_ANY.  Anyone
>using it directly in a PVC address is already broken and non-determanistic
>if they have more than one interface, so I'm not worried if the semantics
>in that case are only 90% identical instead of 100%

i think the vswitch stuff used it.  but it can be made to work w/o 
too much trouble.

>I doubt many crashes happen there (in practice mostly those operations
>will be serialized by userland - it's rare to have multiple threads
>opening/closing vccs at once) but that doesn't mean that races aren't
>hiding.  Again, there's zero performance implication to serializing
>them so we might as well make the driver API a little more foolproof.

so if it isnt a problem why fix it?  further, if, as you say, open and
close could sleep and possibly for long periods of time then holding
this semaphore will block other open/close during this time.  that's
going to be very annoying.  (i have already seen this problem with the
old-style SOCKOPS lock_kernel() nonsense.  on vcc's that are slow to
close the machine basically comes to a complete stop until that vcc
is closed).  so either you make open/close non sleeping and add a 
semaphore and just dont add a semaphore.

>Yes, but the worst-case is unacceptable.  There are at least some people
>who have used the code to terminate VCCs coming from DSL customers (a
>project like that is actually what got me started with hacking on
>linux-atm 5 years ago :-).  They could have hundreds of VCCs active at
>once.

i agree.  our atm router typically has something like 100 open at a
time.  so a linear search here is bad, but the he driver does a little
work to make this somewhat more efficient (like caching the mapping 
since this cant change while under the lock).

>Hmmmm... ok.  I really believe that we need to sleep in close until the
>VCC is truly free.  If userland can't do a close followed immediately by
>an open on the same vci then something is busted.

see above why sleeping is bad.  tcp sockets can also get 'stuck' in a 
close where you cant reopen immediately, TIME_WAIT i believe.
