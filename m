From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel memory leak in bnx2x driver with vxlan tunnel
Date: Tue, 19 Jan 2016 15:51:04 -0800
Message-ID: <1453247464.1223.297.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5697D833.5010506@hpe.com>
	 <CAEh+42jMi2EP3LFvUTXiO+WKkGSOuZ5e8X748QFipZUBk8uz9g@mail.gmail.com>
	 <1453243654.1223.290.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEh+42iikonSmsLu5f3UyQCPge0rmUmNu15ggvpkPdv9gqKQ=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John <john.phillips5@hpe.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, david.roth@hpe.com,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33030 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754244AbcASXvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 18:51:07 -0500
Received: by mail-pa0-f45.google.com with SMTP id cy9so459578324pac.0
        for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 15:51:06 -0800 (PST)
In-Reply-To: <CAEh+42iikonSmsLu5f3UyQCPge0rmUmNu15ggvpkPdv9gqKQ=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-19 at 15:34 -0800, Jesse Gross wrote:
> On Tue, Jan 19, 2016 at 2:47 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Tue, 2016-01-19 at 13:07 -0800, Jesse Gross wrote:
> >> On Thu, Jan 14, 2016 at 9:17 AM, John <john.phillips5@hpe.com> wrote:
> >> > I'm getting what seems to be a kernel memory leak while doing a TCP
> >> > throughput test between two VMs on identical systems, in order to test a
> >> > broadcom NIC's performance with a kernel 4.4.0-rc8 and OpenVSwitch version
> >> > 2.4.90. The host system of the receiving (server) VM leaks memory during the
> >> > throughput test. The memory leaks fast enough to make the system completely
> >> > unusable within five minutes. Once I stop the throughput test, the memory
> >> > stops
> >> > leaking. A couple of times, the kernel on the host system has actually
> >> > killed
> >> > the qemu process for me, but this doesn't happen reliably. The leaked memory
> >> > doesn't become available again even after the VM is killed.
> >>
> >> It looks like the problem is in napi_skb_finish(). If we when do
> >> GRO_MERGED_FREE we have NAPI_GRO_CB(skb)->free ==
> >> NAPI_GRO_FREE_STOLEN_HEAD then we will just free the skb memory itself
> >> but not any of the associated elements. Historically, this would have
> >> been OK but these days we will have allocated a dst entry already for
> >> tunnel metadata, which will get leaked.
> >>
> >> If we don't have NAPI_GRO_FREE_STOLEN_HEAD then we'll do a
> >> __kfree_skb(), which will release the dst entry. That would explain
> >> why some drivers have the problem but not others since the memory is
> >> laid out differently.
> >
> >
> > Wow.... What is the purpose of using skb_dst_set() on skb before calling
> > gro_cells_receive() exactly ?
> >
> > Commit 2e15ea390e6f4466655066d97e22ec66870a042c changelog is not
> > helpful :
> >
> >     Following patch create new tunnel flag which enable
> >     tunnel metadata collection on given device.
> 
> Note that this isn't really the problem commit. The general issue is
> lightweight tunnels - the above commit is just adding support for GRE
> in a way that I think follows the existing model.

I believe this commit added the first skb_dst_set() before
gro_cells_receive(), in ip_tunnel_rcv().

This is already buggy.

Then Tom in 58ce31cca1ffe057f4744c3f671e3e84606d3d4a added the
gro_cells_receive() in vxlan_rcv(), which added another bug, because of
existing skb_dst_set() call.
