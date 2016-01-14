From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hv_netvsc: don't make assumptions on struct
 flow_keys layout
Date: Thu, 14 Jan 2016 22:29:05 +0000
Message-ID: <BN1PR0301MB07708D359F390C86418A34CFCACC0@BN1PR0301MB0770.namprd03.prod.outlook.com>
References: <1452159189-11473-1-git-send-email-vkuznets@redhat.com>
 <20160110.172558.367101858392871618.davem@davemloft.net>
 <BN1PR0301MB07701A189AABFBF664B5775BCACB0@BN1PR0301MB0770.namprd03.prod.outlook.com>
 <CALx6S35PbTHF7nY0ugtxCUkc5kUmMYAyuy6ZM34bZ9v42nDudg@mail.gmail.com>
 <20160114175304.161ff0af@lxorguk.ukuu.org.uk>
 <1452795849.1223.112.camel@edumazet-glaptop2.roam.corp.google.com>
 <BN1PR0301MB077010E0AC22812F390C14CACACC0@BN1PR0301MB0770.namprd03.prod.outlook.com>
 <CALx6S36c73ESX2djY4QxWO3Yz_rnGaJ_wMrWm1spdcBj_ePVTw@mail.gmail.com>
 <BN1PR0301MB0770157002F6294CFF594C13CACC0@BN1PR0301MB0770.namprd03.prod.outlook.com>
 <CALx6S34NWdBe0ZBuSMJCC8r68LOVvbY3ZXhneo+TSU1qz=9mYw@mail.gmail.com>
 <BN1PR0301MB0770C72CCEDD9AEBA7AEA329CACC0@BN1PR0301MB0770.namprd03.prod.outlook.com>
 <1452809286.1223.152.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
 Tom Herbert <tom@herbertland.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1452809286.1223.152.camel@edumazet-glaptop2.roam.corp.google.com>
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
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> Sent: Thursday, January 14, 2016 5:08 PM
> To: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: Tom Herbert <tom@herbertland.com>; One Thousand Gnomes
> <gnomes@lxorguk.ukuu.org.uk>; David Miller <davem@davemloft.net>;
> vkuznets@redhat.com; netdev@vger.kernel.org; KY Srinivasan
> <kys@microsoft.com>; devel@linuxdriverproject.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH net-next] hv_netvsc: don't make assumptions on
> struct flow_keys layout
> 
> On Thu, 2016-01-14 at 20:23 +0000, Haiyang Zhang wrote:
> >
> 
> 
> > For non-random inputs, I used the port selection of iperf that
> increases
> > the port number by 2 for each connection. Only send-port numbers are
> > different, other values are the same. I also tested some other fixed
> > increment, Toeplitz spreads the connections evenly. For real
> applications,
> > if the load came from local area, then the IP/port combinations are
> > likely to have some non-random patterns.
> 
> We are not putting code in core networking stack favoring non secure
> behavior.
> 
> The +2 behavior for connections from A to B:<fixed port> is something
> that we will eventually remove in the future. It used to be +1 not a
> long time ago...
> 
> Say if we implement the following,
> 
> https://na01.safelinks.protection.outlook.com/?url=https%3a%2f%2ftools.i
> etf.org%2fhtml%2frfc6056%23section-
> 3.3.4&data=01%7c01%7chaiyangz%40microsoft.com%7ced5f98ae23a843df05c408d3
> 1d2f3028%7c72f988bf86f141af91ab2d7cd011db47%7c1&sdata=uPo0Rdme20vZX%2b%2
> frcwe1iE0mKGZYl%2fMdeaF1wld%2fgbQ%3d
> 
> 
> The fact that Toeplitz hash has this linear property should not be a
> valid reason to help hackers to exploit vulnerabilities.
> 
> In my tests I was using netperf, which randomizes both source &
> destination ports.
> 
> This is why I could not reproduce your results based on iperf, which
> generates 5-tuple in a totally predictable way.
> 
> This reminds me some drivers had a well known Toeplitz RSS key, allowing
> attackers to direct their attack on a single queue.
> 
> I guess we could replace sk_txhash generator by a simple linear
> allocator and boom, your driver will be pleased.
> 
> But this is only for a very specific workload.
> 
> diff --git a/include/net/sock.h b/include/net/sock.h
> index e830c1006935..949527413cfb 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1689,7 +1689,8 @@ unsigned long sock_i_ino(struct sock *sk);
> 
>  static inline u32 net_tx_rndhash(void)
>  {
> -       u32 v = prandom_u32();
> +       static u32 last_hash;
> +       u32 v = ++last_hash; // do not care about SMP races.
> 
>         return v ?: 1;
>  }

Tom, Thanks for your test -- I was not able to reproduce the 
"0 8 8 0 0 8 8 0 8 0 0 8 8 0 0 8" distribution, but I did see some 
predictable patterns by using some increments like 512... 

Tom, Dave, and Eric -- I share your concerns on potential DoS attack 
on predictable patterns. We will re-think about this.

Thanks,
- Haiyang
