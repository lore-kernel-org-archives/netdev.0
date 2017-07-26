From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next v2 01/10] net: dsa: lan9303: Fixed MDIO interface
Date: Wed, 26 Jul 2017 14:18:09 +0200
Message-ID: <87999a6c-4ea8-ba4c-e2db-cdb37c1c8c8a@egil-hjelmeland.no>
References: <20170725161553.30147-1-privat@egil-hjelmeland.no>
 <20170725161553.30147-2-privat@egil-hjelmeland.no>
 <878tjc49bl.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        corbet@lwn.net, andrew@lunn.ch, f.fainelli@gmail.com,
        davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <878tjc49bl.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25. juli 2017 21:15, Vivien Didelot wrote:
> Hi Egil,
> 
> Egil Hjelmeland <privat@egil-hjelmeland.no> writes:
> 
>> Fixes after testing on actual HW:
>>
>> - lan9303_mdio_write()/_read() must multiply register number
>>    by 4 to get offset
>>
>> - Indirect access (PMI) to phy register only work in I2C mode. In
>>    MDIO mode phy registers must be accessed directly. Introduced
>>    struct lan9303_phy_ops to handle the two modes. Renamed functions
>>    to clarify.
>>
>> - lan9303_detect_phy_setup() : Failed MDIO read return 0xffff.
>>    Handle that.
> 
> Small patch series when possible are better. Bullet points in commit
> messages are likely to describe how a patch or series may be split up
> ;-)
> 
> This patch seems to be the unique patch of the series resolving what is
> described in the cover letter as "Make the MDIO interface work".
> 
> I'd suggest you to split up this one commit in several *atomic* and easy
> to review patches and send them separately as on thread named "net: dsa:
> lan9303: fix MDIO interface" (also note that imperative is prefered for
> subject lines, see: https://chris.beams.io/posts/git-commit/#imperative)
> 
> <...>
> 
>> -static int lan9303_port_phy_reg_wait_for_completion(struct lan9303 *chip)
>> +static int lan9303_indirect_phy_wait_for_completion(struct lan9303 *chip)
> 
> For instance you can have a first commit only renaming the functions.
> The reason for it is to separate the functional changes from cosmetic
> changes, which makes it easier for review.
> 
> <...>

Thank you for reviewing.

I can split the first patch.

I can also split the patch series to more digestible series. But
since most of the patches touches the same file, I assume that each
series must be completed and applied before starting on a new one.
So I really want to group the patches into only a few series in order
to not spend months on the process.


>> +	if ((reg != 0) && (reg != 0xffff))
> 
> if (reg && reg != 0xffff) should be enough.

Of course.

>> +struct lan9303_phy_ops {
>> +	/* PHY 1 &2 access*/
> 
> The spacing is weird in the comment. "/* PHY 1 & 2 access */" maybe?
> 

Yes.

>> +int lan9303_mdio_phy_write(struct lan9303 *chip, int phy, int regnum, u16 val)
>> +{
>> +	struct lan9303_mdio *sw_dev = dev_get_drvdata(chip->dev);
>> +	struct mdio_device *mdio = sw_dev->device;
>> +
>> +	mutex_lock(&mdio->bus->mdio_lock);
>> +	mdio->bus->write(mdio->bus, phy, regnum, val);
>> +	mutex_unlock(&mdio->bus->mdio_lock);
> 
> This is exactly what mdiobus_write(mdio->bus, phy, regnum, val) is
> doing. There are very few valid reasons to go play in the mii_bus
> structure, using generic APIs are strongly prefered. Plus you have
> checks and traces for free!
> 

Lack of oversight was the only reason. I just adapted stuff from
lan9303_mdio_phy_write above. Will switch to mdiobus_write of course.

> Same here, mdiobus_read().
> 
Ditto.

> 
> Thanks,
> 
>          Vivien
> 

Appreciated,
Egil

