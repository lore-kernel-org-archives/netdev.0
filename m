From: Marc Lehmann <schmorp@schmorp.de>
Subject: Re: Fw: masquerading failure for at least icmp and tcp+sack on amd64
Date: Wed, 7 Sep 2005 22:59:23 +0200
Message-ID: <20050907205923.GA6567@schmorp.de>
References: <20050907052057.09714a4c.akpm@osdl.org>
	<431EDF78.8060505@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <431EDF78.8060505@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 07, 2005 at 02:39:20PM +0200, Patrick McHardy <kaber@trash.net> wrote:
> Andrew Morton wrote:

Thanks for your response!

> >   tcp      6 52 SYN_SENT src=10.0.0.1 dst=129.13.162.95 sport=44320 
> >   dport=80 [UNREPLIED] src=129.13.162.95 dst=84.56.237.68 sport=80 
> >   dport=44320 mark=0 use=1
> 
> It seems ip_conntrack did not like the SYN/ACK and marked it as invalid,
> NAT leaves the packet alone and the firewall resets the connection.
> Please try if loading the ipt_LOG module and executing
> "echo 255 > /proc/sys/net/ipv4/netfilter/ip_conntrack_log_invalid"
> gives more information

I think I have the LOG target compiled into the kernel. After the echo, I got
this within a matter of seconds:

   printk: 614 messages suppressed.
   ip_ct_tcp: bad TCP checksum IN= OUT= SRC=xxxxxxxxxxxx DST=84.56.231.206 LEN=105 TOS=0x00 PREC=0x00 TTL=53 ID=33989 DF PROTO=TCP SPT=119 DPT=41349 SEQ=495763142 ACK=177548929 WINDOW=56677 RES=0x00 ACK PSH URGP=0 OPT (0101080A0986EF9D00E16123) 

This is interesting, as the connection in question seems to work fine (at
least I can download news at 32kb/s, which is the rate limit on the other
side without much more than 32kb/s on my ppp link, so it is weird that
this many packets should have invalid tcp checksum. Maybe this is somehow
related?)

I then tried to create a masqueraded connection and got the expected
symptoms: correctly re-written packet leaves interface, return packet gets
RST.

During that time, I got more of the above messages, but none related to the
test connection.

I then stopped all traffic-generating programs to get an idle link and
retried. Still no log messages from the test conenction.

> >eth0:
> >   19:23:29.928470 IP 10.0.0.1.45611 > 129.13.162.95.80: S 
> >   4113365634:4113365634(0) win 5840 <mss 1460>
> >   19:23:29.942246 IP 129.13.162.95.80 > 10.0.0.1.45611: S 
> >   4161877683:4161877683(0) ack 4113365635 win 5840 <mss 1460>
> >   19:23:29.942313 IP 10.0.0.1.45611 > 129.13.162.95.80: . ack 1 win 5840
> >
> >inet:
> >   19:23:29.928249 IP 84.56.237.68.45611 > 129.13.162.95.80: S 
> >   4113365634:4113365634(0) win 5840 <mss 1452>
> >   19:23:29.942199 IP 129.13.162.95.80 > 84.56.237.68.45611: S 
> >   4161877683:4161877683(0) ack 4113365635 win 5840 <mss 1460>
> >   19:23:29.942332 IP 84.56.237.68.45611 > 129.13.162.95.80: . ack 1 win 
> >   5840
> >
> >However, ICMP still is not masqueraded.
> 
> Please also try this again with logging enabled.

No messages, either.

(As I wrote in another mail), I also found in the meantime that switching
off SACK only results in a correct handshake, further packets might and
usually will cause a RST.

> >Kernels that don't work:
> >
> >   2.6.13-rc7 (compiled with gcc-3.4 and 4.0.2 debian), 2.6.13 (gcc-4.02)
> 
> Can you retest with 2.6.12.5 on 64bit so we can see if it is a new
> problem?

I hope that trying with 2.6.11, and getting the same problem (as I did in
the meantime), is even better than testing 2.6.12.5.

> So far I don't think its related to routed.

The weird thing is that it works on tap, but not on ethernet/ppp. Maybe
the kernel code gets some offset wrong?

-- 
                The choice of a
      -----==-     _GNU_
      ----==-- _       generation     Marc Lehmann
      ---==---(_)__  __ ____  __      pcg@goof.com
      --==---/ / _ \/ // /\ \/ /      http://schmorp.de/
      -=====/_/_//_/\_,_/ /_/\_\      XX11-RIPE
