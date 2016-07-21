From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: [net-next PATCH 1/3] net: phy: dp83867: Add documentation for
 optional impedance control
Date: Thu, 21 Jul 2016 11:52:36 +0530
Message-ID: <57906A2C.7010201@ti.com>
References: <20160720145614.13132-1-mugunthanvnm@ti.com>
 <20160720145614.13132-2-mugunthanvnm@ti.com> <578F99D3.9090601@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
	Tony Lindgren <tony@atomide.com>,
	Russell King <linux@armlinux.org.uk>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>,
	<devicetree@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>
To: Nishanth Menon <nm@ti.com>, Mugunthan V N <mugunthanvnm@ti.com>,
	<netdev@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <578F99D3.9090601@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nishanth,

On Wednesday 20 July 2016 09:03 PM, Nishanth Menon wrote:
> On 07/20/2016 09:56 AM, Mugunthan V N wrote:
>> Add documention of ti,impedance-control which can be used to
>> correct MAC impedance mismatch using phy extended registers.
>>
>> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
>> ---
>>   Documentation/devicetree/bindings/net/ti,dp83867.txt | 7 +++++++
>>   1 file changed, 7 insertions(+)
>>
>> diff --git a/Documentation/devicetree/bindings/net/ti,dp83867.txt
>> b/Documentation/devicetree/bindings/net/ti,dp83867.txt
>> index 5d21141..531ea3c5 100644
>> --- a/Documentation/devicetree/bindings/net/ti,dp83867.txt
>> +++ b/Documentation/devicetree/bindings/net/ti,dp83867.txt
>> @@ -9,6 +9,13 @@ Required properties:
>>       - ti,fifo-depth - Transmitt FIFO depth- see
>> dt-bindings/net/ti-dp83867.h
>>           for applicable values
>>
>> +Optional property:
>> +    - ti,impedance-control - MAC Interface Impedance control to vary the
>> +                 output impedance with an approximate range
>> +                 from 35-70 ohms in 32 steps. Value range can
>> +                 be 0x0 to 0x1f. Lowest impedance value is
>> +                 0x1f and highest impedance being 0x0.
>> +
> 
> Should'nt you be using the impedance values of 35 to 70 as the valid
> values here? that would be the hardware description, and the values to
> program corresponding to those are 0x00 to 0x1f. Right?
> 
> Rob: is'nt that the right way to do it?

Agree that that is usually the right way to do it. I believe this case
is bit peculiar though. Here is the extract from the datasheet[1] about
how the register in question works.

"
Output impedance approximate range from 35-70 ohms in 32 steps.
Lowest being 11110 and highest being 00000. Range and Step size
will vary with process.

Default is set to 50 ohms by trim. But the default register value can
vary by process. Non default values of MAC I/O impedance can be
used based on trace impedance. Mismatch between device and
trace impedance can cause voltage overshoot and undershoot.
"

So clearly, there is no easy correspondence that the hardware guarantees
between output impedance ohmage and the register value programmed. Only
couple of things are guaranteed.

1) Programming a value of 0 gives approximately 35 ohms
2) Programming a value of 0x1F gives approximately 70 ohms
3) Default value of the register gives 50 ohms (the default value could
vary by device).
4) Programming a value in between will give some ohmage in the
approximate range 35-70 (curve is unknown).

Given this, I am not sure how one can convert a given user supplied ohms
values to a reasonable register value. Clearly, the register is supposed
to be programmed by experimentation, not calculation.

That said, we could take another approach. At least for the current
issue we are trying to address, we only need to configure the register
to max value. And given the nature of the register, I am pretty sure
that is what most people will end up doing.

So, may be we have two properties:

ti,max-output-impedance
ti,min-output-imepdance

which configure the impedance to maximum and minimum values
respectively. If, in future, someone needs to configure a value in
between, he can introduce a more granular property which when then
override whatever else is specified.

Regards,
Sekhar

[1] http://www.ti.com/lit/ds/symlink/dp83867ir.pdf
