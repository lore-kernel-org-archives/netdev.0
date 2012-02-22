From: Julian Anastasov <ja@ssi.bg>
Subject: Re: route add default fails with ESRCH?
Date: Wed, 22 Feb 2012 23:27:26 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1202222319150.1603@ja.ssi.bg>
References: <4F3F0158.2020406@fb.com> <4F4541E5.5040700@fb.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Arun Sharma <asharma@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F4541E5.5040700@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 22 Feb 2012, Arun Sharma wrote:

> [ Expanded cc ]
> 
> On 2/17/12 5:39 PM, Arun Sharma wrote:
> > 
> > I've been trying to debug this strange problem with recent 3.2 kernels:
> > 
> > # boot to single user mode
> > # service network start
> > # ifconfig eth0
> > eth0 Link encap:Ethernet HWaddr <blah>
> > inet addr:10.47.46.39 Bcast:10.47.46.255 Mask:255.255.255.0
> > 
> > <Link is up>
> > # strace route add default gw 10.47.46.1
> > ioctl(3, SIOCADDRT, 0x7fff1fd4db80) = -1 ESRCH (No such process)
> 
> I git bisected the problem to this commit:
> 
> commit 3630b7c050d9c3564f143d595339fc06b888d6f3
> Author: David S. Miller <davem@davemloft.net>
> Date: Tue Feb 1 15:15:39 2011 -0800
> 
> ipv4: Remove fib_hash.
> 
> which came in via 2.6.39.
> 
> > If there are any semantic differences found in fib_trie, we should
> > simply fix them.
> 
> Looks like the problem I'm running into falls into this bucket (since it goes
> away if I revert the commit).
> 
> I changed the pr_debug() in fib_trie.c to pr_info() and got some debug output
> (attached).
> 
> Based on the debug info, I think it's this call that's failing with ESRCH:

	Why the subnet is deleted from table main (254) in
the same second ?

	First default route is removed:

[   44.351839] Deleting 00000000/0 tos=0 t=ffff880212b846a0
[   44.351843] entering trie_leaf_remove(ffff880213d120e0)
[   44.351846] In tnode_resize ffff880213d0a5a0 inflate_threshold=50
threshold=25

	Then link route 10.47.46.0/24:

[   44.351852] Deleting 0a2f2e00/24 tos=0 t=ffff880212b846a0
[   44.351855] entering trie_leaf_remove(ffff880211585150)

	Insert tries to find if GW 10.47.46.1 is reachable,
there must be 10.47.46.0/24 in table main but it was
deleted just before adding the IP.

[   69.189627] Insert table=254 00000000/0

> [   69.189627] Insert table=254 00000000/0
> 
> /sbin/route -V
> net-tools 1.60
> route 1.98 (2001-04-15)
> 
> # cat /proc/net/fib_trie

	Where is "Main:" here?

> Local:
>   +-- 0.0.0.0/1 1 0 0
>      +-- 10.47.46.0/24 1 0 0
>         +-- 10.47.46.0/26 1 0 0
>            |-- 10.47.46.0
>               /32 link BROADCAST
>            |-- 10.47.46.39
>               /32 host LOCAL
>         |-- 10.47.46.255
>            /32 link BROADCAST
>      +-- 127.0.0.0/8 1 0 0
>         +-- 127.0.0.0/31 1 0 0
>            |-- 127.0.0.0
>               /32 link BROADCAST
>               /8 host LOCAL
>            |-- 127.0.0.1
>               /32 host LOCAL
>         |-- 127.255.255.255
>            /32 link BROADCAST
> 
> Please let me know if you have any suggestions.

	The only place that returns ESRCH during insert is
net/core/fib_rules.c fib_rules_lookup(). Are you sure that
some daemon is not monitoring your actions and playing
with the ip rules and routes? May be during 'route add'
there are no ip rules and the link route is removed too.
Is the problem some race with such routing daemon?

Regards

--
Julian Anastasov <ja@ssi.bg>
