From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 08/18] net: dsa: mv88e6xxx: Add Hardware bridging support
Date: Sun, 22 Mar 2015 15:39:20 -0700
Message-ID: <550F4498.9040203@roeck-us.net>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net> <1426952815-4642-9-git-send-email-linux@roeck-us.net> <20150322200600.GD15025@lunn.ch> <550F29FD.7050509@roeck-us.net> <20150322205957.GF15025@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150322205957.GF15025@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/22/2015 01:59 PM, Andrew Lunn wrote:
> On Sun, Mar 22, 2015 at 01:45:49PM -0700, Guenter Roeck wrote:
>> On 03/22/2015 01:06 PM, Andrew Lunn wrote:
>>> Hi Guenter
>>>
>>>> +static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, int fid, u16 cmd)
>>>> +{
>>>> +	int ret;
>>>> +
>>>> +	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x01, fid);
>>>> +	if (ret < 0)
>>>> +		return ret;
>>>
>>> Please could you check this. I think register 0x01 here is wrong. I
>>> think you want 0x0b, the ATU Operations register?
>>>
>> The ATU operation is initiated below (and does write to register 0x0b).
>> Register 0x01 is FID[11..0] for ATU, which is what we want to write here.
>
> http://lxr.free-electrons.com/source/drivers/net/dsa/mv88e6xxx.c#L156
>
> 156 int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr)
> 157 {
> 158         REG_WRITE(REG_GLOBAL, 0x01, (addr[0] << 8) | addr[1]);
> 159         REG_WRITE(REG_GLOBAL, 0x02, (addr[2] << 8) | addr[3]);
> 160         REG_WRITE(REG_GLOBAL, 0x03, (addr[4] << 8) | addr[5]);
> 161
> 162         return 0;
> 163 }
>
> So maybe the meaning of these registers has changed between different
> versions of the chips? Only 6131 uses mv88e6xxx_set_addr_direct, all
> the others use indirect method. So maybe the 6131 is going to need
> something different here in _mv88e6xxx_atu_cmd()?
>

Good catch. You are so right, the meaning of this register has changed.

a) 6165, 6171, 6172, 6176, 6240, 6532
b) 6060, 6152, 6155, 6182, 6185

		(a)		(b)
Global 0x01	ATU FID		Switch mac address bytes 0 & 1
Global 0x0a	Age time	Age time, FID (DBNum) bit 4..7
Global 0x0b	ATU cmd		ATU cmd, FID (DBNum) bit 0..3
Global2 0x0d	Switch mac add	undefined / unused

I don't know about the 6095 and the 6131, but I assume those chips
are similar to the the chips listed in (b) above.

So the HW bridging code as written won't work for the switches in
group (b), meaning I need to drop the related patches for now.
Guess we need to wait for someone who can test the code with that chip
before releasing it.

That also means that we'll have to move the list of switch IDs into
mv88e6xxx.h to be able to use it where needed (such as in mv88e6xxx_atu_cmd).

Guenter
