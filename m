From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: [PATCH RFC 1/2] Documentation: add Device tree bindings for QCA7000
Date: Wed, 30 Apr 2014 09:30:18 +0200
Message-ID: <5360A68A.1080408@i2se.com>
References: <1398707697-43785-1-git-send-email-stefan.wahren@i2se.com> <1398707697-43785-2-git-send-email-stefan.wahren@i2se.com> <20140429223638.GB2382@flaeskesteg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.org" <pawel.moll@arm.org>,
	"mark.rutland@arm.org" <mark.rutland@arm.org>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:55940 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbaD3Has (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 03:30:48 -0400
In-Reply-To: <20140429223638.GB2382@flaeskesteg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Am 30.04.2014 00:36, schrieb Mark Rutland:
> On Mon, Apr 28, 2014 at 06:54:56PM +0100, Stefan Wahren wrote:
>> This patch adds the Device tree bindings for the Ethernet over SPI
>> protocol driver of the Qualcomm QCA7000 HomePlug GreenPHY.
>>
>> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
>> ---
>>  .../devicetree/bindings/net/qca-qca7000-spi.txt    |   51 ++++++++++++++++++++
>>  1 file changed, 51 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
>>
>> diff --git a/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt b/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
>> new file mode 100644
>> index 0000000..132c10f
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
>> @@ -0,0 +1,51 @@
>> +* Qualcomm QCA7000 (Ethernet over SPI protocol)
>> +
>> +Note: The QCA7000 is useable as a SPI device. In this case it must be defined
>> +as a child of a spi master in the device tree.
>> +
>> +Required properties:
>> +- compatible : Should be "qca,qca7000"
>> +- reg : Should specify the SPI chip select
>> +- intr-gpios : Should specify the GPIO for SPI interrupt
> As Arnd mentioned, this should be described as an interrupt if it's an
> interrupt from the point of view of the QCA7000.

yes, i will fix that. I think i've an idea how to handle the case a
interrupt appear
before the device comes up without fetching the GPIO value.

>> +- spi-cpha : Must be set
>> +- spi-cpol: Must be set
>> +
>> +Optional properties:
>> +- spi-max-frequency : Maximum frequency of the SPI bus the chip can operate at.
>> +  Numbers smaller than 1000000 or greater than 16000000 are invalid. Missing
>> +  the property will set the SPI frequency to 8000000 Hertz.
>> +- local-mac-address: 6 bytes, mac address
>> +- qca,legacy-mode : Should specify the data transfer mode of the QCA7000
>> +  (0 = burst mode, 1 = legacy mode). Missing the property will use the
>> +  burst mode.
> This sounds like it could be a boolean property (one with no value, like
> cpi-cpha). When is this necessary?

You're right. I could make it a boolean property.

The SPI interface of the QCA7000 supports 2 different transfer modes:
* legacy mode (spi chip select toogle after each word, cs gaps)
* burst mode (spi chip select toogle after complete data, no cs gaps)

This mode must be configured on the QCA7000 and the driver must also
know the setting. The
burst mode is preferred because of better performance. I think this
parameter is for spi host
controller, which doesn't support burst mode.

>> +- linux,burst-length : Number of data bytes per burst. Numbers smaller than 1
>> +  or greater than 5000 are invalid. Missing the property will set the
>> +  burst length to 5000 bytes. This property has only an effect in burst mode.
> When is this needed?

This parameter makes only sense in case of burst mode and specify the
maximum length of a
spi burst. I think this parameter has an influence on the latency of the
system. Higher values
means higher performance but worse system latency. I think that make
sense on embedded system.

>> +- linux,pluggable-connection : Should be set to skip signature check while
>> +  probing. This property is useful if the SPI master and QCA7000 are not on the
>> +  same board.
> This does not sounds like it belongs in the DT, as it's strongly tied to the
> implementation of the driver. Why is this necessary?
>
> Cheers,
> Mark.

I introduce this parameter to handle a scenario where spi host
controller and QCA7000 are
not on the same board and connected via cable. So in this case the
driver skips a device probe
and wait until the QCA7000 becomes ready.

Stefan
