From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH 00/13] mvneta Buffer Management and enhancements
Date: Mon, 30 Nov 2015 20:53:44 +0100
Message-ID: <CAPv3WKc+HbirDxKy5n6W5O5BUTDEc3X5et5dTKdp81WOXjphGg@mail.gmail.com>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
	<87lh9f4dbt.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Simon Guinot <simon.guinot@sequanux.org>, nadavh@marvell.com,
	Lior Amsalem <alior@marvell.com>,
	Evan Wang <xswang@marvell.com>,
	Yair Mahalalel <myair@marvell.com>, nitroshift@yahoo.com,
	Grzegorz Jaszczyk <jaz@semihalf.com>,
	Tomasz Nowicki <tn@semihalf.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87lh9f4dbt.fsf@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gregory,

2015-11-30 18:16 GMT+01:00 Gregory CLEMENT <gregory.clement@free-electrons.com>:
> Hi Marcin,
>
>  On dim., nov. 22 2015, Marcin Wojtas <mw@semihalf.com> wrote:
>
>> Hi,
>>
>> Hereby I submit a patchset that introduces various fixes and support
>> for new features and enhancements to the mvneta driver:
>>
>> 1. First three patches are minimal fixes, stable-CC'ed.
>>
>> 2. Suspend to ram ('s2ram') support. Due to some stability problems
>> Thomas Petazzoni's patches did not get merged yet, but I used them for
>> verification. Contrary to wfi mode ('standby' - linux does not
>> differentiate between them, so same routines are used) all registers'
>> contents are lost due to power down, so the configuration has to be
>> fully reconstructed during resume.
>>
>> 3. Optimisations - concatenating TX descriptors' flush, basing on
>> xmit_more support and combined approach for finalizing egress processing.
>> Thanks to HR timer buffers can be released with small latency, which is
>> good for low transfer and small queues. Along with the timer, coalescing
>> irqs are used, whose threshold could be increased back to 15.
>>
>> 4. Buffer manager (BM) support with two preparatory commits. As it is a
>> separate block, common for all network ports, a new driver is introduced,
>> which configures it and exposes API to the main network driver. It is
>> throughly described in binding documentation and commit log. Please note,
>> that enabling per-port BM usage is done using phandle and the data passed
>> in mvneta_bm_probe. It is designed for usage of on-demand device probe
>> and dev_set/get_drvdata, however it's awaiting merge to linux-next.
>> Therefore, deferring probe is not used - if something goes wrong (same
>> in case of errors during changing MTU or suspend/resume cycle) mvneta
>> driver falls back to software buffer management and works in a regular way.
>>
>> Known issues:
>> - problems with obtaining all mapped buffers from internal SRAM, when
>> destroying the buffer pointer pool
>> - problems with unmapping chunk of SRAM during driver removal
>> Above do not have an impact on the operation, as they are called during
>> driver removal or in error path.
>>
>> 5. Enable BM on Armada XP and 38X development boards - those ones and
>> A370 I could check on my own. In all cases they survived night-long
>> linerate iperf. Also tests were performed with A388 SoC working as a
>> network bridge between two packet generators. They showed increase of
>> maximum processed 64B packets by ~20k (~555k packets with BM enabled
>> vs ~535 packets without BM). Also when pushing 1500B-packets with a
>> line rate achieved, CPU load decreased from around 25% without BM vs
>> 18-20% with BM.
>
> I was trying to test the BM part of tour series on the Armada XP GP
> board. However it failed very quickly during the pool allocation. After
> a first debug I found that the size of the cs used in the
> mvebu_mbus_dram_info struct was 0. I have applied your series on a
> v4.4-rc1 kernel. At this stage I don't know if it is a regression in the
> mbus driver, a misconfiguration on my side or something else.
>
> Does it ring a bell for you?

Frankly, I'm a bit surprised, I've never seen such problems on any of
the boards (AXP-GP/DB, A38X-DB/GP/AP). Did mvebu_mbus_dram_win_info
function exit with an error? Can you please apply below diff:
http://pastebin.com/2ws1txWk
And send me a full log beginning from u-boot?

>
> How do you test test it exactly?
> Especially on which kernel and with which U-Boot?
>

I've just re-built the patchset I sent, which is on top of 4.4-rc1.

I use AXP-GP, 78460 @ 1600MHz, 2GB DRAM, and everything works fine. My
u-boot version: v2011.12 2014_T2.0_eng_dropv2.

Best regards,
Marcin
