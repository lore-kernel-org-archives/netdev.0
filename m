From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH v2 net-next 1/2] net: dsa: lan9303: Add port_fast_age and
 port_fdb_dump methods
Date: Thu, 19 Oct 2017 16:46:40 +0200
Message-ID: <1976baec-5ec3-9ec4-252b-743d9f1d9579@egil-hjelmeland.no>
References: <20171019121015.7395-1-privat@egil-hjelmeland.no>
 <20171019121015.7395-2-privat@egil-hjelmeland.no>
 <87mv4nw869.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87mv4nw869.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19. okt. 2017 15:58, Vivien Didelot wrote:
> Hi Egil,
> 
Hi Vivien

> Egil Hjelmeland <privat@egil-hjelmeland.no> writes:
> 
>> Add DSA method port_fast_age as a step to STP support.
>>
>> Add low level functions for accessing the lan9303 ALR (Address Logic
>> Resolution).
>>
>> Added DSA method port_fdb_dump
>>
>> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
> 
> The patch looks good overall, a few nitpicks though.
> 
>> ---
>>   drivers/net/dsa/lan9303-core.c | 159 +++++++++++++++++++++++++++++++++++++++++
>>   drivers/net/dsa/lan9303.h      |   2 +
>>   2 files changed, 161 insertions(+)
>>
>> diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
>> index 09a748327fc6..ae904242b001 100644
>> --- a/drivers/net/dsa/lan9303-core.c
>> +++ b/drivers/net/dsa/lan9303-core.c
>> @@ -124,6 +124,21 @@
>>   #define LAN9303_MAC_RX_CFG_2 0x0c01
>>   #define LAN9303_MAC_TX_CFG_2 0x0c40
>>   #define LAN9303_SWE_ALR_CMD 0x1800
>> +# define ALR_CMD_MAKE_ENTRY    BIT(2)
>> +# define ALR_CMD_GET_FIRST     BIT(1)
>> +# define ALR_CMD_GET_NEXT      BIT(0)
>> +#define LAN9303_SWE_ALR_WR_DAT_0 0x1801
>> +#define LAN9303_SWE_ALR_WR_DAT_1 0x1802
>> +# define ALR_DAT1_VALID        BIT(26)
>> +# define ALR_DAT1_END_OF_TABL  BIT(25)
>> +# define ALR_DAT1_AGE_OVERRID  BIT(25)
>> +# define ALR_DAT1_STATIC       BIT(24)
>> +# define ALR_DAT1_PORT_BITOFFS  16
>> +# define ALR_DAT1_PORT_MASK    (7 << ALR_DAT1_PORT_BITOFFS)
>> +#define LAN9303_SWE_ALR_RD_DAT_0 0x1805
>> +#define LAN9303_SWE_ALR_RD_DAT_1 0x1806
>> +#define LAN9303_SWE_ALR_CMD_STS 0x1808
>> +# define ALR_STS_MAKE_PEND     BIT(0)
> 
> Why is there different spacing and prefix with these defines?

The extra space is to set bit definitions apart from register offsets,
a convention that is used in the file. However, agree that the
bit defs should be prefixed with LAN9303_ to be consistent with
rest of the file.

> 
>>   #define LAN9303_SWE_VLAN_CMD 0x180b
>>   # define LAN9303_SWE_VLAN_CMD_RNW BIT(5)
>>   # define LAN9303_SWE_VLAN_CMD_PVIDNVLAN BIT(4)
>> @@ -478,6 +493,125 @@ static int lan9303_detect_phy_setup(struct lan9303 *chip)
>>   	return 0;
>>   }
>>   
>> +/* ----------------- Address Logic Resolution (ALR)------------------*/
>> +
>> +/* Map ALR-port bits to port bitmap, and back*/
> 
> The (leading and trailing) spacing in your comments is often
> inconsistent. You can use simple inline or block comments, no need for
> fancy rules. Please refer to Documentation/networking/netdev-FAQ.txt for
> block comment style in netdev though, they are a bit different.
> 

I can add an trailing space to the second comment.

The first comment is sort of "section" comment, so I wanted it to be 
separate. But perhaps I should drop these "section" comments, see 
further below.


>> +static const int alrport_2_portmap[] = {1, 2, 4, 0, 3, 5, 6, 7 };
>> +static const int portmap_2_alrport[] = {3, 0, 1, 4, 2, 5, 6, 7 };
>> +
>> +/* ALR: Actual register access functions */
>> +
>> +/* This function will wait a while until mask & reg == value */
>> +/* Otherwise, return timeout */
> 
> Same, a single block comment will do the job.
> 

