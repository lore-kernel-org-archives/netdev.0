From: James Feeney <james-fvV4AYHggTTR7s880joybQ@public.gmane.org>
Subject: Re: Regression: Bug 196547 - Since 4.12 - bonding module not working
 with wireless drivers
Date: Sat, 12 Aug 2017 13:30:53 -0600
Message-ID: <deb37db2-a55b-4010-475a-e756e67d3bc9@nurealm.net>
References: <87shh0gewn.fsf@kamboji.qca.qualcomm.com>
 <8845e49b-3165-e6df-5935-c86278d220d9@broadcom.com>
 <CADps9UA7S2betC-+5sOXjYWmDC8gnk6JJ9aEueEOoYAC3DU8hg@mail.gmail.com>
 <87tw1edz5j.fsf@kamboji.qca.qualcomm.com>
 <87tw1dck6o.fsf@kamboji.qca.qualcomm.com>
Reply-To: james-fvV4AYHggTTR7s880joybQ@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Mahesh Bandewar <maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Andreas Born <futur.andy-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87tw1dck6o.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hey Kalle

Still, a problem:

On 08/12/2017 01:35 AM, Kalle Valo wrote:
> Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> writes:
> 
>> Andreas Born <futur.andy-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> writes:
>>
>>> Earlier today I submitted the patch (bonding: require speed/duplex
>>> only for 802.3ad, alb and tlb) [2] that only partially reverts what is
>>> a regression following my aforementioned logic. This seems to me like
>>> the best solution in the short term since it should satisfy both
>>> usergroups represented by Mahesh and James and restores consistence
>>> with the bonding documentation. James already commented approvingly on
>>> that patch in the bug report. [3]
>>>
>>> Regards
>>> Andreas
>>>
>>> [1]
>>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/networking/bonding.txt
>>
>> Great, thanks.
>>
>> I'll take it the patch is meant for net tree (and not net-next) so that
>> it will be fixed for v4.13? Also it should backported to v4.12 stable
>> tree. I don't see any mention of that in the patch submission and that's
>> why I'm asking.
> 
> I see that Dave applied this to the net tree and queued also for stable,
> excellent. Thanks everyone!
> 
> https://patchwork.ozlabs.org/patch/800080/
> 

Andreas patch failed to address the continuous, *10-times per second* warning
which will "spam" the log file, sometimes the console, whenever the test fails:
 if (bond_update_speed_duplex(slave) && bond_needs_speed_duplex(bond)) {...}
which then has:
 netdev_warn(bond->dev, "failed to get link speed/duplex for%s\n",
			slave->dev->name);

That is the sort of irresponsible code that "works fine" as long as there are no
errors, and it never actually runs!

I'm guessing that the simple fix is to use "net_warn_ratelimited()" instead of
"netdev_warn()", where net/core/utils.c says:

/*
 * All net warning printk()s should be guarded by this function.
 */
int net_ratelimit(void)
{
        return __ratelimit(&net_ratelimit_state);
}

though Andreas has also suggested "pr_warn_ratelimited()", which instead uses
"__ratelimit(&_rs)".

Here's a link to the rate-limiting patch, after Andreas' patch is already
applied, since you say that David has already applied the first patch:

https://bugzilla.kernel.org/attachment.cgi?id=257903


Thanks
James
