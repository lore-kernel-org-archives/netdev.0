From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Mon, 1 Sep 2008 10:11:20 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808300924310.12388@wrl-59.cs.helsinki.fi>
References: <20080819213417.45133573@tux> <Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
 <20080822183224.2d52f16c@tux> <20080822.143709.65615512.davem@davemloft.net>
 <20080823111446.06a350a2@tux> <Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
 <20080824163843.33b4f890@tux> <Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
 <20080826141812.589848a0@tux> <Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
 <20080828184919.611dd578@tux> <Pine.LNX.4.64.0808291045430.7971@wrl-59.cs.helsinki.fi>
 <20080829144150.171ba495@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1209811986-1220078144=:12388"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080829144150.171ba495@tux>
Content-ID: <Pine.LNX.4.64.0809011004190.28826@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1209811986-1220078144=:12388
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0809011004191.28826@wrl-59.cs.helsinki.fi>

On Fri, 29 Aug 2008, Dâniel Fraga wrote:

> On Fri, 29 Aug 2008 16:07:04 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > Can you check during a "normal" time if the ListenOverflows grows with as 
> > considerable rate as during the stall (no need to send that log to me,
> > just confirm that it doesn't do that is enough). A little cheat to do that 
> > for a logfile (the command I used):
> > 
> > grep -A1 "ListenOverflows" <log> | cut -d ' ' -f 21-22 | grep [0-9]
> 
> 	It does not grow:
> 
> 10953 10953

...snip...

> 	It stays in this value for a long time.

Yeah, a constant one is expected. During the stall it was growing sharply.

> > ...When you use nmap to resolve, is the time always constant or do you run 
> > it until the situation resolves?
> 
> 	The time is constant. It takes just 3 seconds to nmap to
> "solve" the problem. I always have to use Ctrl+C to stop nmap before it
> completes the scanning because in the first 3 seconds the problem is
> "solved".

Thanks (though I hoped the other way around :-)).

> > There are constantly 9 items in sk_ack_backlog (ie., connections which are 
> > not yet accept), those connections are in TCP_CLOSE_WAIT, then there are 
> > ~7 connections hanging in SYN_RECV which cannot make progress (all of them 
> > from a single address besides two flows of yours in SYN_RECV).
> > 
> > So I guess that the configured 128 is not related to the number that 
> > is given to listen syscall, as it seems to be 9.
> > 
> > ...Next we need to find out why dovecot is not accept()ing or is doing 
> > that dead slow (the client's state is hardly significant, so I guess 
> > it's no longer mandatory to collect it every time)...
> 
> 	Would it be useful if I do the same for port 119? Because inn
> (nntp) stalls too. And proftp too. So I'm sure it isn't related to
> dovecot, otherwise the other services wouldn't stall too.

Sure. Whatever of them you feel is the best choice but I doubt there's 
much benefit from doing that for many at the same time. Once we find out 
what is happening for one, the others are the same.

ftp is problematic to tcpdump. Nntp should be fine I guess.

> > Can you provide these to familiarize myself a bit to the server's 
> > environment (no need to wait for the stall):
> > 
> > ps ax | grep dovecot  (or whatever the process is named)
> 
> fraga@teleporto ~$ ps ax|grep dovecot
>  2361 ?        Ss     0:13 /usr/local/sbin/dovecot
>  2363 ?        S      0:07 dovecot-auth
>  4751 ?        S      0:00 dovecot-auth -w
>  6133 ?        S      0:00 dovecot-auth -w
>  6134 ?        S      0:00 dovecot-auth -w
> 15963 ?        S      0:00 dovecot-auth -w
> 
> 	The dovecot-auth I use for postfix too.
> 
> > netstat -p -n -l | grep "995"
> 
> fraga@teleporto ~$ sudo netstat -p -n -l | grep "995"
> Password:
> tcp        0      0 0.0.0.0:995             0.0.0.0:*       LISTEN      2361/dovecot        
> 
> > But you'll mostly have to resort to strace during the stall, I recommend 
> > trying to trace just part of the syscalls, eg at least these:
> > 
> > strace -e trace=accept,listen,close,shutdown,select
> > 
> > ...as it would probably not be wise to make a full dump available (that it 
> > would contain every syscall). Alternatively, you can create one full dump 
> > for yourself and just grep the relevant parts. There may be need to strace
> > more than one process (all dovecot related).
> 	
> 	Ok, at next stall I'll do that.
> 
> 	Maybe it's good to strace inn and proftp too, right?

I'm fine with either way. Basically we just want to find out where server 
processes are waiting when the stall happens. If at least one of them was 
in accept() but never made progress it's related to wakeup somehow, if not 
in accept, well, lets reconsider then...

> Don't you think it's interesting that http (apache) and ssh never 
> stalls?

It is interesting, yes... but do you have some idea how that would help
to solve the problem (I don't)? Only thing that I could think of is that 
it could related to setsockopt()s they set differently.

-- 
 i.
---696208474-1209811986-1220078144=:12388--
