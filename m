From: Jeff Haran <Jeff.Haran@citrix.com>
Subject: RE: [PATCH 3/5] netfilter: xt_TCPMSS: Fix violation of RFC879 in
 absence of MSS option
Date: Tue, 11 Jun 2013 18:00:49 +0000
Message-ID: <4E5779AD88B2F040B8A7E83ECF544D1A016005@SJCPEX01CL02.citrite.net>
References: <1370880461-4265-1-git-send-email-pablo@netfilter.org>
 <1370880461-4265-4-git-send-email-pablo@netfilter.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7282@saturn3.aculab.com>
 <20130610071954.GA13500@gmail.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7285@saturn3.aculab.com>
 <20130610082739.GA14277@gmail.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7286@saturn3.aculab.com>
 <20130611162525.GA11547@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Phil Oester <kernel@linuxace.com>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Laight <David.Laight@ACULAB.COM>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130611162525.GA11547@localhost>
Content-Language: en-US
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netfilter-devel-owner@vger.kernel.org [mailto:netfilter-devel-owner@vger.kernel.org] On Behalf Of Pablo Neira Ayuso
> Sent: Tuesday, June 11, 2013 9:25 AM
> To: David Laight
> Cc: Phil Oester; netfilter-devel@vger.kernel.org; davem@davemloft.net; netdev@vger.kernel.org
> Subject: Re: [PATCH 3/5] netfilter: xt_TCPMSS: Fix violation of RFC879 in absence of MSS option
> 
> On Tue, Jun 11, 2013 at 05:09:11PM +0100, David Laight wrote:
> > > On Tue, Jun 11, 2013 at 04:00:06PM +0100, David Laight wrote:
> > > > To quote that bug:
> > > >
> > > > I stumbled upon this problem in debian bug #541658[1] ("[iceweasel] cannot open
> > > > research.microsoft.com" - only worth reading for entertainment purposes) and,
> > > > after that bug was closed, analysed it in my blog[2] until a friend of mine
> > > > found out why the page loads when clamping mss to pmtu is disabled or
> > > > restricted to a range (like with "iptables -A FORWARD -p tcp --tcp-flags
> > > > SYN,RST SYN -m tcpmss --mss 1400:1536 -j TCPMSS --clamp-mss-to-pmtu") but
> > > > doesn't load with "simple" clamping. His really great and detailed analysation
> > > > of the problem may be seen at [3].
> > > >
> > > > If I read/understand that correctly, clamping to 1400 worked - there was
> > > > no need to clamp all the way down to 536.
> > >
> > > You are not understanding the issue correctly.  The reason the command worked with
> > > "-m tcpmss --mss 1400:1536" is because that implies an MSS option was provided.
> > > The issue occurs only when NO MSS option is sent.  In these cases, we cannot
> > > ASSUME that it is ok to use some arbitrarily high value (1400 as you propose).
> > > The RFC is clear on this point.
> >
> > My problem is that I don't want TCP connections to drop the mss to
> > 536 when talking to minimal/old implementations that don't add any
> > options to SYN packets.
> 
> That will not happen if you use:
> 
> ... -m tcpmss --mss 1400:1536 ...
> 
> as in your example above.

There is likely no "right" answer for this issue, but for what it's worth I can report a somewhat related experience I had a few years ago when updating my PC at home with a new Suse distro. The machine had been running previous versions of Suse with my Comcast cable internet service just fine for several years. I downloaded the ISO from opensuse, burned the DVD, did the install but when it came back up again the internet service was quite unreliable. It would work for a few minutes, but then no packets would flow. I happened to run ifconfig eth0 and it showed an MTU of 576. It seems the version of the DHCP client that came with the new distro honored the DHCP MTU option, but Comcast was advertising DHCP offers with an MTU of 576.

Problem was, the cable modem that Comcast supplied apparently didn't like that short MTU. I found that if I power cycled the modem, packets would flow again, for a little while. When I modified the configuration of the DHCP client to ignore the MTU option and use a fixed 1500, it started working fine like it did before. I suppose the Windows versions of the time ignored the MTU option by default, so this was not something that impacted most of Comcast's users.

The moral of the story for me was that despite what the RFC says, the de facto default MTU of the Internet is 1500 and MSS's derived from shorter MTUs are likely to cause interoperability problems.

Jeff Haran

