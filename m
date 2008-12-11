From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: BUG: bad unlock balance detected! e1000e
Date: Wed, 10 Dec 2008 16:37:46 -0800
Message-ID: <9929d2390812101637r7df0a80av7a171e9cfa624c6e@mail.gmail.com>
References: <c4e36d110812080324y68c0e453qcb68a040da7ac9a2@mail.gmail.com>
	<20081209110337.GJ4864@gambetta>
	<20081209150801.2aa76ac6.akpm@linux-foundation.org>
	<20081209234346.GB7394@gambetta>
	<20081209155655.e82f9c24.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org,
	Frederik Deweerdt <frederik.deweerdt@xprog.eu>,
	tglx@linutronix.de, zdenek.kabelac@gmail.com, stable@kernel.org
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20081209155655.e82f9c24.akpm@linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Dec 9, 2008 at 3:56 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed, 10 Dec 2008 00:43:46 +0100
> Frederik Deweerdt <frederik.deweerdt@xprog.eu> wrote:
>
>> On Tue, Dec 09, 2008 at 03:08:01PM -0800, Andrew Morton wrote:
>> > On Tue, 9 Dec 2008 12:03:37 +0100
>> > Frederik Deweerdt <frederik.deweerdt@xprog.eu> wrote:
>> >
>> > > It some error checking is missing in e1000e: debug contention on NVM
>> > > SWFLAG
>> > > On Mon, Dec 08, 2008 at 12:24:09PM +0100, Zdenek Kabelac wrote:
>> > > > Hi
>> > > >
>> > > > During occasional scan of message log - I've found out this BUG which
>> > > > happened on Dec3 with the -rc7 from that day.
>> > > > (So if it's now fixed in current git feel free to ignore :))
>> > > >
>> > > > My machine T61 - C2D, 2GB, 64bit kernel - message appeared during
>> > > > shutdown and was actually not noticed by me...
>> > > >
>> > > >
>> > > > NetworkManager: <WARN>  nm_signal_handler(): Caught signal 15,
>> > > > shutting down normally.
>> > > > NetworkManager: <info>  (eth0): now unmanaged
>> > > > NetworkManager: <info>  (eth0): device state change: 3 -> 1
>> > > > NetworkManager: <info>  (eth0): cleaning up...
>> > > > NetworkManager: <info>  (eth0): taking down device.
>> > > >
>> > > > =====================================
>> > > > [ BUG: bad unlock balance detected! ]
>> > > > -------------------------------------
>> >
>> > (top-posting repaired.  Please don't do that!!!).
>> Yep, sorry.
>> >
>> > > Hello Zdenek,
>> > >
>> > > This could be due to 717d438d1fde94decef874b9808379d1f4523453
>> > >     "e1000e: debug contention on NVM SWFLAG"
>> > > Error handling is missing from e1000_reset_hw_ich8lan so it may happen
>> > > that we don't acquire the nvm_mutex if the card times out.
>> > >
>> > > Adding Thomas to CC.
>> >
>> > yup.  2.6.27 needs fixing also.
>> >
>> > Like this?
>> I don't think so, e1000_acquire_swflag_ich8lan() locks and
>> e1000_release_swflag_ich8lan() unlocks.
>
> urgh, OK, I made the mistake of reading the comments.
>
>> I think it is more along the
>> lines of:
>>
>>
>> diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
>> index 523b971..f971b83 100644
>> --- a/drivers/net/e1000e/ich8lan.c
>> +++ b/drivers/net/e1000e/ich8lan.c
>> @@ -1892,7 +1892,13 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
>>                */
>>               ctrl |= E1000_CTRL_PHY_RST;
>>       }
>> +
>>       ret_val = e1000_acquire_swflag_ich8lan(hw);
>> +     if (ret_val) {
>> +             hw_dbg(hw, "Failed to acquire NVM swflag");
>> +             return ret_val;
>> +     }
>> +
>>       hw_dbg(hw, "Issuing a global reset to ich8lan");
>>       ew32(CTRL, (ctrl | E1000_CTRL_RST));
>>       msleep(20);
>>
>>
>> But I'm not sure we should cancel the ongoing reset if the card times
>> out...
>>
>
> Yes, something like that.  Or something like
>
> --- a/drivers/net/e1000e/ich8lan.c~a
> +++ a/drivers/net/e1000e/ich8lan.c
> @@ -1940,12 +1940,14 @@ static s32 e1000_reset_hw_ich8lan(struct
>                ctrl |= E1000_CTRL_PHY_RST;
>        }
>        ret_val = e1000_acquire_swflag_ich8lan(hw);
> -       hw_dbg(hw, "Issuing a global reset to ich8lan\n");
> -       ew32(CTRL, (ctrl | E1000_CTRL_RST));
> -       msleep(20);
> +       if (!ret_val) {
> +               hw_dbg(hw, "Issuing a global reset to ich8lan\n");
> +               ew32(CTRL, (ctrl | E1000_CTRL_RST));
> +               msleep(20);
>
> -       /* release the swflag because it is not reset by hardware reset */
> -       e1000_release_swflag_ich8lan(hw);
> +               /* release the swflag because it is not reset by hardware reset */
> +               e1000_release_swflag_ich8lan(hw);
> +       }
>
>        ret_val = e1000e_get_auto_rd_done(hw);
>        if (ret_val) {
> _
>
>
> Dunno. It's e1000-developer-summoning-dance time.
>

Actually, if we time out trying to acquire the swflag, we still want
to reset the part because we are most likely in an unrecoverable
state.

So I would suggest the following
 --- a/drivers/net/e1000e/ich8lan.c~a
 +++ a/drivers/net/e1000e/ich8lan.c
 @@ -1940,9 +1940,10 @@ static s32 e1000_reset_hw_ich8lan(struct
                ctrl |= E1000_CTRL_PHY_RST;
        }
        ret_val = e1000_acquire_swflag_ich8lan(hw);
        hw_dbg(hw, "Issuing a global reset to ich8lan\n");
        ew32(CTRL, (ctrl | E1000_CTRL_RST));
        msleep(20);
 +       if (!ret_val) {
 -
 -       /* release the swflag because it is not reset by hardware reset */
 -       e1000_release_swflag_ich8lan(hw);
 +               /* release the swflag because it is not reset by
hardware reset */
 +               e1000_release_swflag_ich8lan(hw);
 +       }

Of course, we will want to add a comment to the fact that we still
want to reset the part, even if we have not acquired the lock because
we are in an unrecoverable state.

I can provide a patch in a few minutes.

-- 
Cheers,
Jeff

------------------------------------------------------------------------------
SF.Net email is Sponsored by MIX09, March 18-20, 2009 in Las Vegas, Nevada.
The future of the web can't happen without you.  Join us at MIX09 to help
pave the way to the Next Web now. Learn more and register at
http://ad.doubleclick.net/clk;208669438;13503038;i?http://2009.visitmix.com/
