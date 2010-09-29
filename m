From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next-2.6] ip_gre: lockless xmit
Date: Wed, 29 Sep 2010 10:33:08 -0700
Message-ID: <AANLkTinCz_0jHsMYW9_Wko78i9U20qefFbTYCQQQ-pz5@mail.gmail.com>
References: <1285664747.2607.48.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:54608 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753187Ab0I2RdJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 13:33:09 -0400
Received: by iwn5 with SMTP id 5so1278154iwn.19
        for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 10:33:08 -0700 (PDT)
In-Reply-To: <1285664747.2607.48.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 28, 2010 at 2:05 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> GRE tunnels can benefit from lockless xmits, using NETIF_F_LLTX
>
> Note: If tunnels are created with the "oseq" option, LLTX is not
> enabled :
>
> Even using an atomic_t o_seq, we would increase chance for packets be=
ing
> out of order at receiver.
>
> Bench on a 16 cpus machine (dual E5540 cpus), 16 threads sending
> 10000000 UDP frames via one gre tunnel (size:200 bytes per frame)
>
> Before patch :
> real =A0 =A03m0.094s
> user =A0 =A00m9.365s
> sys =A0 =A0 47m50.103s
>
> After patch:
> real =A0 =A00m29.756s
> user =A0 =A00m11.097s
> sys =A0 =A0 7m33.012s
>
> Last problem to solve is the contention on dst :
>
>
> 38660.00 21.4% __ip_route_output_key =A0 =A0 =A0 =A0 =A0vmlinux
> 20786.00 11.5% dst_release =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vml=
inux
> 14191.00 =A07.8% __xfrm_lookup =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vml=
inux
> 12410.00 =A06.9% ip_finish_output =A0 =A0 =A0 =A0 =A0 =A0 =A0 vmlinux
> =A04540.00 =A02.5% ip_push_pending_frames =A0 =A0 =A0 =A0 vmlinux
> =A04427.00 =A02.4% ip_append_data =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vml=
inux
> =A04265.00 =A02.4% __alloc_skb =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
vmlinux
> =A04140.00 =A02.3% __ip_local_out =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vml=
inux
> =A03991.00 =A02.2% dev_queue_xmit =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vml=
inux
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

The tx lock has another use here: to break local loops.  With this
change, a misconfigured tunnel can bring down the machine with a stack
overflow.  There are clearly other ways to fix this that don't require
a lock that restricts parallelism, such as a loop counter, but that's
the way it is now.
