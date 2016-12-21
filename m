From: Geoff Lansberry <geoff@kuvee.com>
Subject: Re: [PATCH 2/3] NFC: trf7970a: Add device tree option of 1.8 Volt IO voltage
Date: Wed, 21 Dec 2016 06:47:36 -0500
Message-ID: <32FAB08E-BE8E-4127-80A6-013300B43BD0@kuvee.com>
References: <1482250592-4268-1-git-send-email-glansberry@gmail.com> <1482250592-4268-2-git-send-email-glansberry@gmail.com> <20161221022347.GB5444@animalcreek.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
        charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: linux-wireless@vger.kernel.org, lauro.venancio@openbossa.org,
        aloisio.almeida@openbossa.org, sameo@linux.intel.com,
        robh+dt@kernel.org, mark.rutland@arm.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        justin@kuvee.com
To: Mark Greer <mgreer@animalcreek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161221022347.GB5444@animalcreek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Mark.   Should I resubmit patches with the requested edits today, or w=
ait a bit for more comments?  What is the desired etiquette?

> On Dec 20, 2016, at 9:23 PM, Mark Greer <mgreer@animalcreek.com> wrote:
>=20
>> On Tue, Dec 20, 2016 at 11:16:31AM -0500, Geoff Lansberry wrote:
>> From: Geoff Lansberry <geoff@kuvee.com>
>>=20
>> The TRF7970A has configuration options for supporting hardware designs
>> with 1.8 Volt or 3.3 Volt IO.   This commit adds a device tree option,
>> using a fixed regulator binding, for setting the io voltage to match
>> the hardware configuration. If no option is supplied it defaults to
>> 3.3 volt configuration.
>=20
> Sign-off ??  Same comment for you other patches.
>=20
> <time passes>
>=20
> Okay I see you have it at the end of the patch.  It should be here.
> 'git commit -s' is your friend.
>=20
>> ---
>> .../devicetree/bindings/net/nfc/trf7970a.txt       |  4 ++--
>> drivers/nfc/trf7970a.c                             | 28 +++++++++++++++++=
++++-
>> 2 files changed, 29 insertions(+), 3 deletions(-)
>>=20
>> diff --git a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt b/Doc=
umentation/devicetree/bindings/net/nfc/trf7970a.txt
>> index e262ac1..b5777d8 100644
>> --- a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
>> +++ b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
>> @@ -21,9 +21,9 @@ Optional SoC Specific Properties:
>> - t5t-rmb-extra-byte-quirk: Specify that the trf7970a has the erratum
>>   where an extra byte is returned by Read Multiple Block commands issued
>>   to Type 5 tags.
>> +- vdd-io-supply: Regulator specifying voltage for vdd-io
>> - clock-frequency: Set to specify that the input frequency to the trf7970=
a is 13560000Hz or 27120000Hz
>>=20
>> -
>> Example (for ARM-based BeagleBone with TRF7970A on SPI1):
>>=20
>> &spi1 {
>> @@ -41,11 +41,11 @@ Example (for ARM-based BeagleBone with TRF7970A on SP=
I1):
>>                  <&gpio2 5 GPIO_ACTIVE_LOW>;
>>        vin-supply =3D <&ldo3_reg>;
>>        vin-voltage-override =3D <5000000>;
>> +        vdd-io-supply =3D <&ldo2_reg>;
>>        autosuspend-delay =3D <30000>;
>>        irq-status-read-quirk;
>>        en2-rf-quirk;
>>        t5t-rmb-extra-byte-quirk;
>> -        vdd_io_1v8;
>=20
> It was already mentioned but this shouldn't have been added in the
> previous patch so it shouldn't be here now.
>=20
>>        clock-frequency =3D <27120000>;
>>        status =3D "okay";
>>    };
>> diff --git a/drivers/nfc/trf7970a.c b/drivers/nfc/trf7970a.c
>> index 4e051e9..8a88195 100644
>> --- a/drivers/nfc/trf7970a.c
>> +++ b/drivers/nfc/trf7970a.c
>=20
>> @@ -2062,6 +2068,7 @@ static int trf7970a_probe(struct spi_device *spi)
>>        return ret;
>>    }
>>=20
>> +
>=20
> Please don't add an extra blank line.
>=20
>>    of_property_read_u32(np, "clock-frequency", &clk_freq);
>>    if ((clk_freq !=3D TRF7970A_27MHZ_CLOCK_FREQUENCY) ||
>>        (clk_freq !=3D TRF7970A_27MHZ_CLOCK_FREQUENCY)) {
>> @@ -2105,6 +2112,25 @@ static int trf7970a_probe(struct spi_device *spi)
>>    if (uvolts > 4000000)
>>        trf->chip_status_ctrl =3D TRF7970A_CHIP_STATUS_VRS5_3;
>>=20
>> +    trf->regulator =3D devm_regulator_get(&spi->dev, "vdd-io");
>> +    if (IS_ERR(trf->regulator)) {
>> +        ret =3D PTR_ERR(trf->regulator);
>> +        dev_err(trf->dev, "Can't get VDD_IO regulator: %d\n", ret);
>> +        goto err_destroy_lock;
>> +    }
>> +
>> +    ret =3D regulator_enable(trf->regulator);
>> +    if (ret) {
>> +        dev_err(trf->dev, "Can't enable VDD_IO: %d\n", ret);
>> +        goto err_destroy_lock;
>> +    }
>> +
>> +
>=20
> Please don't add an extra blank line.
>=20
>> +    if (regulator_get_voltage(trf->regulator) =3D=3D 1800000) {
>> +        trf->io_ctrl =3D TRF7970A_REG_IO_CTRL_IO_LOW;
>> +        dev_dbg(trf->dev, "trf7970a config vdd_io to 1.8V\n");
>> +    }
>> +
>>    trf->ddev =3D nfc_digital_allocate_device(&trf7970a_nfc_ops,
>>            TRF7970A_SUPPORTED_PROTOCOLS,
>>            NFC_DIGITAL_DRV_CAPS_IN_CRC |
>> --=20
>> Signed-off-by: Geoff Lansberry <geoff@kuvee.com>
>=20
> Your 'Signed-off-by:' goes at the end of the commit description not here.
>=20
> Overall, I think you did the right thing (unless someone disagrees).
> Just some minor issues.
>=20
> Mark
> --
