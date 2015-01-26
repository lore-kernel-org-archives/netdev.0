From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] drivers: net: xgene: fix: Out of order descriptor bytes
 read
Date: Mon, 26 Jan 2015 13:27:32 -0800
Message-ID: <1422307652.29618.30.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421957007-720-1-git-send-email-isubramanian@apm.com>
	 <1421967050.3471.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAKh23FmxvV82mVrHq5jv-FE+e6u6CkW+xL_a2_ULAQgP_mM2VA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, mlangsdo@redhat.com,
	patches <patches@apm.com>, Keyur Chudgar <kchudgar@apm.com>
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKh23FmxvV82mVrHq5jv-FE+e6u6CkW+xL_a2_ULAQgP_mM2VA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-01-26 at 13:12 -0800, Iyappan Subramanian wrote:
> On Thu, Jan 22, 2015 at 2:50 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Thu, 2015-01-22 at 12:03 -0800, Iyappan Subramanian wrote:
> >> This patch fixes the following kernel crash,
> >>
> >>       WARNING: CPU: 2 PID: 0 at net/ipv4/tcp_input.c:3079 tcp_clean_rtx_queue+0x658/0x80c()
> >>       Call trace:
> >
> >>
> >> Software writes poison data into the descriptor bytes[15:8] and upon
> >> receiving the interrupt, if those bytes are overwritten by the hardware with
> >> the valid data, software also reads bytes[7:0] and executes receive/tx
> >> completion logic.
> >>
> >> If the CPU executes the above two reads in out of order fashion, then the
> >> bytes[7:0] will have older data and causing the kernel panic.  We have to
> >> force the order of the reads and thus this patch introduces read memory
> >> barrier between these reads.
> >>
> >> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> >> Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
> >> Tested-by: Mark Langsdorf <mlangsdo@redhat.com>
> >> ---
> >>  drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 2 ++
> >>  1 file changed, 2 insertions(+)
> >>
> >> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> >> index 83a5028..3622cdb 100644
> >> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> >> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> >> @@ -369,6 +369,8 @@ static int xgene_enet_process_ring(struct xgene_enet_desc_ring *ring,
> >>               if (unlikely(xgene_enet_is_desc_slot_empty(raw_desc)))
> >>                       break;
> >>
> >> +             /* read fpqnum field after dataaddr field */
> >> +             smp_rmb();
> >>               if (is_rx_desc(raw_desc))
> >>                       ret = xgene_enet_rx_frame(ring, raw_desc);
> >>               else
> >
> > Reading your changelog, it looks like you need a plain rmb() here.
> 
> rmb() translates into dsb, which in arm64 serializes everything
> including instructions and thus expensive compared to dmb.
> 
> Do you see any issue with smp_rmb() (which translates into dmb) ?

What happens if you compile a kernel with CONFIG_SMP=n ?


Most drivers in drivers/net use rmb() in this case, not smp_rmb() or
barrier()
