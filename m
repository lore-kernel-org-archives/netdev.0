From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [Intel-wired-lan] [RFC PATCH net] e1000e: keep vlan interfaces
 functional after rxvlan off
Date: Thu, 9 Jun 2016 19:26:10 -0400
Message-ID: <20160609232610.GU56933@redhat.com>
References: <1463511831-13684-1-git-send-email-jarod@redhat.com>
 <CAKgT0UfKV23p18L=wCoyy7WXa7s7pQQRVVK8F_mVea0dOJKekA@mail.gmail.com>
 <20160601192724.GA56933@redhat.com>
 <CAKgT0UdXyHt1tbFijqiN57H49TBxSrJ4VcT4A7uKS0oXUouWTA@mail.gmail.com>
 <20160609180204.GR56933@redhat.com>
 <20160609205501.GS56933@redhat.com>
 <20160609221745.GT56933@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36046 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbcFIX0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 19:26:16 -0400
Received: by mail-wm0-f47.google.com with SMTP id n184so245044641wmn.1
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 16:26:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160609221745.GT56933@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 09, 2016 at 06:17:45PM -0400, Jarod Wilson wrote:
> On Thu, Jun 09, 2016 at 04:55:01PM -0400, Jarod Wilson wrote:
> > On Thu, Jun 09, 2016 at 02:02:04PM -0400, Jarod Wilson wrote:
> > > On Wed, Jun 01, 2016 at 03:31:46PM -0700, Alexander Duyck wrote:
> > > > On Wed, Jun 1, 2016 at 12:27 PM, Jarod Wilson <jarod@redhat.com> wrote:
> > > > > On Wed, Jun 01, 2016 at 07:31:53AM -0700, Alexander Duyck wrote:
> > > > >> On Tue, May 17, 2016 at 12:03 PM, Jarod Wilson <jarod@redhat.com> wrote:
> > > > >> > I've got a bug report about an e1000e interface, where a vlan interface is
> > > > >> > set up on top of it:
> > > > >> >
> > > > >> > $ ip link add link ens1f0 name ens1f0.99 type vlan id 99
> > > > >> > $ ip link set ens1f0 up
> > > > >> > $ ip link set ens1f0.99 up
> > > > >> > $ ip addr add 192.168.99.92 dev ens1f0.99
> > > > >> >
> > > > >> > At this point, I can ping another host on vlan 99, ip 192.168.99.91.
> > > > >> > However, if I do the following:
> > > > >> >
> > > > >> > $ ethtool -K ens1f0 rxvlan off
> > > > >> >
> > > > >> > Then no traffic passes on ens1f0.99. It comes back if I toggle rxvlan on
> > > > >> > again. I'm not sure if this is actually intended behavior, or if there's a
> > > > >> > lack of software vlan stripping fallback, or what, but things continue to
> > > > >> > work if I simply don't call e1000e_vlan_strip_disable() if there are
> > > > >> > active vlans (plagiarizing a function from the e1000 driver here) on the
> > > > >> > interface.
...
> > Okay, so rxvlan is *supposed* to only impact the rx path, right? It's
> > looking like it is actually impacting the tx path too here. I actually
> > *do* see calls to skb_vlan_untag with rxvlan off, if I ping from an
> > external host, so it seems only the packets from the host with rxvlan
> > toggled off aren't escaping correctly for some reason.
> 
> And this leads me to believe maybe the bit in the e1000 driver that
> mentions explicitly that the hardware has no support for separate RX/TX
> vlan accel toggling rings true for e1000e as well, and thus both
> NETIF_F_HW_VLAN_CTAG_RX and NETIF_F_HW_VLAN_CTAG_TX need to be kept in
> sync. Testing this theory out shortly...

We have a winner. If I make sure the TX flag gets toggled too, ping
continues to work after disabling rxvlan.

$ ping 192.168.99.91
PING 192.168.99.91 (192.168.99.91) 56(84) bytes of data.
64 bytes from 192.168.99.91: icmp_seq=1 ttl=64 time=0.591 ms
64 bytes from 192.168.99.91: icmp_seq=2 ttl=64 time=0.335 ms
64 bytes from 192.168.99.91: icmp_seq=3 ttl=64 time=0.417 ms
^C
--- 192.168.99.91 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2000ms
rtt min/avg/max/mdev = 0.335/0.447/0.591/0.109 ms

$ sudo ethtool -K ens1f0 rxvlan off
Actual changes:
rx-vlan-offload: off
tx-vlan-offload: off [requested on]

$ ping 192.168.99.91
PING 192.168.99.91 (192.168.99.91) 56(84) bytes of data.
64 bytes from 192.168.99.91: icmp_seq=1 ttl=64 time=0.327 ms
64 bytes from 192.168.99.91: icmp_seq=2 ttl=64 time=0.393 ms
64 bytes from 192.168.99.91: icmp_seq=3 ttl=64 time=0.424 ms
^C
--- 192.168.99.91 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 1999ms
rtt min/avg/max/mdev = 0.327/0.381/0.424/0.043 ms

I'll clean things up and submit a patch tonight or tomorrow.

-- 
Jarod Wilson
jarod@redhat.com
