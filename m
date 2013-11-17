From: Willy Tarreau <w@1wt.eu>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Sun, 17 Nov 2013 15:19:40 +0100
Message-ID: <20131117141940.GA18569@1wt.eu>
References: <8761s0cqhh.fsf@natisbad.org>
 <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site> <87y54u59zq.fsf@natisbad.org>
 <20131112083633.GB10318@1wt.eu> <87a9hagex1.fsf@natisbad.org>
 <20131112100126.GB23981@1wt.eu> <87vbzxd473.fsf@natisbad.org>
 <20131113072257.GB10591@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Cong Wang <xiyou.wangcong@gmail.com>, edumazet@google.com,
 linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20131113072257.GB10591@1wt.eu>
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

Hi Arnaud,

[CCing Thomas and removing stable@]

On Wed, Nov 13, 2013 at 08:22:57AM +0100, Willy Tarreau wrote:
> On Tue, Nov 12, 2013 at 04:34:24PM +0100, Arnaud Ebalard wrote:
> > Can you give a pre-3.11.7 kernel a try if you find the time? I started
> > working on RN102 during 3.10-rc cycle but do not remember if I did the
> > first preformance tests on 3.10 or 3.11. And if you find more time,
> > 3.11.7 would be nice too ;-)
> 
> Still have not found time for this but I observed something intriguing
> which might possibly match your experience : if I use large enough send
> buffers on the mirabox and receive buffers on the client, then the
> traffic drops for objects larger than 1 MB. I have quickly checked what's
> happening and it's just that there are pauses of up to 8 ms between some
> packets when the TCP send window grows larger than about 200 kB. And
> since there are no drops, there is no reason for the window to shrink.
> I suspect it's exactly related to the issue explained by Eric about the
> timer used to recycle the Tx descriptors. However last time I checked,
> these ones were also processed in the Rx path, which means that the
> ACKs that flow back should have had the same effect as a Tx IRQ (unless
> I'd use asymmetric routing, which was not the case). So there might be
> another issue. Ah, and it only happens with GSO.

I just had a quick look at the driver and I can confirm that Eric is right
about the fact that we use up to two descriptors per GSO segment. Thus, we
can saturate the Tx queue at 532/2 = 266 Tx segments = 388360 bytes (for
1460 MSS). I thought I had seen a tx flush from the rx poll function but I
can't find it so it seems I was wrong, or that I possibly misunderstood
mvneta_poll() the first time I read it. Thus the observed behaviour is
perfectly normal.

With GSO enabled, as soon as the window grows large enough, we can fill
all the Tx descriptors with few segments, then need to wait for 10ms (12
if running at 250 Hz as I am) to flush them, which explains the low speed
I was observing with large windows. When disabling GSO, as much as twice
the number of descriptors can be used, which is enough to fill the wire
in the same time frame. Additionally it's likely that more descriptors
get the time to be sent during that period and that each call to mvneta_tx()
causing a call to mvneta_txq_done() releases some of the previously sent
descriptors, allowing to sustain wire rate.

I wonder if we can call mvneta_txq_done() from the IRQ handler, which would
cause some recycling of the Tx descriptors when receiving the corresponding
ACKs.

Ideally we should enable the Tx IRQ, but I still have no access to this
chip's datasheet despite having asked Marvell several times in one year
(Thomas has it though).

So it is fairly possible that in your case you can't fill the link if you
consume too many descriptors. For example, if your server uses TCP_NODELAY
and sends incomplete segments (which is quite common), it's very easy to
run out of descriptors before the link is full.

I still did not have time to run a new kernel on this device however :-(

Best regards,
Willy
