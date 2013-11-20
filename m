From: Willy Tarreau <w@1wt.eu>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Wed, 20 Nov 2013 18:34:36 +0100
Message-ID: <20131120173436.GK8581@1wt.eu>
References: <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site>
 <87y54u59zq.fsf@natisbad.org> <20131112083633.GB10318@1wt.eu>
 <87a9hagex1.fsf@natisbad.org> <20131112100126.GB23981@1wt.eu>
 <87vbzxd473.fsf@natisbad.org> <20131113072257.GB10591@1wt.eu>
 <20131117141940.GA18569@1wt.eu>
 <1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131120171227.GG8581@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 netdev@vger.kernel.org, Arnaud Ebalard <arno@natisbad.org>,
 edumazet@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
 linux-arm-kernel@lists.infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20131120171227.GG8581@1wt.eu>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 20, 2013 at 06:12:27PM +0100, Willy Tarreau wrote:
> Hi guys,
> 
> On Sun, Nov 17, 2013 at 09:41:38AM -0800, Eric Dumazet wrote:
> > On Sun, 2013-11-17 at 15:19 +0100, Willy Tarreau wrote:
> > 
> > > 
> > > So it is fairly possible that in your case you can't fill the link if you
> > > consume too many descriptors. For example, if your server uses TCP_NODELAY
> > > and sends incomplete segments (which is quite common), it's very easy to
> > > run out of descriptors before the link is full.
> > 
> > BTW I have a very simple patch for TCP stack that could help this exact
> > situation...
> > 
> > Idea is to use TCP Small Queue so that we dont fill qdisc/TX ring with
> > very small frames, and let tcp_sendmsg() have more chance to fill
> > complete packets.
> > 
> > Again, for this to work very well, you need that NIC performs TX
> > completion in reasonable amount of time...
> 
> Eric, first I would like to confirm that I could reproduce Arnaud's issue
> using 3.10.19 (160 kB/s in the worst case).
> 
> Second, I confirm that your patch partially fixes it and my performance
> can be brought back to what I had with 3.10-rc7, but with a lot of
> concurrent streams. In fact, in 3.10-rc7, I managed to constantly saturate
> the wire when transfering 7 concurrent streams (118.6 kB/s). With the patch
> applied, performance is still only 27 MB/s at 7 concurrent streams, and I
> need at least 35 concurrent streams to fill the pipe. Strangely, after
> 2 GB of cumulated data transferred, the bandwidth divided by 11-fold and
> fell to 10 MB/s again.
> 
> If I revert both "0ae5f47eff tcp: TSQ can use a dynamic limit" and
> your latest patch, the performance is back to original.
> 
> Now I understand there's a major issue with the driver. But since the
> patch emphasizes the situations where drivers take a lot of time to
> wake the queue up, don't you think there could be an issue with low
> bandwidth links (eg: PPPoE over xDSL, 10 Mbps ethernet, etc...) ?
> I'm a bit worried about what we might discover in this area I must
> confess (despite generally being mostly focused on 10+ Gbps).

One important point, I was looking for the other patch you pointed
in this long thread and finally found it :

> So
> http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=98e09386c0ef4dfd48af7ba60ff908f0d525cdee
> 
> restored this minimal amount of buffering, and let the bigger amount for
> 40Gb NICs ;)

This one definitely restores original performance, so it's a much better
bet in my opinion :-)

Best regards,
Willy
