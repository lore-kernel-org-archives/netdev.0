From: "Arend van Spriel" <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: assert_cfg80211_lock warning with Linux v3.5-8833-g2d53492
Date: Wed, 1 Aug 2012 19:24:48 +0200
Message-ID: <50196660.8090001@broadcom.com>
References: <20120801131232.GA1785@zod.bos.redhat.com>
 <20120801141810.GB27433@tuxdriver.com> <50194D7A.6060400@broadcom.com>
 <5019506C.6020707@broadcom.com>
 <1343836438.4638.5.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Josh Boyer" <jwboyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Brett Rudley" <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Roland Vossen" <rvossen-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Seth Forshee" <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"Luis R. Rodriguez" <rodrigue-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
To: "Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1343836438.4638.5.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

+ Luis

On 08/01/2012 05:53 PM, Johannes Berg wrote:
> On Wed, 2012-08-01 at 17:51 +0200, Arend van Spriel wrote:
>> On 08/01/2012 05:38 PM, Arend van Spriel wrote:
>>>> brcmsmac needs to hold cfg80211_mutex before calling freq_reg_info...
>>>>>
>>>>> It looks like those calls were added in mid-June.
>>>>>
>>> I think mid-june sounds about right. We never observed the warning when
>>> changes to use regulatory infrastructure were tested/reviewed. Should
>>> this precondition be mentioned in cfg80211.h?
>>>
>>> Gr. AvS
>>
>> Diving in further it seems brcmsmac can not grab the cfg80211_mutex. So
>> another solution is needed.
> 
> Yeah I was going to say -- how can it possibly access that? It seems
> that in some patch the API got broken, it should be taking the lock or
> whatever ... I'll leave it to Luis to sort out though :-P
> 
> johannes
> 

The assert was added by following commit:

commit ac46d48e00349c63650b3cc6f9460fcc183da6a6
Author: Luis R. Rodriguez <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Date:   Fri May 1 18:44:50 2009 -0400

    cfg80211: fix race condition with wiphy_apply_custom_regulatory()

    We forgot to lock using the cfg80211_mutex in
    wiphy_apply_custom_regulatory(). Without the lock
    there is possible race between processing a reply from CRDA
    and a driver calling wiphy_apply_custom_regulatory(). During
    the processing of the reply from CRDA we free last_request and
    wiphy_apply_custom_regulatory() eventually accesses an
    element from last_request in the through freq_reg_info_regd().

    This is very difficult to reproduce (I haven't), it takes us
    3 hours and you need to be banging hard, but the race is obvious
    by looking at the code.

    This should only affect those who use this caller, which currently
    is ath5k, ath9k, and ar9170.

    EIP: 0060:[<f8ebec50>] EFLAGS: 00210282 CPU: 1
    EIP is at freq_reg_info_regd+0x24/0x121 [cfg80211]

It seems the API was as it currently is when adding regulatory framework
changes in brcmsmac so we should have seen this assert flying by. The
problem is that freq_reg_info() is exposed in cfg80211.h, but as it is
now it can only be used under the cfg80211_mutex lock, ie. in regulatory
notify callback (as Seth indicated).

Gr. AvS

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
