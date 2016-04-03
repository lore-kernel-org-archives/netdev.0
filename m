From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [RFC PATCH 0/5] Add driver bpf hook for early packet drop
Date: Sun, 3 Apr 2016 11:28:00 +0900
Message-ID: <CAKD1Yr351bEXwBOj8e8Hq=_u7J4Zi2-r=w3k9Z3XFe0AP4m5aw@mail.gmail.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
 <1459622491.18188.6.camel@sipsolutions.net> <CALx6S35kK9eNk8r-fZmP-mOSB=Tb8udbaQeSUjmHWJagh+=i=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Brenden Blanco <bblanco@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	gerlitz@mellanox.com, Daniel Borkmann <daniel@iogearbox.net>,
	john fastabend <john.fastabend@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:35052 "EHLO
	mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbcDCC2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2016 22:28:21 -0400
Received: by mail-yw0-f171.google.com with SMTP id g127so215123801ywf.2
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2016 19:28:21 -0700 (PDT)
In-Reply-To: <CALx6S35kK9eNk8r-fZmP-mOSB=Tb8udbaQeSUjmHWJagh+=i=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 3, 2016 at 7:57 AM, Tom Herbert <tom@herbertland.com> wrote:
> I am curious though, how do you think this would specifically help
> Android with power? Seems like the receiver still needs to be powered
> to receive packets to filter them anyway...

The receiver is powered up, but its wake/sleep cycles are much shorter
than the main CPU's. On a phone, leaving the CPU asleep with wifi on
might consume ~5mA average, but getting the CPU out of suspend might
average ~200mA for ~300ms as the system comes out of sleep,
initializes other hardware, wakes up userspace processes whose
timeouts have fired, freezes, and suspends again. Receiving one such
superfluous packet every 3 seconds (e.g., on networks that send
identical IPv6 RAs once every 3 seconds) works out to ~25mA, which is
5x the cost of idle. Pushing down filters to the hardware so it can
drop the packet without waking up the CPU thus saves a lot of idle
power.

That said, getting BPF to the driver is part of the picture. On the
chipsets we're targeting for APF, we're only seeing 2k-4k of memory
(that's 256-512 BPF instructions) available for filtering code, which
means that BPF might be too large.
