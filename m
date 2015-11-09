From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [RFC PATCH net-next v2 0/8] openvswitch: NAT support.
Date: Mon, 9 Nov 2015 15:48:19 -0800
Message-ID: <A8FC05BD-6124-482F-A817-62814771B66B@ovn.org>
References: <1446854768-38299-1-git-send-email-jrajahalme@nicira.com> <20151109133122.GC8098@macbook.localdomain>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, dev@openvswitch.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20151109133122.GC8098@macbook.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Resending as plain text]

> On Nov 9, 2015, at 5:31 AM, Patrick McHardy <kaber@trash.net> wrote:
>=20
> On 06.11, Jarno Rajahalme wrote:
>> This series adds NAT support to openvswitch kernel module.  A few
>> changes are needed to the netfilter code to facilitate this (patches
>> 1-3/8).  Patches 4-7 make the openvswitch kernel module ready for th=
e
>> patch 8 that adds the NAT support for calling into netfilter NAT cod=
e
>> from the openvswitch conntrack action.
>=20
> I'm missing some high level description, especially how it is invoked=
, how
> it makes sure expectations of the NAT code about its invocation are m=
et
> (it is my understanding that OVS simply invokes this based on actions
> specified by the user) and how it interacts with the remaining netfil=
ter
> features.
>=20

The corresponding OVS userspace patches contain the new test cases for =
the NAT features (http://openvswitch.org/pipermail/dev/2015-November/06=
1920.html) in tests/system-traffic.at. I=E2=80=99ll walk through two of=
 them below.

Test case: conntrack - simple SNAT

In these tests ports 1 and 2 are in different namespaces. The flow tabl=
e below allows all IPv4 traffic between port 1 to port 2, but IP connec=
tions from port 1 to port 2 are source NATted:

    in_port=3D1,ip,action=3Dct(commit,zone=3D1,nat(src=3D10.1.1.240-10.=
1.1.255)),2
    in_port=3D2,ct_state=3D-trk,ip,action=3Dct(table=3D0,zone=3D1,nat)
    in_port=3D2,ct_state=3D+trk,ct_zone=3D1,ip,action=3D1

This flow table matches all IPv4 traffic from port 1, runs them through=
 conntrack in zone 1 and NATs them. The NAT is initialized to do source=
 IP mapping to the given range for the first packet of each connection,=
 after which the new connection is committed. For further packets of al=
ready tracked connections NAT is done according to the connection state=
 and the commit is a no-op. Each packet that is not flagged as a drop b=
y the CT action is forwarded to port 2. The CT action does an implicit =
fragmentation reassembly, so that only complete packets are run through=
 conntrack. Reassembled packets are re-fragmented on output.

The IPv4 traffic coming from port 2 is first matched for the non-tracke=
d state (-trk), which means that the packet has not been through a CT a=
ction yet. Such traffic is run trough the conntrack in zone 1 and all p=
ackets associated with a NATted connection are NATted also in the retur=
n direction. After the packet has been through conntrack it is recircul=
ated back to table 0 (which is the default table, so all the rules abov=
e are in table 0). The CT action changes the =E2=80=98trk=E2=80=99 flag=
 to being set, so the packets after recirculation match the third rule =
(+trk), and the packet is output on port 1. Since also the ct_zone is m=
atched, only packets that were actually tracked by conntrack can match =
the 3rd rule and output to 1.

I=E2=80=99m skipped the rules for ARP handling in this walkthrough, but=
 the test case has rules to match on the ARP request on the NATted addr=
ess and reply to it.

