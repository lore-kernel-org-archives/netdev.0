From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next RFC 3/9] net: dsa: mv88e6xxx: add support for
 GPIO configuration
Date: Thu, 28 Sep 2017 10:45:03 -0700
Message-ID: <659c4254-d0b7-52dc-dd9b-3921cd2f20c0@gmail.com>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-4-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>
To: Brandon Streiff <brandon.streiff@ni.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506612341-18061-4-git-send-email-brandon.streiff@ni.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/28/2017 08:25 AM, Brandon Streiff wrote:
> The Scratch/Misc register is a windowed interface that provides access
> to the GPIO configuration. Provide a new method for configuration of
> GPIO functions.
> 
> Signed-off-by: Brandon Streiff <brandon.streiff@ni.com>
> ---

> +/* Offset 0x1A: Scratch and Misc. Register */
> +static int mv88e6xxx_g2_scratch_reg_read(struct mv88e6xxx_chip *chip,
> +					 int reg, u8 *data)
> +{
> +	int err;
> +	u16 value;
> +
> +	err = mv88e6xxx_g2_write(chip, MV88E6XXX_G2_SCRATCH_MISC_MISC,
> +				 reg << 8);
> +	if (err)
> +		return err;
> +
> +	err = mv88e6xxx_g2_read(chip, MV88E6XXX_G2_SCRATCH_MISC_MISC, &value);
> +	if (err)
> +		return err;
> +
> +	*data = (value & MV88E6XXX_G2_SCRATCH_MISC_DATA_MASK);
> +
> +	return 0;
> +}

With the write and read acquiring and then releasing the lock
immediately, is no there room for this sequence to be interrupted in the
middle and end-up returning inconsistent reads?

> +
> +static int mv88e6xxx_g2_scratch_reg_write(struct mv88e6xxx_chip *chip,
> +					  int reg, u8 data)
> +{
> +	u16 value = (reg << 8) | data;
> +
> +	return mv88e6xxx_g2_update(chip, MV88E6XXX_G2_SCRATCH_MISC_MISC, value);
> +}
> +
> +/* Configures the specified pin for the specified function. This function
> + * does not unset other pins configured for the same function. If multiple
> + * pins are configured for the same function, the lower-index pin gets
> + * that function and the higher-index pin goes back to being GPIO.
> + */
> +int mv88e6xxx_g2_set_gpio_config(struct mv88e6xxx_chip *chip, int pin,
> +				 int func, int dir)
> +{
> +	int mode_reg = MV88E6XXX_G2_SCRATCH_GPIO_MODE(pin);
> +	int dir_reg = MV88E6XXX_G2_SCRATCH_GPIO_DIR(pin);
> +	int err;
> +	u8 val;
> +
> +	if (pin < 0 || pin >= mv88e6xxx_num_gpio(chip))
> +		return -ERANGE;
> +
> +	/* Set function first */
> +	err = mv88e6xxx_g2_scratch_reg_read(chip, mode_reg, &val);
> +	if (err)
> +		return err;
> +
> +	/* Zero bits in the field for this GPIO and OR in new config */
> +	val &= ~MV88E6XXX_G2_SCRATCH_GPIO_MODE_MASK(pin);
> +	val |= (func << MV88E6XXX_G2_SCRATCH_GPIO_MODE_OFFSET(pin));
> +
> +	err = mv88e6xxx_g2_scratch_reg_write(chip, mode_reg, val);
> +	if (err)
> +		return err;
> +
> +	/* Set direction */
> +	err = mv88e6xxx_g2_scratch_reg_read(chip, dir_reg, &val);
> +	if (err)
> +		return err;
> +
> +	/* Zero bits in the field for this GPIO and OR in new config */
> +	val &= ~MV88E6XXX_G2_SCRATCH_GPIO_DIR_MASK(pin);
> +	val |= (dir << MV88E6XXX_G2_SCRATCH_GPIO_DIR_OFFSET(pin));
> +
> +	return mv88e6xxx_g2_scratch_reg_write(chip, dir_reg, val);
> +}

Would there be any value in implementing a proper gpiochip structure
here such that other pieces of SW can see this GPIO controller as a
provider and you can reference it from e.g: Device Tree using GPIO
descriptors?
-- 
Florian
