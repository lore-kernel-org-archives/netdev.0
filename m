From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] forcedeth: hung interface under load
Date: Fri, 6 Apr 2007 12:51:03 +0200
Message-ID: <20070406105103.GA30533@elte.hu>
References: <20070402115325.GA945@elte.hu> <DBFABB80F7FD3143A911F9E6CFD477B0189CB20B@hqemmail02.nvidia.com> <20070403062629.GA13210@elte.hu> <20070403070514.GA22940@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="sdtB3X0nJg68CQEu"
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Adrian Bunk <bunk@stusta.de>
To: Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:38630 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1766693AbXDFKva (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2007 06:51:30 -0400
Content-Disposition: inline
In-Reply-To: <20070403070514.GA22940@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


* Ingo Molnar <mingo@elte.hu> wrote:

> > there's a different type of regression now: under high load i dont 
> > get a crash, i get a hung interface instead. No error packets or 
> > other weird interface state - just a hung interface. [...]
> 
> the interface stats do not change from that point on:
> 
> eth1      Link encap:Ethernet  HWaddr 00:13:D4:DC:41:12
>           inet addr:10.0.1.12  Bcast:10.0.1.255  Mask:255.255.255.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:14976 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:3928743 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:1028544 (1004.4 KiB)  TX bytes:4126766510 (3.8 GiB)
>           Interrupt:16 Base address:0xa000
> 
> and the irq count does not change either:
> 
>  16:        816    3463148   IO-APIC-fasteoi   eth1
> 
> no matter what i do to the interface. So it's completely stuck. No 
> kernel messages either - apparently nv_tx_timeout() never triggered.

i've attached an ethtool dump, ifconfig output, interrupts output and 
lspci output of such a hang. Does the ethtool dump make any sense to 
you? The driver is -rc6 plus the changes below. (but the hang looks 
exactly the same that i got with an unmodified driver. the 
optimization_tweak is a new change too - it drastically improves the 
performance and scalability of the driver btw., by not letting it do 
100-200K irqs/sec (!).)

	Ingo

---------------->
Index: linux/drivers/net/forcedeth.c
===================================================================
--- linux.orig/drivers/net/forcedeth.c
+++ linux/drivers/net/forcedeth.c
@@ -800,7 +800,7 @@ struct fe_priv {
  * Maximum number of loops until we assume that a bit in the irq mask
  * is stuck. Overridable with module param.
  */
-static int max_interrupt_work = 5;
+static int max_interrupt_work = 50;
 
 /*
  * Optimization can be either throuput mode or cpu mode
@@ -812,7 +812,7 @@ enum {
 	NV_OPTIMIZATION_MODE_THROUGHPUT,
 	NV_OPTIMIZATION_MODE_CPU
 };
-static int optimization_mode = NV_OPTIMIZATION_MODE_THROUGHPUT;
+static int optimization_mode = NV_OPTIMIZATION_MODE_CPU;
 
 /*
  * Poll interval for timer irq
@@ -1902,6 +1902,11 @@ static void nv_tx_done(struct net_device
 						np->stats.tx_carrier_errors++;
 					np->stats.tx_errors++;
 				} else {
+					if (!np->get_tx_ctx->skb) {
+						printk("get_tx: %ld, put_tx: %ld\n", (long)(np->get_tx_ctx - np->first_tx_ctx), (long)(np->put_tx_ctx - np->first_tx_ctx));
+						WARN_ON(1);
+						break;
+					}
 					np->stats.tx_packets++;
 					np->stats.tx_bytes += np->get_tx_ctx->skb->len;
 				}
@@ -1917,6 +1922,11 @@ static void nv_tx_done(struct net_device
 						np->stats.tx_carrier_errors++;
 					np->stats.tx_errors++;
 				} else {
+					if (!np->get_tx_ctx->skb) {
+						printk("get_tx: %ld, put_tx: %ld\n", (long)(np->get_tx_ctx - np->first_tx_ctx), (long)(np->put_tx_ctx - np->first_tx_ctx));
+						WARN_ON(1);
+						break;
+					}
 					np->stats.tx_packets++;
 					np->stats.tx_bytes += np->get_tx_ctx->skb->len;
 				}
@@ -3108,9 +3118,17 @@ static int nv_napi_poll(struct net_devic
 	int retcode;
 
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+		spin_lock_irqsave(&np->lock, flags);
+		nv_tx_done(dev);
+		spin_unlock_irqrestore(&np->lock, flags);
+
 		pkts = nv_rx_process(dev, limit);
 		retcode = nv_alloc_rx(dev);
 	} else {
+		spin_lock_irqsave(&np->lock, flags);
+		nv_tx_done_optimized(dev, np->tx_ring_size);
+		spin_unlock_irqrestore(&np->lock, flags);
+
 		pkts = nv_rx_process_optimized(dev, limit);
 		retcode = nv_alloc_rx_optimized(dev);
 	}

--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="eth0.dump"

Offset	Value
--------	-----
00	0x72
01	0x00
02	0x00
03	0x00
04	0xe7
05	0x00
06	0x00
07	0x00
08	0x03
09	0x00
10	0x00
11	0x00
12	0x0d
13	0x00
14	0x08
15	0x00
16	0x00
17	0x00
18	0x00
19	0x00
20	0x00
21	0x00
22	0x00
23	0x00
24	0x00
25	0x00
26	0x00
27	0x00
28	0x00
29	0x00
30	0x00
31	0x00
32	0x00
33	0x53
34	0x25
35	0x06
36	0x65
37	0x13
38	0x70
39	0xff
40	0x00
41	0x00
42	0x00
43	0x00
44	0x00
45	0x00
46	0x00
47	0x00
48	0x00
49	0x00
50	0x00
51	0x00
52	0x00
53	0x00
54	0x00
55	0x00
56	0x00
57	0x00
58	0x00
59	0x00
60	0x00
61	0x00
62	0x00
63	0x00
64	0x0e
65	0xe2
66	0x20
67	0x04
68	0x55
69	0xa8
70	0x00
71	0x00
72	0x20
73	0x2e
74	0x00
75	0x00
76	0x00
77	0x00
78	0x00
79	0x00
80	0x00
81	0x00
82	0x00
83	0x00
84	0x00
85	0x00
86	0x00
87	0x00
88	0x00
89	0x00
90	0x00
91	0x00
92	0x00
93	0x00
94	0x00
95	0x00
96	0x00
97	0x00
98	0x00
99	0x00
100	0x00
101	0x00
102	0x00
103	0x00
104	0x00
105	0x00
106	0x00
107	0x00
108	0x00
109	0x00
110	0x00
111	0x00
112	0x00
113	0x00
114	0x00
115	0x00
116	0x00
117	0x00
118	0x00
119	0x00
120	0x00
121	0x00
122	0x00
123	0x00
124	0x00
125	0x00
126	0x00
127	0x00
128	0x3c
129	0x0f
130	0x3b
131	0x00
132	0x01
133	0x00
134	0x00
135	0x00
136	0x00
137	0x00
138	0x04
139	0x00
140	0x28
141	0x00
142	0x7f
143	0x00
144	0x1c
145	0x06
146	0x00
147	0x00
148	0x01
149	0x00
150	0x00
151	0x00
152	0x00
153	0x00
154	0x00
155	0x00
156	0xa5
157	0x7f
158	0x00
159	0x00
160	0x0f
161	0x05
162	0x14
163	0x00
164	0x16
165	0x00
166	0x00
167	0x00
168	0x00
169	0x13
170	0xd4
171	0xdc
172	0x41
173	0x12
174	0x00
175	0x00
176	0x01
177	0x00
178	0x5e
179	0x00
180	0x00
181	0x01
182	0x00
183	0x00
184	0xff
185	0xff
186	0xff
187	0xff
188	0xff
189	0xff
190	0x00
191	0x00
192	0x02
193	0x00
194	0x00
195	0x10
196	0x01
197	0x00
198	0x00
199	0x00
200	0x01
201	0x00
202	0x00
203	0x00
204	0x01
205	0x00
206	0x00
207	0x00
208	0x01
209	0x00
210	0x00
211	0x00
212	0x01
213	0x00
214	0x00
215	0x00
216	0x01
217	0x00
218	0x00
219	0x00
220	0x01
221	0x00
222	0x00
223	0x00
224	0x01
225	0x00
226	0x00
227	0x00
228	0x01
229	0x00
230	0x00
231	0x00
232	0x01
233	0x00
234	0x00
235	0x00
236	0x01
237	0x00
238	0x00
239	0x00
240	0x01
241	0x00
242	0x00
243	0x00
244	0x01
245	0x00
246	0x00
247	0x00
248	0x01
249	0x00
250	0x00
251	0x00
252	0x01
253	0x00
254	0x00
255	0x00
256	0x00
257	0x68
258	0xa3
259	0x04
260	0x00
261	0x60
262	0xa3
263	0x04
264	0xff
265	0x00
266	0x7f
267	0x00
268	0x00
269	0x80
270	0x00
271	0x00
272	0x32
273	0x00
274	0x01
275	0x00
276	0x00
277	0x00
278	0x00
279	0x00
280	0x1f
281	0x00
282	0x00
283	0x00
284	0x00
285	0x6d
286	0xa3
287	0x04
288	0xa0
289	0x60
290	0xa3
291	0x04
292	0x40
293	0x48
294	0x32
295	0x1a
296	0xeb
297	0xff
298	0x00
299	0xa0
300	0x10
301	0xc8
302	0x71
303	0x3e
304	0x1c
305	0x06
306	0x00
307	0x80
308	0x0c
309	0x6d
310	0xa3
311	0x04
312	0xbc
313	0x67
314	0xa3
315	0x04
316	0x00
317	0x80
318	0xe0
319	0x0f
320	0x20
321	0x41
322	0x30
323	0x00
324	0x00
325	0x26
326	0x00
327	0x80
328	0x00
329	0x00
330	0x00
331	0x00
332	0x00
333	0x00
334	0x00
335	0x00
336	0x00
337	0x00
338	0x00
339	0x00
340	0x00
341	0x00
342	0x00
343	0x00
344	0x00
345	0x00
346	0x00
347	0x00
348	0x00
349	0x00
350	0x00
351	0x00
352	0x00
353	0x00
354	0x00
355	0x00
356	0x00
357	0x00
358	0x00
359	0x00
360	0x00
361	0x00
362	0x00
363	0x00
364	0x00
365	0x00
366	0x00
367	0x00
368	0x00
369	0x00
370	0x00
371	0x00
372	0x00
373	0x00
374	0x00
375	0x00
376	0x00
377	0x00
378	0x00
379	0x00
380	0x00
381	0x00
382	0x00
383	0x00
384	0x1e
385	0x00
386	0x00
387	0x00
388	0x08
389	0x00
390	0x00
391	0x00
392	0x6d
393	0x79
394	0x94
395	0x09
396	0x03
397	0x81
398	0x00
399	0x00
400	0x2a
401	0x01
402	0x00
403	0x00
404	0x00
405	0x78
406	0x00
407	0x00
408	0x0f
409	0x00
410	0x94
411	0x09
412	0x03
413	0x00
414	0x00
415	0x00
416	0x1e
417	0x00
418	0x00
419	0x00
420	0x08
421	0x00
422	0x00
423	0x00
424	0x6d
425	0x79
426	0x94
427	0x09
428	0x03
429	0x81
430	0x00
431	0x00
432	0x2a
433	0x01
434	0x00
435	0x00
436	0x00
437	0x78
438	0x00
439	0x00
440	0x0f
441	0x00
442	0x94
443	0x09
444	0x03
445	0x00
446	0x00
447	0x00
448	0x1e
449	0x00
450	0x00
451	0x00
452	0x08
453	0x00
454	0x00
455	0x00
456	0x6d
457	0x79
458	0x94
459	0x09
460	0x03
461	0x81
462	0x00
463	0x00
464	0x2a
465	0x01
466	0x00
467	0x00
468	0x00
469	0x78
470	0x00
471	0x00
472	0x0f
473	0x00
474	0x94
475	0x09
476	0x03
477	0x00
478	0x00
479	0x00
480	0x1e
481	0x00
482	0x00
483	0x00
484	0x08
485	0x00
486	0x00
487	0x00
488	0x6d
489	0x79
490	0x94
491	0x09
492	0x03
493	0x81
494	0x00
495	0x00
496	0x2a
497	0x01
498	0x00
499	0x00
500	0x00
501	0x78
502	0x00
503	0x00
504	0x0f
505	0x00
506	0x94
507	0x09
508	0x03
509	0x00
510	0x00
511	0x00
512	0x00
513	0x00
514	0x00
515	0x00
516	0x00
517	0x00
518	0x00
519	0x00
520	0x00
521	0x00
522	0x00
523	0x00
524	0x00
525	0x00
526	0x00
527	0x00
528	0x00
529	0x00
530	0x00
531	0x00
532	0x00
533	0x00
534	0x00
535	0x00
536	0x00
537	0x00
538	0x00
539	0x00
540	0x00
541	0x00
542	0x00
543	0x00
544	0x00
545	0x00
546	0x00
547	0x00
548	0x00
549	0x00
550	0x00
551	0x00
552	0x00
553	0x00
554	0x00
555	0x00
556	0x00
557	0x00
558	0x00
559	0x00
560	0x00
561	0x00
562	0x00
563	0x00
564	0x00
565	0x00
566	0x00
567	0x00
568	0x00
569	0x00
570	0x00
571	0x00
572	0x00
573	0x00
574	0x00
575	0x00
576	0x00
577	0x00
578	0x00
579	0x00
580	0x00
581	0x00
582	0x00
583	0x00
584	0x00
585	0x00
586	0x00
587	0x00
588	0x00
589	0x00
590	0x00
591	0x00
592	0x00
593	0x00
594	0x00
595	0x00
596	0x00
597	0x00
598	0x00
599	0x00
600	0x00
601	0x00
602	0x00
603	0x00
604	0x00
605	0x00
606	0x00
607	0x00
608	0x00
609	0x00
610	0x00
611	0x00
612	0x00
613	0x00
614	0x00
615	0x00
616	0x01
617	0x00
618	0x02
619	0xfe
620	0x00
621	0x01
622	0x00
623	0x00
624	0x00
625	0x00
626	0x00
627	0x00
628	0x00
629	0x00
630	0x00
631	0x00
632	0x01
633	0x00
634	0x02
635	0x7e
636	0x00
637	0x01
638	0x00
639	0x00
640	0xc0
641	0x00
642	0x00
643	0x00
644	0x03
645	0x00
646	0x00
647	0x00
648	0x00
649	0x00
650	0x00
651	0x00
652	0x00
653	0x00
654	0x00
655	0x00
656	0x00
657	0x00
658	0x00
659	0x00
660	0x00
661	0x00
662	0x00
663	0x00
664	0x00
665	0x00
666	0x00
667	0x00
668	0x00
669	0x00
670	0x00
671	0x00
672	0x00
673	0x00
674	0x00
675	0x00
676	0x00
677	0x00
678	0x00
679	0x00
680	0x00
681	0x00
682	0x00
683	0x00
684	0x00
685	0x00
686	0x00
687	0x00
688	0x00
689	0x00
690	0x00
691	0x00
692	0x00
693	0x00
694	0x00
695	0x00
696	0x00
697	0x00
698	0x00
699	0x00
700	0x00
701	0x00
702	0x00
703	0x00
704	0x00
705	0x00
706	0x00
707	0x00
708	0x00
709	0x00
710	0x00
711	0x00
712	0x00
713	0x00
714	0x00
715	0x00
716	0x00
717	0x00
718	0x00
719	0x00
720	0x00
721	0x00
722	0x00
723	0x00

eth0      Link encap:Ethernet  HWaddr 00:13:D4:DC:41:12  
          inet addr:10.0.1.12  Bcast:10.0.1.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:10957 errors:0 dropped:0 overruns:0 frame:0
          TX packets:14140 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:760457 (742.6 KiB)  TX bytes:1881680 (1.7 MiB)
          Interrupt:23 Base address:0xa000 

00:00.0 Memory controller: nVidia Corporation CK804 Memory Controller (rev a3)
	Subsystem: ASUSTeK Computer Inc. Unknown device 815a
	Flags: bus master, 66MHz, fast devsel, latency 0
	Capabilities: [44] HyperTransport: Slave or Primary Interface
	Capabilities: [e0] HyperTransport: MSI Mapping

00:01.0 ISA bridge: nVidia Corporation CK804 ISA Bridge (rev a3)
	Subsystem: ASUSTeK Computer Inc. K8N4-E Mainboard
	Flags: bus master, 66MHz, fast devsel, latency 0

00:01.1 SMBus: nVidia Corporation CK804 SMBus (rev a2)
	Subsystem: ASUSTeK Computer Inc. K8N4-E Mainboard
	Flags: 66MHz, fast devsel, IRQ 255
	I/O ports at dc00 [size=32]
	I/O ports at 4c00 [size=64]
	I/O ports at 4c40 [size=64]
	Capabilities: [44] Power Management version 2

00:02.0 USB Controller: nVidia Corporation CK804 USB Controller (rev a2) (prog-if 10 [OHCI])
	Subsystem: ASUSTeK Computer Inc. K8N4-E Mainboard
	Flags: bus master, 66MHz, fast devsel, latency 0, IRQ 255
	Memory at da102000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [44] Power Management version 2

00:02.1 USB Controller: nVidia Corporation CK804 USB Controller (rev a3) (prog-if 20 [EHCI])
	Subsystem: ASUSTeK Computer Inc. K8N4-E Mainboard
	Flags: bus master, 66MHz, fast devsel, latency 0, IRQ 255
	Memory at feb00000 (32-bit, non-prefetchable) [size=256]
	Capabilities: [44] Debug port
	Capabilities: [80] Power Management version 2

00:04.0 Multimedia audio controller: nVidia Corporation CK804 AC'97 Audio Controller (rev a2)
	Subsystem: ASUSTeK Computer Inc. K8N4-E Mainboard
	Flags: bus master, 66MHz, fast devsel, latency 0, IRQ 3
	I/O ports at d400 [size=256]
	I/O ports at d800 [size=256]
	Memory at da101000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [44] Power Management version 2

00:06.0 IDE interface: nVidia Corporation CK804 IDE (rev f2) (prog-if 8a [Master SecP PriP])
	Subsystem: ASUSTeK Computer Inc. K8N4-E Mainboard
	Flags: bus master, 66MHz, fast devsel, latency 0
	[virtual] Memory at 000001f0 (32-bit, non-prefetchable) [disabled] [size=8]
	[virtual] Memory at 000003f0 (type 3, non-prefetchable) [disabled] [size=1]
	[virtual] Memory at 00000170 (32-bit, non-prefetchable) [disabled] [size=8]
	[virtual] Memory at 00000370 (type 3, non-prefetchable) [disabled] [size=1]
	I/O ports at f000 [size=16]
	Capabilities: [44] Power Management version 2

00:09.0 PCI bridge: nVidia Corporation CK804 PCI Bridge (rev a2) (prog-if 01 [Subtractive decode])
	Flags: bus master, 66MHz, fast devsel, latency 0
	Bus: primary=00, secondary=05, subordinate=05, sec-latency=128
	I/O behind bridge: 0000c000-0000cfff
	Memory behind bridge: da000000-da0fffff

00:0a.0 Bridge: nVidia Corporation CK804 Ethernet Controller (rev a3)
	Subsystem: ASUSTeK Computer Inc. K8N4-E Mainboard
	Flags: bus master, 66MHz, fast devsel, latency 0, IRQ 23
	Memory at da100000 (32-bit, non-prefetchable) [size=4K]
	I/O ports at d000 [size=8]
	Capabilities: [44] Power Management version 2

00:0b.0 PCI bridge: nVidia Corporation CK804 PCIE Bridge (rev a3) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
	Capabilities: [40] Power Management version 2
	Capabilities: [48] Message Signalled Interrupts: 64bit+ Queue=0/1 Enable+
	Capabilities: [58] HyperTransport: MSI Mapping
	Capabilities: [80] Express Root Port (Slot+) IRQ 0
	Capabilities: [100] Virtual Channel

00:0c.0 PCI bridge: nVidia Corporation CK804 PCIE Bridge (rev a3) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
	Capabilities: [40] Power Management version 2
	Capabilities: [48] Message Signalled Interrupts: 64bit+ Queue=0/1 Enable+
	Capabilities: [58] HyperTransport: MSI Mapping
	Capabilities: [80] Express Root Port (Slot+) IRQ 0
	Capabilities: [100] Virtual Channel

00:0d.0 PCI bridge: nVidia Corporation CK804 PCIE Bridge (rev a3) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	Capabilities: [40] Power Management version 2
	Capabilities: [48] Message Signalled Interrupts: 64bit+ Queue=0/1 Enable+
	Capabilities: [58] HyperTransport: MSI Mapping
	Capabilities: [80] Express Root Port (Slot+) IRQ 0
	Capabilities: [100] Virtual Channel

00:0e.0 PCI bridge: nVidia Corporation CK804 PCIE Bridge (rev a3) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
	I/O behind bridge: 0000b000-0000bfff
	Memory behind bridge: d8000000-d9ffffff
	Prefetchable memory behind bridge: 00000000d0000000-00000000d7f00000
	Capabilities: [40] Power Management version 2
	Capabilities: [48] Message Signalled Interrupts: 64bit+ Queue=0/1 Enable+
	Capabilities: [58] HyperTransport: MSI Mapping
	Capabilities: [80] Express Root Port (Slot+) IRQ 0
	Capabilities: [100] Virtual Channel

00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] HyperTransport Technology Configuration
	Flags: fast devsel
	Capabilities: [80] HyperTransport: Host or Secondary Interface

00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Address Map
	Flags: fast devsel

00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] DRAM Controller
	Flags: fast devsel

00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Miscellaneous Control
	Flags: fast devsel

01:00.0 VGA compatible controller: ATI Technologies Inc RV370 5B60 [Radeon X300 (PCIE)] (prog-if 00 [VGA])
	Subsystem: PC Partner Limited Unknown device 0500
	Flags: bus master, fast devsel, latency 0, IRQ 5
	Memory at d0000000 (32-bit, prefetchable) [size=128M]
	I/O ports at b000 [size=256]
	Memory at d9000000 (32-bit, non-prefetchable) [size=64K]
	[virtual] Expansion ROM at d8000000 [disabled] [size=128K]
	Capabilities: [50] Power Management version 2
	Capabilities: [58] Express Endpoint IRQ 0
	Capabilities: [80] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
	Capabilities: [100] Advanced Error Reporting

01:00.1 Display controller: ATI Technologies Inc RV370 [Radeon X300SE]
	Subsystem: PC Partner Limited Unknown device 0501
	Flags: fast devsel
	Memory at d9010000 (32-bit, non-prefetchable) [disabled] [size=64K]
	Capabilities: [50] Power Management version 2
	Capabilities: [58] Express Endpoint IRQ 0

05:07.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8139/8139C/8139C+ (rev 10)
	Subsystem: Realtek Semiconductor Co., Ltd. RT8139
	Flags: bus master, medium devsel, latency 32, IRQ 17
	I/O ports at c000 [size=256]
	Memory at da000000 (32-bit, non-prefetchable) [size=256]
	Capabilities: [50] Power Management version 2

           CPU0       CPU1       
  0:        782          0   IO-APIC-edge      timer
  1:          0          8   IO-APIC-edge      i8042
  4:          1       1714   IO-APIC-edge      serial
  8:          0          0   IO-APIC-edge      rtc
  9:          0          0   IO-APIC-fasteoi   acpi
 12:          6         99   IO-APIC-edge      i8042
 14:      31560       6886   IO-APIC-edge      ide0
 17:          0          0   IO-APIC-fasteoi   eth1
 23:        209    2043903   IO-APIC-fasteoi   eth0
NMI:          0          0 
LOC:      72842      78904 
ERR:          0

--sdtB3X0nJg68CQEu--