The above is verified with a HTTP request and a subsequent conntrack en=
try listing in the test case:

    dnl HTTP requests from p0->p1 should work fine.
    NETNS_DAEMONIZE([at_ns1], [[$PYTHON $srcdir/test-l7.py]], [http0.pi=
d])
    NS_CHECK_EXEC([at_ns0], [wget 10.1.1.2 -t 5 -T 1 --retry-connrefuse=
d -v -o wget0.log])

    AT_CHECK([conntrack -L 2>&1 | FORMAT_CT(10.1.1.2) | sed -e 's/dst=3D=
10.1.1.2[[45]][[0-9]]/dst=3D10.1.1.2XX/'], [0], [dnl
    TIME_WAIT src=3D10.1.1.1 dst=3D10.1.1.2 sport=3D<cleared> dport=3D<=
cleared> src=3D10.1.1.2 dst=3D10.1.1.2XX sport=3D<cleared> dport=3D<cle=
ared> [[ASSURED]] mark=3D0 zone=3D1 use=3D1
    ])


As a second example, I=E2=80=99ll walk through a test case of NAT with =
=46TP on IPv6:

As before, ports 1 (p0) and 2 (p1) reside in different namespaces (=E2=80=
=98at_ns0=E2=80=99 and =E2=80=98at_ns1=E2=80=99, respectively). A stati=
c neighbor cache entry for the NATted address is created in at_ns1. In =
a more realistic scenario a controller would need to implement a ND pro=
xy instead:

    ADD_VETH(p0, at_ns0, br0, "fc00::1/96")
    NS_CHECK_EXEC([at_ns0], [ip link set dev p0 address 80:88:88:88:88:=
88])
    ADD_VETH(p1, at_ns1, br0, "fc00::2/96")
    dnl Would be nice if NAT could translate neighbor discovery message=
s, too.
    NS_CHECK_EXEC([at_ns1], [ip -6 neigh add fc00::240 lladdr 80:88:88:=
88:88:88 dev p1])


The OpenFlow rules are split into two tables (table 0 and table 1).

Table 0 tracks all IPv6 traffic and drops all other traffic. Packets ar=
e recirculated to table 1 after conntrack. Existing connections are NAT=
ted before recirculation:

    table=3D0 priority=3D10 ip6, action=3Dct(nat,table=3D1)
    table=3D0 priority=3D0 action=3Ddrop

Table 1:

=46TP control connections from the =E2=80=9Cprivate=E2=80=9D address to=
 port 21 are output to port 1 after being tracked, NATted, and committe=
d (=3D=3D confirmed).

    table=3D1 in_port=3D1 ct_state=3D+new tcp6 ipv6_src=3Dfc00::1 tp_ds=
t=3D21  action=3Dct(alg=3Dftp,commit,nat(src=3Dfc00::240)),2

The matches on the source/dest IP address below are not really needed, =
but in the test case they are to make sure the NATting actually happens=
=2E

Related TCP connections to the reverse direction are NATted, committed =
and output to port 1:

    table=3D1 in_port=3D2 ct_state=3D+new+rel tcp6 ipv6_dst=3Dfc00::240=
 action=3Dct(commit,nat),1

Packets on established TCP connections are allowed both ways (the CT ac=
tion in table 0 NATted these before recirculation, so we see the mapped=
 address going from port 1 to port 2, and the reverse-mapped (=3D=3D or=
iginal) address on return traffic):

    table=3D1 in_port=3D1 ct_state=3D+est tcp6 ipv6_src=3Dfc00::240   a=
ction=3D2
    table=3D1 in_port=3D2 ct_state=3D+est tcp6 ipv6_dst=3Dfc00::1     a=
ction=3D1=20

We pass icmp6 packets both ways:

    table=3D1 priority=3D100 in_port=3D1 icmp6, action=3D2
    table=3D1 priority=3D100 in_port=3D2 icmp6, action=3D1

Everything else is dropped:

    table=3D1 priority=3D0, action=3Ddrop

=46unctionality is verified with a Python FTP server in at_ns1 and wget=
 to it from at_ns0:

    NETNS_DAEMONIZE([at_ns1], [[$PYTHON $srcdir/test-l7.py ftp]], [ftp0=
=2Epid])

    dnl FTP requests from p0->p1 should work fine.
    NS_CHECK_EXEC([at_ns0], [wget=20
ftp://[[fc00::2
]] -6 --no-passive-ftp -t 3 -T 1 --retry-connrefused -v --server-respon=
se --no-proxy --no-remove-listing -o wget0.log -d])

