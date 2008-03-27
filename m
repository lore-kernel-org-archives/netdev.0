From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 0/7]: uninline some net related static inline in .h bloaters
Date: Thu, 27 Mar 2008 14:37:59 +0200
Message-ID: <1206621486-5408-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60140 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758906AbYC0MiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 08:38:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

As suggested by Andrew, I rerun the uninlining of all what's in .h
(v2.6.25-rc2-mm1 this time) to fix the (un)likely profiling overhead
which showed up in the allyesconfig results. The config was manually
tweaked from allyesconfig to not include a number of debug related
options [1]. Other setup: 32-bit x86, gcc (GCC) 4.1.2 20070626
(Red Hat 4.1.2-13). I also tweaked the uninlining machinery a bit and
got even better coverage than last time.

IS_ERR is now successfully off the top :-). The numbers are smaller
than what was previously measured, esp. when a function has a large
number of call-sites and has (un)likely, nevertheless, mostly the
same functions show up among top bloaters as with plain allyesconfig.
Also my earlier, smaller scale tests yielded similar conclusion.
Interesting new comers, however, are those list related functions
which had non-inlined debug versions with allyesconfig.

Ok, here's the top of the list (5000+ bytes):

-60744  855 funcs, 861 +, 61605 -, diff: -60744 --- skb_put 
-33129  42 funcs, 199 +, 33328 -, diff: -33129 --- cfi_build_cmd 
-32338  1182 funcs, 594 +, 32932 -, diff: -32338 --- atomic_dec_and_test 
-22906  1208 funcs, 462 +, 23368 -, diff: -22906 --- list_del 
-18399  468 funcs, 282 +, 18681 -, diff: -18399 --- netif_wake_queue 
-14283  14 funcs, 365 +, 14648 -, diff: -14283 --- cfi_send_gen_cmd 
-13890  341 funcs, 189 +, 14079 -, diff: -13890 --- skb_push 
-12853  35 funcs, 114 +, 12967 -, diff: -12853 --- le_key_k_type 
-12178  382 funcs, 157 +, 12335 -, diff: -12178 --- dev_alloc_skb 
-11675  1178 funcs, 1471 +, 13146 -, diff: -11675 --- list_add_tail 
-10996  1688 funcs, 1144 +, 12140 -, diff: -10996 --- raw_local_irq_enable 
-10838  1832 funcs, 3763 +, 14601 -, diff: -10838 --- __list_add 
-10283  401 funcs, 208 +, 10491 -, diff: -10283 --- __dev_alloc_skb 
-9697  338 funcs, 221 +, 9918 -, diff: -9697 --- skb_pull 
-8963  836 funcs, 1903 +, 10866 -, diff: -8963 --- list_add 
-7939  29 funcs, 304 +, 8243 -, diff: -7939 --- __vlan_hwaccel_rx 
-7937  238 funcs, 314 +, 8251 -, diff: -7937 --- i_size_read 
-7768  106 funcs, 254 +, 8022 -, diff: -7768 --- __nlmsg_put 
-7569  376 funcs, 246 +, 7815 -, diff: -7569 --- __skb_pull 
-7467  658 funcs, 503 +, 7970 -, diff: -7467 --- list_del_init 
-7360  192 funcs, 131 +, 7491 -, diff: -7360 --- skb_trim 
-7257  186 funcs, 70 +, 7327 -, diff: -7257 --- dst_release 
-6943  234 funcs, 109 +, 7052 -, diff: -6943 --- __skb_trim 
-6923  71 funcs, 296 +, 7219 -, diff: -6923 --- nlmsg_put 
-6662  475 funcs, 410 +, 7072 -, diff: -6662 --- add_timer 
-6535  380 funcs, 1491 +, 8026 -, diff: -6535 --- ___arch__swab64 
-6457  372 funcs, 1429 +, 7886 -, diff: -6457 --- __fswab64 
-5625  48 funcs, 79 +, 5704 -, diff: -5625 --- tty_insert_flip_char 
-5615  25 funcs, 284 +, 5899 -, diff: -5615 --- vlan_hwaccel_receive_skb 
-5404  23 funcs, 509 +, 5913 -, diff: -5404 --- jhash 
-5396  214 funcs, 155 +, 5551 -, diff: -5396 --- dev_to_shost 
-5310  110 funcs, 133 +, 5443 -, diff: -5310 --- skb_header_pointer 
-5169  403 funcs, 131 +, 5300 -, diff: -5169 --- pci_write_config_byte 

Please note that because one inline was tested (function uninlined)
at a time, the actual benefits of removing multiple inlines may well
be below what the sum of those individually is (especially when
something calls __-func with equal name, e.g., dev_alloc_skb that
basically just calls __dev_alloc_skb).

~210 are 1000+ bytes (was ~250 with allyesconfig) and ~350 in 500+
(was ~440 previously). Full list has small number of entries without
any details indicating compile failures, and a bit larger set of cases
where the static inline was preprocessed away due to #if blocks. Except
for that, it should be self explinary:
  http://www.cs.helsinki.fi/u/ijjarvin/inlines/sorted.v2.6.25-rc2-mm1

I include couple of net related uninlines in this patch series. I don't
include the jhash to lib/ patch this time (was there previously) because
I haven't had time to finish it up.

Another view to the results showing size of the uninlined bodies is
available in here:
  http://www.cs.helsinki.fi/u/ijjarvin/inlines/bodies.v2.6.25-rc2-mm1

The tools I used are available here except the site-specific
distribute machinery (in addition one needs pretty late
codiff from Arnaldo's toolset because there were some inline
related bugs fixed lately):

  http://www.cs.helsinki.fi/u/ijjarvin/inline-tools.git/

As stated earlier, similar analysis should be performed on .h files
not under include/, but it would require minor modifications to
those tools.

--
 i.

[1] http://www.cs.helsinki.fi/u/ijjarvin/inlines/config.nodebug.v2.6.25-rc2-mm1



