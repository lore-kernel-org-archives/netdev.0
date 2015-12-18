From: Vijay Pandurangan <vijayp@vijayp.ca>
Subject: Re: [PATCH] veth: don't modify ip-summed; doing so treats packets
 with bad checksums as good.
Date: Fri, 18 Dec 2015 12:42:37 -0700
Message-ID: <CAKUBDd-VfaBvdMDJE8_mH2vXKn-66PM_0i-ioJLm6yQgwbrE4A@mail.gmail.com>
References: <CAKoqxG=R566bG2sQzWabAaaoUZjUJfoVP7k7dcYK4QuEcH0jrA@mail.gmail.com>
 <CAM_iQpUOKGoNNDF2Nbut8a0q2rGY6pCXBm3NVkBMe=63K7L9bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Evan Jones <ej@evanjones.ca>,
	Eric Biederman <ebiederm@aristanetworks.com>,
	Tom Herbert <tom@herbertland.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpUOKGoNNDF2Nbut8a0q2rGY6pCXBm3NVkBMe=63K7L9bg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evan and I have demonstrated this bug on Kubernetes as well, so it's
not just a problem in Mesos. (See
https://github.com/kubernetes/kubernetes/issues/18898)

Sorry about my email client, I've re-sent the patch in another thread
from git-email as I should have initially.

I'll read through the TX path again to see if we missed something, but
I'd love input from anyone else!

--

Vijay Pandurangan
https://www.twitter.com/vijayp
http://www.vijayp.ca


On Fri, Dec 18, 2015 at 2:00 PM, Cong Wang <xiyou.wangcong@gmail.com> w=
rote:
> (Cc'ing Eric B and Tom)
>
> On Fri, Dec 18, 2015 at 9:54 AM, Vijay Pandurangan <vijayp@vijayp.ca>=
 wrote:
>> Packets that arrive from real hardware devices have ip_summed =3D=3D
>> CHECKSUM_UNNECESSARY if the hardware verified the checksums, or
>> CHECKSUM_NONE if the packet is bad or it was unable to verify it. Th=
e
>> current version of veth will replace CHECKSUM_NONE with
>> CHECKSUM_UNNECESSARY, which causes corrupt packets routed from hardw=
are to
>> a veth device to be delivered to the application. This caused applic=
ations
>> at Twitter to receive corrupt data when network hardware was corrupt=
ing
>> packets.
>
> Yeah, https://reviews.apache.org/r/41158/.
>
> This is because normally packets to a veth device are _only_ from its=
 pair
> device, Mesos network isolator redirects packets from a hardware inte=
rface
> to veth, which violates this expectation. This is also why no one els=
e sees
> this bug. ;)
>
>>
>> We believe this was added as an optimization to skip computing and
>> verifying checksums for communication between containers. However, l=
ocally
>> generated packets have ip_summed =3D=3D CHECKSUM_PARTIAL, so the cod=
e as
>> written does nothing for them. As far as we can tell, after removing=
 this
>> code, these packets are transmitted from one stack to another unmodi=
fied
>> (tcpdump shows invalid checksums on both sides, as expected), and th=
ey are
>> delivered correctly to applications. We didn=E2=80=99t test every po=
ssible network
>> configuration, but we tried a few common ones such as bridging conta=
iners,
>> using NAT between the host and a container, and routing from hardwar=
e
>> devices to containers. We have effectively deployed this in producti=
on at
>> Twitter (by disabling RX checksum offloading on veth devices).
>
>
> I am wondering if there is any other CHECKSUM_NONE case in the tx
> path we could miss here. Mesos case is too special not only because
> it redirects packets from hardware to veth, but also because it moves
> packets from RX path to TX path.
>
> Eric? Tom?
>
>>
>> This code dates back to the first version of the driver, commit
>> <e314dbdc1c0dc6a548ecf> ("[NET]: Virtual ethernet device driver"), s=
o I
>> suspect this bug occurred mostly because the driver API has evolved
>> significantly since then. Commit <0b7967503dc97864f283a> ("net/veth:=
 Fix
>> packet checksumming") (in December 2010) fixed this for packets that=
 get
>> created locally and sent to hardware devices, by not changing
>> CHECKSUM_PARTIAL. However, the same issue still occurs for packets c=
oming
>> in from hardware devices.
>>
>> Co-authored-by: Evan Jones <ej@evanjones.ca>
>> Signed-off-by: Evan Jones <ej@evanjones.ca>
>> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Cc: Phil Sutter <phil@nwl.cc>
>> Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>> Cc: netdev@vger.kernel.org
>> Cc: linux-kernel@vger.kernel.org
>> Signed-off-by: Vijay Pandurangan <vijayp@vijayp.ca>
>
> Your patch looks good to me but your email client corrupts your patch=
,
> so please resend.