Both the control connection and the data connection were NATted:

    AT_CHECK([conntrack -L -f ipv6 2>&1 | FORMAT_CT(fc00::2) | grep -v =
"FIN" | grep -v "CLOSE"], [0], [dnl
    TIME_WAIT src=3Dfc00::1 dst=3Dfc00::2 sport=3D<cleared> dport=3D<cl=
eared> src=3Dfc00::2 dst=3Dfc00::240 sport=3D<cleared> dport=3D<cleared=
> [[ASSURED]] mark=3D0 helper=3Dftp use=3D2
    TIME_WAIT src=3Dfc00::2 dst=3Dfc00::240 sport=3D<cleared> dport=3D<=
cleared> src=3Dfc00::1 dst=3Dfc00::2 sport=3D<cleared> dport=3D<cleared=
> [[ASSURED]] mark=3D0 use=3D1
    ])

The flow tables in the test cases are OpenFlow tables, which are transl=
ated to kernel flows by ovs-vswitchd. I have included the relevant kern=
el datapath flows generated in the IPv6 NAT test case above below for y=
our reference. Please note that the kernel port numbers are different f=
rom the OpenFlow port numbers, as each bridge has it=E2=80=99s own rang=
e of OpenFlow port numbers, but they all share the same kernel datapath=
=2E In this case OpenFlow port 1 is kernel port 2, and OpenFlow port 2 =
is kernel port 3. Kernel flows are all in the same table and they have =
no priorities (so they should have mutually exclusive matches). Recircu=
lation IDs are allocated on-demand, here the recirculation ID 1 deals w=
ith traffic to the original direction and 2 to the return direction (re=
circ_id(0) designates no recirculation). ovs_vswitchd always exact matc=
hes IP frag, so since the test traffic had no fragments, you=E2=80=99ll=
 see (frag=3Dno) in each flow below. Also, the packet that causes the f=
low to be created is executed independently (but with the same actions)=
 of the newly created flow, so the kernel datapath flow counts do not r=
eflect the first packet (OpenFlow counters do), this explains 0 counts =
on some flows below:

    recirc_id(0),in_port(2),eth_type(0x86dd),ipv6(frag=3Dno), packets:2=
8, bytes:2541, used:0.048s, flags:SFPR., actions:ct(nat),recirc(0x1)
    recirc_id(0x1),in_port(2),ct_state(+new),eth_type(0x86dd),ipv6(src=3D=
fc00::1,proto=3D6,frag=3Dno),tcp(dst=3D21), packets:1, bytes:94, used:0=
=2E072s, flags:S, actions:ct(commit,helper=3Dftp,nat(src=3Dfc00::240)),=
3
    recirc_id(0x1),in_port(2),ct_state(-new+est+rel),eth_type(0x86dd),i=
pv6(src=3Dfc00::240,proto=3D6,frag=3Dno), packets:4, bytes:344, used:0.=
048s, flags:F., actions:3
    recirc_id(0x1),in_port(2),ct_state(-new+est-rel),eth_type(0x86dd),i=
pv6(src=3Dfc00::240,proto=3D6,frag=3Dno), packets:12, bytes:1145, used:=
0.048s, flags:FP., actions:3

    recirc_id(0),in_port(3),eth_type(0x86dd),ipv6(frag=3Dno), packets:2=
6, bytes:4939, used:0.048s, flags:SFP., actions:ct(nat),recirc(0x2)
    recirc_id(0x2),in_port(3),ct_state(+new+rel),eth_type(0x86dd),ipv6(=
dst=3Dfc00::240,proto=3D6,frag=3Dno), packets:0, bytes:0, used:never, a=
ctions:ct(commit,nat),2
    recirc_id(0x2),in_port(3),ct_state(-new+est-rel),eth_type(0x86dd),i=
