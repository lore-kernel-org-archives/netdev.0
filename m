From: "Vitaly V. Bursov" <vitalyb@telenet.dn.ua>
Subject: Re: Scaling problem with a lot of AF_PACKET sockets on different
 interfaces
Date: Mon, 10 Jun 2013 09:34:12 +0300
Message-ID: <51B57364.4090601@telenet.dn.ua>
References: <51B1CA50.30702@telenet.dn.ua> <1370608871.5854.64.camel@marge.simpson.net> <51B1DA96.1080303@redhat.com> <51B1EB7D.7060801@telenet.dn.ua> <51B1EF27.9030300@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mike Galbraith <bitbucket@online.de>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51B1EF27.9030300@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

07.06.2013 17:33, Daniel Borkmann =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 06/07/2013 04:17 PM, Vitaly V. Bursov wrote:
>> 07.06.2013 16:05, Daniel Borkmann =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> [...]
>>>>> Ideas are welcome :)
>>>
>>> Probably, that depends on _your scenario_ and/or BPF filter, but wo=
uld it be
>>> an alternative if you have only a few packet sockets (maybe one pin=
ned to each
>>> cpu) and cluster/load-balance them together via packet fanout? (Whe=
re you
>>> bind the socket to ifindex 0, so that you get traffic from all devs=
=2E..) That
>>> would at least avoid that "hot spot", and you could post-process th=
e interface
>>> via sockaddr_ll. But I'd agree that this will not solve the actual =
problem you've
>>> observed. ;-)
>>
>> I was't aware of the ifindex 0 thing, it can help, thanks! Of course=
, if it'll
>> work for me (applications is a custom DHCP server) it'll surely
>> increase the overhead of BPF (I don't need to tap the traffic from a=
ll
>> interfaces), there are vlans, bridges and bonds - likely the server =
will receive
>> same packets multiple times and replies must be sent too...
>> but it still should be faster.
>
> Well, as already said, if you use a fanout socket group, then you won=
't receive the
> _exact_ same packet twice. Rather, packets are balanced by different =
policies among
> your packet sockets in that group. What you could do is to have a (e.=
g.) single BPF
> filter (jitted) for all those sockets that'll let needed packets pass=
 and you can then
> access the interface they came from via sockaddr_ll, which then is fu=
rther processed
> in your fast path (or dropped depending on the iface). There's also a=
 BPF extension
> (BPF_S_ANC_IFINDEX) that lets you load the ifindex of the skb into th=
e BPF accumulator,
> so you could also filter early from there for a range of ifindexes (i=
n combination to
> bind the sockets to index 0). Probably that could work.

Thanks everybody, this should help a lot.

--=20
Vitaly
