From: Ryan Mallon <rmallon@gmail.com>
Subject: Re: [PATCH] net/packet: remove dead code and unneeded variable from
 prb_setup_retire_blk_timer()
Date: Tue, 15 Nov 2011 11:00:14 +1100
Message-ID: <4EC1AB8E.8010409@gmail.com>
References: <alpine.LNX.2.00.1111132247440.3368@swampdragon.chaosbits.net> <4EC0AA31.9040403@gmail.com> <alpine.LNX.2.00.1111150034120.9919@swampdragon.chaosbits.net> <4EC1A65E.5040607@gmail.com> <alpine.LNX.2.00.1111150046350.9919@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Ben Greear <greearb@candelatech.com>,
	Chetan Loke <loke.chetan@gmail.com>,
	waltje@uWalt.NL.Mugnet.ORG, gw4pts@gw4pts.ampr.org,
	waltje@linux.com, ross.biro@gmail.com, alan@linux.intel.com
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1111150046350.9919@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/11/11 10:48, Jesper Juhl wrote:
> On Tue, 15 Nov 2011, Ryan Mallon wrote:
>
>> On 15/11/11 10:37, Jesper Juhl wrote:
>>
>>> On Mon, 14 Nov 2011, Ryan Mallon wrote:
>>>
>>>> On 14/11/11 08:55, Jesper Juhl wrote:
>>>>
>>>>> We test for 'tx_ring' being != zero and BUG() if that's the case. So after
>>>>> that check there is no way that 'tx_ring' could be anything _but_ zero, so
>>>>> testing it again is just dead code. Once that dead code is removed, the
>>>>> 'pkc' local variable becomes entirely redundant, so remove that as well.
>>>>
>>>> What if CONFIG_BUG=n?
>>>>
>>> Arrgh, I didn't consider that (should have, but didn't).. In that case 
>>> we'll have 
>>> #define BUG() do {} while(0)
>>> which is not going to work all that peachy with my change...
>>>
>>> David: You may want to pass on this one. I obviously didn't think it 
>>> through properly - sorry :-(
>>>
>>
>> It's something I've never been entirely clear on. How are you meant to
>> handle something which really is a fatal bug if CONFIG_BUG=n?
>>
>> I think there are several places in the kernel where the expectation is
>> that BUG() causes a panic that probably don't behave nicely at all
>> (though I guess that might be the expected behaviour) if CONFIG_BUG=n.
>>
> You have a point. Perhaps the proper solution would be to remove 
> CONFIG_BUG so that it is always enabled...?  As you say, if something is a 
> fatal bug there is no sane way to continue, so why do we even allow 
> people/systems to try???
> That way lies madness it would seem...
>
The Kconfig looks like this:

config BUG
        bool "BUG() support" if EXPERT
        default y
        help
          Disabling this option eliminates support for BUG and WARN, reducing
          the size of your kernel image and potentially quietly ignoring
          numerous fatal conditions. You should only consider disabling this
          option for embedded systems with no facilities for reporting errors.
          Just say Y.


So you can only disable it if you have CONFIG_EXPERT (read embedded I
think). It says that you should only disable it for embedded systems
where you have no error reporting facilities, but you probably still
want the system to hang/die though since you might have a watchdog which
can reset the machine if it hangs. With CONFIG_BUG=n you could
potentially hit a BUG() and manage to carry on for sometime even though
the system is now unstable. Maybe BUG() should at least drop in to an
infinite loop in the case of CONFIG_BUG=n. I might try and come up with
a patch later tonight.

~Ryan
