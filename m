From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Mon, 26 May 2008 17:43:09 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805261724280.16829@wrl-59.cs.helsinki.fi>
References: <20080526115628.GA31316@elte.hu> <Pine.LNX.4.64.0805261550340.16829@wrl-59.cs.helsinki.fi>
 <20080526135940.GB24870@elte.hu> <20080526141252.GA31352@elte.hu>
 <20080526141713.GA5771@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757006AbYEZOnZ@vger.kernel.org>
In-Reply-To: <20080526141713.GA5771@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 26 May 2008, Ingo Molnar wrote:

> 
> * Ingo Molnar <mingo@elte.hu> wrote:
> 
> > i also ran this for 15 minutes:
> > 
> >   [root@europe ~]# tcpdump src and dst 10.0.1.15 -n
> >   tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
> >   listening on eth0, link-type EN10MB (Ethernet), capture size 96 bytes
> > 
> > but there was no output at all - i.e. TCP has not attempted to do 
> > anything to these connections.
> 
> ... which is not surprising as it traced eth0 ;-) [10.0.1.15 is the IP 
> of the box and routes back to loopback]

Thanks, it's much easier to diagnose right with symptoms that are based
on reality :-).

> with the proper tcpdump it gave:
> 
> [root@europe ~]# tcpdump -i lo
> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
> listening on lo, link-type EN10MB (Ethernet), capture size 96 bytes
> 16:15:05.260000 IP europe.37198 > europe.distcc: . ack 2022529163 win 257 <nop,nop,timestamp 209526 197526>
> 16:15:05.260000 IP europe.distcc > europe.37198: . ack 1 win 0 <nop,nop,timestamp 209526 7020>
> 
> hm, a window of 257 and zero, is that right?

...Yes, though that 257 is lacks the effect of window scaling (and it's 
mostly irrelevant anyway since the problem occurs in opposite dir). The 
sender is using just window probes (/proc/net/tcp shows that too), that's 
why you see them occassionally. So the main problem seems to be that 
receiver doesn't read, rest is just a consequence of that (from TCP POV). 
I doubt that tcp_frto will affect to that (and I read what a stale 
retrans_stamp could do, it would hard cause any troubles, and those minor 
things wouldn't realize in your setup anyway).

I'll take a look into pre -rc1 changes now but it may well be beoynd
what I'm able to figure out.

-- 
 i.
