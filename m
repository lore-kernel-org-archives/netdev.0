From: =?UTF-8?Q?Fredrik_Markstr=C3=B6m?= <fredrik.markstrom@gmail.com>
Subject: Re: [PATCH v2 1/2] net: Added mtu parameter to
	dev_forward_skb calls
Date: Thu, 11 May 2017 21:10:11 +0200
Message-ID: <CAKdL+dS_-UiHA5tr7zP-5LtwDd0aXpZq5tpMYf9kr7hu2SwdGQ@mail.gmail.com>
References: <20170511134629.139528-1-fredrik.markstrom@gmail.com>
	<20170511134629.139528-2-fredrik.markstrom@gmail.com>
	<20170511090132.79fdbf12@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170511090132.79fdbf12@xeon-e3>
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

On Thu, May 11, 2017 at 6:01 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Thu, 11 May 2017 15:46:27 +0200
> Fredrik Markstrom <fredrik.markstrom@gmail.com> wrote:
>
>> From: Fredrik Markstr=C3=B6m <fredrik.markstrom@gmail.com>
>>
>> is_skb_forwardable() currently checks if the packet size is <=3D mtu of
>> the receiving interface. This is not consistent with most of the hardwar=
e
>> ethernet drivers that happily receives packets larger then MTU.
>
> Wrong.

What is "Wrong" ? I was initially skeptical to implement this patch,
since it feels odd to have different MTU:s set on the two sides of a
link. After consulting some IP people and the RFC:s I kind of changed
my mind and thought I'd give it a shot. In the RFCs I couldn't find
anything that defined when and when not a received packet should be
dropped.

>
> Hardware interfaces are free to drop any packet greater than MTU (actuall=
y MTU + VLAN).
> The actual limit is a function of the hardware. Some hardware can only li=
mit by
> power of 2; some can only limit frames larger than 1500; some have no lim=
iting at all.

Agreed. The purpose of these patches is to be able to configure an
veth interface to mimic these different behaviors. Non of the Ethernet
interfaces I have access to drops packets due to them being larger
then the configured MTU like veth does.

Being able to mimic real Ethernet hardware is useful when
consolidating hardware using containers/namespaces.

In a reply to a comment from David Miller in my previous version of
the patch I attached the example below to demonstrate the case in
detail.

This works with all ethernet hardware setups I have access to:

---- 8< ------
# Host A eth2 and Host B eth0 is on the same network.

# On HOST A
% ip address add 1.2.3.4/24 dev eth2
% ip link set eth2 mtu 300 up

% # HOST B
% ip address add 1.2.3.5/24 dev eth0
% ip link set eth0 mtu 1000 up
% ping -c 1 -W 1 -s 400 1.2.3.4
PING 1.2.3.4 (1.2.3.4) 400(428) bytes of data.
408 bytes from 1.2.3.4: icmp_seq=3D1 ttl=3D64 time=3D1.57 ms

--- 1.2.3.4 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev =3D 1.573/1.573/1.573/0.000 ms
---- 8< ------


But it doesn't work with veth:

---- 8< ------
# veth0 and veth1 is a veth pair and veth1 has ben moved to a separate
network namespace.
% # NS A
% ip address add 1.2.3.4/24 dev veth0
% ip link set veth0 mtu 300 up

% # NS B
% ip address add 1.2.3.5/24 dev veth1
% ip link set veth1 mtu 1000 up
% ping -c 1 -W 1 -s 400 1.2.3.4
PING 1.2.3.4 (1.2.3.4) 400(428) bytes of data.

--- 1.2.3.4 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms
---- 8< ------

--=20
/Fredrik
