From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Fri, 25 Mar 2016 14:31:23 -0400
Message-ID: <CAF=yD-+QgnbM5_LR73NFnzE2AJWwPxkoii30O8bbEwXR3XhCvA@mail.gmail.com>
References: <CAEfhGizvwATcG--OH_xhrV-c1t11ie-vNibJY8kqFAq3GX9upw@mail.gmail.com>
 <20160325162114.GA72479@ast-mbp.thefacebook.com> <CAEfhGiy-V0da6LQ_SY+E4u7S49n5dEpVaKiOOo103ijQtPujAw@mail.gmail.com>
 <1458925242.6473.41.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Craig Gallek <kraigatgoog@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:36642 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753321AbcCYScF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 14:32:05 -0400
Received: by mail-lf0-f65.google.com with SMTP id r8so6490222lfe.3
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 11:32:04 -0700 (PDT)
In-Reply-To: <1458925242.6473.41.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2016 at 1:00 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2016-03-25 at 12:31 -0400, Craig Gallek wrote:
>
>> I believe the issue here is that closing the listen sockets will drop
>> any connections that are in the listen queue but have not been
>> accepted yet.  In the case of reuseport, you could in theory drain
>> those queues into the non-closed sockets, but that probably has some
>> interesting consequences...
>
> It is more complicated than this.
>
> Ideally, no TCP connection should be dropped during a server change.
>
> The idea is to let old program running as long as :
> 1) It has established TCP sessions
> 2) Some SYN_RECV pseudo requests are still around
>
> Once 3WHS completes for these SYN_RECV, children are queued into
> listener accept queues.
>
> But the idea is to direct all new SYN packets to the 'new' process and
> its listeners. (New SYN_RECV should be created on behalf on the new
> listeners only)
>
>
> In some environments, the listeners are simply transfered via FD
> passing, from the 'old process' to the new one.

Right. Comparatively, one of the nice features of the BPF variant is
that the sockets in the old process can passively enter listen_off
state solely with changes initiated by the new process (change the bpf
filter for the group).

By the way, if I read correctly, the listen_off feature was already
possible without kernel changes prior to fast reuseport by changing
SO_BINDTODEVICE on the old process's sockets to effectively segment
them into a separate reuseport group. With fast reuseport,
sk_bound_dev_if state equivalence is checked on joining a group, but
the socket is not removed from the array when that syscall is made, so
this does not work.
