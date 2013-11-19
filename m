From: Willy Tarreau <w@1wt.eu>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Tue, 19 Nov 2013 18:43:23 +0100
Message-ID: <20131119174323.GH913@1wt.eu>
References: <87y54u59zq.fsf@natisbad.org> <20131112083633.GB10318@1wt.eu>
 <87a9hagex1.fsf@natisbad.org> <20131112100126.GB23981@1wt.eu>
 <87vbzxd473.fsf@natisbad.org> <20131113072257.GB10591@1wt.eu>
 <20131117141940.GA18569@1wt.eu>
 <1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
 <87li0kkhzx.fsf@natisbad.org>
 <1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Florian Fainelli <f.fainelli@gmail.com>, simon.guinot@sequanux.org,
 netdev@vger.kernel.org, Arnaud Ebalard <arno@natisbad.org>,
 edumazet@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
 linux-arm-kernel@lists.infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com>
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

Hi Eric,

On Tue, Nov 19, 2013 at 05:53:14AM -0800, Eric Dumazet wrote:
> These strange results you have tend to show that if you have a big TCP
> send window, the web server pushes a lot of bytes per system call and
> might stall the ACK clocking or TX refills.

It's tx refills which are not done in this case from what I think I
understood in the driver. IIRC, the refill is done once at the beginning
of xmit and in the tx timer callback. So if you have too large a window
that fills the descriptors during a few tx calls during which no desc was
released, you could end up having to wait for the timer since you're not
allowed to send anymore.

> > Then, I started playing w/ tcp_limit_output_bytes (default is 131072),
> > w/ TCP send window set to 256KB:
> > 
> > tcp_limit_output_bytes set to 512KB: 59.3 MB/s
> > tcp_limit_output_bytes set to 256KB: 58.5 MB/s
> > tcp_limit_output_bytes set to 128KB: 56.2 MB/s
> > tcp_limit_output_bytes set to  64KB: 32.1 MB/s
> > tcp_limit_output_bytes set to  32KB: 4.76 MB/s
> > 
> > As a side note, during the test, I sometimes gets peak for some seconds
> > at the beginning at 90MB/s which tend to confirm what WIlly wrote,
> > i.e. that the hardware can do more.
> 
> I would also check the receiver. I suspect packets drops because of a
> bad driver doing skb->truesize overshooting.

When I first observed the issue, at first I suspected my laptop's driver
when I saw this problem, so I tried with a dockstar instead and the issue
disappeared... until I increased the tcp_rmem on it to match my laptop :-)

Arnaud, you might be interested in trying checking if the following change
does something for you in mvneta.c :

- #define MVNETA_TX_DONE_TIMER_PERIOD 10
+ #define MVNETA_TX_DONE_TIMER_PERIOD (1000/HZ)

This can only have any effect if you run at 250 or 1000 Hz, but not at 100
of course. It should reduce the time to first IRQ.

Willy
