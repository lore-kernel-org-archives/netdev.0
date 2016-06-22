From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Wed, 22 Jun 2016 15:47:44 -0700
Message-ID: <1466635664.6850.90.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
	 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
	 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
	 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
	 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
	 <576B08A2.8080603@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35298 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608AbcFVWrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 18:47:47 -0400
Received: by mail-pf0-f178.google.com with SMTP id c2so21796583pfa.2
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 15:47:46 -0700 (PDT)
In-Reply-To: <576B08A2.8080603@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-22 at 14:52 -0700, Rick Jones wrote:
> On 06/22/2016 11:22 AM, Yuval Mintz wrote:
> > But seriously, this isn't really anything new but rather a step forward in
> > the direction we've already taken - bnx2x/qede are already performing
> > the same for non-encapsulated TCP.
> 
> Since you mention bnx2x...   I would argue that the NIC firmware on 
> those NICs driven by bnx2x is doing it badly.  Not so much from a 
> functional standpoint I suppose, but from a performance one.  The 
> NIC-firmware GRO done there has this rather unfortunate assumption about 
> "all MSSes will be directly driven by my own physical MTU" and when it 
> sees segments of a size other than would be suggested by the physical 
> MTU, will coalesce only two segments together.  They then do not get 
> further coalesced in the stack.
> 
> Suffice it to say this does not do well from a performance standpoint.
> 
> One can disable LRO via ethtool for these NICs, but what that does is 
> disable old-school LRO, not GRO-in-the-NIC.  To get that disabled, one 
> must also get the bnx2x module loaded with "disable-tpa=1" so the Linux 
> stack GRO gets used instead.
> 
> Had the bnx2x-driven NICs' firmware not had that rather unfortunate 
> assumption about MSSes I probably would never have noticed.

I do not see this behavior on my bnx2x nics ?

ip ro add 10.246.11.52 via 10.246.11.254 dev eth0 mtu 1000
lpk51:~# ./netperf -H 10.246.11.52 -l 1000
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
10.246.11.52 () port 0 AF_INET


On receiver :

15:46:08.296241 IP 10.246.11.52.46907 > 10.246.11.51.34131: Flags [.],
ack 303360, win 8192, options [nop,nop,TS val 1245217243 ecr
1245306446], length 0
15:46:08.296430 IP 10.246.11.51.34131 > 10.246.11.52.46907: Flags [.],
seq 303360:327060, ack 1, win 229, options [nop,nop,TS val 1245306446
ecr 1245217242], length 23700
15:46:08.296441 IP 10.246.11.52.46907 > 10.246.11.51.34131: Flags [.],
ack 327060, win 8192, options [nop,nop,TS val 1245217243 ecr
1245306446], length 0
15:46:08.296644 IP 10.246.11.51.34131 > 10.246.11.52.46907: Flags [.],
seq 327060:350760, ack 1, win 229, options [nop,nop,TS val 1245306446
ecr 1245217242], length 23700
15:46:08.296655 IP 10.246.11.52.46907 > 10.246.11.51.34131: Flags [.],
ack 350760, win 8192, options [nop,nop,TS val 1245217244 ecr
1245306446], length 0
15:46:08.296854 IP 10.246.11.51.34131 > 10.246.11.52.46907: Flags [.],
seq 350760:374460, ack 1, win 229, options [nop,nop,TS val 1245306446
ecr 1245217242], length 23700
15:46:08.296897 IP 10.246.11.52.46907 > 10.246.11.51.34131: Flags [.],
ack 374460, win 8192, options [nop,nop,TS val 1245217244 ecr
1245306446], length 0
15:46:08.297054 IP 10.246.11.51.34131 > 10.246.11.52.46907: Flags [.],
seq 374460:398160, ack 1, win 229, options [nop,nop,TS val 1245306446
ecr 1245217242], length 23700
15:46:08.297099 IP 10.246.11.52.46907 > 10.246.11.51.34131: Flags [.],
ack 398160, win 8192, options [nop,nop,TS val 1245217244 ecr
1245306446], length 0
15:46:08.297258 IP 10.246.11.51.34131 > 10.246.11.52.46907: Flags [.],
seq 398160:420912, ack 1, win 229, options [nop,nop,TS val 1245306446
ecr 1245217242], length 22752
15:46:08.297301 IP 10.246.11.52.46907 > 10.246.11.51.34131: Flags [.],
ack 420912, win 8192, options [nop,nop,TS val 1245217244 ecr
1245306446], length 0
