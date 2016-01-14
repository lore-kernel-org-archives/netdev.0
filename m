From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hv_netvsc: don't make assumptions on struct
 flow_keys layout
Date: Thu, 14 Jan 2016 19:15:27 +0000
Message-ID: <BN1PR0301MB0770157002F6294CFF594C13CACC0@BN1PR0301MB0770.namprd03.prod.outlook.com>
References: <1452159189-11473-1-git-send-email-vkuznets@redhat.com>
 <20160110.172558.367101858392871618.davem@davemloft.net>
 <BN1PR0301MB07701A189AABFBF664B5775BCACB0@BN1PR0301MB0770.namprd03.prod.outlook.com>
 <CALx6S35PbTHF7nY0ugtxCUkc5kUmMYAyuy6ZM34bZ9v42nDudg@mail.gmail.com>
 <20160114175304.161ff0af@lxorguk.ukuu.org.uk>
 <1452795849.1223.112.camel@edumazet-glaptop2.roam.corp.google.com>
 <BN1PR0301MB077010E0AC22812F390C14CACACC0@BN1PR0301MB0770.namprd03.prod.outlook.com>
 <CALx6S36c73ESX2djY4QxWO3Yz_rnGaJ_wMrWm1spdcBj_ePVTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
 Eric Dumazet <eric.dumazet@gmail.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 David Miller <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CALx6S36c73ESX2djY4QxWO3Yz_rnGaJ_wMrWm1spdcBj_ePVTw@mail.gmail.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Tom Herbert [mailto:tom@herbertland.com]
> Sent: Thursday, January 14, 2016 1:49 PM
> To: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>; One Thousand Gnomes
> <gnomes@lxorguk.ukuu.org.uk>; David Miller <davem@davemloft.net>;
> vkuznets@redhat.com; netdev@vger.kernel.org; KY Srinivasan
> <kys@microsoft.com>; devel@linuxdriverproject.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH net-next] hv_netvsc: don't make assumptions on
> struct flow_keys layout
> 
> On Thu, Jan 14, 2016 at 10:35 AM, Haiyang Zhang <haiyangz@microsoft.com>
> wrote:
> >
> >
> >> -----Original Message-----
> >> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> >> Sent: Thursday, January 14, 2016 1:24 PM
> >> To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
> >> Cc: Tom Herbert <tom@herbertland.com>; Haiyang Zhang
> >> <haiyangz@microsoft.com>; David Miller <davem@davemloft.net>;
> >> vkuznets@redhat.com; netdev@vger.kernel.org; KY Srinivasan
> >> <kys@microsoft.com>; devel@linuxdriverproject.org; linux-
> >> kernel@vger.kernel.org
> >> Subject: Re: [PATCH net-next] hv_netvsc: don't make assumptions on
> >> struct flow_keys layout
> >>
> >> On Thu, 2016-01-14 at 17:53 +0000, One Thousand Gnomes wrote:
> >> > > These results for Toeplitz are not plausible. Given random input
> you
> >> > > cannot expect any hash function to produce such uniform results.
> I
> >> > > suspect either your input data is biased or how your applying the
> >> hash
> >> > > is.
> >> > >
> >> > > When I run 64 random IPv4 3-tuples through Toeplitz and Jenkins I
> >> get
> >> > > something more reasonable:
> >> >
> >> > IPv4 address patterns are not random. Nothing like it. A long long
> >> time
> >> > ago we did do a bunch of tuning for network hashes using big porn
> site
> >> > data sets. Random it was not.
> >> >
> >>
> >> I ran my tests with non random IPV4 addresses, as I had 2 hosts,
> >> one server, one client. (typical benchmark stuff)
> >>
> >> The only 'random' part was the ports, so maybe ~20 bits of entropy,
> >> considering how we allocate ports during connect() to a given
> >> destination to avoid port reuse.
> >>
> >> > It's probably hard to repeat that exercise now with geo specific
> >> routing,
> >> > and all the front end caches and redirectors on big sites but I'd
> >> > strongly suggest random input is not a good test, and also that you
> >> need
> >> > to worry more about hash attacks than perfect distributions.
> >>
> >> Anyway, the exercise is not to find a hash that exactly splits 128
> flows
> >> into 16 buckets, according to the number of flows per bucket.
> >>
> >> Maybe only 4 flows are sending at 3Gbits, and others are sending at
> 100
> >> kbits. There is no way the driver can predict the future.
> >>
> >> This is why we prefer to select a queue given the cpu sending the
> >> packet. This permits a natural shift based on actual load, and is the
> >> default on linux (see XPS in Documentation/networking/scaling.txt)
> >>
> >> Only this driver has a selection based on a flow 'hash'.
> >
> > Also, the port number selection may not be random either. For example,
> > the well-known network throughput test tool, iperf, use port numbers
> with
> > equal increment among them. We tested these non-random cases, and
> found
> > the Toeplitz hash has distributed evenly, but Jenkins hash has non-
> even
> > distribution.
> >
> > I'm aware of the test from Tom Herbert <tom@herbertland.com>, which
> > showing similar results of Toeplitz v.s. Jenkins with random inputs.
> >
> > In summary, the Toeplitz performs better in case of non-random inputs,
> > and performs similar to Jenkins in random inputs (which may not be the
> > case in real world). So we still prefer to use Toeplitz hash.
> >
> You are basing your conclusions on one toy benchmark. I don't believe
> that an realistically loaded web server is going to consistently give
> you tuples that happen to somehow fit into a nice model so that the
> bias benefits your load distribution.
> 
> > To minimize the computational overhead, we may consider put the hash
> > in a per-connection cache in TCP layer, so it only needs one time
> > computation. But, even with the computation overhead at this moment,
> > the throughput based on Toeplitz hash is better than Jenkins:
> > Throughput (Gbps) comparison:
> > #conn           Toeplitz        Jenkins
> > 32              26.6            23.2
> > 64              32.1            23.4
> > 128             29.1            24.1
> >
> You don't need to do that. We already store a random hash value in the
> connection context. If you want to make it non-random then just
> replace that with a simple global counter. This will have the exact
> same effect that you see in your tests without needing any expensive
> computation.

Could you point me to the data field of connection context where this 
hash value is stored? Is it computed only one time?

Thanks!

- Haiyang
