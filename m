From: Kyle Moffett <kyle@moffetthome.net>
Subject: Re: iptables very slow after commit 784544739a25c30637397ace5489eeb6e15d7d49
Date: Sun, 12 Apr 2009 01:05:52 -0400
Message-ID: <f73f7ab80904112205x379a7d5n282085d90030f300@mail.gmail.com>
References: <alpine.LFD.2.00.0904101828490.4583@localhost.localdomain>
	 <20090411041533.GB6822@linux.vnet.ibm.com>
	 <alpine.LSU.2.00.0904110657410.26485@fbirervta.pbzchgretzou.qr>
	 <20090410.230016.176733137.davem@davemloft.net>
	 <f73f7ab80904111112n7c95d06ei32eb1f081842ae41@mail.gmail.com>
	 <alpine.DEB.1.10.0904111751430.28893@asgard.lang.hm>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jengelh@medozas.de,
	paulmck@linux.vnet.ibm.com, torvalds@linux-foundation.org,
	mingo@elte.hu, laijs@cn.fujitsu.com, shemminger@vyatta.com,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, kaber@trash.net,
	r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: david@lang.hm
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0904111751430.28893@asgard.lang.hm>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 11, 2009 at 8:54 PM,  <david@lang.hm> wrote:
> On Sat, 11 Apr 2009, Kyle Moffett wrote:
>> Almost all of the standard firewall tools (such as shorewall, etc) a=
re
>> already using iptables-restore command to load firewall rules,
>> primarily because using separate iptables commands was *already* way
>> too slow. =C2=A0There's also the serious race-condition of doing a f=
irewall
>> restart that way where you only have half your rules loaded for a bi=
t.
>> The "iptables" command is fine for fiddling around with the command
>> line and making minor tweaks, but it simply doesn't cut it for
>> large-scale rules.
>
> what are the userspace level tools that I am supposed to use in place=
 of my
> current process? (which is to have a script that 1. stops traffic, 2.
> executes the iptables commands to create the rules that I want, then =
3.
> enables traffic)
>
> iptables-restore only works if you are actually restoring the old set=
 of
> rules. if you need to change the rules that doesn't work.

Not true...  The iptables-restore format is pretty well documented and
not far off the standard command-line argument format.  For instance
the "shorewall" tool does a sort of "compile" of its high-level
firewall language into an input file for the "iptables-restore"
command.

The basic format to atomically load a table is:
*tablename
:CHAINNAME DEFAULTACTION [packets:bytes]
:ANOTHERCHAIN ANOTHERACTION [packets:bytes]
:customchain - [packets:bytes]
-A SOMECHAIN --rule-arguments-here
-A customchain --rule-arguments-here
COMMIT

At the end of this email you can find some sample data cut-n-pasted
from the iptables-restore file from one of my boxes running shorewall.
 The full file is 645 lines but takes at most a second or so to load
once compiled.

You could also do an iptables-save -c on one of your configured
systems to see what various constructions you use look like in the
iptables format.  It's all pretty straightforward.

Cheers,
Kyle Moffett


*raw
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
*nat
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:excl0 - [0:0]
:excl1 - [0:0]
:excl2 - [0:0]
:world_masq - [0:0]
-A POSTROUTING -o world -j world_masq
-A excl0 -d 10.0.0.0/8 -j RETURN
-A excl0 -d 192.168.0.0/16 -j RETURN
-A excl0 -d 172.16.0.0/12 -j RETURN
-A excl0 -j MASQUERADE
-A excl1 -d 10.0.0.0/8 -j RETURN
-A excl1 -d 192.168.0.0/16 -j RETURN
-A excl1 -d 172.16.0.0/12 -j RETURN
-A excl1 -j MASQUERADE
-A excl2 -d 10.0.0.0/8 -j RETURN
-A excl2 -d 192.168.0.0/16 -j RETURN
-A excl2 -d 172.16.0.0/12 -j RETURN
-A excl2 -j MASQUERADE
-A world_masq -s 10.0.0.0/8 -j excl0
-A world_masq -s 172.16.0.0/12 -j excl1
-A world_masq -s 192.168.0.0/16 -j excl2
COMMIT
*mangle
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:fortos - [0:0]
:tcfor - [0:0]
:tcout - [0:0]
:tcpost - [0:0]
:tcpre - [0:0]
-A PREROUTING  -j tcpre
-A FORWARD -j tcfor
-A FORWARD -j fortos
-A OUTPUT  -j tcout
-A POSTROUTING -j tcpost
-A fortos -p 17 -i dmz -s 72.214.41.2 -j TOS --set-tos 16
-A fortos -p 17 -o dmz -d 72.214.41.2 -j TOS --set-tos 16
COMMIT
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT DROP [0:0]
:Drop - [0:0]
:Reject - [0:0]
[...many more lines snipped...]
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
