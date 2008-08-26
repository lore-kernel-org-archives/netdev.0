From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Tue, 26 Aug 2008 23:40:58 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
References: <20080819213417.45133573@tux> <Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
 <20080822183224.2d52f16c@tux> <20080822.143709.65615512.davem@davemloft.net>
 <20080823111446.06a350a2@tux> <Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
 <20080824163843.33b4f890@tux> <Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
 <20080826141812.589848a0@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-83759992-1219780288=:1168"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34296 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745AbYHZUlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 16:41:00 -0400
In-Reply-To: <20080826141812.589848a0@tux>
Content-ID: <Pine.LNX.4.64.0808262337260.1168@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-83759992-1219780288=:1168
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0808262252021.1168@wrl-59.cs.helsinki.fi>

On Tue, 26 Aug 2008, Dâniel Fraga wrote:

> On Tue, 26 Aug 2008 17:10:46 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > There is more than one TCP flow in your workload btw (so using 
> > "connection" is a bit more blurry from my/TCP's pov). Some stall and never 
> > finish, some get immediately through without any stalling and proceed ok. 
> > So far I've not seen any cases with mixed behavior.
> 
> 	Interesting.

If you want to, a tcpdump from normal, working case wouldn't hurt either 
to show the "normal pattern" on network level and that is trivial to 
produce in no time now that you know the commands etc. I guess... :-)

> > It could be userspace related thing.
> 
> 	Hmmm. I'll try to report this to the dovecot and inn lists.

They might not be that interested until we have something more concrete 
than what we know currently... :-)

> > It seems that there could well be more than one problem, with symptoms 
> > similar enough that they're hard to distinguish without a packet trace.
> 
> 	Yes, exactly! I think the same.
> 
> > Did it solve in this particular case? At least for 995 nothing 
> 
> 	Yes. nmap -sS always solves the problem. Very strange. nmap -sS
> for me is kind of brute force attempt to restablish the normal
> behaviour of the server... 

Can you explain a bit more. Does it resolve during it or some time after 
it? And more importantly how do you know that it resolves? Ie., what is 
the normal behavior (be more specific than "it works" :-), how do know 
that it's working).

It seems that either we lack some traffic between the parties or simply 
need to find out what the userspace is doing, and in the latter case what 
happens in the network might not be relevant at all. Is there possibility 
that we miss an alternative route by using the host rule for tcpdump (at 
the server)? Nmap starts at 22:26:26.613098, the last packet in the client 
log is at 22:26:01.452842. Alternatively, the port 995 was not the right 
one to track (though there's clearly this on network level visible problem 
with it too)... :-(

> 	Anyway, I disabled htb and frto and everything is fine for now.
> I'll keep investigating this.

Two points:

HTB shaping could cause drops that are related but considering what it 
visible in the server end's tcpdump, the userspace's behavior is quite 
relevant.

You might jump into conclusions too quickly every now and then, more
time might be needed to really ensure something is working. Obviously
if any non-workingness is noticed, it's always a counter-proof even if 
long working periods occur in between.

> > ListenOverflows might explain this (it can't be ListenDrops since it's 
> > equal to ListenOverflows and both get incremented on overflow). Are you 
> > perhaps short on workers at the userspace server? It would be nice to 
> 
> 	I use dovecot por mail. I'll post on the dovecot list. If it's
> an userspace issue, better.

It's not guaranteed that it's _only_ userspace, there could be some kernel 
aspect in the problem too (e.g., related to wakeups or so).

In syscall terms this ListenOverflow means that int listen(int sockfd, int 
backlog); (see man -S 2 listen) is given some size as backlog for those 
connections that are not yet accept()'ed, and that is exhausted when the 
ListenOverflow gets incremented (ie., if I'm not completely wrong :-)).

You might want to look on dovecot how to make it accept more concurrent 
connections, perhaps the login_max_processes_count might the right one
(I quickly glanced http://wiki.dovecot.org/LoginProcess) though this is 
somewhat site configuration dependant according to that page.

> > capture those mibs often enough (eg., once per 1s with timestamps) during 
> > the stall to see what actually gets incremented during the event because 
> > there's currently so much haystack that finding the needle gets impossible 
> > (ListenOverflows 47410) :-). Also, the corresponding tcpdump would be 
> > needed to match the events.
> 
> 	Ok. If I had more useful information, I'll reply.
> 
> 	Thank you very much!

You could try setting up some script which does something along these 
lines and then redirect its during the event to some file (+ tcpdumping 
the thing obviously):

while [ : ]; do
	date "+%s.%N"
	cat /proc/net/{netstat,snmp}
	sleep 1
done

-- 
 i.
---696208474-83759992-1219780288=:1168--
