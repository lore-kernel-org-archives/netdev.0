From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH] brcmfmac: prevent watchdog from interfering with	scanning
 and connecting
Date: Mon, 4 Aug 2014 22:12:35 +0200
Message-ID: <53DFE933.2080805@broadcom.com>
References: <539E8559.3010601@linux.intel.com> <539EA79C.7010206@broadcom.com> <53A30F96.3010206@linux.intel.com> <53A311E4.301@broadcom.com> <53CCC44C.2070507@linux.intel.com> <53D124B3.7030807@linux.intel.com> <53DFB6A1.7040900@linux.intel.com> <20140804165202.GG30282@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>,
	<brudley@broadcom.com>, Franky Lin <frankyl@broadcom.com>,
	<meuleman@broadcom.com>, <linville@tuxdriver.com>,
	<pieterpg@broadcom.com>, <dekim@broadcom.com>,
	<mcgrof@do-not-panic.com>, <antonio@open-mesh.com>,
	<johannes.berg@intel.com>, <linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-mmc@vger.kernel.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <20140804165202.GG30282@n2100.arm.linux.org.uk>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/04/14 18:52, Russell King - ARM Linux wrote:
> On Tue, Aug 05, 2014 at 12:36:49AM +0800, Fu, Zhonghui wrote:
>> Hi, Arend
>>
>> I investigated this issue, and its root cause is still that sdio
>> controller can't receive interrupts from WiFi chip on sdio bus when
>> sdio controller is in runtime suspend status. I am running 3.16-rc5
>> linux kernel on ASUS T100TA tablet, and using sdhci-acpi driver.
>
> That's the root cause.  I fixed this with the Freescale i.MX SD driver
> which is now able to report pending SDIO interrupts while runtime PM
> suspended.
>
> Other host drivers probably need fixing too, or having runtime PM
> disabled on them - if you can't receive SDIO interrupts while runtime
> PM suspended, then entering runtime PM while you have a SDIO device
> attached is a bug.
>
> This is something for the MMC people to deal with rather than Arend.

Occasionally, the itch is there to fix mmc code, but this looks a bit 
tricky. The fun starts in sdio.c:mmc_attach_sdio():

	/*
	 * Enable runtime PM only if supported by host+card+board
	 */
	if (host->caps & MMC_CAP_POWER_OFF_CARD) {
		/*
		 * Let runtime PM core know our card is active
		 */
		err = pm_runtime_set_active(&card->dev);
		if (err)
			goto remove;

		/*
		 * Enable runtime PM for this card
		 */
		pm_runtime_enable(&card->dev);
	}

The comment above the if statement seems to be stating the right idea, 
but the code only looks at the host controller capability flags.

Regards,
Arend

