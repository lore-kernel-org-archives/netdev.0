From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Sun, 8 Dec 2013 10:08:57 -0800 (PST)
Message-ID: <alpine.LFD.2.03.1312080951160.23234@intel.com>
References: <529DF340.70602@mellanox.com> <1386084620.30495.28.camel@edumazet-glaptop2.roam.corp.google.com> <CAJZOPZJ9WM1H9zKNzT5MvQ2UH7RxkTLk2Rhzsk9vdvKz6d2uAw@mail.gmail.com> <alpine.LFD.2.03.1312031310140.23893@intel.com>
 <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com> <alpine.LFD.2.03.1312031500020.570@intel.com> <CAJZOPZLT_3msfz_XY45GOBMWK_y8WEYBTq3rGRUijpYyXE1ddg@mail.gmail.com> <alpine.LFD.2.03.1312031626400.7539@intel.com>
 <CAJZOPZJKsrj2+SQJsgq-w7BrNwDR0OsYWiF+1CcRQ3-KhejZhQ@mail.gmail.com> <alpine.LFD.2.03.1312040113290.14367@intel.com> <CAJZOPZJVBpqm-OduV4K2YwbXESP7awhsk0HbjuHazAiQJZTLWQ@mail.gmail.com> <52A197DF.5010806@mellanox.com> <alpine.LFD.2.03.1312060205220.3499@intel.com>
 <CAJZOPZ+o=gjhmyvDwVCO8pOTJSf8aKLfB9sqjmbW-1+YjLLAaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	John Fastabend <john.fastabend@gmail.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:22366 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759890Ab3LHRvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Dec 2013 12:51:24 -0500
In-Reply-To: <CAJZOPZ+o=gjhmyvDwVCO8pOTJSf8aKLfB9sqjmbW-1+YjLLAaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 7 Dec 2013, Or Gerlitz wrote:

> On Fri, Dec 6, 2013, Joseph Gasparakis <joseph.gasparakis@intel.com> wrote:
> > On Fri, 6 Dec 2013, Or Gerlitz wrote:
> >
> >> On 04/12/2013 11:41, Or Gerlitz wrote:
> >> > On Wed, Dec 4, 2013 at 11:24 AM, Joseph
> >> > Gasparakis<joseph.gasparakis@intel.com>  wrote:
> >> > > >And just for the record,
> >> > > >you are seeing (SKB_UDP_TUNNEL | SKB_GSO_TCPV4) as 0x201 while I was
> >> > > >seeing it as 0x81 because commit 61c1db7fae "ipv6: sit: add GSO/TSO
> >> > > >support" pushed the SKB_UDP_TUNNEL two bits left, and I had done my tests
> >> > > before it.
> >> > indeed, also, on what kernel did you conducted your tests which you managed
> >> > to WA the problem with unsetting that bit?
> >>
> >>
> >> Hi Joseph,
> >>
> >> Really need your response here --
> >
> > I'm sorry Or, I managed to miss your original request...
> 
> sure.. it happens.
> 
> >> 1. on which kernel did you manage to get along fine vxlan performance wise
> >> with this hack?
> 
> > I was running 3.10.6.
> 
> I see, will try it out, and just for getting closer to your env, what
> kernel where the guests running? was a bridge / ovs instance involved
> in the VM PV connectivity?
>

The VMs were running an old 2.6.32 kernel, although if I remember well I 
also tried a 3.x - sorry can't remember which one. The VMs were attached 
to a bridge, but I haven't noticed any packet loss there.
 
> 
> >> 2. did the hack helped for both veth host traffic or only on PV VM traffic?
> 
> > No, just VM. I haven't tried veth.
> 
> I see, earlier I was somehow under the impression you noted the
> problem for veth too.
> 
> > If you leave the DODGY bit, does your traffic get droped on Tx, after it
> > leaves vxlan and before it hits your driver, which is what I had seen. Is
> > that right?
>
> What I saw is that if I leave the DODGY bit set, practically things
> don't work at all, its not that some packets are dropped, was that
> what you saw?
>
What I saw was gso packets badly segmented, causing many re-transmissions 
and dropping the performance to a few MB/s.
 
> Or on your env only **some** or **few** packets were dropped each time
> but this killed the tcp session performance?
> 
> Also, did you hack/modified the VM NIC MTU to take into the account
> the encapsulation overhead?
> 
The virtio interfaces I used had MTU 1500, but the MTU of the physical NIC 
was increased to 1600.

> > If you unset it, do you recover?
> 
> let me redo this with your setting and see, please make sure to tell
> me what kernel the VM was running too (thanks!)
> 
> > What is the output of your ethtool -k on the interface you are
> > transmitting from?
> 
> will send you tomorrow, but this happens without offloads for
> encapsulated traffic.
> 
I have only noticed this with the offloads on. Turning off encapsuation 
TSO off, would simply make the gso's to get segmented in dev_hard_xmit() 
as expected.
