From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add
 legacy ISA bus driver for the CC770 and AN82527
Date: Mon, 28 Nov 2011 14:59:12 +0100
Message-ID: <4ED393B0.2030004@grandegger.com>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com>
	<1322214204-1121-3-git-send-email-wg@grandegger.com>
	<4ED379F3.1070206@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4ED379F3.1070206-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-users>
List-Post: <mailto:socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/28/2011 01:09 PM, Marc Kleine-Budde wrote:
> On 11/25/2011 10:43 AM, Wolfgang Grandegger wrote:
>> This patch adds support for legacy Bosch CC770 and Intel AN82527 CAN
>> controllers on the ISA or PC-104 bus. The I/O port or memory address
>> and the IRQ number must be specified via module parameters:
>>
>>   insmod cc770_isa.ko port=0x310,0x380 irq=7,11
>>
>> for ISA devices using I/O ports or:
>>
>>   insmod cc770_isa.ko mem=0xd1000,0xd1000 irq=7,11
>>
>> for memory mapped ISA devices.
>>
>> Indirect access via address and data port is supported as well:
>>
>>   insmod cc770_isa.ko port=0x310,0x380 indirect=1 irq=7,11
>>
>> Furthermore, the following mode parameter can be defined:
>>
>>   clk: External oscillator clock frequency (default=16000000 [16 MHz])
>>   cir: CPU interface register (default=0x40 [DSC])
>>   ocr, Bus configuration register (default=0x40 [CBY])
>>   cor, Clockout register (default=0x00)
>>
>> Note: for clk, cir, bcr and cor, the first argument re-defines the
>> default for all other devices, e.g.:
>>
>>   insmod cc770_isa.ko mem=0xd1000,0xd1000 irq=7,11 clk=24000000
>>
>> is equivalent to
>>
>>   insmod cc770_isa.ko mem=0xd1000,0xd1000 irq=7,11 clk=24000000,24000000
>>
>> Signed-off-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
> 
> Some nitpicking inside.
> 
> Marc
>> ---
>>  drivers/net/can/cc770/Kconfig     |   11 ++
>>  drivers/net/can/cc770/Makefile    |    1 +
>>  drivers/net/can/cc770/cc770_isa.c |  336 +++++++++++++++++++++++++++++++++++++
>>  3 files changed, 348 insertions(+), 0 deletions(-)
>>  create mode 100644 drivers/net/can/cc770/cc770_isa.c
>>
>> diff --git a/drivers/net/can/cc770/Kconfig b/drivers/net/can/cc770/Kconfig
>> index 225131b..28e4d48 100644
>> --- a/drivers/net/can/cc770/Kconfig
>> +++ b/drivers/net/can/cc770/Kconfig
>> @@ -1,3 +1,14 @@
>>  menuconfig CAN_CC770
>>  	tristate "Bosch CC770 and Intel AN82527 devices"
>>  	depends on CAN_DEV && HAS_IOMEM
>> +
>> +if CAN_CC770
>> +
>> +config CAN_CC770_ISA
>> +	tristate "ISA Bus based legacy CC770 driver"
>> +	---help---
>> +	  This driver adds legacy support for CC770 and AN82527 chips
>> +	  connected to the ISA bus using I/O port, memory mapped or
>> +	  indirect access.
>> +
>> +endif
>> diff --git a/drivers/net/can/cc770/Makefile b/drivers/net/can/cc770/Makefile
>> index 34e8180..872ecff 100644
>> --- a/drivers/net/can/cc770/Makefile
>> +++ b/drivers/net/can/cc770/Makefile
>> @@ -3,5 +3,6 @@
>>  #
>>  
>>  obj-$(CONFIG_CAN_CC770) += cc770.o
>> +obj-$(CONFIG_CAN_CC770_ISA) += cc770_isa.o
>>  
>>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
>> diff --git a/drivers/net/can/cc770/cc770_isa.c b/drivers/net/can/cc770/cc770_isa.c
...
>> +	for (idx = 0; idx < MAXDEV; idx++) {
> ARRAY_SIZE?

Well, I think ARRAY_SIZE is useful to derive the number of elements from
a static array of the type:

  static const int array[] = { 1, 2, 3, 4, }

but not if its declared as:

  static array[MAXDEV]:

... or have I missed something?

I'm fine with all other comments.

Wolfgang.
