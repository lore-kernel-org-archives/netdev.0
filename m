From: =?UTF-8?Q?Fredrik_Markstr=C3=B6m?= <fredrik.markstrom@gmail.com>
Subject: Re: [PATCH v2 1/2] net: Added mtu parameter to
 dev_forward_skb calls
Date: Fri, 12 May 2017 14:48:24 +0200
Message-ID: <CAKdL+dReaXk1Bb6=Nb=5YgpxxcJCXc0C0+F+oozvOA_=beSmng@mail.gmail.com>
References: <20170511134629.139528-1-fredrik.markstrom@gmail.com>
	<20170511134629.139528-2-fredrik.markstrom@gmail.com>
	<20170511090132.79fdbf12@xeon-e3>
	<CAKdL+dS_-UiHA5tr7zP-5LtwDd0aXpZq5tpMYf9kr7hu2SwdGQ@mail.gmail.com>
	<08B3205A-8856-49B6-B806-7BD026D92D33@inf-net.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Teco Boot <teco@inf-net.nl>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <08B3205A-8856-49B6-B806-7BD026D92D33@inf-net.nl>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, May 12, 2017 at 10:05 AM, Teco Boot <teco@inf-net.nl> wrote:
> IP MTU and L2 MTU are different animals.
>
> IMHO IP MTU is for fragmentation at sender of a link. There is no need dr=
opping IP packets at receiver with size > configured IP MTU. IP packets wit=
h size > receiver L2 MTU will be dropped at sub-IP layer.
>
First, thanks for putting words on the different MTU:s (L2 vs IP MTU)

I agree and don't understand why we are dropping packets due to
receiver IP MTU at all and would not mind removing that test
altogether, at least for veth.

/Fredrik


> For this patch: if veth has some notion on L2 MTU (e.g. buffer size limit=
s), there has to be checks for it. I don't know why configuring MRU helps, =
more config, more mistakes. If there is no need for dropping the packet: do=
n't.
>
> Teco
>
>
>> Op 11 mei 2017, om 21:10 heeft Fredrik Markstr=C3=B6m <fredrik.markstrom=
@gmail.com> het volgende geschreven:
>>
>> On Thu, May 11, 2017 at 6:01 PM, Stephen Hemminger
>> <stephen@networkplumber.org> wrote:
>>> On Thu, 11 May 2017 15:46:27 +0200
>>> Fredrik Markstrom <fredrik.markstrom@gmail.com> wrote:
>>>
>>>> From: Fredrik Markstr=C3=B6m <fredrik.markstrom@gmail.com>
>>>>
>>>> is_skb_forwardable() currently checks if the packet size is <=3D mtu o=
f
>>>> the receiving interface. This is not consistent with most of the hardw=
are
>>>> ethernet drivers that happily receives packets larger then MTU.
>>>
>>> Wrong.
>>
>> What is "Wrong" ? I was initially skeptical to implement this patch,
>> since it feels odd to have different MTU:s set on the two sides of a
>> link. After consulting some IP people and the RFC:s I kind of changed
>> my mind and thought I'd give it a shot. In the RFCs I couldn't find
>> anything that defined when and when not a received packet should be
>> dropped.
>>
>>>
>>> Hardware interfaces are free to drop any packet greater than MTU (actua=
lly MTU + VLAN).
>>> The actual limit is a function of the hardware. Some hardware can only =
limit by
>>> power of 2; some can only limit frames larger than 1500; some have no l=
imiting at all.
>>
>> Agreed. The purpose of these patches is to be able to configure an
>> veth interface to mimic these different behaviors. Non of the Ethernet
>> interfaces I have access to drops packets due to them being larger
>> then the configured MTU like veth does.
>>
>> Being able to mimic real Ethernet hardware is useful when
>> consolidating hardware using containers/namespaces.
>>
>> In a reply to a comment from David Miller in my previous version of
>> the patch I attached the example below to demonstrate the case in
>> detail.
>>
>> This works with all ethernet hardware setups I have access to:
>>
>> ---- 8< ------
>> # Host A eth2 and Host B eth0 is on the same network.
>>
>> # On HOST A
>> % ip address add 1.2.3.4/24 dev eth2
>> % ip link set eth2 mtu 300 up
>>
>> % # HOST B
>> % ip address add 1.2.3.5/24 dev eth0
>> % ip link set eth0 mtu 1000 up
>> % ping -c 1 -W 1 -s 400 1.2.3.4
>> PING 1.2.3.4 (1.2.3.4) 400(428) bytes of data.
>> 408 bytes from 1.2.3.4: icmp_seq=3D1 ttl=3D64 time=3D1.57 ms
>>
>> --- 1.2.3.4 ping statistics ---
>> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
>> rtt min/avg/max/mdev =3D 1.573/1.573/1.573/0.000 ms
>> ---- 8< ------
>>
>>
>> But it doesn't work with veth:
>>
>> ---- 8< ------
>> # veth0 and veth1 is a veth pair and veth1 has ben moved to a separate
>> network namespace.
>> % # NS A
>> % ip address add 1.2.3.4/24 dev veth0
>> % ip link set veth0 mtu 300 up
>>
>> % # NS B
>> % ip address add 1.2.3.5/24 dev veth1
>> % ip link set veth1 mtu 1000 up
>> % ping -c 1 -W 1 -s 400 1.2.3.4
>> PING 1.2.3.4 (1.2.3.4) 400(428) bytes of data.
>>
>> --- 1.2.3.4 ping statistics ---
>> 1 packets transmitted, 0 received, 100% packet loss, time 0ms
>> ---- 8< ------
>>
>> --
>> /Fredrik
>



--=20
/Fredrik
