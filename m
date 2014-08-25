From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V4 3/8] namespaces: expose ns instance serial numbers
 in proc
Date: Mon, 25 Aug 2014 17:43:31 +0200
Message-ID: <53FB59A3.5030804@6wind.com>
References: <cover.1408581429.git.rgb@redhat.com> <cd6cd0622ce677b639afae18a69ff79c72490bab.1408581429.git.rgb@redhat.com> <CALCETrUnzG1V8w+H9ctAJP+Hvo8LQax=dhLG4bBpBKmVi+C1cQ@mail.gmail.com> <20140822015803.GG20529@madcap2.tricolour.ca> <CALCETrUkFD0iNi1SV_6ypN5Kf4GYybT5tzjRjRQuLzT9iBnQAg@mail.gmail.com> <53FB3A86.2060203@6wind.com> <CALCETrW1Lv0qeccMjNHSEzgtiaNN3NgJVR1dFjjR_dw5KVVnqA@mail.gmail.com>
Reply-To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrW1Lv0qeccMjNHSEzgtiaNN3NgJVR1dFjjR_dw5KVVnqA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 25/08/2014 16:04, Andy Lutomirski a =C3=A9crit :
> On Aug 25, 2014 6:30 AM, "Nicolas Dichtel" <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org=
> wrote:
>>> CRIU wants to save the complete state of a namespace and then resto=
re
>>> it.  For that to work, any information exposed to things in the
>>> namespace *cannot* be globally unique or unique per boot, since CRI=
U
>>> needs to arrange for that information to match whatever it was when
>>> CRIU saved it.
>>
>> How are ifindex of network devices managed? These ifindexes are uniq=
ue per boot,
>> thus can change depending on the order in which netdev are created.
>> These ifindexes are unique per boot and exposed to userspace ...
>>
>
> This does not appear to be true.
>
> $ sudo unshare --net
> # ip link add veth0 type veth peer name veth1
> # ip link
> 1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group =
default
>      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> 2: veth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
> DEFAULT group default qlen 1000
>      link/ether 06:0d:59:c7:a6:a8 brd ff:ff:ff:ff:ff:ff
> 3: veth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
> DEFAULT group default qlen 1000
>      link/ether b2:5c:8b:f2:12:28 brd ff:ff:ff:ff:ff:ff
> # logout
> $ ip link
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
>      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> 3: em1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast
> state DOWN qlen 1000
>
I've probably misunderstood what you're trying to say. ifindexes are un=
ique per
boot and per netns. These ifindexes depend on the interface creation or=
der:

$ ip netns add 1
$ ip link set eth1 netns 1
$ ip netns exec 1 ip link add veth0 type veth peer name veth1
$ ip netns exec 1 ip link
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group de=
fault
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: veth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEF=
AULT=20
group default qlen 1000
     link/ether 9a:a0:89:99:a0:3c brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFA=
ULT group=20
default qlen 1000
     link/ether 52:54:00:12:34:57 brd ff:ff:ff:ff:ff:ff
4: veth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEF=
AULT=20
group default qlen 1000
     link/ether 96:86:44:49:ce:a8 brd ff:ff:ff:ff:ff:ff
$ ip netns del 1
$ ip netns add 1
$ ip netns exec 1 ip link add veth0 type veth peer name veth1
$ ip link set eth1 netns 1
$ ip netns exec 1 ip link
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group de=
fault
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: veth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEF=
AULT=20
group default qlen 1000
     link/ether 86:92:90:01:32:6b brd ff:ff:ff:ff:ff:ff
3: veth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEF=
AULT=20
group default qlen 1000
     link/ether ae:8b:d2:71:48:a2 brd ff:ff:ff:ff:ff:ff
4: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFA=
ULT group=20
default qlen 1000
     link/ether 52:54:00:12:34:57 brd ff:ff:ff:ff:ff:ff

Note: when an interface is moved to another netns, the ifindex is kept =
if
possible, else another ifindex is chosen.
I will dig a bit to understand how CRIU save these netns informations.

>>
>>>
>>> Also, I think that code running in a namespace has no business even
>>> knowing a unique identity of that namespace from the perspective of
>>> the host.
>>
>> Another scenario is when you have virtual network devices across two=
 netns. You
>> need to identify the peer netns to have a netlink message which is f=
ully interpretable by the userspace.
>
> Let me try again, with emphasis in the right place.
>
> I think that *code running in a namespace* has no business even
> knowing a unique identity of *that namespace* from the perspective of
> the host.
>
> In your example, if there's a veth device between netns A and netns B=
,
> then code *in netns A* has no business knowing the identity of its
> veth peer if its peer (B) is a sibling or ancestor.  It also IMO has
> no business knowing the identity of its own netns (A) other than as
> "my netns".
I do not agree (see the example below).

>
> If A and B are siblings, then their parent needs to know where that
> veth device goes, but I think this is already the case to a sufficien=
t
> extent today.
I'm not aware of a hierarchy between netns. A daemon should be able to
got the full network configuration, even if it's started when this conf=
iguration
is already applied, ie even if it doesn't know what happen before it st=
arts.

>
> I feel like this discussion is falling into a common trap of new API
> discussions.  Can one of you who wants this API please articulate,
> with a reasonably precise example, what it is that you want to do, wh=
y
> you can't easily do it already, and how this API helps?  I currently
> understand how the API creates problems, but I don't understand how i=
t
> solves any problems, and I will NAK it (and I suspect that Eric will,
> too, which is pretty much fatal) unless that changes.
What I'm trying to solve is to have full info in netlink messages sent =
by the
kernel, thus beeing able to identify a peer netns (and this is close fr=
om what
audit guys are trying to have). Theorically, messages sent by the kerne=
l can be
reused as is to have the same configuration. This is not the case with =
x-netns
devices. Here is an example, with ip tunnels:

$ ip netns add 1
$ ip link add ipip1 type ipip remote 10.16.0.121 local 10.16.0.249 dev =
eth0
$ ip -d link ls ipip1
8: ipip1@eth0: <POINTOPOINT,NOARP> mtu 1480 qdisc noop state DOWN mode =
DEFAULT=20
group default
     link/ipip 10.16.0.249 peer 10.16.0.121 promiscuity 0
     ipip remote 10.16.0.121 local 10.16.0.249 dev eth0 ttl inherit pmt=
udisc
$ ip link set ipip1 netns 1
$ ip netns exec 1 ip -d link ls ipip1
8: ipip1@tunl0: <POINTOPOINT,NOARP,M-DOWN> mtu 1480 qdisc noop state DO=
WN mode=20
DEFAULT group default
     link/ipip 10.16.0.249 peer 10.16.0.121 promiscuity 0
     ipip remote 10.16.0.121 local 10.16.0.249 dev tunl0 ttl inherit pm=
tudisc

Now informations got with 'ip link' are wrong and incomplete:
  - the link dev is now tunl0 instead of eth0, because we only got an i=
findex
    from the kernel without any netns informations.
  - the encapsulation addresses are not part of this netns but the user=
 doesn't
    known that (still because netns info is missing). These IPv4 addres=
ses may
    exist into this netns.
  - it's not possible to create the same netdevice with these infos.


Hope it's more clear now.


Regards,
Nicolas
