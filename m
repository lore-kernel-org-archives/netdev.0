From: Chris Boot <bootc@bootc.net>
Subject: Re: [PATCH RFC 0/2] e1000e: 82574 also needs ASPM L1
	completely disabled
Date: Sun, 29 Apr 2012 19:03:52 +0100
Message-ID: <4F9D8288.3000001@bootc.net>
References: <9BBC4E0CF881AA4299206E2E1412B6260E512E0C@ORSMSX102.amr.corp.intel.com>
	<1335216578-21542-1-git-send-email-bootc@bootc.net>
	<20120423161119.0000022f@unknown> <87y5pe1o89.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>, linux-kernel@vger.kernel.org
To: Nix <nix@esperi.org.uk>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <87y5pe1o89.fsf@spindle.srvr.nix>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 29/04/2012 17:45, Nix wrote:
> On 24 Apr 2012, Jesse Brandeburg outgrape:
>
>> Please let us know the results of your testing, we will let you know if
>> we see any issues as well.

Right, I have finally managed to test my patch on my servers. I've had a 
really tough week with them due to my cluster falling over inexplicably 
so I didn't want to change too much too soon after everything came back up.

The patch does properly disable ASPM L1 as well as L0s as before. Unlike 
for Nix, these do remain disabled. I'll keep running with the patch now 
but I'm confident this will solve my NIC lockups just as Nix's setpci 
incantations did.

Please apply the patches. I'd also really like to have them CCed to 
stable so that Debian will pick them up in time.

> Alas, it has no effect at all here; L0s and L1 claim to be being
> disabled at boot time, but if you ask with lspci you see that they are
> not. I strongly suspect that they *are* being disabled, but then get
> re-enabled by something else, because even if I force them off with
> setpci in the boot scripts, by the time the scripts have finished
> executing and I've got to a root prompt where I can run setpci, L0s and
> L1 are always back on again.

Indeed our troubles must be different. My patch definitely disables ASPM 
fully on the NIC and the upstream device as evidenced by lspci.

Here are extracts from the boot logs and lspci before my patch:

[    3.305372] e1000e: Intel(R) PRO/1000 Network Driver - 1.5.1-k
[    3.317015] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
[    3.328436] e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level, low) -> 
IRQ 20
[    3.328482] e1000e 0000:00:19.0: setting latency timer to 64
[    3.329493] e1000e 0000:00:19.0: irq 45 for MSI/MSI-X
[    3.679153] e1000e 0000:00:19.0: eth1: (PCI Express:2.5GT/s:Width x1) 
00:25:90:56:ac:d1
[    3.691391] e1000e 0000:00:19.0: eth1: Intel(R) PRO/1000 Network 
Connection
[    3.703689] e1000e 0000:00:19.0: eth1: MAC: 10, PHY: 11, PBA No: 
FFFFFF-0FF
[    3.715639] e1000e 0000:05:00.0: Disabling ASPM L0s
[    4.156806] e1000e 0000:05:00.0: PCI INT A -> GSI 16 (level, low) -> 
IRQ 16
[    4.371659] e1000e 0000:05:00.0: setting latency timer to 64
[    4.371928] e1000e 0000:05:00.0: irq 65 for MSI/MSI-X
[    4.371933] e1000e 0000:05:00.0: irq 66 for MSI/MSI-X
[    4.371937] e1000e 0000:05:00.0: irq 67 for MSI/MSI-X
[    4.485505] e1000e 0000:05:00.0: eth3: (PCI Express:2.5GT/s:Width x1) 
00:25:90:56:ac:d0
[    4.485507] e1000e 0000:05:00.0: eth3: Intel(R) PRO/1000 Network 
Connection
[    4.485647] e1000e 0000:05:00.0: eth3: MAC: 3, PHY: 8, PBA No: FFFFFF-0FF
[   14.237551] e1000e 0000:00:19.0: irq 45 for MSI/MSI-X
[   14.293193] e1000e 0000:00:19.0: irq 45 for MSI/MSI-X
[   16.160177] e1000e: eth2 NIC Link is Up 100 Mbps Full Duplex, Flow 
Control: None
[   16.174293] e1000e 0000:05:00.0: eth2: 10/100 speed: disabling TSO

tidyup ~ # lspci -vvv -s 05:00.0 | grep ASPM
                 LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, 
Latency L0 <128ns, L1 <64us
                 LnkCtl: ASPM L1 Enabled; RCB 64 bytes Disabled- 
Retrain- CommClk+
tidyup ~ # lspci -vvv -s 00:1c.4 | grep ASPM
                 LnkCap: Port #5, Speed 5GT/s, Width x1, ASPM L0s L1, 
Latency L0 <512ns, L1 <4us
                 LnkCtl: ASPM L1 Enabled; RCB 64 bytes Disabled- 
Retrain- CommClk+

And now the same kernel with the patch applied:

[    3.310165] e1000e: Intel(R) PRO/1000 Network Driver - 1.5.1-k
[    3.321625] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
[    3.332996] e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level, low) -> 
IRQ 20
[    3.413898] e1000e 0000:00:19.0: setting latency timer to 64
[    3.426699] e1000e 0000:00:19.0: irq 54 for MSI/MSI-X
[    3.731112] e1000e 0000:00:19.0: eth2: (PCI Express:2.5GT/s:Width x1) 
00:25:90:56:ac:d1
[    3.743437] e1000e 0000:00:19.0: eth2: Intel(R) PRO/1000 Network 
Connection
[    3.755918] e1000e 0000:00:19.0: eth2: MAC: 10, PHY: 11, PBA No: 
FFFFFF-0FF
[    3.768758] e1000e 0000:05:00.0: Disabling ASPM L0s L1
[    3.794095] e1000e 0000:05:00.0: PCI INT A -> GSI 16 (level, low) -> 
IRQ 16
[    3.794178] e1000e 0000:05:00.0: setting latency timer to 64
[    3.795074] e1000e 0000:05:00.0: irq 64 for MSI/MSI-X
[    3.795088] e1000e 0000:05:00.0: irq 65 for MSI/MSI-X
[    3.795107] e1000e 0000:05:00.0: irq 66 for MSI/MSI-X
[    3.912691] e1000e 0000:05:00.0: eth3: (PCI Express:2.5GT/s:Width x1) 
00:25:90:56:ac:d0
[    3.912693] e1000e 0000:05:00.0: eth3: Intel(R) PRO/1000 Network 
Connection
[    3.912842] e1000e 0000:05:00.0: eth3: MAC: 3, PHY: 8, PBA No: FFFFFF-0FF
[   14.454955] e1000e 0000:00:19.0: irq 54 for MSI/MSI-X
[   14.507724] e1000e 0000:00:19.0: irq 54 for MSI/MSI-X
[   15.944706] e1000e: eth2 NIC Link is Up 100 Mbps Full Duplex, Flow 
Control: None
[   15.956279] e1000e 0000:05:00.0: eth2: 10/100 speed: disabling TSO

tidyup ~ # lspci -vvv -s 05:00.0 | grep ASPM
                 LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, 
Latency L0 <128ns, L1 <64us
                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- 
CommClk+
tidyup ~ # lspci -vvv -s 00:1c.4 | grep ASPM
                 LnkCap: Port #5, Speed 5GT/s, Width x1, ASPM L0s L1, 
Latency L0 <512ns, L1 <4us
                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- 
CommClk+

Cheers,
Chris

-- 
Chris Boot
bootc@bootc.net


------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
