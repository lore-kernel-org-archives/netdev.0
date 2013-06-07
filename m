From: "Vitaly V. Bursov" <vitalyb@telenet.dn.ua>
Subject: Re: Scaling problem with a lot of AF_PACKET sockets on different
 interfaces
Date: Fri, 07 Jun 2013 17:17:33 +0300
Message-ID: <51B1EB7D.7060801@telenet.dn.ua>
References: <51B1CA50.30702@telenet.dn.ua> <1370608871.5854.64.camel@marge.simpson.net> <51B1DA96.1080303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mike Galbraith <bitbucket@online.de>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51B1DA96.1080303@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

07.06.2013 16:05, Daniel Borkmann =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 06/07/2013 02:41 PM, Mike Galbraith wrote:
>> (CC's net-fu dojo)
>>
>> On Fri, 2013-06-07 at 14:56 +0300, Vitaly V. Bursov wrote:
>>> Hello,
>>>
>>> I have a Linux router with a lot of interfaces (hundreds or
>>> thousands of VLANs) and an application that creates AF_PACKET
>>> socket per interface and bind()s sockets to interfaces.
>>>
>>> Each socket has attached BPF filter too.
>>>
>>> The problem is observed on linux-3.8.13, but as far I can see
>>> from the source the latest version has alike behavior.
>>>
>>> I noticed that box has strange performance problems with
>>> most of the CPU time spent in __netif_receive_skb:
>>>    86.15%  [k] __netif_receive_skb
>>>     1.41%  [k] _raw_spin_lock
>>>     1.09%  [k] fib_table_lookup
>>>     0.99%  [k] local_bh_enable_ip
>>>
>>> and this the assembly with the "hot spot":
>>>          =E2=94=82       shr    $0x8,%r15w
>>>          =E2=94=82       and    $0xf,%r15d
>>>     0.00 =E2=94=82       shl    $0x4,%r15
>>>          =E2=94=82       add    $0xffffffff8165ec80,%r15
>>>          =E2=94=82       mov    (%r15),%rax
>>>     0.09 =E2=94=82       mov    %rax,0x28(%rsp)
>>>          =E2=94=82       mov    0x28(%rsp),%rbp
>>>     0.01 =E2=94=82       sub    $0x28,%rbp
>>>          =E2=94=82       jmp    5c7
>>>     1.72 =E2=94=825b0:   mov    0x28(%rbp),%rax
>>>     0.05 =E2=94=82       mov    0x18(%rsp),%rbx
>>>     0.00 =E2=94=82       mov    %rax,0x28(%rsp)
>>>     0.03 =E2=94=82       mov    0x28(%rsp),%rbp
>>>     5.67 =E2=94=82       sub    $0x28,%rbp
>>>     1.71 =E2=94=825c7:   lea    0x28(%rbp),%rax
>>>     1.73 =E2=94=82       cmp    %r15,%rax
>>>          =E2=94=82       je     640
>>>     1.74 =E2=94=82       cmp    %r14w,0x0(%rbp)
>>>          =E2=94=82       jne    5b0
>>>    81.36 =E2=94=82       mov    0x8(%rbp),%rax
>>>     2.74 =E2=94=82       cmp    %rax,%r8
>>>          =E2=94=82       je     5eb
>>>     1.37 =E2=94=82       cmp    0x20(%rbx),%rax
>>>          =E2=94=82       je     5eb
>>>     1.39 =E2=94=82       cmp    %r13,%rax
>>>          =E2=94=82       jne    5b0
>>>     0.04 =E2=94=825eb:   test   %r12,%r12
>>>     0.04 =E2=94=82       je     6f4
>>>          =E2=94=82       mov    0xc0(%rbx),%eax
>>>          =E2=94=82       mov    0xc8(%rbx),%rdx
>>>          =E2=94=82       testb  $0x8,0x1(%rdx,%rax,1)
>>>          =E2=94=82       jne    6d5
>>>
>>> This corresponds to:
>>>
>>> net/core/dev.c:
>>>           type =3D skb->protocol;
>>>           list_for_each_entry_rcu(ptype,
>>>                           &ptype_base[ntohs(type) & PTYPE_HASH_MASK=
], list) {
>>>                   if (ptype->type =3D=3D type &&
>>>                       (ptype->dev =3D=3D null_or_dev || ptype->dev =
=3D=3D skb->dev ||
>>>                        ptype->dev =3D=3D orig_dev)) {
>>>                           if (pt_prev)
>>>                                   ret =3D deliver_skb(skb, pt_prev,=
 orig_dev);
>>>                           pt_prev =3D ptype;
>>>                   }
>>>           }
>>>
>>> Which works perfectly OK until there are a lot of AF_PACKET sockets=
, since
>>> the socket adds a protocol to ptype list:
>>>
>>> # cat /proc/net/ptype
>>> Type Device      Function
>>> 0800 eth2.1989 packet_rcv+0x0/0x400
>>> 0800 eth2.1987 packet_rcv+0x0/0x400
>>> 0800 eth2.1986 packet_rcv+0x0/0x400
>>> 0800 eth2.1990 packet_rcv+0x0/0x400
>>> 0800 eth2.1995 packet_rcv+0x0/0x400
>>> 0800 eth2.1997 packet_rcv+0x0/0x400
>>> .......
>>> 0800 eth2.1004 packet_rcv+0x0/0x400
>>> 0800          ip_rcv+0x0/0x310
>>> 0011          llc_rcv+0x0/0x3a0
>>> 0004          llc_rcv+0x0/0x3a0
>>> 0806          arp_rcv+0x0/0x150
>>>
>>> And this obviously results in a huge performance penalty.
>>>
>>> ptype_all, by the looks, should be the same.
>>>
>>> Probably one way to fix this it to perform interface name matching =
in
>>> af_packet handler, but there could be other cases, other protocols.
>>>
>>> Ideas are welcome :)
>
> Probably, that depends on _your scenario_ and/or BPF filter, but woul=
d it be
> an alternative if you have only a few packet sockets (maybe one pinne=
d to each
> cpu) and cluster/load-balance them together via packet fanout? (Where=
 you
> bind the socket to ifindex 0, so that you get traffic from all devs..=
=2E) That
> would at least avoid that "hot spot", and you could post-process the =
interface
> via sockaddr_ll. But I'd agree that this will not solve the actual pr=
oblem you've
> observed. ;-)

I was't aware of the ifindex 0 thing, it can help, thanks! Of course, i=
f it'll
work for me (applications is a custom DHCP server) it'll surely
increase the overhead of BPF (I don't need to tap the traffic from all
interfaces), there are vlans, bridges and bonds - likely the server wil=
l receive
same packets multiple times and replies must be sent too...
but it still should be faster.

I just checked isc-dhcpd-V3.1.3 running on multiple interfaces
(another system with 2.6.32):
$ cat /proc/net/ptype
Type Device      Function
ALL  eth0     packet_rcv_spkt+0x0/0x190
ALL  eth0.10  packet_rcv_spkt+0x0/0x190
ALL  eth0.11  packet_rcv_spkt+0x0/0x190
=2E...

As I understand, it'll hit this code:
         list_for_each_entry_rcu(ptype, &ptype_all, list) {
                 if (!ptype->dev || ptype->dev =3D=3D skb->dev) {
                         if (pt_prev)
                                 ret =3D deliver_skb(skb, pt_prev, orig=
_dev);
                         pt_prev =3D ptype;
                 }
         }
which scales the same.

Thanks.
