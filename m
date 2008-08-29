From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Fri, 29 Aug 2008 16:07:04 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808291045430.7971@wrl-59.cs.helsinki.fi>
References: <20080819213417.45133573@tux> <Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
 <20080822183224.2d52f16c@tux> <20080822.143709.65615512.davem@davemloft.net>
 <20080823111446.06a350a2@tux> <Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
 <20080824163843.33b4f890@tux> <Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
 <20080826141812.589848a0@tux> <Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
 <20080828184919.611dd578@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1324579233-1219997733=:7971"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080828184919.611dd578@tux>
Content-ID: <Pine.LNX.4.64.0808291443160.1034@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1324579233-1219997733=:7971
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0808291346201.1034@wrl-59.cs.helsinki.fi>

On Thu, 28 Aug 2008, Dâniel Fraga wrote:

> Well, I hope this time you have more information and I hope I 
> didn't forget anything. If not, let's keep trying.

Thanks. It took a moment for me to analyze such sheer amount of data, 
but I'm used to large logs... :-)

Can you check during a "normal" time if the ListenOverflows grows with as 
considerable rate as during the stall (no need to send that log to me,
just confirm that it doesn't do that is enough). A little cheat to do that 
for a logfile (the command I used):

grep -A1 "ListenOverflows" <log> | cut -d ' ' -f 21-22 | grep [0-9]

> Important: these data were collected with frto disabled (0) and htb 
> disabled too. So it isn't related to frto, neither htb.

I kind of assumed/knew that since the htb patch didn't solve it.

...When you use nmap to resolve, is the time always constant or do you run 
it until the situation resolves?

There are constantly 9 items in sk_ack_backlog (ie., connections which are 
not yet accept), those connections are in TCP_CLOSE_WAIT, then there are 
~7 connections hanging in SYN_RECV which cannot make progress (all of them 
from a single address besides two flows of yours in SYN_RECV).

So I guess that the configured 128 is not related to the number that 
is given to listen syscall, as it seems to be 9.

...Next we need to find out why dovecot is not accept()ing or is doing 
that dead slow (the client's state is hardly significant, so I guess 
it's no longer mandatory to collect it every time)...

Can you provide these to familiarize myself a bit to the server's 
environment (no need to wait for the stall):

ps ax | grep dovecot  (or whatever the process is named)
netstat -p -n -l | grep "995"

But you'll mostly have to resort to strace during the stall, I recommend 
trying to trace just part of the syscalls, eg at least these:

strace -e trace=accept,listen,close,shutdown,select

...as it would probably not be wise to make a full dump available (that it 
would contain every syscall). Alternatively, you can create one full dump 
for yourself and just grep the relevant parts. There may be need to strace
more than one process (all dovecot related).


-- 
 i.
---696208474-1324579233-1219997733=:7971--
