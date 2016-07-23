From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] net: neigh: disallow state transition DELAY->STALE in
 neigh_update()
Date: Sat, 23 Jul 2016 09:17:59 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1607230654070.2032@ja.home.ssi.bg>
References: <1469123890-2715-1-git-send-email-hchunhui@mail.ustc.edu.cn> <alpine.LFD.2.11.1607220954060.1764@ja.home.ssi.bg> <20160722.124757.283248020246505940.hchunhui@mail.ustc.edu.cn>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, dsa@cumulusnetworks.com,
	nicolas.dichtel@6wind.com, roopa@cumulusnetworks.com,
	rshearma@brocade.com, dbarroso@fastly.com, martinbj2008@gmail.com,
	rick.jones2@hp.com, koct9i@gmail.com, edumazet@google.com,
	tgraf@suug.ch, ebiederm@xmission.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chunhui He <hchunhui@mail.ustc.edu.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160722.124757.283248020246505940.hchunhui@mail.ustc.edu.cn>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Fri, 22 Jul 2016, Chunhui He wrote:

> The origin code allows NUD_DELAY -> NUD_STALE and NUD_PROBE -> NUD_STALE.
> This part was imported to kernel since v2.1.79, I don't know clearly why it
> allows that.
> 
> My analysis:
> (1) As shown in my previous mail, NUD_DELAY -> NUD_STALE may cause "dead loop",
> so it should be fixed.

	Yes, because we stay in NUD_DELAY for many seconds
which is enough for remote host to reset our resolving.

	BTW, you said:

<quote>
In my case, the gateway refuses to send unicast packets to me, before it sees
my ARP request. So it's critical to enter REACHABLE state by sending ARP
request, but not by external confirmation.
</quote>

	What kind of problem is this? Remote host wants to
see a recent probe from us, otherwise it refuses to resolve
our address before its traffic to us and it is not sent?
Can you explain this in more detail because after looking
again I have some doubts what actually happens, see below.

> (2) But NUD_PROBE -> NUD_STALE is acceptable, because in NUD_PROBE, ARP request
> has been sent, it is sufficient to break the "dead loop".
> More attempts are accomplished by the following sequence:
> NUD_STALE --> NUD_DELAY -(sent req)-> NUD_PROBE -(reset by neigh_update())->

	I think, when entering NUD_DELAY we do not send
any ARP probe: for NUD_STALE __neigh_event_send is called on
outgoing traffic to change state to NUD_DELAY and to start
timer (it was stopped in NUD_STALE) to detect if address is
still alive before probing it again. Now in this period of
5 seconds (delay_first_probe_time) two things can happen:

1. Unexpected Unicast ARP reply (immediate switch to NUD_REACHABLE)
or protocol indication (dst_confirm) causing delayed switch to
NUD_REACHABLE on next outgoing packet. On sporadic
request+reply we may not switch immediately to NUD_REACHABLE.
Even if the reply called dst_confirm, the change happens
next time when new request is sent and dst_neigh_output is called.

2. Remote host is fast enough to reset us again to NUD_STALE
before we change state to ->NUD_PROBE->NUD_REACHABLE.

	To summarize: currently the change to NUD_STALE serves the
purpose to avoid/delay our hwaddr refreshing probes. They are
avoided if protocols indicate progress with the current hwaddr.
Outgoing IP traffic that does not trigger confirmation
from replies (for example TCP ACK calling dst_confirm) or
from applications (MSG_CONFIRM) surely will cause a
switch to NUD_PROBE.

	Now the main question: is reaching a NUD_REACHABLE
state a good enough goal (if we ignore the NUD_STALE in
NUD_DELAY | NUD_PROBE state) or we prefer traffic that does
not provide confirmation indications to use the current
hwaddr based only on indications from received ARP broadcasts
or requests, in which case we avoid our ARP probes. In the
latter case remote hosts do not see fresh probes from us
and we may cycle between NUD_STALE and NUD_DELAY if
such remote packets come more often.

	So, the question is, to avoid probes or to refresh
frequently? Is there a good reason to ignore this NUD_STALE
event in NUD_DELAY | NUD_PROBE state?

> NUD_STALE --> NUD_DELAY -(send req again)-> ... -->
> NUD_REACHABLE

Regards

--
Julian Anastasov <ja@ssi.bg>
