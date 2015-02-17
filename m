From: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Subject: Re: [PATCH v2 1/3] Ethernet packet sniffer: Device tree binding and
 vendor prefix
Date: Tue, 17 Feb 2015 16:22:04 +0000
Message-ID: <54E36AAC.7010308@linn.co.uk>
References: <cover.1424181053.git.stathis.voukelatos@linn.co.uk> <0a86907642a97e5bd880f69299664232fcffaf9d.1424181053.git.stathis.voukelatos@linn.co.uk> <20150217145124.GM8994@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"abrestic@chromium.org" <abrestic@chromium.org>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150217145124.GM8994@leverpostej>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Mark,

On 17/02/15 14:51, Mark Rutland wrote:

>> +Matched packet bytes and timestamp values are returned through a
>> +FIFO. Timestamps are provided to the module through an externally
>> +generated Gray-encoded counter.
>
> Does this counter unit need to be enabled (or have any input clocks
> enabled)?
>

Yes it does, that is the purpose of the 'tstamp' entry in the
'clock-names' property below.

>> +
>> +Required properties:
>> +- compatible : must be "linn,eth-sniffer"
>
> Is there not a more precise name for this IP block?

It is generally called 'ethernet packet sniffer', maybe
linn,eth-packet-sniffer would be a more descriptive name?

>
>> +- reg : physical addresses and sizes of registers. Must contain 3 entries:
>> +          - registers memory space
>> +          - TX command string memory
>> +          - RX command string memory
>> +- reg-names : must contain the following 3 entries:
>> +                  "regs", "tx-ram", "rx-ram"
>
> It would be nicer to format this as:
>
> - reg: A list of physical address and size pairs corresponding to each
>         entry in reg-names
>
> - reg-names: must contain:
>    * "regs" for the control registers
>    * "tx-ram" for the TX command string memory
>    * "rx-ram" for the RX command string memory
>
> Which avoids redundancy.
>

Will change formatting as suggested

> The phrase "command string" sounds a bit odd. What are these used for
> exactly?

In these two memory areas we program a sequence of bytes in the
format: [cmd][value][cmd][value] to configure the data patterns that
the sniffer should match for Ethernet TX and RX packets respectively.
Maybe 'command memory' would be clearer?

>
>> +- interrupts : sniffer interrupt specifier
>> +- clocks : specify the system clock for the peripheral and
>> +	   the enable clock for the timestamp counter
>> +- clock-names : must contain the "sys" and "tstamp" entries
>
> Similarly here clocks should just be defined in terms of clock-names.

Will reformat similar to the 'regs' field

>
>> +- fifo-block-words : number of words in one data FIFO entry
>
> I didn't see a data FIFO described. Is that dynamically allocated and
> handed to the sniffer, or does that correspond to one of the memory
> regions above?
>

It is a H/W FIFO internal to the module and accessed through
a register. It is divided in blocks and 'fifo-block-words'
specify the number of words in each block. It is needed by
the driver to make sure it reads an entire block, in order
to clear the 'data available' interrupt.

>> +- tstamp-hz : frequency of the timestamp counter
>> +- tstamp-shift : shift value for the timestamp cyclecounter struct
>
> What exactly is this used for?
>
> Are there any docs?

See: include/linux/clocksource.h
The driver uses a cyclecounter and timecounter to convert raw timestamps
to nanoseconds. 'tstamp-shift' refers to the 'shift' field of the
cyclecounter structure, that can be used to improve the precision of
the conversion

>
>> +- tstamp-bits : width in bits of the timestamp counter
>> +
>> +Example:
>> +
>> +sniffer@1814a000 {
>> +	compatible = "linn,eth-sniffer";
>> +	reg = <0x1814a000 0x100>, <0x1814a400 0x400>,
>> +	      <0x1814a800 0x400>;
>> +	reg-names = "regs", "tx-ram", "rx-ram";
>> +	interrupts = <GIC_SHARED 58 IRQ_TYPE_LEVEL_HIGH>;
>> +	clocks = <&clk_core CLK_AUDIO>,
>> +		 <&cr_periph SYS_CLK_EVENT_TIMER>;
>> +	clock-names = "sys", "tstamp";
>> +	fifo-block-words = <4>;
>> +	tstamp-hz = <52000000>;
>> +	tstamp-shift = <27>;
>> +	tstamp-bits = <30>;
>
> This property wasn't documented.
>
> As mentioned previously, I think the relation between this unit and the
> MAC and/or PHY needs to be explicitly described in the DT.

Do you suggest a field along the lines of:
mac = <&eth_controller_0>;
The driver could check that it exists and is valid but does
not need to make use of it.

>
>> +};
>> diff --git a/Documentation/devicetree/bindings/vendor-prefixes.txt b/Documentation/devicetree/bindings/vendor-prefixes.txt
>> index d443279..891c224 100644
>> --- a/Documentation/devicetree/bindings/vendor-prefixes.txt
>> +++ b/Documentation/devicetree/bindings/vendor-prefixes.txt
>> @@ -90,6 +90,7 @@ lacie	LaCie
>>   lantiq	Lantiq Semiconductor
>>   lenovo	Lenovo Group Ltd.
>>   lg	LG Corporation
>> +linn    Linn Products Ltd.
>
> This addition looks fine to me. For some reason it seems to be padded
> with spaces instead of tabs though; is my mail server corrupting things
> or is that the case in the original patch?

Sorry, it was spaces. Will be fixed
>
> Thanks,
> Mark.
>

Thank you,
Stathis
