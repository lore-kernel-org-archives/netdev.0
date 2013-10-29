From: Markus Pargmann <mpa@pengutronix.de>
Subject: Re: [PATCH v2] can: c_can: Speed up rx_poll function
Date: Tue, 29 Oct 2013 09:58:53 +0100
Message-ID: <20131029085853.GC20839@pengutronix.de>
References: <1383035267-19604-1-git-send-email-mpa@pengutronix.de>
 <1383035688.2713.2.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: Joe Perches <joe@perches.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1383035688.2713.2.camel@joe-AO722>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 29, 2013 at 01:34:48AM -0700, Joe Perches wrote:
> On Tue, 2013-10-29 at 09:27 +0100, Markus Pargmann wrote:
> > This patch speeds up the rx_poll function by reducing the number of
> > register reads.
> []
> > 125kbit:
> >   Function                               Hit    Time            Avg             s^2
> >   --------                               ---    ----            ---             ---
> >   c_can_do_rx_poll                     63960    10168178 us     158.977 us      1493056 us
> > With patch:
> >   c_can_do_rx_poll                     63939    4268457 us     66.758 us       818790.9 us
> > 
> > 1Mbit:
> >   Function                               Hit    Time            Avg             s^2
> >   --------                               ---    ----            ---             ---
> >   c_can_do_rx_poll                     69489    30049498 us     432.435 us      9271851 us
> > With patch:
> >   c_can_do_rx_poll                    103034    24220362 us     235.071 us      6016656 us
> 
> Also nicer if you updated the timings table
> 
> 

Yes I just measured the timings again:

./perf_can_test.sh 125000 30
  Function                               Hit    Time            Avg             s^2
  --------                               ---    ----            ---             ---
  c_can_poll                          127882    6178806 us     48.316 us       4393411 us 
  c_can_do_rx_poll                     63941    3764057 us     58.867 us       776162.2 us 
  c_can_enable_all_interrupts         255764    2213697 us     8.655 us        1093934 us 
  c_can_plat_write_reg_aligned_t      807252    1607115 us     1.990 us        10053684 us 
  c_can_isr                           127882    1220001 us     9.540 us        789.495 us  
  c_can_object_put                    119887    1039222 us     8.668 us        1608.668 us 
  c_can_plat_read_reg_aligned_to     1015072    1033283 us     1.017 us        7021.465 us 
  c_can_read_msg_object                63943    1026159 us     16.048 us       718.464 us  
  c_can_activate_all_lower_rx_ms        7992    755782.4 us     94.567 us       55.270 us   
  c_can_mark_rx_msg_obj                55951    709072.1 us     12.673 us       39.974 us   
  c_can_object_get                     63943    555669.2 us     8.690 us        96.211 us   
  c_can_msg_obj_is_busy               183830    527826.1 us     2.871 us        7289.221 us 
  alloc_can_skb                        63943    170966.6 us     2.673 us        165.765 us  
  c_can_has_and_handle_berr            63941    47063.18 us     0.736 us        2.757 us    

./perf_can_test.sh 1000000 30
  Function                               Hit    Time            Avg             s^2
  --------                               ---    ----            ---             ---
  c_can_poll                          270678    30290751 us     111.906 us      5809627 us 
  c_can_do_rx_poll                    207109    24322185 us     117.436 us      171469047 us 
  c_can_object_put                    841431    7278794 us     8.650 us        305841.0 us 
  c_can_plat_write_reg_aligned_t     4037180    6244636 us     1.546 us        4581066 us 
  c_can_read_msg_object               453988    6033464 us     13.289 us       128809.6 us 
  c_can_enable_all_interrupts         541342    5849826 us     10.806 us       22458900 us 
  c_can_activate_all_lower_rx_ms       55349    5237761 us     94.631 us       19004.79 us 
  c_can_mark_rx_msg_obj               387429    4865632 us     12.558 us       380606.4 us 
  c_can_plat_read_reg_aligned_to     4597629    4633247 us     1.007 us        315286.2 us 
  c_can_object_get                    453988    3919692 us     8.633 us        59847.76 us 
  c_can_msg_obj_is_busy              1295419    3706862 us     2.861 us        316655.7 us 
  c_can_isr                           270671    2496734 us     9.224 us        530.967 us  
  alloc_can_skb                       453988    856917.4 us     1.887 us        18157.68 us 
  c_can_activate_rx_msg_obj            11210    141177.4 us     12.593 us       123.068 us  
  c_can_has_and_handle_berr            63569    44995.85 us     0.707 us        12.780 us

It is interesting that the number of hits for c_can_do_rx_poll is twice as much
as it was with find_next_bit. Unfortunately this reduces the overall benefit of
this patch. Any ideas how to increase the number of waiting message objects we
handle in one poll call?


Regards,

Markus

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
