From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [PATCH 1/4] net: ethernet: dwmac: add Ethernet glue logic for
 stm32 chip
Date: Tue, 23 Feb 2016 12:21:35 +0100
Message-ID: <CAGhQ9VxQ3nW+dr9pdj=H8UcsNHEATxVeAf8N_PsQA7-73uksTA@mail.gmail.com>
References: <1454511275-9791-1-git-send-email-alexandre.torgue@gmail.com>
	<1454511275-9791-2-git-send-email-alexandre.torgue@gmail.com>
	<CAGhQ9VypZ5J0pQmrf1Mk-mNsv=XTXu7fhoLt_r2LHJ_Lsyj0yA@mail.gmail.com>
	<CAJgp7zwOVEq=hnxfUt7eHZWSFUAwuK6MCVHdH591=xReRUsW8Q@mail.gmail.com>
	<CAGhQ9VzPTgRqqLi4zjHkP-++v5smZ7s52drev1z-AvgXaLuC7Q@mail.gmail.com>
	<CAJgp7zxYhbQ4yQHBB3cu50TU9N9xvk3HxCp0NP5fxFbxrMsD_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Maxime Coquelin <mcoquelin.stm32@gmail.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexandre Torgue <alexandre.torgue@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJgp7zxYhbQ4yQHBB3cu50TU9N9xvk3HxCp0NP5fxFbxrMsD_g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23 February 2016 at 10:59, Alexandre Torgue
<alexandre.torgue@gmail.com> wrote:
> 2016-02-22 22:52 GMT+01:00 Joachim  Eastwood <manabian@gmail.com>:
>> On 22 February 2016 at 15:50, Alexandre Torgue
>> <alexandre.torgue@gmail.com> wrote:
>>> 2016-02-13 14:48 GMT+01:00 Joachim  Eastwood <manabian@gmail.com>:
>>>> On 3 February 2016 at 15:54, Alexandre TORGUE
>>>> <alexandre.torgue@gmail.com> wrote:
>>>>> +       plat_dat->bsp_priv = dwmac;
>>>>> +       plat_dat->init = stm32_dwmac_init;
>>>>> +       plat_dat->exit = stm32_dwmac_exit;
>>>>
>>>> Instead of using these callbacks could you rather implement the PM
>>>> callbacks directly in this driver?
>>>> I don't think it should add much code and it will make it look more
>>>> like standard driver. This will also give you some more control and
>>>> flexibility in your code.
>>>
>>> I prefer to keep the code as it is. Glue layer is directly linked to
>>> stmmac driver and I don't want to brake the link between the glue and
>>> the stmmac driver.
>>
>> What do you mean by break the link?
>>
>
> I thought that you wanted to split stmmac_pltfr_supend (glue part and
> stmamc part), but I well understood it is not the case (sorry for
> mistake).
>
>> There has been numerous of patch sets to make the stmmac "glue"
>> drivers into more standard platform drivers.
>> http://marc.info/?l=linux-netdev&m=143159850631093&w=2
>> http://marc.info/?l=linux-netdev&m=143708560009851&w=2
>> http://marc.info/?l=linux-netdev&m=143812136600541&w=2
>>
>> Do you see any advantage by using the init and exit hooks in your
>> driver instead of using the standard driver PM callbacks and remove
>> function?
>> The only "cost" I see is slightly more boilerplate code. But since you
>> already have init/exit functions you could easily make them into PM
>> resume/suspend so I doubt there would be much increase in code size.
>>
>
> If I well understood you want to continue the stmmac glue driver
> rework by moving stmmac_pltfr_suspend/resume/remove in each glue
> driver (stm32, sun, sti ....).

At least I want to avoid the init/exit callbacks for new drivers like
stm32-dwmac.


> Each glue driver will call directly stmmac_suspend/resume/remove and
> their own init/exit function.
> If it is what you meant, I can do it.

Yes, in your stm32 driver's suspend/resume/remove functions call
stmmac_suspend/stmmac_resume/stmmac_dvr_remove directly. Then you
shouldn't need to use the init/exit callbacks. Just put the need code
in the driver's suspend/resume/remove functions instead of init/exit
functions.

For example:
static int stm32_dwmac_resume(struct device *dev)
{
    struct net_device *ndev = dev_get_drvdata(dev);
    struct plat_stmmacenet_data *plat_dat = get_stmmac_plat_data(ndev)
    struct stm32_dwmac *dwmac =plat_dat->bsp_priv;

    /* enable clocks */
    /* set phy mode */

    return stmmac_resume(ndev);
}

If it makes sense to have the enable clk/phy mode stuff in it's own
function that is fine too.


>> One other thing;
>> Do you need to have the PHY mode setup code in the init function which
>> is called each time on resume?
>
> I can't guarantee that after a suspend the sysconfig register will
> contain same data than before suspend.

I see.


regards,
Joachim Eastwood
