From: Mason <slash.tmp@free.fr>
Subject: Re: Initializing MAC address at run-time
Date: Thu, 19 Jan 2017 16:31:56 +0100
Message-ID: <79fef293-74ec-dece-1941-747cd55f1ca2@free.fr>
References: <e083ed68-0e8e-380e-23bd-5ad387c88575@free.fr>
 <20170118185435.fen6np7lydzgxxek@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Mark Rutland <mark.rutland@arm.com>, DT <devicetree@vger.kernel.org>,
 Arnd Bergmann <arnd@arndb.de>, Kevin Hilman <khilman@kernel.org>,
 netdev <netdev@vger.kernel.org>,
 Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170118185435.fen6np7lydzgxxek@pengutronix.de>
Content-Language: 
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hello Uwe,

On 18/01/2017 19:54, Uwe Kleine-K=F6nig wrote:

> On Wed, Jan 18, 2017 at 03:03:57PM +0100, Mason wrote:
>
>> When my system boots up, eth0 is given a seemingly random MAC address.
>>
>> [    0.950734] nb8800 26000.ethernet eth0: MAC address ba:de:d6:38:b8:38
>> [    0.957334] nb8800 26000.ethernet eth0: MAC address 6e:f1:48:de:d6:c4
>>
>>
>> The DT node for eth0 is:
>>
>> 	eth0: ethernet@26000 {
>> 		compatible =3D "sigma,smp8734-ethernet";
>> 		reg =3D <0x26000 0x800>;
>> 		interrupts =3D <38 IRQ_TYPE_LEVEL_HIGH>;
>> 		clocks =3D <&clkgen SYS_CLK>;
>> 	};
>>
>> Documentation/devicetree/bindings/net/ethernet.txt mentions
>> - local-mac-address: array of 6 bytes, specifies the MAC address that was
>>   assigned to the network device;
>>
>> And indeed, if I define this property, eth0 ends up with the MAC address
>> I specify in the device tree. But of course, I don't want all my boards
>> to share the same MAC address. Every interface has a unique MAC address.
>>
>> In fact, the boot loader (not Uboot, a custom non-DT boot loader) stores
>> the MAC address somewhere in MMIO space, in some weird custom format.
> =

> Where does your machine get the dtb from? You write it to the boot
> medium at a certain point of time I assume.

The DTB is appended to the kernel uImage.
(It's never written to the board's storage.)

> So AFAICT you have the following options (in no particular order):
> =

>  a) Describe in the dtb how to find out how the MAC address is stored
>     (already pointed out Mark and Robin)
>  b) Make your bootloader dt aware and let it provide the
>     local-mac-address property.

Do you agree that such boot loader would execute code that is roughly
identical to the one posted for illustration purposes?
  1. find the MAC address to use for eth0
  2. find the eth0 node in the DT
  3. insert the right prop in the eth0 node

In which case, it seems a waste to add the DT library to the boot
loader, when the operation can be done in Linux, which requires the
DT library anyway. (Additionally, adding DT support to some custom
legacy boot loader might be a complex task.)

>  c) Adapt the dtb before it is written to the boot medium.

This is not applicable, as the DTB is not written to the board.

>  d) Let the bootloader configure the device and teach the driver to pick
>     up the mac from the device's address space.

I'm not sure what you call "the device" ?
The local RAM where the MAC is stored? the eth controller?

>  e) Accept that the mac address is random during development, and make
>     Userspace configure the MAC address, which is early enough for
>     production use.

During development, some devs configure the DHCP server to provide
a specific uImage and/or rootfs to their board, based on the MAC
address. This scheme would fall apart with a random MAC.

> Not sure d) is considered ok today, but some drivers have this feature.
> I'd say b) is the best choice.

In my mind, doing it early in Linux is similar in spirit to doing it
at the boot loader stage, in that it's neatly separated from the rest
of the setup.

>> I need to do something similar with the NAND partitions. The boot loader
>> stores the partition offsets somewhere, and I need to pass this info
>> to the NAND framework, so I assumed that inserting the corresponding
>> properties at run-time was the correct way to do it.
> =

> The list of options here is similar to the list above. d) doesn't work,
> but instead you can pass the partitioning on the kernel commandline.

Yes, I will test the command line approach. Thanks.

Regards.
