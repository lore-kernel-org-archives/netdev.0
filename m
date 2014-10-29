From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] use smp_load_acquire()/smp_store_release()
Date: Wed, 29 Oct 2014 12:57:00 -0700
Message-ID: <1414612620.631.98.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414594159.631.85.camel@edumazet-glaptop2.roam.corp.google.com>
	 <545112E0.40106@redhat.com> <1414610868.2420.52.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:45223 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755548AbaJ2T47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 15:56:59 -0400
Received: by mail-pd0-f179.google.com with SMTP id g10so3632278pdj.10
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 12:56:58 -0700 (PDT)
In-Reply-To: <1414610868.2420.52.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-29 at 12:27 -0700, Jeff Kirsher wrote:
> On Wed, 2014-10-29 at 09:16 -0700, Alexander Duyck wrote:
> > On 10/29/2014 07:49 AM, Eric Dumazet wrote:
> > > Hi Alexander
> > >
> > > The memory barriers added in commit
> > > b37c0fbe3f6dfba1f8ad2aed47fb40578a254635
> > > ("net: Add memory barriers to prevent possible race in byte queue
> > > limits")
> > >
> > > have heavy cost.
> > >
> > > It seems we could use smp_load_acquire() and smp_store_release()
> > > instead ?
> > >
> > > I'll post a patch later today. I would be interested if someone w=
as able
> > > to test it, as your commit apparently was tested and known to fix=
 a
> > > reproducible race.
> > >
> > > Thanks !
>=20
> Eric- just CC me on the patch you post and I will see what I can do
> about getting validation eyes on it.

Thanks guys, will do, and will CC Paul as well.

Alexander, here is the following profile showing the cost of the
'mfence', in a typical rpc workload (a lot of IRQ are generated for TX
completions, because RPC tend to send small packets)

  0.11 =E2=94=82       je     33a
       =E2=94=82       mov    -0x3c(%rbp),%esi
  0.06 =E2=94=82       lea    0xc0(%rbx),%rdi
  0.06 =E2=94=82       callq  dql_completed
  0.06 =E2=94=82       mfence
 38.68 =E2=94=82       mov    0xc4(%rbx),%edx
  1.83 =E2=94=82       mov    0xc0(%rbx),%eax
       =E2=94=82       cmp    %eax,%edx
  0.22 =E2=94=82       js     333
  0.11 =E2=94=82       lock   btrl $0x1,0x98(%rbx)
