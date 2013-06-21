From: Michael Leun <lkml20130126@newton.leun.net>
Subject: Re: Missing iproute2 support for 802.1ad
Date: Fri, 21 Jun 2013 17:37:44 +0200
Message-ID: <20130621173744.1c1ce920@xenia.leun.net>
References: <20130620231713.4f6a3c1f@xenia.leun.net>
 <CAKoUArm0w70TZvaZSMa1C9vAj+UXsMkza7XTBX0Vq-7B3xrFLA@mail.gmail.com>
 <CAKoUArnyR+6bk9UU3GuyteznX-wWVQUfWuaiVuS0YOSKCKKF5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Rami Rosen <roszenrami@gmail.com>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKoUArnyR+6bk9UU3GuyteznX-wWVQUfWuaiVuS0YOSKCKKF5w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Rami,

On Fri, 21 Jun 2013 16:52:41 +0300
Rami Rosen <roszenrami@gmail.com> wrote:

> This patch by Patrick McHardy, titled:
> "add 802.1ad support", seems to do the job:
> http://www.spinics.net/lists/netdev/msg233587.html

thank you very much for that link - I'm not subscribed to netdev and
that searches on web archives sometimes do not seem to work very well.
I only found that patches from 2011.

OK, when applying that patch to iproute2 git the if_link.h hunk
expectedly fails, but the rest applies.

But, unfortunately the result is not what I would expect:

./ip link add link veth0 veth0.1000  type vlan proto 802.1ad id 1000
./ip link add link veth0.1000 veth0.1000.1000  type vlan proto 802.1q id 1000
ifconfig veth0.1000.1000 192.168.123.1/24
ping 192.168.123.2

tcpdump -i veth0 -n
17:27:41.067431 4e:06:ea:bc:87:38 > 8e:42:eb:bd:cc:f2, ethertype 802.1Q (0x8100), length 106: vlan 1000, p 0, ethertype 802.1Q, vlan 1000, p 0, ethertype IPv4, 192.168.123.1 > 192.168.123.2: ICMP echo request, id 15754, seq 1, length 64
17:27:41.067453 8e:42:eb:bd:cc:f2 > 4e:06:ea:bc:87:38, ethertype 802.1Q (0x8100), length 106: vlan 1000, p 0, ethertype 802.1Q, vlan 1000, p 0, ethertype IPv4, 192.168.123.2 > 192.168.123.1: ICMP echo reply, id 15754, seq 1, length 64

Both have ether type 0x8100, the first one should have 0x88a8, or did I get something wrong?

(Note: veth1 is in a different network namespace and set up like veth0 above)

I didn't have much time yet to look into if I can find an explanation myself...

Best Regards,

Michael

> Hello,Michael,
> 
> You are right.
> 
> It is probably a matter of synchronization between iproute2 git
> version and kernel version.
> 
> This patch by Patrick McHardy, titled:
> "add 802.1ad support", seems to do the job:
> http://www.spinics.net/lists/netdev/msg233587.html
> 
> But it was not integrated to iproute2 git tree.
> 
> But don't be wrong: if you look into this patch, you will see that the
> first addition of it was integrated but as a part of a different
> patch:
> commit 79e9a1db11db494eade7bd6917a34f383c0774e3
> Author: Stephen Hemminger <stephen@networkplumber.org>
>     titled "Update headers to 3.10".
> 
> But you should look at the rest of the patch  of Patrick McHardy ("add
> 802.1ad support"), it does not appear in the latest git tree of
> iproute2.
> 
> Please look for example in ip/iplink_vlan.c b/ip/iplink_vlan.c
> in the explain() method and compare to the above mentioned patch.
> 
> 
> Regards,
> Rami Rosen
> http://ramirose.wix.com/ramirosen
> 
> On Fri, Jun 21, 2013 at 4:49 PM, Rami Rosen <roszenrami@gmail.com>
> wrote:
> > Hello,Michael,
> >
> > You are right.
> >
> > It is probably a matter of synchronization between iproute2 git
> > version and kernel version.
> >
> > This patch by Patrick McHardy, titled:
> > "add 802.1ad support", seems to do the job:
> > http://www.spinics.net/lists/netdev/msg233587.html
> >
> > But it was not integrated to iproute2 git tree.
> >
> > But don't be wrong: if you look into this patch, you will see that
> > the first addition of it was integrated but as a part of a
> > different patch: commit 79e9a1db11db494eade7bd6917a34f383c0774e3
> > Author: Stephen Hemminger <stephen@networkplumber.org>
> >     titled "Update headers to 3.10".
> >
> > But you should look at the rest of the patch  of Patrick McHardy
> > ("add 802.1ad support"), it does not appear in the latest git tree
> > of iproute2.
> >
> > Please look for example in ip/iplink_vlan.c b/ip/iplink_vlan.c
> > in the explain() method and compare to the above mentioned patch.
> >
> >
> > Regards,
> > Rami Rosen
> > http://ramirose.wix.com/ramirosen
> >
> >
> >
> > On Fri, Jun 21, 2013 at 12:17 AM, Michael Leun
> > <lkml20130126@newton.leun.net> wrote:
> >>
> >>
> >>
> >> 2013-04-19 12:04:31 GMT kaber@trash.net wrote:
> >>
> >> > Add support for 802.1ad VLAN devices. This mainly consists of
> >> > checking for
> >> > ETH_P_8021AD in addition to ETH_P_8021Q in a couple of places
> >> > and check offloading capabilities based on the used protocol.
> >>
> >> > Configuration is done using "ip link":
> >>
> >> > # ip link add link eth0 eth0.1000 \
> >> >       type vlan proto 802.1ad id 1000
> >> > # ip link add link eth0.1000 eth0.1000.1000 \
> >> >       type vlan proto 802.1q id 1000
> >>
> >> I fear, that does not work:
> >>
> >> lara:/home/ml # ip link add link eth0 eth0.1000 type vlan proto
> >> 802.1ad id 1000
> >> vlan: what is "proto"?
> >> Usage: ... vlan id VLANID [ FLAG-LIST ]
> >>                           [ ingress-qos-map QOS-MAP ]
> >> [ egress-qos-map QOS-MAP ]
> >> [...]
> >>
> >> ip does not seem to know about proto. This does not  have changed
> >> in git either.
> >>
> >> I've seen there was an patch to add this around somewhen in 2011,
> >> but it does not seem to have made it.
> >>
> >> Or did I miss something?
> >>
> >> --
> >> MfG,
> >>
> >> Michael Leun
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe netdev"
> >> in the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> >
> 