See "section comment" comments...

>> +static int lan9303_csr_reg_wait(struct lan9303 *chip, int regno,
>> +				int mask, char value)
>> +{
>> +	int i;
>> +
>> +	for (i = 0; i < 0x1000; i++) {
>> +		u32 reg;
>> +
>> +		lan9303_read_switch_reg(chip, regno, &reg);
>> +		if ((reg & mask) == value)
>> +			return 0;
>> +		usleep_range(1000, 2000);
>> +	}
>> +	return -ETIMEDOUT;
>> +}
>> +
>> +static int lan9303_alr_make_entry_raw(struct lan9303 *chip, u32 dat0, u32 dat1)
>> +{
>> +	lan9303_write_switch_reg(
>> +		chip, LAN9303_SWE_ALR_WR_DAT_0, dat0);
>> +	lan9303_write_switch_reg(
>> +		chip, LAN9303_SWE_ALR_WR_DAT_1, dat1);
>> +	lan9303_write_switch_reg(
>> +		chip, LAN9303_SWE_ALR_CMD, ALR_CMD_MAKE_ENTRY);
>> +	lan9303_csr_reg_wait(
>> +		chip, LAN9303_SWE_ALR_CMD_STS, ALR_STS_MAKE_PEND, 0);
> 
> As I said in a previous series, please don't do this. Function arguments
> must be vertically aligned with the opening parenthesis.
> 

Will fix

>> +	lan9303_write_switch_reg(chip, LAN9303_SWE_ALR_CMD, 0);
>> +	return 0;
> 
> A newline before a return statement is appreciated.
> 

OK

>> +}
>> +
>> +typedef void alr_loop_cb_t(struct lan9303 *chip, u32 dat0, u32 dat1,
>> +			   int portmap, void *ctx);
>> +
>> +static void lan9303_alr_loop(struct lan9303 *chip, alr_loop_cb_t *cb, void *ctx)
>> +{
>> +	int i;
>> +
>> +	lan9303_write_switch_reg(chip, LAN9303_SWE_ALR_CMD, ALR_CMD_GET_FIRST);
>> +	lan9303_write_switch_reg(chip, LAN9303_SWE_ALR_CMD, 0);
>> +
>> +	for (i = 1; i < LAN9303_NUM_ALR_RECORDS; i++) {
>> +		u32 dat0, dat1;
>> +		int alrport, portmap;
>> +
>> +		lan9303_read_switch_reg(chip, LAN9303_SWE_ALR_RD_DAT_0, &dat0);
>> +		lan9303_read_switch_reg(chip, LAN9303_SWE_ALR_RD_DAT_1, &dat1);
>> +		if (dat1 & ALR_DAT1_END_OF_TABL)
>> +			break;
>> +
>> +		alrport = (dat1 & ALR_DAT1_PORT_MASK) >> ALR_DAT1_PORT_BITOFFS;
>> +		portmap = alrport_2_portmap[alrport];
>> +
>> +		cb(chip, dat0, dat1, portmap, ctx);
>> +
>> +		lan9303_write_switch_reg(
>> +			chip, LAN9303_SWE_ALR_CMD, ALR_CMD_GET_NEXT);
> 
> Please align arguments with the opening parenthesis.
> 

ok

>> +		lan9303_write_switch_reg(chip, LAN9303_SWE_ALR_CMD, 0);
>> +	}
>> +}
>> +
>> +/* ALR: lan9303_alr_loop callback functions */
>> +
>  > No need for an extra newline if your comment refers directly to the
> function below. It will also be consistent with the rest of your patch.
> 

The comment refer to several functions...

