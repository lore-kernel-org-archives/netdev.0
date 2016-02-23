From: Edward Cree <ecree@solarflare.com>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by
 default
Date: Tue, 23 Feb 2016 15:18:32 +0000
Message-ID: <56CC7848.2000704@solarflare.com>
References: <20160219191806.15687.37621.stgit@localhost.localdomain>
 <CAEh+42jHjEqjEyN3-OopZK2hAowh4LGKSgZWgSe9+W1zdezpZA@mail.gmail.com>
 <CAMt9YRrOxCmJbrftixdJTXZcySZ_mARqCT6C=4-Nqv_ZJKnTwA@mail.gmail.com>
 <CAEh+42hStEh=5z8KBic0hmEZNti4tjahySjjv7kU3YUes_R4Zg@mail.gmail.com>
 <CALx6S351KYGFFLi08cX=DFCucZtGJLoMJGvFAW1_H-cRXZ0rQg@mail.gmail.com>
 <CAEh+42hEVQOFaFk7BW=wZ-gb9HCfYqbr7Q600gbm1q1Oz+yZcA@mail.gmail.com>
 <CALx6S36EyzjWKi_iK_uAVcCceFnZe3QmLcw7BBejKuB79Uo7PA@mail.gmail.com>
 <CAEh+42hzkW6i+M52iDAyFtCBfxcJJmsZOiNdqd-DqYrN5isMBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alex Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Jesse Gross <jesse@kernel.org>, Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:63821 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753498AbcBWPUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 10:20:44 -0500
In-Reply-To: <CAEh+42hzkW6i+M52iDAyFtCBfxcJJmsZOiNdqd-DqYrN5isMBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/02/16 03:31, Jesse Gross wrote:
> The only issue that I see is that making TSO completely unaware of
> outer headers will likely cause performance regressions in some cases.
> Imagine if we have an incoming TCP stream with incrementing IP IDs
> that we aggregate through GRO and forward. Today's TSO would be able
> to recreate the stream by incrementing the ID as new segments are
> created. However, if the outgoing NIC is truly only dealing with the
> L4 header then it wouldn't be able to do this.
Perhaps TSO should force setting the DF bit, so that the IP ID can be
ignored.  After all, if your network is going to cause fragmentation and
reassembly, your performance will probably be bad enough that TSO won't
help you much.  (And TCP usually wants DF anyway so it can do PMTUD.)
Arguably, as soon as we perform GRO on traffic to be forwarded, we've
already violated the end-to-end principle (there are always imaginable
situations in which a different packet stream comes out than went in),
so it doesn't really matter if we go on to change the network layer
parameters in this way - it's not really the same IP datagram any more
so it's OK for its identification to change.
And of course this problem doesn't present itself for IPv6 :)
