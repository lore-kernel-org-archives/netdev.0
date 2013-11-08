From: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: transmit lockup using smsc95xx ethernet on usb3
Date: Thu, 7 Nov 2013 16:45:53 -0800
Message-ID: <20131108004553.GC11529@xanatos>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B738B@saturn3.aculab.com>
 <20131017000758.GL7082@xanatos>
 <AE90C24D6B3A694183C094C60CF0A2F6026B73BA@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Xenia Ragiadakou <burzalodowa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73BA-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 28, 2013 at 05:09:25PM -0000, David Laight wrote:
> > > We are seeing complete lockups of the transmit side when using
> > > the smsc95xx driver connected to a USB3 port on an i7 (Ivybridge) cpu.
> > > These errors are very intermittent - less than once a day, and
> > > it isn't actually clear that they are related to traffic load.
> ...
> > I would suggest you try with the latest stable kernel, with
> > CONFIG_USB_DEBUG enabled.
> 
> I've finally got the same failure with a 3.12-0-rc5 kernel.
> The only change I made was to comment out the 'short packet' trace.
> 
> The kernel trace contains:
> (I've shortened the lines by removing the fixed part of the header.
> I've got the full trace, and the matching usbmon trace, but they
> are a bit large to post to the mailing lists!

The log was good enough, analysis below:

> All from xhci_hcd 0000:00:14.0
> [38704.116936] Transfer error on endpoint
> [38704.116941] Cleaning up stalled endpoint ring
> [38704.116944] Finding segment containing stopped TRB.
> [38704.116946] Finding endpoint context
> [38704.116948] Finding segment containing last TRB in TD.
> [38704.116950] Cycle state = 0x0
> [38704.116952] New dequeue segment = ffff880214565660 (virtual)
> [38704.116954] New dequeue pointer = 0x210cf4ad0 (DMA)
> [38704.116956] Queueing new dequeue state
> [38704.116959] Set TR Deq Ptr cmd, new deq seg = ffff880214565660 (0x210cf4800 dma), new deq ptr = ffff880210cf4ad0 (0x210cf4ad0 dma), new cycle = 0
> [38704.116962] // Ding dong!
> [38704.116966] Giveback URB ffff8800d6841d80, len = 0, expected = 18944, status = -71
> [38704.116970] Transfer error on endpoint
> [38704.116973] Cleaning up stalled endpoint ring
> [38704.116974] Finding segment containing stopped TRB.
> [38704.116976] Finding endpoint context
> [38704.116978] Finding segment containing last TRB in TD.
> [38704.116980] Cycle state = 0x1
> [38704.116982] New dequeue segment = ffff880214565680 (virtual)
> [38704.116984] New dequeue pointer = 0x210cf47e0 (DMA)
> [38704.116986] Queueing new dequeue state
> [38704.116989] Set TR Deq Ptr cmd, new deq seg = ffff880214565680 (0x210cf4400 dma), new deq ptr = ffff880210cf47e0 (0x210cf47e0 dma), new cycle = 1
> [38704.116991] // Ding dong!
> [38704.116995] Giveback URB ffff8802132169c0, len = 1024, expected = 1526, status = -71
> [38704.116998] Ignoring reset ep completion code of 1
> [38704.117001] Successful Set TR Deq Ptr cmd, deq = @210cf4ad0
> [38704.117004] Ignoring reset ep completion code of 1
> [38704.117006] Successful Set TR Deq Ptr cmd, deq = @210cf47e1

> [38704.240067] Stalled endpoint
> [38704.240075] Giveback URB ffff8800d4438900, len = 0, expected = 1526, status = -32

So it looks like the endpoint stalls, and then the USB device driver
never clears the halted condition.  If the endpoint was anything other
than a control endpoint, that's a driver bug.

> [38704.240112] Cancel URB ffff8800d4438b40, dev 1.1, ep 0x2, starting at offset 0x210cf4030
> [38704.240118] // Ding dong!
> [38704.240124] Cancel URB ffff8800d4438cc0, dev 1.1, ep 0x2, starting at offset 0x210cf4040
> [38704.240129] Removing canceled TD starting at 0x210cf4030 (dma).
> [38704.240132] TRB to noop at offset 0x210cf4030
> [38704.240134] Removing canceled TD starting at 0x210cf4040 (dma).
> [38704.240136] TRB to noop at offset 0x210cf4040

If these transfers were queued for the same endpoint that halted, the
endpoint is still stopped, and it would make sense that they would need
to be canceled.  No transfers will occur until the halt condition is
cleared through the Reset Endpoint command, and the doorbell ring is
rung for the endpoint after the Set TR Dequeue Pointer command.

> [38704.240155] WARN halted endpoint, queueing URB anyway.
> [38704.240163] WARN halted endpoint, queueing URB anyway.
> [38704.240170] WARN halted endpoint, queueing URB anyway.

These warnings are consistent with the USB device driver not clearing
the stall.

> [38704.240177] Cancel URB ffff8800d4438840, dev 1.1, ep 0x2, starting at offset 0x210cf4050
> [38704.240179] // Ding dong!
> [38704.240184] Cancel URB ffff8800d44389c0, dev 1.1, ep 0x2, starting at offset 0x210cf4060
> [38704.240189] Removing canceled TD starting at 0x210cf4050 (dma).
> [38704.240191] TRB to noop at offset 0x210cf4050
> [38704.240193] Removing canceled TD starting at 0x210cf4060 (dma).
> [38704.240195] TRB to noop at offset 0x210cf4060
> [38704.240205] WARN halted endpoint, queueing URB anyway.
> [38704.240210] WARN halted endpoint, queueing URB anyway.
> [38704.240216] Cancel URB ffff8800d4438c00, dev 1.1, ep 0x2, starting at offset 0x210cf4070
> [38704.240219] // Ding dong!
> [38704.240224] Cancel URB ffff8800d4438a80, dev 1.1, ep 0x2, starting at offset 0x210cf4080
> [38704.240228] Removing canceled TD starting at 0x210cf4070 (dma).
> [38704.240230] TRB to noop at offset 0x210cf4070
> [38704.240232] Removing canceled TD starting at 0x210cf4080 (dma).
> [38704.240234] TRB to noop at offset 0x210cf4080
> [38704.240244] WARN halted endpoint, queueing URB anyway.
> [38704.240249] WARN halted endpoint, queueing URB anyway.

...and the cycle continues endlessly, as the USB device driver tries to
submit URBs to a stalled endpoint.

> [38704.240255] Cancel URB ffff8800d4438780, dev 1.1, ep 0x2, starting at offset 0x210cf4090
> [38704.240257] // Ding dong!
> [38704.240262] Cancel URB ffff8800d4438480, dev 1.1, ep 0x2, starting at offset 0x210cf40a0
> [38704.240266] Cancel URB ffff8800d44386c0, dev 1.1, ep 0x2, starting at offset 0x210cf40b0
> [38704.240271] Removing canceled TD starting at 0x210cf4090 (dma).
> [38704.240273] TRB to noop at offset 0x210cf4090
> [38704.240275] Removing canceled TD starting at 0x210cf40a0 (dma).
> [38704.240277] TRB to noop at offset 0x210cf40a0
> [38704.240279] Removing canceled TD starting at 0x210cf40b0 (dma).
> [38704.240281] TRB to noop at offset 0x210cf40b0
> [38704.240292] WARN halted endpoint, queueing URB anyway.
> [38704.240296] WARN halted endpoint, queueing URB anyway.
> [38704.240301] WARN halted endpoint, queueing URB anyway.
> [38704.240307] Cancel URB ffff8800d4438900, dev 1.1, ep 0x2, starting at offset 0x210cf40c0
> [38704.240309] // Ding dong!
> [38704.240314] Cancel URB ffff8800d4438b40, dev 1.1, ep 0x2, starting at offset 0x210cf40d0
> [38704.240319] Removing canceled TD starting at 0x210cf40c0 (dma).
> [38704.240321] TRB to noop at offset 0x210cf40c0
> [38704.240323] Removing canceled TD starting at 0x210cf40d0 (dma).
> [38704.240325] TRB to noop at offset 0x210cf40d0
> [38704.240335] WARN halted endpoint, queueing URB anyway.
> [38704.240340] WARN halted endpoint, queueing URB anyway.
> [38704.240346] Cancel URB ffff8800d4438f00, dev 1.1, ep 0x2, starting at offset 0x210cf40e0
> [38704.240348] // Ding dong!
> [38704.240353] Cancel URB ffff8800d4438840, dev 1.1, ep 0x2, starting at offset 0x210cf40f0
> [38704.240357] Removing canceled TD starting at 0x210cf40e0 (dma).
> [38704.240359] TRB to noop at offset 0x210cf40e0
> [38704.240361] Removing canceled TD starting at 0x210cf40f0 (dma).
> [38704.240363] TRB to noop at offset 0x210cf40f0
> [38704.240373] WARN halted endpoint, queueing URB anyway.
> [38704.240378] WARN halted endpoint, queueing URB anyway.
> [38704.240384] Cancel URB ffff8800d4438cc0, dev 1.1, ep 0x2, starting at offset 0x210cf4100
> [38704.240386] // Ding dong!
> [38704.240391] Cancel URB ffff8800d4438c00, dev 1.1, ep 0x2, starting at offset 0x210cf4110
> [38704.240395] Cancel URB ffff8800d44389c0, dev 1.1, ep 0x2, starting at offset 0x210cf4120
> [38704.240400] Removing canceled TD starting at 0x210cf4100 (dma).
> [38704.240402] TRB to noop at offset 0x210cf4100
> [38704.240404] Removing canceled TD starting at 0x210cf4110 (dma).
> [38704.240406] TRB to noop at offset 0x210cf4110
> [38704.240408] Removing canceled TD starting at 0x210cf4120 (dma).
> [38704.240410] TRB to noop at offset 0x210cf4120
> [38704.240420] WARN halted endpoint, queueing URB anyway.
> [38704.240425] WARN halted endpoint, queueing URB anyway.
> [38704.240430] WARN halted endpoint, queueing URB anyway.
> [38704.240436] Cancel URB ffff8800d4438480, dev 1.1, ep 0x2, starting at offset 0x210cf4130
> [38704.240438] // Ding dong!
> [38704.240443] Cancel URB ffff8800d4438780, dev 1.1, ep 0x2, starting at offset 0x210cf4140
> [38704.240447] Removing canceled TD starting at 0x210cf4130 (dma).
> [38704.240449] TRB to noop at offset 0x210cf4130
> [38704.240451] Removing canceled TD starting at 0x210cf4140 (dma).
> [38704.240453] TRB to noop at offset 0x210cf4140
> [38704.240463] WARN halted endpoint, queueing URB anyway.
> [38704.240468] WARN halted endpoint, queueing URB anyway.
> [38704.240474] Cancel URB ffff8800d4438a80, dev 1.1, ep 0x2, starting at offset 0x210cf4150
> [38704.240476] // Ding dong!
> [38704.240481] Cancel URB ffff8800d4438900, dev 1.1, ep 0x2, starting at offset 0x210cf4160
> [38704.240486] Removing canceled TD starting at 0x210cf4150 (dma).
> [38704.240488] TRB to noop at offset 0x210cf4150
> [38704.240490] Removing canceled TD starting at 0x210cf4160 (dma).
> [38704.240492] TRB to noop at offset 0x210cf4160
> [38704.240501] WARN halted endpoint, queueing URB anyway.
> [38704.240506] WARN halted endpoint, queueing URB anyway.
> [38704.240512] Cancel URB ffff8800d44386c0, dev 1.1, ep 0x2, starting at offset 0x210cf4170
> [38704.240514] // Ding dong!
> [38704.240519] Cancel URB ffff8800d4438f00, dev 1.1, ep 0x2, starting at offset 0x210cf4180
> [38704.240524] Cancel URB ffff8800d4438b40, dev 1.1, ep 0x2, starting at offset 0x210cf4190
> [38704.240528] Removing canceled TD starting at 0x210cf4170 (dma).
> [38704.240530] TRB to noop at offset 0x210cf4170
> [38704.240532] Removing canceled TD starting at 0x210cf4180 (dma).
> [38704.240535] TRB to noop at offset 0x210cf4180
> [38704.240537] Removing canceled TD starting at 0x210cf4190 (dma).
> [38704.240539] TRB to noop at offset 0x210cf4190
> [38704.240549] WARN halted endpoint, queueing URB anyway.
> [38704.240554] WARN halted endpoint, queueing URB anyway.
> [38704.240559] WARN halted endpoint, queueing URB anyway.
> [38704.240565] Cancel URB ffff8800d4438c00, dev 1.1, ep 0x2, starting at offset 0x210cf41a0
> [38704.240567] // Ding dong!
> [38704.240572] Cancel URB ffff8800d4438cc0, dev 1.1, ep 0x2, starting at offset 0x210cf41b0
> [38704.240577] Removing canceled TD starting at 0x210cf41a0 (dma).
> [38704.240579] TRB to noop at offset 0x210cf41a0
> [38704.240581] Removing canceled TD starting at 0x210cf41b0 (dma).
> [38704.240583] TRB to noop at offset 0x210cf41b0
> [38704.240592] WARN halted endpoint, queueing URB anyway.
> [38704.240598] WARN halted endpoint, queueing URB anyway.
> [38704.240603] Cancel URB ffff8800d4438840, dev 1.1, ep 0x2, starting at offset 0x210cf41c0
> [38704.240605] // Ding dong!
> [38704.240610] Cancel URB ffff8800d4438480, dev 1.1, ep 0x2, starting at offset 0x210cf41d0
> [38704.240614] Cancel URB ffff8800d44389c0, dev 1.1, ep 0x2, starting at offset 0x210cf41e0
> [38704.240618] Removing canceled TD starting at 0x210cf41c0 (dma).
> [38704.240620] TRB to noop at offset 0x210cf41c0
> [38704.240623] Removing canceled TD starting at 0x210cf41d0 (dma).
> [38704.240625] TRB to noop at offset 0x210cf41d0
> [38704.240627] Removing canceled TD starting at 0x210cf41e0 (dma).
> [38704.240629] TRB to noop at offset 0x210cf41e0
> [38704.240639] WARN halted endpoint, queueing URB anyway.
> [38704.240644] WARN halted endpoint, queueing URB anyway.
> [38704.240648] WARN halted endpoint, queueing URB anyway.
> [38704.240654] Cancel URB ffff8800d4438a80, dev 1.1, ep 0x2, starting at offset 0x210cf41f0
> [38704.240656] // Ding dong!
> [38704.240661] Cancel URB ffff8800d4438780, dev 1.1, ep 0x2, starting at offset 0x210cf4200
> [38704.240665] Removing canceled TD starting at 0x210cf41f0 (dma).
> [38704.240667] TRB to noop at offset 0x210cf41f0
> [38704.240669] Removing canceled TD starting at 0x210cf4200 (dma).
> [38704.240671] TRB to noop at offset 0x210cf4200
> [38704.240681] WARN halted endpoint, queueing URB anyway.
> [38704.240687] Cancel URB ffff8800d4438f00, dev 1.1, ep 0x2, starting at offset 0x210cf4210
> [38704.240689] // Ding dong!
> [38704.240694] Cancel URB ffff8800d44386c0, dev 1.1, ep 0x2, starting at offset 0x210cf4220
> [38704.240699] Cancel URB ffff8800d4438900, dev 1.1, ep 0x2, starting at offset 0x210cf4230
> [38704.240703] Cancel URB ffff8800d4438c00, dev 1.1, ep 0x2, starting at offset 0x210cf4240
> [38704.240707] Removing canceled TD starting at 0x210cf4210 (dma).
> [38704.240709] TRB to noop at offset 0x210cf4210
> [38704.240711] Removing canceled TD starting at 0x210cf4220 (dma).
> [38704.240713] TRB to noop at offset 0x210cf4220
> [38704.240716] Removing canceled TD starting at 0x210cf4230 (dma).
> [38704.240718] TRB to noop at offset 0x210cf4230
> [38704.240720] Removing canceled TD starting at 0x210cf4240 (dma).
> [38704.240722] TRB to noop at offset 0x210cf4240
> [38704.240733] Cancel URB ffff8800d4438b40, dev 1.1, ep 0x2, starting at offset 0x210cf4250
> [38704.240735] // Ding dong!
> [38704.240740] Cancel URB ffff8800d4438480, dev 1.1, ep 0x2, starting at offset 0x210cf4260
> [38704.240745] Removing canceled TD starting at 0x210cf4250 (dma).
> [38704.240747] TRB to noop at offset 0x210cf4250
> [38704.240749] Removing canceled TD starting at 0x210cf4260 (dma).
> [38704.240751] TRB to noop at offset 0x210cf4260
> [38704.240764] Cancel URB ffff8800d4438840, dev 1.1, ep 0x2, starting at offset 0x210cf4270
> [38704.240766] // Ding dong!
> [38704.240771] Cancel URB ffff8800d4438cc0, dev 1.1, ep 0x2, starting at offset 0x210cf4280
> [38704.240776] Cancel URB ffff8800d4438a80, dev 1.1, ep 0x2, starting at offset 0x210cf4290
> [38704.240787] Removing canceled TD starting at 0x210cf4270 (dma).
> [38704.240789] TRB to noop at offset 0x210cf4270
> [38704.240791] Removing canceled TD starting at 0x210cf4280 (dma).
> [38704.240793] TRB to noop at offset 0x210cf4280
> [38704.240796] Removing canceled TD starting at 0x210cf4290 (dma).
> [38704.240798] TRB to noop at offset 0x210cf4290

Finally, something changes, and the driver clears the halted condition:

> [38704.240812] Queueing reset endpoint command
> [38704.240814] Cleaning up stalled endpoint ring
> [38704.240816] Finding segment containing stopped TRB.
> [38704.240818] Finding endpoint context
> [38704.240820] Finding segment containing last TRB in TD.
> [38704.240822] Cycle state = 0x0
> [38704.240825] New dequeue segment = ffff8802145657a0 (virtual)
> [38704.240827] New dequeue pointer = 0x210cf4030 (DMA)
> [38704.240829] Queueing new dequeue state
> [38704.240832] Set TR Deq Ptr cmd, new deq seg = ffff8802145657a0 (0x210cf4000 dma), new deq ptr = ffff880210cf4030 (0x210cf4030 dma), new cycle = 0
> [38704.240834] // Ding dong!
> [38704.240843] Ignoring reset ep completion code of 1
> [38704.240846] Successful Set TR Deq Ptr cmd, deq = @210cf4030

The next time it finds a stalled endpoint, it clears the halted
condition right away:

> [38704.332072] Stalled endpoint
> [38704.332080] Giveback URB ffff8800d4438480, len = 0, expected = 1526, status = -32
> [38704.332135] Queueing reset endpoint command
> [38704.332138] Cleaning up stalled endpoint ring
> [38704.332140] Finding segment containing stopped TRB.
> [38704.332142] Finding endpoint context
> [38704.332144] Finding segment containing last TRB in TD.
> [38704.332146] Cycle state = 0x0
> [38704.332149] New dequeue segment = ffff8802145657a0 (virtual)
> [38704.332151] New dequeue pointer = 0x210cf42b0 (DMA)
> [38704.332153] Queueing new dequeue state
> [38704.332156] Set TR Deq Ptr cmd, new deq seg = ffff8802145657a0 (0x210cf4000 dma), new deq ptr = ffff880210cf42b0 (0x210cf42b0 dma), new cycle = 0
> [38704.332158] // Ding dong!
> [38704.332170] Ignoring reset ep completion code of 1
> [38704.332175] Successful Set TR Deq Ptr cmd, deq = @210cf42b0

You should take a close look at the code that clears the halted
conditions when an URB is returned with -EPIPE.  I suspect there's some
sort of race condition that means URBs are submitted to endpoints that
are stalled, and the stall never gets cleared.

> From then on this gets traced every few seconds - probably whenever
> dhclient tries to send a packet.
> 
> [38704.747916] Stalled endpoint
> [38704.747924] Giveback URB ffff8800d4438480, len = 0, expected = 1526, status = -32
> [38704.747972] Queueing reset endpoint command
> [38704.747982] Cleaning up stalled endpoint ring
> [38704.747984] Finding segment containing stopped TRB.
> [38704.747986] Finding endpoint context
> [38704.747988] Finding segment containing last TRB in TD.
> [38704.747990] Cycle state = 0x0
> [38704.747992] New dequeue segment = ffff8802145657a0 (virtual)
> [38704.747994] New dequeue pointer = 0x210cf42c0 (DMA)
> [38704.747996] Queueing new dequeue state
> [38704.747999] Set TR Deq Ptr cmd, new deq seg = ffff8802145657a0 (0x210cf4000 dma), new deq ptr = ffff880210cf42c0 (0x210cf42c0 dma), new cycle = 0
> [38704.748002] // Ding dong!
> [38704.748010] Ignoring reset ep completion code of 1
> [38704.748018] Successful Set TR Deq Ptr cmd, deq = @210cf42c0
> 
> The only way to recover is to unplug and replug.

Are you saying that after the driver doesn't clear the stall on the
endpoint, the device always responds with a stalled packet?

Sarah Sharp
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