pv6(dst=3Dfc00::1,proto=3D6,frag=3Dno), packets:12, bytes:1323, used:0.=
048s, flags:SFP., actions:2
    recirc_id(0x2),in_port(3),ct_state(-new+est+rel),eth_type(0x86dd),i=
pv6(dst=3Dfc00::1,proto=3D6,frag=3Dno), packets:3, bytes:1113, used:0.0=
48s, flags:FP., actions:2


The generated matches depend on the order of processing of rules in the=
 OpenFlow tables, which can be influenced by specifying rule priorities=
 to OpenFlow rules. For example, with a different set of priorities the=
 datapath rules become (In this test run the first IP (ICMPv6) packet w=
as received from at_ns1, so the recirc_ids are reversed from above, ICM=
Pv6 flows not included here.):

    recirc_id(0),in_port(2),eth_type(0x86dd),ipv6(frag=3Dno), packets:2=
7, bytes:2455, used:0.040s, flags:SFPR., actions:ct(nat),recirc(0x2)
    recirc_id(0x2),in_port(2),ct_state(+est),eth_type(0x86dd),ipv6(src=3D=
fc00::240,proto=3D6,frag=3Dno), packets:16, bytes:1497, used:0.040s, fl=
ags:SFP., actions:3
    recirc_id(0x2),in_port(2),ct_state(+new-est),eth_type(0x86dd),ipv6(=
src=3Dfc00::1,proto=3D6,frag=3Dno),tcp(dst=3D21), packets:1, bytes:94, =
used:0.108s, flags:S, actions:ct(commit,helper=3Dftp,nat(src=3Dfc00::24=
0)),3

    recirc_id(0),in_port(3),eth_type(0x86dd),ipv6(frag=3Dno), packets:2=
8, bytes:5111, used:0.040s, flags:SFP., actions:ct(nat),recirc(0x1)
    recirc_id(0x1),in_port(3),ct_state(+est),eth_type(0x86dd),ipv6(dst=3D=
fc00::1,proto=3D6,frag=3Dno), packets:19, bytes:4281, used:0.040s, flag=
s:SFP., actions:2
    recirc_id(0x1),in_port(3),ct_state(+new-est+rel),eth_type(0x86dd),i=
pv6(dst=3Dfc00::240,proto=3D6,frag=3Dno), packets:0, bytes:0, used:neve=
r, actions:ct(commit,nat),2

Hope this helps,

  Jarno

>> Jarno Rajahalme (8):
>>  netfilter: Remove IP_CT_NEW_REPLY definition.
>>  netfilter: Factor out nf_ct_get_info().
>>  netfilter: Allow calling into nat helper without skb_dst.
>>  openvswitch: Update the CT state key only after nf_conntrack_in().
>>  openvswitch: Find existing conntrack entry after upcall.
>>  openvswitch: Handle NF_REPEAT in conntrack action.
>>  openvswitch: Delay conntrack helper call for new connections.
>>  openvswitch: Interface with NAT.
>>=20
>> include/net/netfilter/nf_conntrack.h               |  15 +
>> include/uapi/linux/netfilter/nf_conntrack_common.h |  12 +-
>> include/uapi/linux/openvswitch.h                   |  47 ++
>> net/ipv4/netfilter/nf_nat_l3proto_ipv4.c           |  29 +-
>> net/ipv6/netfilter/nf_nat_l3proto_ipv6.c           |  29 +-
>> net/netfilter/nf_conntrack_core.c                  |  22 +-
>> net/openvswitch/conntrack.c                        | 632 +++++++++++=
++++++++--
>> net/openvswitch/conntrack.h                        |   3 +-
>> 8 files changed, 686 insertions(+), 103 deletions(-)
>>=20
>> --=20
>> 2.1.4
>>=20
>> --
>> To unsubscribe from this list: send the line "unsubscribe netfilter-=
devel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
