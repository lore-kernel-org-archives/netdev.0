From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Wed, 27 Aug 2008 13:22:22 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808271236080.1034@wrl-59.cs.helsinki.fi>
References: <20080819213417.45133573@tux> <Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
 <20080822183224.2d52f16c@tux> <20080822.143709.65615512.davem@davemloft.net>
 <20080823111446.06a350a2@tux> <Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
 <20080824163843.33b4f890@tux> <Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
 <20080826141812.589848a0@tux> <Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
 <20080826181731.4581fd2c@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1272662245-1219829897=:1034"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080826181731.4581fd2c@tux>
Content-ID: <Pine.LNX.4.64.0808271301190.1034@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1272662245-1219829897=:1034
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0808271238401.1034@wrl-59.cs.helsinki.fi>

On Tue, 26 Aug 2008, Dâniel Fraga wrote:

> On Tue, 26 Aug 2008 23:40:58 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > If you want to, a tcpdump from normal, working case wouldn't hurt either 
> > to show the "normal pattern" on network level and that is trivial to 
> > produce in no time now that you know the commands etc. I guess... :-)
> 
> 	Ok, there it is:
> 
> http://www.abusar.org/htb/dump-normal.log
> 	
> 	Just the port 995... I checked email, then received a message,
> checked again, just the normal behaviour.

Thanks, those flows (there were again some) looks exactly what also the 
working connections in the earlier log do.

> > They might not be that interested until we have something more concrete 
> > than what we know currently... :-)
> 
> 	Ok :) And you're right, because if I disable frto and htb *and*
> the problem has gone, there's a huge chance to be something related to
> kernel. Or a mix of kernel and user space problem which happens just
> when frto and/or htb are used.
> 
> > Can you explain a bit more. Does it resolve during it or some time after 
> > it? And more importantly how do you know that it resolves? Ie., what is 
> > the normal behavior (be more specific than "it works" :-), how do know 
> > that it's working).
> 
> 	Ok. For example:
> 
> 1) the connection is normal, then suddenly it stalls. I cannot receive
> mail, nor download nntp messages, nor access ftp etc.

...thus there could be other ports that are related as well, do you 
remember what exactly started working in that particular case :-)?

> 2) I do on my client machine a "nmap -sS server" and...
> 
> 3) ...imediatelly the connection is not stalled anymore.

Which of the connections? Mail, nntp, ftp, or the etc.? :-) To the host ip 
which was given for the tcpdump filter, definately nothing was resumed.

> 	Now I remembered one thing and I'd like to make a question (I
> hope it isn't a stupid question): dynticks (tickless) were implemented
> for x86-64 in 2.6.24 kernel and I started to use dynticks in 2.6.24. Could 
> it be affecting the server behaviour? I use dynticks (enabled) on all
> my machines, but does it make sense to use in a server environment?
> Could the dynticks cause this? Until now, I don't think so, but... who
> knows?
> 
> http://kernelnewbies.org/Linux_2_6_24#head-4edc562fa1b9fa8e5da5adaf1beab057237c325d

I was think that at a time (even thought of enquiring you about this 
part of the config), but the tcpdump log shows a problem that is 
unlikely to depend on timers in any way (and at least some timer expires 
because the SYNACKs are retransmitted, so it's not in some infinite wait 
bug). I'd like to know what causes that and try to solve it.

Once we know the reasons, we can probably easily determinate whether 
there's need to experiment with the timers. Trying to conquer all problems 
at once, when not even knowing how many problems one is going to find is 
not that easy either. Besides, I'd be more concerned about the timers on 
the client after seeing that nothing goes in the network while the nmap 
trick resolves the thing.

> > It seems that either we lack some traffic between the parties or simply 
> > need to find out what the userspace is doing, and in the latter case what 
> > happens in the network might not be relevant at all. Is there possibility 
> > that we miss an alternative route by using the host rule for tcpdump (at 
> > the server)? Nmap starts at 22:26:26.613098, the last packet in the client 
> > log is at 22:26:01.452842. Alternatively, the port 995 was not the right 
> > one to track (though there's clearly this on network level visible problem 
> > with it too)... :-(
> 
> 	I tracked the 995 port, because I have problems reading email
> pro pop3s (995). Should I do it different with tcpdump? 

The server's log captured not only 995 traffic but everything else to the 
host with the given ip (including udp which should show the tunnelled 
traffic I guess). Unless there's some other route to that host with 
a different ip, I think we don't have much more to find out in the network 
(besides the potential of missing packets from tcpdump during the syn 
flooding, but it's very unlikely that all packets of some active flow 
would be hit at the same time, so something from a progressing flow would 
still be shown even if some of packets would be missing).

This makes me wander if the network behavior is at all related to 
resolving of the problem. Only thing I can think of is that for some 
reason the userspace gets notified much later than it should about
TCP reset and therefore is waiting until that happens and can only
then continue.

> > You might jump into conclusions too quickly every now and then, more
> > time might be needed to really ensure something is working. Obviously
> > if any non-workingness is noticed, it's always a counter-proof even if 
> > long working periods occur in between.
> 
> 	Ok. It seems a complex issue. You're right. I need more
> patience ;)

...of course if one wants to comment something to keep others posted 
what's happening, one could always note that "so far all good but I keep 
testing for longer time" (that's what some other people say).

> > In syscall terms this ListenOverflow means that int listen(int sockfd, int 
> > backlog); (see man -S 2 listen) is given some size as backlog for those 
> > connections that are not yet accept()'ed, and that is exhausted when the 
> > ListenOverflow gets incremented (ie., if I'm not completely wrong :-)).
> 
> 	Hmm interesting.
> 
> > You might want to look on dovecot how to make it accept more concurrent 
> > connections, perhaps the login_max_processes_count might the right one
> > (I quickly glanced http://wiki.dovecot.org/LoginProcess) though this is 
> > somewhat site configuration dependant according to that page.
> 
> 	Yes, I have login_max_processes_count = 128 (the default) and I
> have just a few users (just 10 users), so I think it's not the problem.

It would be too easy explanation, yeah :-). Can you still please check 
next time that there aren't even near that many server processes at the 
server :-).

> > You could try setting up some script which does something along these 
> > lines and then redirect its during the event to some file (+ tcpdumping 
> > the thing obviously):
> > 
> > while [ : ]; do
> > 	date "+%s.%N"
> > 	cat /proc/net/{netstat,snmp}

Adding this wouldn't hurt btw:

cat /proc/net/tcp

> > 	sleep 1
> > done
> 
> 	Ok. You're helping a lot. Thanks Ilpo ;)
> 
> 
> 

-- 
 i.
---696208474-1272662245-1219829897=:1034--
