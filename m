From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] Fix e1000e with Intel 82572EI that has no hardware
 timestamp support
Date: Wed, 6 Aug 2014 23:20:27 -0700
Message-ID: <CAL3LdT5-pyfBTC8=sn=Nk_WEzeCJweK=NyYcOepOfESz44eOhg@mail.gmail.com>
References: <bbcbf584e3624059bf7a0d2186fec6b4@FE-MBX1012.de.bosch.com>
	<20140806191744.GB6611@netboy>
	<CAPDOMVjYkfM49E9DM0=SDDRncLQbXxR8NQE9SrsW++YycMGU5w@mail.gmail.com>
	<20140806193211.GC6611@netboy>
	<CAPDOMViFCifeUoOgExuG7Q6_ObGj20g59siyMxWeKN=Zr2Kbdg@mail.gmail.com>
	<20140806195433.GD6611@netboy>
	<bdf5ba14c73340f7b39f6d3df2473a43@FE-MBX1012.de.bosch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Richard Cochran <richardcochran@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <bdf5ba14c73340f7b39f6d3df2473a43@FE-MBX1012.de.bosch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 6, 2014 at 11:10 PM, Koehrer Mathias (ETAS/ESW5)
<mathias.koehrer@etas.com> wrote:
> With the Intel 82527EI (driver: e1000e) there is an issue when running
> the ptpd2 program, that leads to a kernel oops.  The reason is here that
> in e1000_xmit_frame() a work queue will be scheduled that has not been
> initialized in this case.  The work queue "tx_hwstamp_work" will only be
> initialized if adapter->flags & FLAG_HAS_HW_TIMESTAMP set.  This check
> is missing in e1000_xmit_frame().
>
> The following patch adds the missing check.
>
> Signed-off-by: Mathias Koehrer <mathias.koehrer@etas.com>
>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> Index: linux-3.12.26/drivers/net/ethernet/intel/e1000e/netdev.c
> ===================================================================
> --- linux-3.12.26.orig/drivers/net/ethernet/intel/e1000e/netdev.c       2014-08-04 10:56:56.000000000 +0200
> +++ linux-3.12.26/drivers/net/ethernet/intel/e1000e/netdev.c    2014-08-07 08:05:17.000000000 +0200
> @@ -5550,7 +5550,8 @@
>                              nr_frags);
>         if (count) {
>                 if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
> -                            !adapter->tx_hwtstamp_skb)) {
> +                            !adapter->tx_hwtstamp_skb &&
> +                            (adapter->flags & FLAG_HAS_HW_TIMESTAMP))) {
>                         skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
>                         tx_flags |= E1000_TX_FLAGS_HWTSTAMP;
>                         adapter->tx_hwtstamp_skb = skb_get(skb);
>

So is this v2 of your patch?  and you are ignoring Alex's last suggestion to do:

  unlikely(skb->tx_flags & HW_TSTAMP) &&
  (adapter->flags & HAS_HW_TSTAMP) &&
  !adapter->tx_hwtstamp_skb

Just wondering....

-- 
Cheers,
Jeff
