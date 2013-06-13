From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH v3] ethernet/arc/arc_emac - Add new driver
Date: Thu, 13 Jun 2013 21:48:49 +0000
Message-ID: <4881796E12491D4BB15146FE0209CE643F5DFFBB@DE02WEMBXB.internal.synopsys.com>
References: <1371134239-4531-1-git-send-email-abrodkin@synopsys.com>
	<CAHp75Vf4zjtebbaQMp4L0EmUPDVyrNPfvLODo7gHBuBEsWmZeA@mail.gmail.com>
	<4881796E12491D4BB15146FE0209CE643F5DFB22@DE02WEMBXB.internal.synopsys.com>
 <CAHp75VcChT7=DpUYUBw3ZNXXBNCL4kj6HB6nCFL=ytUYaXUXZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Joe Perches <joe@perches.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Devicetree Discuss <devicetree-discuss@lists.ozlabs.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/14/2013 12:50 AM, Andy Shevchenko wrote:
> On Thu, Jun 13, 2013 at 11:25 PM, Alexey Brodkin
> <Alexey.Brodkin@synopsys.com> wrote:
>> On 06/13/2013 10:25 PM, Andy Shevchenko wrote:
>>> On Thu, Jun 13, 2013 at 5:37 PM, Alexey Brodkin
>>> <Alexey.Brodkin@synopsys.com> wrote:
>>>> Driver for non-standard on-chip ethernet device ARC EMAC 10/100,
>>>> instantiated in some legacy ARC (Synopsys) FPGA Boards such as
>>>> ARCAngel4/ML50x.
>
>>>> +++ b/drivers/net/ethernet/arc/arc_emac.h
>
>> And what about function names? Do you think it worth to shorten them too
>> since most of them aren't visible outside (static).
>
> It's better to keep them in their namespace. So, leave them as is.

Ok, makes sense.

>>>> +struct arc_emac_priv {
>
>>>> +};
>
>>> It seems you missed my comments against the names of the members. Can
>>> you address them or comment why not?
>>
>> You mean to add description in kerneldoc format for all the fields in
>> structures?
>
> Not only that one. About member names as well.

Ok, I'll re-visit member names as advised.

>> Well while in general it could be "a proper way" of documenting sources
>> I found it not that convenient especially in case of really long structures.
>
>> In my case "arc_emac_priv" structure has 21 members, so right before
>> structure itself there will be another at least 21 line of comments.
>
> Not an argument, you understand.
>
>> Moreover: "The kernel-doc function comments describe each parameter to
>> the function, in order, with the @name lines."
>
>> While I don't think that each and every member needs description.
>
> Describe them in couple of words.
>
>> At
>> least some pairs like Tx/Rx I believe may share the only comment saying
>> "Pointers to BD rings - CPU side".
>
> What BD means? May be it worth to describe as well?
>
>> Also I barely can find an example of strict usage of kernel-doc format
>> for data structures in drivers nearby.
>>
>> For example take a look at STMMAC - drivers/net/ethernet/stmicro/stmmac/
>> Lots of structures defined, non with kernel-doc description.
>
> Again, not an excuse :-)

Ok, will add description)

>> Still you think the only way to go is to add kernel-doc description then
>> I'll add it ASAP, might be it will be a good example for other developers.
>
> Right.
>
>>>> +++ b/drivers/net/ethernet/arc/arc_emac_main.c
>>>
>
>>>> +static int arc_emac_poll(struct napi_struct *napi, int budget)
>>>> +{
>
>>>> +       unsigned int i, loop, work_done = 0;
>
>>>> +       for (loop = 0; loop < RX_BD_NUM; loop++) {
>
>>>> +               work_done++;
>>>> +               if (work_done >= budget)
>>>> +                       break;
>>>
>>> Those three could easily go to the for () on the top of this function.
>>
>> Correct. It should be like this on top of the "arc_emac_poll":
>> ====
>>                  if (work_done >= budget)
>>                          break;
>>                  work_done++;
>> ====
>
> I meant something like
> for (loop = 0; loop < RX_BD_NUM && work_done < budget; loop++, work_done++)

Well, it turned out that counter increment was put in the end of the 
loop on purpose.

But with help of this hint I understood that "arc_emac_poll" was 
implemented a bit incorrectly. Now I added an exit from the loop on the 
first BD owned by EMAC. This is possible because we know that buffers 
are processed in order.

>>>> +static int arc_emac_open(struct net_device *ndev)
>>>> +{
>>>
>>>> +       /* Set Poll rate so that it polls every 1 ms */
>>>> +       arc_reg_set(priv, R_POLLRATE,
>>>> +                    priv->clock_frequency / 1000000);
>>>
>>> I don't understand how you end up with 1ms here. 1000000 is just a
>>> magic number, clock_frequency generally is an arbitrary value.
>
> I meant how do you guarantee this is 1ms? What if clock_frequency is not 100MHz?

That's why I needed to pass CPU frequency to "arc_emac_probe" via DT.
As we see from description in HW documentation poll period measured in 
CPU cycles = "1024 cycles *  R_POLLRATE", or "1024 * 
priv->clock_frequency / 1000000", or "priv->clock_frequency / 1000".
Now since length of 1 cycle is "1 / priv->clock_frequency" we may 
calculate poll period measured in seconds. It will be 
"priv->clock_frequency / 1000 * (1 / priv->clock_frequency)" which is 
1/1000 of second i.e. 1 millisecond. Makes sense?

Regards,
Alexey
