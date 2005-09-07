From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: masquerading failure for at least icmp and tcp+sack on amd64
Date: Wed, 07 Sep 2005 23:34:10 +0200
Message-ID: <431F5CD2.8020905@trash.net>
References: <20050907052057.09714a4c.akpm@osdl.org>
	<431EDF78.8060505@trash.net> <20050907205923.GA6567@schmorp.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Marc Lehmann <schmorp@schmorp.de>
In-Reply-To: <20050907205923.GA6567@schmorp.de>
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

Marc Lehmann wrote:
> I think I have the LOG target compiled into the kernel. After the echo, I got
> this within a matter of seconds:
> 
>    printk: 614 messages suppressed.
>    ip_ct_tcp: bad TCP checksum IN= OUT= SRC=xxxxxxxxxxxx DST=84.56.231.206 LEN=105 TOS=0x00 PREC=0x00 TTL=53 ID=33989 DF PROTO=TCP SPT=119 DPT=41349 SEQ=495763142 ACK=177548929 WINDOW=56677 RES=0x00 ACK PSH URGP=0 OPT (0101080A0986EF9D00E16123) 

Interesting .. if this isn't real there is most likely some problem with
HW checksumming in netfilter. What does ethtool -k <dev> show?

> This is interesting, as the connection in question seems to work fine (at
> least I can download news at 32kb/s, which is the rate limit on the other
> side without much more than 32kb/s on my ppp link, so it is weird that
> this many packets should have invalid tcp checksum. Maybe this is somehow
> related?)
> 
> I then tried to create a masqueraded connection and got the expected
> symptoms: correctly re-written packet leaves interface, return packet gets
> RST.
> 
> During that time, I got more of the above messages, but none related to the
> test connection.

Could be because of net_ratelimit() message surpressing.

> (As I wrote in another mail), I also found in the meantime that switching
> off SACK only results in a correct handshake, further packets might and
> usually will cause a RST.

I'm not aware of any special handling for SACKs that would make it fail,
especially considering that ICMP also fails, but I'm going to look into
it.

>>>Kernels that don't work:
>>>
>>>  2.6.13-rc7 (compiled with gcc-3.4 and 4.0.2 debian), 2.6.13 (gcc-4.02)
>>
>>Can you retest with 2.6.12.5 on 64bit so we can see if it is a new
>>problem?
> 
> 
> I hope that trying with 2.6.11, and getting the same problem (as I did in
> the meantime), is even better than testing 2.6.12.5.

Thanks, this is even more evidence for HW checksumming problems, these
existed for a long time.

>>So far I don't think its related to routed.
> 
> The weird thing is that it works on tap, but not on ethernet/ppp. Maybe
> the kernel code gets some offset wrong?

Another sign pointing to HW checksumming ..