>> +static void alr_reg_to_mac(u32 dat0, u32 dat1, u8 mac[6])
>> +{
>> +	mac[0] = (dat0 >>  0) & 0xff;
>> +	mac[1] = (dat0 >>  8) & 0xff;
>> +	mac[2] = (dat0 >> 16) & 0xff;
>> +	mac[3] = (dat0 >> 24) & 0xff;
>> +	mac[4] = (dat1 >>  0) & 0xff;
>> +	mac[5] = (dat1 >>  8) & 0xff;
>> +}
>> +
>> +/* Clear learned (non-static) entry on given port */
>> +static void alr_loop_cb_del_port_learned(struct lan9303 *chip, u32 dat0,
>> +					 u32 dat1, int portmap, void *ctx)
>> +{
>> +	int *port = ctx;
> 
> You can get the value directly to make the line below more readable:
> 
>      int port = *(int *)ctx;
> 

Agree

>> +
>> +	if (((BIT(*port) & portmap) == 0) || (dat1 & ALR_DAT1_STATIC))
>> +		return;
>> +
>> +	/* learned entries has only one port, we can just delete */
>> +	dat1 &= ~ALR_DAT1_VALID; /* delete entry */
>> +	lan9303_alr_make_entry_raw(chip, dat0, dat1);
>> +}
>> +
>> +struct port_fdb_dump_ctx {
>> +	int port;
>> +	void *data;
>> +	dsa_fdb_dump_cb_t *cb;
>> +};
>> +
>> +static void alr_loop_cb_fdb_port_dump(struct lan9303 *chip, u32 dat0,
>> +				      u32 dat1, int portmap, void *ctx)
>> +{
>> +	struct port_fdb_dump_ctx *dump_ctx = ctx;
>> +	u8 mac[ETH_ALEN];
>> +	bool is_static;
>> +
>> +	if ((BIT(dump_ctx->port) & portmap) == 0)
>> +		return;
>> +
>> +	alr_reg_to_mac(dat0, dat1, mac);
>> +	is_static = !!(dat1 & ALR_DAT1_STATIC);
>> +	dump_ctx->cb(mac, 0, is_static, dump_ctx->data);
>> +}
>> +
>> +/* --------------------- Various chip setup ----------------------*/
>> +
> 
> This isn't a very useful comment, at least use an inline or block
> comment if you want to keep it.
> 

I put it to signify the end of the ALR section. But could not think of a
better text... Perhaps "End of ALR functions" would be better?
Or perhaps I should just drop the "section comments"? After all the
functions in question has "alr" in their names.

>>   static int lan9303_disable_processing_port(struct lan9303 *chip,
>>   					   unsigned int port)
>>   {
>> @@ -923,6 +1057,29 @@ static void lan9303_port_stp_state_set(struct dsa_switch *ds, int port,
>>   	/* else: touching SWE_PORT_STATE would break port separation */
>>   }
>>   
>> +static void lan9303_port_fast_age(struct dsa_switch *ds, int port)
>> +{
>> +	struct lan9303 *chip = ds->priv;
>> +
>> +	dev_dbg(chip->dev, "%s(%d)\n", __func__, port);
>> +	lan9303_alr_loop(chip, alr_loop_cb_del_port_learned, &port);
>> +}section
>> +
>> +static int lan9303_port_fdb_dump(struct dsa_switch *ds, int port,
>> +				 dsa_fdb_dump_cb_t *cb, void *data)
>> +{
>> +	struct lan9303 *chip = ds->priv;
>> +	struct port_fdb_dump_ctx dump_ctx = {
>> +		.port = port,
>> +		.data = data,
>> +		.cb   = cb,
>> +	};
>> +
>> +	dev_dbg(chip->dev, "%s(%d)\n", __func__, port);
>> +	lan9303_alr_loop(chip, alr_loop_cb_fdb_port_dump, &dump_ctx);
>> +	return 0;
> 
> A newline before the return statement is welcome.
> 

ok

>> +}
>> +
>>   static const struct dsa_switch_ops lan9303_switch_ops = {
>>   	.get_tag_protocol = lan9303_get_tag_protocol,
>>   	.setup = lan9303_setup,
>> @@ -937,6 +1094,8 @@ static const struct dsa_switch_ops lan9303_switch_ops = {
>>   	.port_bridge_join       = lan9303_port_bridge_join,
>>   	.port_bridge_leave      = lan9303_port_bridge_leave,
>>   	.port_stp_state_set     = lan9303_port_stp_state_set,
>> +	.port_fast_age          = lan9303_port_fast_age,
>> +	.port_fdb_dump          = lan9303_port_fdb_dump,
>>   };
>>   
>>   static int lan9303_register_switch(struct lan9303 *chip)
>> diff --git a/drivers/net/dsa/lan9303.h b/drivers/net/dsa/lan9303.h
>> index 68ecd544b658..4db323d65741 100644
>> --- a/drivers/net/dsa/lan9303.h
>> +++ b/drivers/net/dsa/lan9303.h
>> @@ -11,6 +11,8 @@ struct lan9303_phy_ops {
>>   			     int regnum, u16 val);
>>   };
>>   
>> +#define LAN9303_NUM_ALR_RECORDS 512
>> +
>>   struct lan9303 {
>>   	struct device *dev;
>>   	struct regmap *regmap;
>> -- 
>> 2.11.0
> 

Thanks
Egil
