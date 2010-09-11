From: Michael Williamson <michael.williamson@criticallink.com>
Subject: Re: [PATCH v3 00/10] split out emac cpdma and mdio for reuse
Date: Sat, 11 Sep 2010 09:14:14 -0400
Message-ID: <4C8B80A6.5060609@criticallink.com>
References: <1283891142-15522-1-git-send-email-cyril@ti.com> <871v95f2xv.fsf@deeprootsystems.com> <4C86F369.6040906@criticallink.com> <4C880733.5010909@ti.com> <4C882EAA.9030903@criticallink.com> <4C892AC0.80409@criticallink.com> <4C893ADE.809@ti.com> <4C8950D4.9060102@criticallink.com> <4C8AB85A.8060909@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Kevin Hilman <khilman@deeprootsystems.com>,
	"tony@atomide.com" <tony@atomide.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: cyril@ti.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <4C8AB85A.8060909@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Cyril,

On 09/10/2010 06:59 PM, Cyril Chemparathy wrote:
> Hi Mike,
> 
> I have merged your latest two emails and responded to both here.
> 
[...]
> One of the patches posted on my repo [1] replaces the dumb mdelay() with
> a bit more logic that calculates the worst-case access time.  This
> mechanism may work a lot better for you.  Would you mind trying it out?
> 

You patch from [1] is working much more reliably now (well, 6 for 6 boot cycles as well as
several ifup/ifdown cycles).  I do get the "resetting idled controlled" console message
every cycle, it seems that will be expected now.

[...]

>>
>> Also, your while(1) loops with the continue conditions on the second wait_for_user_access() 
>> in the read and writes might need some consideration, i.e.:
>>
>>         while (1) {
>>                 ret = wait_for_user_access(data);
>>                 if (ret == -EAGAIN)
>>                         continue;
>>                 if (ret < 0)
>>                         break;
>>
>>                 __raw_writel(reg, &data->regs->user[0].access);
>>
>>                 ret = wait_for_user_access(data);
>>                 if (ret == -EAGAIN)
>>                         continue;
>>                         ^^^^^^^^^ <--- this will re-issue the request.... what you want?
> 
> Yes, the wait_for_user_access() would have reset the controller,
> throwing the current transaction out.  The intent here is to restart the
> current transaction with a newly initialized controller.
> 

OK.  Makes sense.  Looking at it felt like there was a chance for end endless spin, but that
seems unlikely given how that condition might fire.

[...]

>> Also, on the shutdown, I get a major kernel trace.  Here is the dump, as much 
>> as I could catch of it.... (I need a better terminal program)
> 
> [...]
>> WARNING: at drivers/net/davinci_emac.c:1025 __cpdma_chan_free+0xac/0xb0()
> 
> The current code spits out a huge volume of stuff as a result of a
> WARN_ON in the rx handler.  The gitweb on [1] has a patch that fixes this.
> 

Yes,  these messages are no longer issued with the patches from [1].  Thanks.

> [...]
>>>> The MDIO module upgrade (rev 1.4 -> 1.5) could have something to do with
>>>> this behavior.  Even so, I can't explain why this issue wasn't seen on
>>>> da8xx prior to this series.  The original code should (at least in
>>>> theory) have sporadically locked up on emac open.
>>>>
>> I think, if I understand it correctly, that in the previous version of 
>> this code, the emac was reset *prior* to enabling, scanning, and assigning 
>> the associated phy on the MDIO bus.  The new implementation sets up and scans 
>> the MDIO bus first, then comes back around to the EMAC second... hits a reset,
>> and doesn't re-ENABLE the MDIO.
> 
> AFAICS, that isn't entirely accurate.  In the previous version, the mdio
> bus was being brought up at probe time in davinci_emac_probe().  The
> soft-reset was happening later on when the device is opened, in
> emac_hw_enable().
> 
> The difference, however, is that the original code forced an
> emac_mii_reset() immediately after the emac_hw_enable().  This is not
> being done with the separated mdio, and that is the problem.  In terms
> of behavior, with the current work around, the new and old versions
> should be close to identical.  More below...
> 
>> Also, maybe hitting the EMAC reset while the MDIO state machine is up is *bad*, I 
>> seem to recall some text in the user's guide about waiting for the state
>> machine to stop before disabling it.  I wonder if that also applies to reset?
> 
> You are correct.  EMAC soft-reset stops the MDIO mid-transaction, quite
> unlike disabling the module via the control register.  Therefore, there
> is a risk that a badly designed phy could be left hanging in an
> arbitrary state.  However, all earlier versions of the emac code have
> been exposed to this very same vulnerability (i.e. arbitrary emac
> soft-reset regardless of mdio state) all along.
> 

Thanks for straightening me out on this, Cryil.  Your patch series in [1] seems to
have resolved the issues I've been able to see on the da850 based board I'm using
here.  I appreciate your patience and quick response.  I may try to beat on it a 
bit more with some network performance tests (even though it's not at all related 
to the immediate problems you've fixed) -- we've had that on our list of todos 
anyway for this module.

I think it would be good to float your patches over to davinci-next, if possible, before the
37 merge window opens...  Speaking, of course, from a very partial perspective.

> [1]
> http://arago-project.org/git/people/?p=cyril/linux-tnetv107x.git;a=shortlog;h=refs/heads/emac-cpdma-mdio-fixes

-Mike
