From: Phil Sutter <phil.sutter@viprinet.com>
Subject: Re: FW: [PATCH] af_packet: flush complete kernel cache in
	packet_sendmsg
Date: Tue, 6 Sep 2011 11:44:23 +0200
Message-ID: <20110906094423.GD29025@philter>
References: <20110505141107.GC30443@orbit.nwl.cc>
	<1314961686-30870-1-git-send-email-phil.sutter@viprinet.com>
	<D3F292ADF945FB49B35E96C94C2061B90A239361@nsmail.netscout.com>
	<CAAsGZS6Tt9FLXfanH1+DgKt_9gR_YPJ8kX_pryhnzWTQVkNkNw@mail.gmail.com>
	<20110902153147.GB29025@philter>
	<CAAsGZS6Qiyc6nhgyVLrphSLW6vf16=hbGVWJ+CFw6rfZQsdiFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@arm.linux.org.uk, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org
To: chetan loke <loke.chetan@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <CAAsGZS6Qiyc6nhgyVLrphSLW6vf16=hbGVWJ+CFw6rfZQsdiFQ@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 02, 2011 at 12:49:47PM -0400, chetan loke wrote:
> On Fri, Sep 2, 2011 at 11:31 AM, Phil Sutter <phil.sutter@viprinet.com> wrote:
> 
> > So far we haven't noticed problems in that direction. I just tried some
> > explicit test: having tcpdump print local timestamps (not the pcap-ones)
> > on every received packet, activating icmp_echo_ignore_all and pinging
> > the host on a dedicated line. I expected to sometimes see a second
> > difference between the two timestamps, as like with sending from time to
> > time a packet should get "lost" in the cache, and then occur to
> > userspace after the next one arrived. Maybe my test is broken, or RX is
> > indeed unaffected.
> >
> 
> You will need high traffic rate. If interested, you could try
> pktgen(with varying packet-load). Keep the packet-payload under 1500
> bytes (don't send jumbo frames) unless you have the following fix:
> commit cc9f01b246ca8e4fa245991840b8076394f86707

Hmm. I don't really get your point here: with higher traffic rates, the
bug should be even harder to identify. Assuming the same behaviour as
for TX, of course. There are no packets lost, just not immediately
transmitted (or never, if it's the last packet to be sent). This is how
it goes:
1) userspace places packet into TX_RING, calls sendto()
2) kernel does not see the packet, reads TP_STATUS_AVAILABLE for the
   given field from the cache
3) userspace places second packet into TX_RING (after the first one,
   since it knows it's there)
4) something happens that makes caches flush
5) userspace calls sendto()
5) kernel sees two packets to be transmitted, sends them out

So analogous for RX, this should mean:
1) tcpdump runs pcap_loop() (which, according to strace, calls poll()
   with a timeout of 1s)
2) kernel receives packet, puts it into RX_RING, sets POLLIN
3) tcpdump's poll() returns, but an unmodified RX_RING is seen
4) something happens that makes caches flush
5) (2) happens again
6) tcpdump's poll() returns, two packets are seen in RX_RING

My tests on TX-side show that this "something that makes caches flush"
actually happens quite frequently. But nevertheless, when receiving a
packet once a second, I'm expecting to occasionally see no packet in two
seconds, and then two in the following. The higher the packet rate, the
harder it should be to notice this phenomenon.

> Your Tx path is working because flush_cache_call gets triggered before
> flush_dcache_page. On the Rx path, since you don't have that
> workaround, you will eventually(it's just a matter of time) see this
> problem.

So you say if I called flush_cache_all() _after_ flush_dcache_page() it
wouldn't work?

> Or, delete your patch and try this workaround (in
> __packet_get/set_status) and you may be able to cover both Tx and Rx
> paths.

Oh great, thanks a lot for improving my ugly hacks! :)

Greetings, Phil
