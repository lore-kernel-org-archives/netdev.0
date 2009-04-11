From: Kyle Moffett <kyle@moffetthome.net>
Subject: Re: iptables very slow after commit 784544739a25c30637397ace5489eeb6e15d7d49
Date: Sat, 11 Apr 2009 14:12:35 -0400
Message-ID: <f73f7ab80904111112n7c95d06ei32eb1f081842ae41@mail.gmail.com>
References: <alpine.LFD.2.00.0904101828490.4583@localhost.localdomain>
	 <20090411041533.GB6822@linux.vnet.ibm.com>
	 <alpine.LSU.2.00.0904110657410.26485@fbirervta.pbzchgretzou.qr>
	 <20090410.230016.176733137.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jengelh@medozas.de, paulmck@linux.vnet.ibm.com,
	torvalds@linux-foundation.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	shemminger@vyatta.com, jeff.chua.linux@gmail.com,
	dada1@cosmosbay.com, kaber@trash.net, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090410.230016.176733137.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 11, 2009 at 2:00 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Jan Engelhardt <jengelh@medozas.de>
> Date: Sat, 11 Apr 2009 07:14:50 +0200 (CEST)
>
>> The fact that `iptables -A` is called a hundred times means you are
>> doing 100 table replacements -- instead of one. And calling
>> synchronize_net at least a 100 times.
>>
>> "Wanna use iptables-restore?"
>
> I want to derail this line of thinking as fast as possible.
>
> This is not an acceptable response to this problem. =C2=A0We made som=
ething
> fundamentally slower by several orders of magnitude.
>
> Therefore, saying "Don't insert your firewall rules like that." is no=
t
> a valid response for this regression.
>
> We really have to fix it or revert.

Let me start by saying that I agree that for most systems this patch
provided a bad performance tradeoff that needs to get fixed.

On the other hand I have certain systems where I would much rather
reduce the per-packet load by a few percent...  even if it increases
the effort to load a new ruleset by many orders of magnitude!!!  Quite
simply the boxes only reboot a few times a year but in-between times
they forward many terabytes of low-latency network traffic.

So... to play devils advocate:

Almost all of the standard firewall tools (such as shorewall, etc) are
already using iptables-restore command to load firewall rules,
primarily because using separate iptables commands was *already* way
too slow.  There's also the serious race-condition of doing a firewall
restart that way where you only have half your rules loaded for a bit.
 The "iptables" command is fine for fiddling around with the command
line and making minor tweaks, but it simply doesn't cut it for
large-scale rules.

I remember when switching from a shell-based shorewall to a perl-based
shorewall.  The time to build my rule lists with the perl-based
version was about 20% of what it had been, but the time to load the
rules into the kernel with iptables-restore was easily 2% or perhaps
less.

=46inally, if you really are loading a couple hundred IPs into a linear
ruleset, you're adding a fair amount of packet latency to each and
every packet that goes through totally independent of iptables load
time.  It would be much better to use ipsets (or similar) because they
load all of the IP ranges into an appropriate tree datastructure with
O(small-constant * log(N) + large-constant * 1) lookup instead of
O(large-constant * N).

Cheers,
Kyle Moffett
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
